{ tools, lib, config, ... }:
{
  config = {
    package = tools.ruff;
    entry = "${config.package}/bin/ruff format";
    types = [ "python" ];
  };
}
