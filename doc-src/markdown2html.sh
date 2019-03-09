#!/bin/sh

if test $# -ne 2; then
  printf %s\\n 'Usage: path/to/markdown2html.sh file.md "Page title"'
  exit 1
fi

cat <<EOF
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>$2</title>
    <link type="text/css" rel="stylesheet" href="style.css" />
  </head>
  <body>
EOF
markdown "$1" | sed -e 's/^/    /'
cat <<'EOF'
  </body>
</html>
EOF
