#!/bin/zsh -e
# animatetv.zsh version 0.4.1 (2012-10-20)
# require wget, perl, nkf and mimms

TMPFILE="/var/tmp/tmp.$$"
RMOPT=

if [ $# = 1 ]; then
  REFID=$1
  ASX=http://www.animate.tv`wget -q http://animate.tv/radio/details.php\?id\=${REFID} -O - | nkf -w | grep play.php | head -1 | perl -nle 'm|(/play.*player)|; print $1'`
  wget -q --referer="http://animate.tv/radio/details.php\?id=${REFID}" --user-agent='Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)' ${ASX} -O ${TMPFILE} #- | nkf -w >${TMPFILE}
  if [ $? -ne 0 -o ! -s ${TMPFILE} ]; then
    echo "ERROR download ${ASX}"
    exit 1
  fi
  TITLE=`cat ${TMPFILE} | perl -nle 'm|<Entry><Title>(.*)</Title>|; print $1' | nkf -w`
  MMS=`cat ${TMPFILE} | perl -nle 'm|(mms.*wma)|; print $1'`
  if [ "${MMS}" = "" ]; then
    echo "failed to get mms url."
    rm ${TMPFILE}
    exit 1
  fi
  mimms ${MMS} "${TITLE}.wma"
#  echo ${MMS}
#  echo "${TITLE}.wma"
#  : >"${TITLE}.wma"
  rm ${RMOPT} ${TMPFILE}
else
  echo "usage: `basename $0` hoge"
fi

