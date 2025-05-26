{ tools, lib, config, ... }:
{
  config = {
    package = tools.typstyle;
    entry =
      lib.throwIf
        (config.package == null)
        "The version of nixpkgs used by git-hooks.nix must contain typstyle"
        "${config.package}/bin/typstyle -i";
    files = "\\.typ$";
  };
}
