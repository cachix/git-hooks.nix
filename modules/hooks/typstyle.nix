{ tools, lib, config, ... }:
{
  config = {
    name = "typstyle";
    description = "Beautiful and reliable typst code formatter.";
    package = tools.typstyle;
    entry =
      lib.throwIf
        (config.package == null)
        "The version of nixpkgs used by git-hooks.nix must contain typstyle"
        "${config.package}/bin/typstyle -i";
    files = "\\.typ$";
  };
}
