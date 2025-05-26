{ tools, lib, config, ... }:
{
  config = {
    package = tools.elixir;
    entry = "${config.package}/bin/mix test";
    files = "\.exs?$";
    pass_filenames = false;
  };
}
