{ config, tools, lib, ... }:
{
  config = {
    name = "dialyzer";
    description = "Runs a static code analysis using Dialyzer";
    package = tools.elixir;
    entry = "${config.package}/bin/mix dialyzer";
    files = "\.exs?$";
  };
}
