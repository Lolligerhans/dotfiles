#!/usr/bin/env bash

declare -a files
if (($# == 0)); then
  mapfile -t files < <(find . -iname "*.sh" -not -path "./extern/*")
else
  files=("$@")
fi
ls "${files[@]}"
if ! shellcheck -e SC2128,2154,2034 \
  --color=always \
  -x "${files[@]}" >shellcheck.txt 2>&1; then
  echo "Shellcheck failed! Opening 'shellcheck.txt' for details."
fi
if [[ -s shellcheck.txt ]]; then
  batcat shellcheck.txt
else
  echo "All good (${#files[@]} files)!"
fi
