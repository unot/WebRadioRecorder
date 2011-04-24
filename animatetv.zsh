#!/bin/zsh
if [ $# = 1 ]; then
  URL=$1
  TITLE=`wget -q -O - $URL | perl -nle 'm|<Entry><Title>(.*)</Title>|; print $1' | nkf -w`
#  DATE=`wget -q -O - $URL | nkf -w | tr -d '\015' | sed -n 's|<Title>\(.*\)</Title>|\1|p' | sed -e 's|/|-|g' | sed -n '2p' | tr -d ' '`
#  ASXMMS=`wget -q -O - $URL | nkf -w | grep wma`
  MMS=`wget -q -O - $URL | perl -nle 'm|(mms.*wma)|; print $1'`
  mimms ${MMS} "${TITLE}.wma"
#  echo ${MMS}
#  echo "${TITLE}(${DATE}).wma"
#  : >"${TITLE}(${DATE}).wma"
#  mv `basename $MMS` "${TITLE}(${DATE}).wma"
else
  echo "usage: $0 http://www.animate.tv/asx/hogehoge.asx"
fi

