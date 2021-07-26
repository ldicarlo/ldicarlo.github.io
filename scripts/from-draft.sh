#!/bin/bash
set -e
filename=$(echo $@ | tr ' ' -).md
draft=./_drafts/$filename
echo received: $@, guessing: $draft 

echo date is: $(date '+%Y-%m-%d')
echo backing up...
cp $draft  ./_tmp/$filename
echo moving...
mv $draft ./_posts/$(date '+%Y-%m-%d')-$filename
echo ok.