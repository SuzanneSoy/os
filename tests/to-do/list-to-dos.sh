#!/bin/sh

escapehtml() {
  sed -e 's/&/\&amp;/g' \
      | sed -e 's/</\&lt;/g' \
      | sed -e 's/>/\&gt;/g' \
      | sed -e 's/"/\&quot;/g'
}

cat <<'EOF'
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>{{{project-name}}}</title>
    <style>
      body > ul { display: table; }
      ul   > li { display: table-row; }
      li   > a, li > span { display: table-cell; }
      li   > * + span { padding-left: 1em; }
      li   > a + span { text-align: right; }
    </style>
  </head>
  <body>
    <h1>Open tasks</h1>
    <ul>
EOF
  
commit="$(git rev-parse HEAD | escapehtml)"
(
  cd "$(git rev-parse --show-cdup)";
  git grep -i -n \\\(todo\\\|fixme\\\|xxx\\\)
) \
    | escapehtml \
    | sed -e 's~^\([^:]*\):\([^:]*\):\(.*\)$~      <li><a href="https://gitlab.com/project-name/project-name/blob/'"$commit"'/\1">\1</a> <span>\2</span> <span>\3</span></li>~'

cat <<'EOF'
    </ul>
  </body>
</html>
EOF
