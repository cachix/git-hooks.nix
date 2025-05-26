{ config, tools, lib, pkgs, ... }:
{
  config = {
    package = tools.go;
    entry =
      let
        script = pkgs.writeShellScript "precommit-gotest" ''
          set -e
          # find all directories that contain tests
          dirs=()
          for file in "$@"; do
            # either the file is a test
            if [[ "$file" = *_test.go ]]; then
              dirs+=("$(dirname "$file")")
              continue
            fi

            # or the file has an associated test
            filename="''${file%.go}"
            test_file="''${filename}_test.go"
            if [[ -f "$test_file"  ]]; then
              dirs+=("$(dirname "$test_file")")
              continue
            fi
          done

          # ensure we are not duplicating dir entries
          IFS=$'\n' sorted_dirs=($(sort -u <<<"''${dirs[*]}")); unset IFS

          # test each directory one by one
          for dir in "''${sorted_dirs[@]}"; do
              ${config.package}/bin/go test "./$dir"
          done
        '';
      in
      builtins.toString script;
    files = "\.go$";
    # to avoid multiple invocations of the same directory input, provide
    # all file names in a single run.
    require_serial = true;
  };
}
