#!/bin/bash
# onsen.sh Ver. 0.7 (2011.04.24)

# STR=$1
# target date
GOTDATE=`date +%y%m%d`
# precode of POST data
PRECODE=onsen`date +%w%d%H`
# POST data
PDATA="code=`md5 -q -s $PRECODE`\&file%5Fname=regular%5F"
# week number
REGXMLNUM=`date +%w`
# onsen URL
URL="http://onsen.ag/getXML.php?`date +%s`000"
# tmp file
TMPFILE="/var/tmp/tmp.$$"

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

# download regular XML file
wget -q --post-data="${PDATA}${REGXMLNUM}" ${URL} -O ${TMPFILE}

# number of program
PROGNUM=`grep -c '<title>' ${TMPFILE}`
echo "番組数: $PROGNUM"

# index number
i=1
while test ${PROGNUM} -gt 0
do
  PROGNUM=`expr ${PROGNUM} - 1`
  ISNEW=`cat ${TMPFILE} | ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/isNew[${i}]\"].text"`
  TITLE=`cat ${TMPFILE} | ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/title[${i}]\"].text"`
  NUM=`cat ${TMPFILE} | ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/number[${i}]\"].text"`
  UPDATE=`cat ${TMPFILE} | ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/update[${i}]\"].text" | tr '/' '-'`
  MP3FILE=`cat ${TMPFILE} | ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/fileUrlIphone[${i}]\"].text"`
  i=`expr ${i} + 1`
  if test ${ISNEW} -eq 0 ; then
    continue
  fi
  # Question
  echo -n "Download \"${TITLE} 第${NUM}回(${UPDATE}).mp3\"?[yes/no/quit] "
  read ANSWER
  case `echo "$ANSWER" | tr [A-Z] [a-z]` in
  yes | y ) ANSWER=yes
            #break
            ;;
  no | n ) ANSWER=no
           continue
           ;;
  quit | q ) break
             ;;
  * ) #break
      ;;
  esac

  wget -O "${TITLE} 第${NUM}回(${UPDATE}).mp3" ${MP3FILE}
done

rm ${TMPFILE}
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

