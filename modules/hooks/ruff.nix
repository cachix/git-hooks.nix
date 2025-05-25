{ tools, lib, ... }:
{
  config = {
    name = "ruff";
    description = "An extremely fast Python linter, written in Rust.";
    package = tools.ruff;
    entry = "${tools.ruff}/bin/ruff check --fix";
    types = [ "python" ];
    require_serial = true;
  };
}