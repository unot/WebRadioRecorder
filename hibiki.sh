#!/bin/sh -e
# hibiki.sh ver.0.5.6 (2013-02-13)
# require wget, ruby, and mimms
TMPFILE="/var/tmp/tmp.$$"
trap 'rm -f ${TMPFILE}' EXIT

if [ $# -eq 1 ]; then
  STR=$1

  # save asx file
  wget -q -O - http://hibiki-radio.jp/description/${STR} | grep WMV | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | tail -1 | xargs wget -q -O ${TMPFILE}
  if [ -z ${TMPFILE} ]; then
    echo "download ERROR"
    exit 1
  fi
  TITLE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/entry/title"].text'`
  WMVFILE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/entry/Ref"].attributes["href"]'`
  if test a"$TITLE" = a"" ; then
    echo "asx detection failed."
    exit 1
  fi

  mimms -r ${WMVFILE} "${TITLE}.asf" || mimms -r ${WMVFILE} "${TITLE}.asf"
  mimms -r ${WMVFILE} "${TITLE}.asf" || mimms -r ${WMVFILE} "${TITLE}.asf"

else
  echo "usage: `basename $0` STRING"
fi
