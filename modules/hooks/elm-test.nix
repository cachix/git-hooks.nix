{ config, tools, lib, ... }:
{
  config = {
    package = tools.elm-test;
    entry = "${config.package}/bin/elm-test";
    files = "\.elm$";
    pass_filenames = false;
  };
}
