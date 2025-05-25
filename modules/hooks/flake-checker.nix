{ tools, lib, ... }:
{
  config = {
    name = "flake-checker";
    description = "Run health checks on your flake-powered Nix projects.";
    package = tools.flake-checker;
    entry = "${tools.flake-checker}/bin/flake-checker -f";
    files = "(^flake\.nix$|^flake\.lock$)";
    pass_filenames = false;
  };
}