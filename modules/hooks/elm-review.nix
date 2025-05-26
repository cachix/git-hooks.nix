{ config, tools, lib, ... }:
{
  config = {
    package = tools.elm-review;
    entry = "${config.package}/bin/elm-review";
    files = "\.elm$";
    pass_filenames = false;
  };
}
