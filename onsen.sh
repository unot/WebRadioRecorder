#!/bin/sh
# onsen.sh Ver. 0.6 (2009.10.16)

GOTDATE=`date +%y%m%d`
TFLAG=FALSE
TITLE=
OPT=
while getopts tyd: OPT
do
  case $OPT in
    t) TFLAG=TRUE
       ;;
    y) GOTDATE=`TZ=JST+15 date +%y%m%d`
       ;;
    d) GOTDATE=$OPTARG
       ;;
    \?) echo "Usage: $0 [-ty] hoge" 1>&2
        exit 1
        ;;
  esac
done
shift `expr $OPTIND - 1`

if [ $# -eq 1 ]; then
  #cd $HOME
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

