#!/bin/bash
set -e
echo received: $@
title="$@"
draft=$(echo $@ | tr ' ' - | tr '[:upper:]' '[:lower:]' | tr "'" "-")
echo name: $draft
echo creating: $draft
mkdir -p _drafts
cat model | sed "s/%TITLE%/${title}/g" >> _drafts/$draft.md
echo ok.
