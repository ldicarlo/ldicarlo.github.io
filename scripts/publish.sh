#!/bin/bash

set -e
mkdir -p _tmp
file=$(find _drafts | fzf)
echo file: $file
filename=$(basename $file)
echo filename: $filename
echo date is: $(date '+%Y-%m-%d')
echo backing up...
cp $file  ./_tmp/$filename
echo moving...
mv $file ./_posts/$(date '+%Y-%m-%d')-$filename
echo ok.