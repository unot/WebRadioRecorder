#!/bin/sh
# onsen.sh Ver. 0.7 (2011.04.24)

STR=$1
GOTDATE=`date +%y%m%d`
PRECODE=onsen`date +%w%d%H`
PDATA="code=`md5 -q -s $PRECODE`&file%5Fname=regular%5F"
REGXMLNUM=`date +%w`
URL="http://onsen.ag/getXML.php?`date +%s`000"

TFLAG=FALSE
TITLE=
OPT=
while getopts tyd: OPT
do
  case $OPT in
    t) TFLAG=TRUE
       ;; # empty
    y) GOTDATE=`TZ=JST+15 date +%y%m%d`
       REGXMLNUM=`TZ=JST+15 date +%w`
       ;; # yesterday
    d) GOTDATE=$OPTARG
       ;; # indicate date
    \?) echo "Usage: $0 [-ty] [-d yymmdd] hoge" 1>&2
        exit 1
        ;;
  esac
done
shift `expr $OPTIND - 1`

wget --post-data="${PDATA}${REGXMLNUM}" ${URL} | grep ${GOTDATE} | uniq | grep ${STR} | wget

exit 0


if [ $# -eq 1 ]; then
  STR=$1
  URL=http://onsen.ag/asx/${STR}${GOTDATE}.asx
  MMS=`wget -q -O - $URL | grep $STR | awk '{gsub(/"/,"",$4);print $4;}'`
  if [ $TFLAG = "TRUE" ]; then
    TITLE=`wget -q -O - $URL | nkf -w | sed -n 's/<TITLE>\(.*\)<\/TITLE>/\1/p' | sed -e 's|/|-|g' | tr -d "\r" | tail -n 1`.wmv
    echo "$URL"
    echo "$MMS"
    echo "$TITLE"
  fi
  mimms $MMS ${TITLE:+"$TITLE"}
else
  echo "Usage: $0 [-ty] [-d yymmdd] hoge" 1>&2
fi

