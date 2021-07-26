#!/bin/bash
set -e

file=$(ls _posts | fzf)

pm=$(echo "${file}" | sed -r 's/([0-9]{4})-([0-9]{2})-([0-9]{2})-(.*)\.md/\1\2\3\4/g')

echo "$pm"
echo "/pl/$pm.html"


