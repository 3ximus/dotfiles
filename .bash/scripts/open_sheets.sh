#!/bin/bash

# Reads file contents from stdin
# the first argument is the name of the file, if omited 'temp.xlsx' is given
# NOTE Depends on ./extract_cookies.sh script

$(dirname ${BASH_SOURCE[0]})/extract_cookies.sh ~/.mozilla/firefox/*.default-release/cookies.sqlite > /tmp/sheets_upload_cookies.txt

# save file form
cat > /tmp/curl_upload.xlsx << EOF
--lygsa2ob8du8
content-type: application/json; charset=UTF-8

{"title":"${1:-temp.xlsx}","mimeType":"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}
--lygsa2ob8du8
content-transfer-encoding: base64
content-type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

$(cat $1 <&0 | base64 -w0)
--lygsa2ob8du8--
EOF

RESPONSE=$(curl 'https://clients6.google.com/upload/drive/v2internal/files?uploadType=multipart&supportsTeamDrives=true&fields=id&pinned=false&convert=true&openDrive=false&reason=907&syncType=0&errorRecovery=false&key=AIzaSyAw-cTyp9Xotzvu3vNDWhDU3E9NConkKxQ' \
	-X POST \
	--cookie "/tmp/sheets_upload_cookies.txt" \
	-H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/116.0' \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H 'authorization: SAPISIDHASH 1692633207_9ac30f5ba90100c8cab2c0e07f0c36a37663869c_u' \
	-H 'Origin: https://docs.google.com' \
	-H 'content-type: multipart/related; boundary="lygsa2ob8du8"' \
	--data-binary '@/tmp/curl_upload.xlsx')

echo Got Response: $RESPONSE
FILEID=$(echo $RESPONSE | sed 's/.*: "\(.\+\)".*/\1/')

# open in new tab
firefox --new-tab "https://docs.google.com/spreadsheets/d/$FILEID"

rm /tmp/sheets_upload_cookies.txt /tmp/curl_upload.xlsx
