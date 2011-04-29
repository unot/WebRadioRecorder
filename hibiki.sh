#!/bin/sh
# hibiki.sh ver.0.2.1 (2011-04-30)
# require wget, ruby, nkf and mimms

if [ $# -eq 1 ]; then
  STR=$1
  TMPFILE="/var/tmp/tmp.$$"

  # save asx file
  wget -q -O - http://hibiki-radio.jp/description/${STR} | grep movie | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | head -1 | xargs wget -q -O - | grep asx | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | uniq | xargs wget -q -O - | nkf -w >${TMPFILE}

  TITLE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/TITLE"].text' | tr '/' '月' | sed -e "s/ WMV/日配信/"`
  WMVFILE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/ENTRY/REF"].attributes["HREF"]'`

  mimms ${WMVFILE} "${TITLE}.asf"
  rm ${TMPFILE}
  exit 0
else
  echo "usage: `basename $0` STRING"
fi
