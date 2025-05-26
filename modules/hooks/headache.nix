{ tools, config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    header-file = mkOption {
      type = types.str;
      description = "Path to the header file.";
      default = ".header";
    };
  };

  config = {
    ## NOTE: Supported `files` are taken from
    ## https://github.com/Frama-C/headache/blob/master/config_builtin.txt
    files = "(\\.ml[ily]?$)|(\\.fmli?$)|(\\.[chy]$)|(\\.tex$)|(Makefile)|(README)|(LICENSE)";
    package = tools.headache;
    entry =
      ## NOTE: `headache` made into in nixpkgs on 12 April 2023. At the
      ## next NixOS release, the following code will become irrelevant.
      lib.throwIf
        (config.package == null)
        "The version of nixpkgs used by git-hooks.nix does not have `ocamlPackages.headache`. Please use a more recent version of nixpkgs."
        "${config.package}/bin/headache -h ${config.settings.header-file}";
  };
}
