#!/bin/bash -e
# onsen.sh Ver. 0.8.6 (2015.01.02)
# recording tool for onsen.ag
# require openssl, wget and ruby

# target date
#GOTDATE=$(date +%y%m%d)
# precode of POST data
PRECODE=onsen$(date +%w%d%H)
# POST data
PDATA="code=$(echo "$PRECODE" | openssl dgst -md5 | sed -e 's/(stdin)= //')&file%5Fname=regular%5F"
# week number
REGXMLNUM=$(date +%w)
# onsen URL
URL="http://onsen.ag/getXML.php?$(date +%s)000"
# tmp file
TMPFILE="/var/tmp/tmp.$$"

AFLAG=FALSE
WGETOPTION=-q
RMOPTION=
OPT=
while getopts ayvw: OPT
do
  case $OPT in
    a) AFLAG=TRUE
       ;; # with all programs on GOTDATE
    y) REGXMLNUM=$(TZ=JST+15 date +%w)
       ;; # yesterday
    v) WGETOPTION=
       RMOPTION=-i
       ;; # verbose mode
    w) REGXMLNUM=$OPTARG
       ;; # indicate week number
    \?) echo "Usage: $(basename "$0") [-avy] [-w weeknumber]" 1>&2
        exit 1
        ;;
  esac
done
shift $((--OPTIND))

# download regular XML file
wget ${WGETOPTION} --post-data="${PDATA}${REGXMLNUM}" "${URL}" -O ${TMPFILE}

# number of program
PROGNUM=$(grep -c '<title>' ${TMPFILE} | cut -d ":" -f2)
#echo "番組数: $PROGNUM"

# index number
i=1
while test "${PROGNUM}" -gt 0
do
  PROGNUM=$((--PROGNUM))
  ISNEW=$(ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/isNew[${i}]\"].text" < ${TMPFILE})
  if test ${AFLAG} = TRUE -a "${ISNEW}" = 0 ; then
    ISNEW=1
  fi
  TITLE=$(ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/title[${i}]\"].text" < ${TMPFILE} | tr '/' '／')
  NUM=$(ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/number[${i}]\"].text" < ${TMPFILE})
  UPDATE=$(ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/update[${i}]\"].text" < ${TMPFILE} | tr '/' '月' | sed -e 's/$/日配信/')
  MP3FILE=$(ruby -rrexml/document -e "puts REXML::Document.new(ARGF).elements[\"data/regular/program/fileUrlIphone[${i}]\"].text" < ${TMPFILE})
  i=$((++i))
  if test ${ISNEW} != 1 ; then
    continue
  fi
  # Question
  echo -n "Record \"${TITLE} 第${NUM}回(${UPDATE}).mp3\"?[Yes/no/quit] "
  read ANSWER
  case $(echo "$ANSWER" | tr '[:upper:]' '[:lower:]') in
  no | n ) ANSWER=no
           continue
           ;;
  quit | q ) break
             ;;
  * ) ANSWER=yes
      ;;
  esac

  wget ${WGETOPTION} -O "${TITLE} 第${NUM}回(${UPDATE}).mp3" "${MP3FILE}"
done

rm ${RMOPTION} ${TMPFILE}

exit 0
