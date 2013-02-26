#!/bin/sh -ex
DESTDIR="$HOME"
XDATE=`date -v+1M +"%Y-%m%d-%H%M"`
RTMPDUMP="/usr/local/bin/rtmpdump"
if [ $# -eq 0 ]; then
  echo "usage : `basename $0` filename [stopmins]"
  exit 1
fi
TITLE="$1"
OUTFILE="${DESTDIR}/${TITLE}_${XDATE}.flv"
STOPMINS=${2:-30}
STOPSECS=`expr ${STOPMINS} \* 60 + 120`

for i in 5 4 3 2 1 ; do
	${RTMPDUMP} --rtmp "rtmpe://fms1.uniqueradio.jp/" \
	--playpath "aandg$i" \
	--app "?rtmp://fms-base1.mitene.ad.jp/agqr/" \
	--stop ${STOPSECS} \
	--live \
	-o "${OUTFILE}"
	if [ $? -eq 0 ]; then
		break;
	fi
done
