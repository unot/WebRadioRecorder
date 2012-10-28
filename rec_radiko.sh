#!/bin/sh -ex
DESTDIR="$HOME"
playerurl=http://radiko.jp/player/swf/player_3.0.0.01.swf
playerfile=${DESTDIR}/player.swf
keyfile=${DESTDIR}/authkey.png
XDATE=`date -v+1M +"%Y-%m%d-%H%M"`
WGET="/usr/local/bin/wget"
SWFEXTRACT="/usr/local/bin/swfextract"
RTMPDUMP="/usr/local/bin/rtmpdump"
FFMPEG="/usr/local/bin/ffmpeg"
AFCONVERT="/usr/bin/afconvert"

if [ $# -eq 0 ]; then
  echo "usage : `basename $0` channel_name [stopmins]"
  exit 1
fi
channel=$1
output=${DESTDIR}/${channel}_${XDATE}.flv
AACFILE=${output%.flv}.aac
STOPMINS=${2:-120}
STOPSECS=`expr ${STOPMINS} \* 60 + 120`

#
# get player
#
if [ ! -f $playerfile ]; then
  ${WGET} -q -O $playerfile $playerurl

  if [ $? -ne 0 ]; then
    echo "failed get player"
    exit 1
  fi
fi

#
# get keydata (need swftool)
#
if [ ! -f $keyfile ]; then
  ${SWFEXTRACT} -b 14 $playerfile -o $keyfile

  if [ ! -f $keyfile ]; then
    echo "failed get keydata"
    exit 1
  fi
fi

if [ -f auth1_fms ]; then
  rm -f auth1_fms
fi

#
# access auth1_fms
#
${WGET} -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --post-data='\r\n' \
     --no-check-certificate \
     --save-headers \
     https://radiko.jp/v2/api/auth1_fms

if [ $? -ne 0 ]; then
  echo "failed auth1 process"
  exit 1
fi

#
# get partial key
#
authtoken=`perl -ne 'print $1 if(/x-radiko-authtoken: ([\w-]+)/i)' auth1_fms`
offset=`perl -ne 'print $1 if(/x-radiko-keyoffset: (\d+)/i)' auth1_fms`
length=`perl -ne 'print $1 if(/x-radiko-keylength: (\d+)/i)' auth1_fms`

partialkey=`dd if=$keyfile bs=1 skip=${offset} count=${length} 2> /dev/null | base64`

echo "authtoken: ${authtoken} \noffset: ${offset} length: ${length} \npartialkey: $partialkey"

rm -f auth1_fms

if [ -f auth2_fms ]; then
  rm -f auth2_fms
fi

#
# access auth2_fms
#
${WGET} -q \
     --header="pragma: no-cache" \
     --header="X-Radiko-App: pc_1" \
     --header="X-Radiko-App-Version: 2.0.1" \
     --header="X-Radiko-User: test-stream" \
     --header="X-Radiko-Device: pc" \
     --header="X-Radiko-Authtoken: ${authtoken}" \
     --header="X-Radiko-Partialkey: ${partialkey}" \
     --post-data='\r\n' \
     --no-check-certificate \
     https://radiko.jp/v2/api/auth2_fms

if [ $? -ne 0 -o ! -f auth2_fms ]; then
  echo "failed auth2 process"
  exit 1
fi

echo "authentication success"

areaid=`perl -ne 'print $1 if(/^([^,]+),/i)' auth2_fms`
echo "areaid: $areaid"

rm -f auth2_fms

#
# rtmpdump
#
${RTMPDUMP} -v \
         -r "rtmpe://w-radiko.smartstream.ne.jp" \
         --playpath "simul-stream.stream" \
         --app "${channel}/_definst_" \
         -W $playerurl \
         -C S:"" -C S:"" -C S:"" -C S:$authtoken \
         --live \
         --stop ${STOPSECS} \
         --flv $output

#
# convert flv to m4a
# 
${FFMPEG} -i ${output} -vn -acodec copy ${AACFILE}
if [ $? != 0 ]; then
    # http://bui.asablo.jp/blog/2012/02/24/6347167
    ${FFMPEG} -i ${output} ${AACFILE}
fi
${AFCONVERT} -f m4af -d aach -b 48000 ${AACFILE}
rm  ${output} ${AACFILE} $playerfile $keyfile
exit 0
