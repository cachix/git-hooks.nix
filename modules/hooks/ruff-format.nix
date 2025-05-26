{ tools, lib, config, ... }:
{
  config = {
    name = "ruff-format";
    description = "An extremely fast Python code formatter, written in Rust.";
    package = tools.ruff;
    entry = "${config.package}/bin/ruff format";
    types = [ "python" ];
  };
}
