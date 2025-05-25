{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    strict =
      mkOption {
        type = types.bool;
        description = "Whether to auto-promote the changes.";
        default = true;
      };
  };
}
