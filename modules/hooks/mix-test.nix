{ tools, lib, ... }:
{
  config = {
    name = "mix-test";
    description = "Run Elixir tests with mix test.";
    package = tools.elixir;
    entry = "${tools.elixir}/bin/mix test";
    files = "\.exs?$";
    pass_filenames = false;
  };
}