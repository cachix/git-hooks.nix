{ tools, lib, config, ... }:
{
  config = {
    name = "mix-test";
    description = "Run Elixir tests with mix test.";
    package = tools.elixir;
    entry = "${config.package}/bin/mix test";
    files = "\.exs?$";
    pass_filenames = false;
  };
}
