#!/usr/bin/env bash

url="$1"
user="$2"
pwd="$3"
target="$(realpath "$(pwd)/$4")"

cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")"

html=$( curl -c ./cookie "$url"'/i/' )
regex='name="_csrf" value="([[:alnum:]]*)" />'
if [[ "$html" =~ $regex ]]; then
        CSRF="${BASH_REMATCH[1]}"
else
        exit 1
fi

json=$( curl -b ./cookie "$url"'/i/?c=javascript&a=nonce&user='"$user" \
        --compressed )
regex='\{"salt1":"(.*)","nonce":"(.*)"\}'
if [[ $json =~ $regex ]]; then
        salt="${BASH_REMATCH[1]}"
        nonce="${BASH_REMATCH[2]}"
else
        exit 1
fi

npm install bcrypt

challenge=$( node ./get_challenge.js "$pwd" "$salt" "$nonce" )

curl -L -b ./cookie "$url"'/i/?c=auth&a=login' \
  --data-raw '_csrf='"$CSRF"'&username='"$user"'&challenge='"$challenge" \
  --compressed > /dev/null

html=$(curl -b ./cookie "$url"'/i/?c=importExport')
regex='name="_csrf" value="([[:alnum:]]*)" />'
if [[ "$html" =~ $regex ]]; then
        CSRF="${BASH_REMATCH[1]}"
else
        exit 1
fi

curl -b ./cookie "$url"'/i/?c=importExport&a=export' \
  --data-raw '_csrf='"$CSRF"'&export_opml=1&export_labelled=1&export_starred=1' \
  --compressed -o export.zip

unzip export.zip

mkdir -p "$target"

mv *.xml "$target/feeds.opml.xml"
mv starred*.json "$target/starred.json"
