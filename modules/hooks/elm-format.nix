{ config, tools, lib, ... }:
{
  config = {
    name = "elm-format";
    description = "Format Elm files.";
    package = tools.elm-format;
    entry = "${config.package}/bin/elm-format --yes --elm-version=0.19";
    files = "\.elm$";
  };
}
