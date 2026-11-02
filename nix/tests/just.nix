{ runCommand, run, python3 }:

let
  mkHook = check:
    (run {
      src = null;
      addGcRoot = false;
      hooks.just = {
        enable = true;
        settings.check = check;
      };
    }).config.hooks.just;

  writeHook = mkHook false;
  checkHook = mkHook true;
in
assert writeHook.raw.pass_filenames && checkHook.raw.pass_filenames;
runCommand "just-test" { } ''
  set -euo pipefail

  ${python3}/bin/python3 - <<'PY'
  import re

  pattern = re.compile(r'${writeHook.raw.files}')
  supported = [
      "justfile",
      "Justfile",
      "JUSTFILE",
      "jUsTfIlE",
      ".justfile",
      ".JUSTFILE",
      ".user.justfile",
      "foo.just",
      "foo/mod.just",
      "dir/file with spaces.just",
  ]
  unsupported = ["justfile.txt", "notjustfile", "foo.JUST", "README.md"]

  for path in supported:
      assert pattern.search(path), f"did not match {path}"
  for path in unsupported:
      assert not pattern.search(path), f"unexpectedly matched {path}"
  PY

  mkdir -p tree/nested tree/upper tree/hidden
  files=(
    tree/justfile
    tree/nested/Justfile
    tree/nested/.justfile
    tree/upper/JUSTFILE
    tree/hidden/.JUSTFILE
    tree/.user.justfile
    tree/nested/recipe.just
    tree/nested/mod.just
    tree/nested/.just
    "tree/file with spaces.just"
  )
  for file in "''${files[@]}"; do
    printf 'default:\n\techo    hello\n' > "$file"
  done
  cp tree/justfile tree/original
  printf 'default:\n    echo    hello\n' > tree/expected

  if ${checkHook.raw.entry} "''${files[@]}"; then
    echo "check mode accepted unformatted justfiles"
    exit 1
  fi
  cmp tree/original tree/justfile

  if ${writeHook.raw.entry} "''${files[@]}"; then
    echo "write mode did not report formatting changes"
    exit 1
  fi
  for file in "''${files[@]}"; do
    cmp tree/expected "$file"
  done
  ${checkHook.raw.entry} "''${files[@]}"
  ${writeHook.raw.entry} "''${files[@]}"

  printf 'not a valid justfile' > invalid.just
  cp invalid.just invalid.original
  if ${checkHook.raw.entry} invalid.just; then
    echo "check mode accepted an invalid justfile"
    exit 1
  fi
  cmp invalid.original invalid.just
  if ${writeHook.raw.entry} invalid.just; then
    echo "write mode accepted an invalid justfile"
    exit 1
  fi
  cmp invalid.original invalid.just

  touch $out
''
