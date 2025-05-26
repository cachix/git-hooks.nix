{ tools, lib, config, ... }:
{
  config = {
    package = tools.ruff;
    entry = "${config.package}/bin/ruff check --fix";
    types = [ "python" ];
    require_serial = true;
  };
}
