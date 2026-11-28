{ writeShellApplication, coreutils, diffutils, libxml2 }:

writeShellApplication {
  name = "pre-commit-xmllint";
  runtimeInputs = [ coreutils diffutils libxml2 ];
  text = ''
    check=0
    if [ "''${1:-}" = "--check" ]; then
      check=1
      shift
    fi

    failed=0
    for file in "$@"; do
      tmp=$(mktemp)
      if ! xmllint --format "$file" > "$tmp"; then
        rm -f -- "$tmp"
        failed=1
        continue
      fi

      if [ "$check" -eq 1 ]; then
        diff -u -- "$file" "$tmp" || failed=1
      elif ! cmp -s -- "$file" "$tmp"; then
        cp -- "$tmp" "$file" || failed=1
      fi
      rm -f -- "$tmp"
    done

    exit "$failed"
  '';
}
