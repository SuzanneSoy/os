#!/bin/sh

if test $# -ne 1 || test "$1" = '-h' || test "$1" = '--help'; then
  echo 'Usage: ./fork.sh name'
  echo 'Renames the project'
  exit 1
fi

if printf %s "$1" | grep -q -v '[-0-9a-zA-Z_ ]'; then
  echo 'The name should not contain characters outside of [-0-9a-zA-Z_ ]'
  echo 'TODO: escape problematic characters in the regexp and allow them'
  exit 1
fi

if git grep -q -e "$1"; then
  echo "The proposed name already appears in the source code."
  echo "If you proceed, the new name will prevent easy renaming of this code base."
  exit 1
fi

git ls-tree -r HEAD | awk '{ print $4 }' | xargs sed -i -e 's/{{{project-name}}}/'"$1"/g
