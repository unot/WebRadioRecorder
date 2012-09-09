#!/bin/sh
XDATE=`date -v+1M +"%Y-%m%d-%H%M"`
STOPMINS=${1:-120}
STOPSECS=`expr ${STOPMINS} \* 60 + 120`
RTMPDUMP=/usr/local/bin/rtmpdump
FFMPEG=/usr/local/bin/ffmpeg
AFCONVERT=/usr/bin/afconvert
SAVEDIR=/Users/unot
FLVFILE=${SAVEDIR}/NHK-FM_${XDATE}.flv
AACFILE=${FLVFILE%.flv}.aac
${RTMPDUMP} --rtmp "rtmpe://netradio-fm-flash.nhk.jp" \
    --playpath 'NetRadio_FM_flash@63343' \
    --app "live" \
    -W http://www3.nhk.or.jp/netradio/files/swf/rtmpe.swf \
    --live \
    -B $STOPSECS \
    -o ${FLVFILE}
if [ $? != 0 ]; then
    rm ${FLVFILE}
    exit 1
fi
${FFMPEG} -i ${FLVFILE} -vn -acodec copy ${AACFILE}
if [ $? != 0 ]; then
    # http://bui.asablo.jp/blog/2012/02/24/6347167
    ${FFMPEG} -i ${FLVFILE} ${AACFILE}
fi
${AFCONVERT} -f m4af -d aach -b 48000 ${AACFILE}
rm ${FLVFILE} ${AACFILE}
exit 0