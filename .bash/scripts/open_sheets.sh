#!/bin/bash

# Open an excel file in google sheets
# Reads file contents from stdin. The first argument is the name of the file, if omited 'temp.xlsx' is given
# You'll need to give your own key underneath. If you don't have one just inspect a drive file upload request and get it from there
# NOTE Depends on ./extract_cookies.sh script (https://gist.github.com/hackerb9/d382e09683a52dcac492ebcdaf1b79af)

APIKEY='AIzaSyAw-cTyp9Xotzvu3vNDWhDU3E9NConkKxQ'

$(dirname ${BASH_SOURCE[0]})/extract_cookies.sh ~/.mozilla/firefox/*.default-release/cookies.sqlite > /tmp/sheets_upload_cookies.txt

# save file form
cat > /tmp/curl_upload.xlsx << EOF
--deadbeef1337
content-type: application/json; charset=UTF-8

{"title":"${1:-temp.xlsx}","mimeType":"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}
--deadbeef1337
content-transfer-encoding: base64
content-type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

$(cat $1 <&0 | base64 -w0)
--deadbeef1337--
EOF

# Calculate SAPISIDHASH
SAPISID=$(grep 'google.com.*SAPISID' /tmp/sheets_upload_cookies.txt | awk '{print$7}')
TIMESTAMP=$(date +%s)
ORIGIN="https://docs.google.com"
SAPISIDHASH="${TIMESTAMP}_$(echo -n "${TIMESTAMP} ${SAPISID} ${ORIGIN}" | sha1sum | cut -d' ' -f1)"

RESPONSE=$(curl "https://clients6.google.com/upload/drive/v2internal/files?uploadType=multipart&supportsTeamDrives=true&fields=id&pinned=false&convert=true&openDrive=false&reason=907&syncType=0&errorRecovery=false&key=${APIKEY}" \
	-X POST \
	--cookie "/tmp/sheets_upload_cookies.txt" \
	-H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/116.0' \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H "authorization: SAPISIDHASH ${SAPISIDHASH}" \
	-H "Origin: ${ORIGIN}" \
	-H 'content-type: multipart/related; boundary="deadbeef1337"' \
	--data-binary '@/tmp/curl_upload.xlsx')

echo Got Response: $RESPONSE
FILEID=$(echo $RESPONSE | sed 's/.*: "\(.\+\)".*/\1/')

# open in new tab
firefox --new-tab "https://docs.google.com/spreadsheets/d/$FILEID"

rm /tmp/sheets_upload_cookies.txt /tmp/curl_upload.xlsx
