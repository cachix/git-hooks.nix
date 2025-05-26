{ config, lib, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    flags =
      mkOption {
        type = types.str;
        description = "Flags passed to latexindent. See available flags [here](https://latexindentpl.readthedocs.io/en/latest/sec-how-to-use.html#from-the-command-line)";
        default = "--local --silent --overwriteIfDifferent";
      };
  };

  config = {
    types = [ "file" "tex" ];
    package = tools.latexindent;
    entry = "${config.package}/bin/latexindent ${config.settings.flags}";
  };
}
