{ tools, lib, ... }:
{
  config = {
    name = "mix-format";
    description = "Format Elixir files with mix format.";
    package = tools.elixir;
    entry = "${tools.elixir}/bin/mix format";
    files = "\.exs?$";
  };
}