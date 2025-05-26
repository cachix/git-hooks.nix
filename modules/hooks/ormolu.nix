{ lib, config, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    defaultExtensions =
      mkOption {
        type = types.listOf types.str;
        description = "Haskell language extensions to enable.";
        default = [ ];
      };
    cabalDefaultExtensions =
      mkOption {
        type = types.bool;
        description = "Use `default-extensions` from `.cabal` files.";
        default = false;
      };
  };

  config = {
    package = tools.ormolu;
    entry =
      let
        extensions =
          lib.escapeShellArgs (lib.concatMap (ext: [ "--ghc-opt" "-X${ext}" ]) config.settings.defaultExtensions);
        cabalExtensions =
          if config.settings.cabalDefaultExtensions then "--cabal-default-extensions" else "";
      in
      "${config.package}/bin/ormolu --mode inplace ${extensions} ${cabalExtensions}";
    files = "\\.l?hs(-boot)?$";
  };
}
