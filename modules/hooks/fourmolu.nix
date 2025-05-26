{ tools, config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    defaultExtensions = mkOption {
      type = types.listOf types.str;
      description = "Haskell language extensions to enable.";
      default = [ ];
    };
  };

  config = {
    package = tools.fourmolu;
    entry =
      "${config.package}/bin/fourmolu --mode inplace ${
    lib.escapeShellArgs (lib.concatMap (ext: [ "--ghc-opt" "-X${ext}" ]) config.settings.defaultExtensions)
    }";
    files = "\\.l?hs(-boot)?$";
  };
}
