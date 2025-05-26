{ tools, lib, config, ... }:
{
  config = {
    name = "ruff";
    description = "An extremely fast Python linter, written in Rust.";
    package = tools.ruff;
    entry = "${config.package}/bin/ruff check --fix";
    types = [ "python" ];
    require_serial = true;
  };
}
