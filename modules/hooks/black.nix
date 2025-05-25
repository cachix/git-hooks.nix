{ tools, config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    flags = mkOption {
      type = types.str;
      description = "Flags passed to black. See all available [here](https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html#command-line-options).";
      default = "";
      example = "--skip-magic-trailing-comma";
    };
  };

  config = {
    name = "black";
    description = "The uncompromising Python code formatter";
    package = tools.black;
    entry = "${tools.black}/bin/black ${config.settings.flags}";
    types = [ "file" "python" ];
  };
}
