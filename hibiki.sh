#!/bin/sh
# hibiki.sh ver.0.3 (2011-06-01)
# require wget, ruby, nkf and mimms

if [ $# -eq 1 ]; then
  STR=$1
  TMPFILE="/var/tmp/tmp.$$"

  # save asx file
  wget -q -O - http://hibiki-radio.jp/description/${STR} | grep movie | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | head -1 | xargs wget -q -O ${TMPFILE}

  WMVFILE=`cat ${TMPFILE} | ruby -ruri -e 'puts URI.extract(ARGF.read, "mms")' | uniq`
  TITLE=`cat ${TMPFILE} | head -n +58 | tail -n 1 | sed -e 's/^ *//g; s/<br \/>//g; s/\//月/'| tr -d '\015'`
  if test a"$WMVFILE" = a"" ; then
    echo "asx detection failed."
    rm ${TMPFILE}
    exit 1
  fi

  mimms ${WMVFILE} "${TITLE}日配信.asf"
  rm ${TMPFILE}
  exit 0
else
  echo "usage: `basename $0` STRING"
fi
