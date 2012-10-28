#!/bin/sh -e
# hibiki.sh ver.0.3.1 (2011-06-12)
# require wget, ruby, nkf and mimms

if [ $# -eq 1 ]; then
  STR=$1
  TMPFILE="/var/tmp/tmp.$$"

  # save asx file
  wget -q -O - http://hibiki-radio.jp/description/${STR} | grep movie | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | head -1 | xargs wget -q -O - | grep asx | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | uniq | xargs wget -q -O - | nkf -w >${TMPFILE}
  if [ -z ${TMPFILE} ]; then
    echo "download ERROR"
    exit 1
  fi
  TITLE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/TITLE"].text' | tr '/' '月'`日配信
  WMVFILE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/ENTRY/REF"].attributes["HREF"]'`
  if test a"$TITLE" = a"" ; then
    wget -q -O - http://hibiki-radio.jp/description/${STR} | grep movie | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | head -1 | xargs wget -q -O ${TMPFILE}
    TITLE=`cat ${TMPFILE} | head -n +58 | tail -n 1 | sed -e 's/^ *//g; s/<br \/>//g; s/\//月/' | tr -d '\015'`
    WMVFILE=`cat ${TMPFILE} | ruby -ruri -e 'puts URI.extract(ARGF.read, "mms")' | uniq`
    if test b"$TITLE" = b"" ; then
      echo "asx detection failed."
      rm ${TMPFILE}
      exit 1
    fi
  fi

  mimms ${WMVFILE} "${TITLE}.asf"
  rm ${TMPFILE}
  exit 0
else
  echo "usage: `basename $0` STRING"
fi
