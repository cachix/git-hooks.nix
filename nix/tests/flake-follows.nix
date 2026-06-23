{ pkgs, run }:
let
  fakeFlakeEdit = pkgs.writeShellScriptBin "flake-edit" ''
    set -eu

    : > flake-edit-args

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --flake)
          printf '%s\n' "$1" "$2" >> flake-edit-args
          shift 2
          ;;
        --lock-file)
          printf '%s\n' "$1" "$2" >> flake-edit-args
          shift 2
          ;;
        --no-lock|--non-interactive|follow)
          printf '%s\n' "$1" >> flake-edit-args
          shift
          ;;
        *)
          echo "unexpected argument: $1" >&2
          exit 2
          ;;
      esac
    done

    echo '# flake-edit follow ran' >> flake.nix
  '';

  hook = (run {
    src = null;
    addGcRoot = false;
    tools.flake-edit = fakeFlakeEdit;
    hooks.flake-follows.enable = true;
  }).config.hooks.flake-follows;

  hookWithoutNoLock = (run {
    src = null;
    addGcRoot = false;
    tools.flake-edit = fakeFlakeEdit;
    hooks.flake-follows = {
      enable = true;
      settings.noLock = false;
    };
  }).config.hooks.flake-follows;

  customPathHook = (run {
    src = null;
    addGcRoot = false;
    tools.flake-edit = fakeFlakeEdit;
    hooks.flake-follows = {
      enable = true;
      settings.flake = "nix/flake.nix";
      settings.lockFile = "nix/flake.lock";
    };
  }).config.hooks.flake-follows;
in
pkgs.runCommand "flake-follows-test" { } ''
  set -euo pipefail

  mkdir enabled
  cd enabled
  touch flake.nix flake.lock
  ${hook.entry}
  grep -q '# flake-edit follow ran' flake.nix
  grep -q -- '--flake' flake-edit-args
  grep -q -- 'flake.nix' flake-edit-args
  grep -q -- '--lock-file' flake-edit-args
  grep -q -- 'flake.lock' flake-edit-args
  grep -q -- '--no-lock' flake-edit-args
  grep -q -- '--non-interactive' flake-edit-args
  grep -q -- 'follow' flake-edit-args
  cd ..

  mkdir no-lock-disabled
  cd no-lock-disabled
  touch flake.nix flake.lock
  ${hookWithoutNoLock.entry}
  grep -q '# flake-edit follow ran' flake.nix
  if grep -q -- '--no-lock' flake-edit-args; then
    echo 'unexpected --no-lock argument' >&2
    exit 1
  fi
  cd ..

  mkdir missing-lock
  cd missing-lock
  touch flake.nix
  ${hook.entry}
  test ! -e flake-edit-args
  cd ..

  mkdir missing-flake
  cd missing-flake
  touch flake.lock
  ${hook.entry}
  test ! -e flake-edit-args
  cd ..

  mkdir -p custom-path/nix
  cd custom-path
  touch nix/flake.nix nix/flake.lock
  ${customPathHook.entry}
  grep -q '# flake-edit follow ran' nix/flake.nix
  grep -q -- 'nix/flake.nix' flake-edit-args
  grep -q -- 'nix/flake.lock' flake-edit-args

  echo success > $out
''
