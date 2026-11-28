{ runCommand, run }:

let
  mkHook = check:
    (run {
      src = null;
      addGcRoot = false;
      hooks.xmllint = {
        enable = true;
        settings.check = check;
      };
    }).config.hooks.xmllint;

  writeHook = mkHook false;
  checkHook = mkHook true;
in
assert writeHook.raw.pass_filenames && checkHook.raw.pass_filenames;
assert writeHook.raw.types == [ "xml" ] && checkHook.raw.types == [ "xml" ];
runCommand "xmllint-test" { } ''
  set -euo pipefail
  export XMLLINT_INDENT='  '

  mkdir -p tree
  files=(tree/document.xml "tree/file with spaces.svg")
  printf '<?xml version="1.0"?>\n<root><item>text</item></root>\n' > tree/unformatted
  printf '<?xml version="1.0"?>\n<root>\n  <item>text</item>\n</root>\n' > tree/expected
  for file in "''${files[@]}"; do
    cp tree/unformatted "$file"
  done
  chmod +x tree/document.xml

  if ${checkHook.raw.entry} "''${files[@]}"; then
    echo "check mode accepted unformatted XML"
    exit 1
  fi
  for file in "''${files[@]}"; do
    cmp tree/unformatted "$file"
  done

  ${writeHook.raw.entry} "''${files[@]}"
  for file in "''${files[@]}"; do
    cmp tree/expected "$file"
  done
  test -x tree/document.xml
  ${checkHook.raw.entry} "''${files[@]}"
  ${writeHook.raw.entry} "''${files[@]}"

  printf '<root><item></root>\n' > invalid.xml
  cp invalid.xml invalid.original
  if ${checkHook.raw.entry} invalid.xml; then
    echo "check mode accepted malformed XML"
    exit 1
  fi
  cmp invalid.original invalid.xml
  if ${writeHook.raw.entry} invalid.xml; then
    echo "write mode accepted malformed XML"
    exit 1
  fi
  cmp invalid.original invalid.xml

  touch $out
''
