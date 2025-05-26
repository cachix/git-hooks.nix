{ tools, config, lib, ... }:
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

  config = {
    name = "credo";
    description = "Runs a static code analysis using Credo";
    package = tools.elixir;
    entry =
      let strict = if config.settings.strict then "--strict" else "";
      in "${config.package}/bin/mix credo ${strict}";
    files = "\\.exs?$";
  };
}
