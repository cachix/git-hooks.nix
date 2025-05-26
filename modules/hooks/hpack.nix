{ config, lib, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    silent =
      mkOption {
        type = types.bool;
        description = "Whether generation should be silent.";
        default = false;
      };
  };

  config = {
    name = "hpack";
    description = "`hpack` converts package definitions in the hpack format (`package.yaml`) to Cabal files.";
    package = tools.hpack-dir;
    entry = "${config.package}/bin/hpack-dir --${if config.settings.silent then "silent" else "verbose"}";
    files = "(\\.l?hs(-boot)?$)|(\\.cabal$)|((^|/)package\\.yaml$)";
    # We don't pass filenames because they can only be misleading.
    # Indeed, we need to rerun `hpack` in every directory:
    # 1. In which there is a *.cabal file, or
    # 2. Below which there are haskell files, or
    # 3. In which there is a package.yaml that references haskell files
    #    that have been changed at arbitrary locations specified in that
    #    file.
    # In other words: We have no choice but to always run `hpack` on every `package.yaml` directory.
    pass_filenames = false;
  };
}
