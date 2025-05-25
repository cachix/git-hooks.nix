{ tools, lib, ... }:
{
  config = {
    name = "ruff-format";
    description = "An extremely fast Python formatter, written in Rust.";
    package = tools.ruff;
    entry = "${tools.ruff}/bin/ruff format";
    types = [ "python" ];
    require_serial = true;
  };
}