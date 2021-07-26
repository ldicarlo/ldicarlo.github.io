#!/bin/bash

rm tag/*

cat _site/tags.html | grep %% | sed 's/%//g' | xargs -I{} bash -c "scripts/tag.sh {}"
