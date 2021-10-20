#!/bin/bash
version=$(date +%Y%m%d%H%M) 
box_name=$1

echo -n "$b "
echo "=============check box exists $box_name============="
# check box exists
box_exists=$(curl --write-out '%{http_code}' --silent --output /dev/null \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  https://app.vagrantup.com/api/v1/box/ivyxjc/$box_name)

echo -n "$b "
if [[ "$box_exists" -eq "404" ]]; then
    echo "=============create box $box_name============="
    # create box
    curl \
      --header "Content-Type: application/json" \
      --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
      https://app.vagrantup.com/api/v1/boxes \
      --data "{ \"box\": { \"username\":\"ivyxjc\", \"name\":\"$box_name\", \"is_private\": false, \"short_description\": \"$box_name\",  \"description\": \"$box_name\"} }"
fi
if [[ "$box_exists" -eq "200" ]]; then
    echo "box exists, no need to create box"
fi

echo -n "$b "
echo "=============create version $box_name============="
# create version
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  https://app.vagrantup.com/api/v1/box/ivyxjc/$box_name/versions \
  --data "{ \"version\": { \"version\": \"$version\" } }"

echo -n "$b "
echo "=============create provider $box_name============="
# create provider
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  https://app.vagrantup.com/api/v1/box/ivyxjc/$box_name/version/$version/providers \
  --data '{ "provider": { "name": "virtualbox" } }'


echo -n "$b "
echo "=============upload $box_name============="
# upload
response=$(curl \
    --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
 https://app.vagrantup.com/api/v1/box/ivyxjc/$box_name/version/$version/provider/virtualbox/upload)

upload_path=$(echo "$response" | jq .upload_path)
upload_path=$(echo "$upload_path" | tr -d '"')

echo $upload_path

echo $(pwd)
ls -la
curl $upload_path --request PUT --upload-file $box_name.virtualbox.box

echo -n "$b "
echo "=============release $box_name============="
curl \
  --header "Authorization: Bearer $VAGRANT_CLOUD_TOKEN" \
  https://app.vagrantup.com/api/v1/box/ivyxjc/$box_name/version/$version/release \
  --request PUT