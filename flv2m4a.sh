#!/bin/sh -e
if [ $# -ne 1 ]; then
	echo "USAGE: $(basename "$0") hogehoge.flv"
	exit 1
fi

FFMPEG=/usr/local/bin/ffmpeg
AFCONVERT=/usr/bin/afconvert
FLVFILE="$1"
AACFILE="${FLVFILE%.???}.aac"
trap 'rm -f ${AACFILE}' EXIT

${FFMPEG} -i "${FLVFILE}" -vn -acodec copy "${AACFILE}"
if [ $? != 0 ]; then
    # http://bui.asablo.jp/blog/2012/02/24/6347167
    ${FFMPEG} -i "${FLVFILE}" "${AACFILE}"
fi
${AFCONVERT} -f m4af -d aach -b 48000 "${AACFILE}"
exit 0
