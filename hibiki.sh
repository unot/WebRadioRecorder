#!/bin/sh
# hibiki.sh ver.0.1 (2011-04-24)

STR=$1
TMPFILE="/var/tmp/tmp.$$"

# save asx file
wget -q -O - http://hibiki-radio.jp/description/${STR} | grep movie | ruby -ruri -e 'puts URI.extract(ARGF.read, "http")' | uniq | xargs wget -q -O - | nkf -w >${TMPFILE}

TITLE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/TITLE"].text' | tr '/' '-'`
WMVFILE=`cat ${TMPFILE} | ruby -rrexml/document -e 'puts REXML::Document.new(ARGF).elements["ASX/ENTRY/REF"].attributes["HREF"]`

echo "mimms ${WMVFILE} ${TITLE}.asf"

exit 0
