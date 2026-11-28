{ writeShellApplication, just }:

writeShellApplication {
  name = "pre-commit-just";
  runtimeInputs = [ just ];
  text = ''
    check=0
    if [ "''${1:-}" = "--check" ]; then
      check=1
      shift
    fi

    failed=0
    for file in "$@"; do
      if [ "$check" -eq 1 ]; then
        just --unstable --fmt --check --justfile "$file" || failed=1
        continue
      fi

      if just --unstable --fmt --check --justfile "$file" >/dev/null 2>&1; then
        continue
      fi

      just --unstable --fmt --justfile "$file" || failed=1
      failed=1
    done

    exit "$failed"
  '';
}
