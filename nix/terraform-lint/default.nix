{
  writeShellApplication,
  coreutils,
  tflint,
}:

writeShellApplication {
  name = "terraform-lint";

  runtimeInputs = [
    tflint
    coreutils
  ];

  text = ''
    red='\033[0;31m'
    none='\033[0m'

    for arg in "$@"; do
      echo -en "$red$arg$none "
      if ! tflint --chdir "$(dirname "$arg")" --filter "$(basename "$arg")"; then
        fail=true
      fi
    done

    [[ -v fail ]] && exit 1
  '';
}
