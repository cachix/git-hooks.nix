{ lib, config, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    simplify = mkOption {
      type = types.bool;
      description = "Simplify the code.";
      default = true;
    };
  };

  config = {
    name = "shfmt";
    description = "Format shell files.";
    types = [ "shell" ];
    package = tools.shfmt;
    entry =
      let
        simplify = if config.settings.simplify then "-s" else "";
      in
      "${config.package}/bin/shfmt -w -l ${simplify}";
  };
}
