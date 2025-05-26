{ config, tools, lib, ... }:
{
  config = {
    name = "mix-format";
    description = "Format Elixir files with mix format.";
    package = tools.elixir;
    entry = "${config.package}/bin/mix format";
    files = "\.exs?$";
  };
}
