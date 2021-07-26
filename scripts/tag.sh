#!/bin/bash

tag=${*##*( )}
fn=$(echo "$tag" | tr ' ' - | tr '[:upper:]' '[:lower:]' | tr -d '\r')
filename=${fn##*( )}
cp ./tagtemplate tag/"$filename".md
sed -i "s/%TAG%/$tag/g" tag/"$filename".md
