{ config, tools, lib, ... }:
{
  config = {
    package = tools.elixir;
    entry = "${config.package}/bin/mix format";
    files = "\.exs?$";
  };
}
