{ config, tools, lib, ... }:
{
  config = {
    name = "elm-review";
    description = "Analyzes Elm projects, to help find mistakes before your users find them.";
    package = tools.elm-review;
    entry = "${config.package}/bin/elm-review";
    files = "\.elm$";
    pass_filenames = false;
  };
}
