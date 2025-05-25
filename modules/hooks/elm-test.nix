{ tools, lib, ... }:
{
  config = {
    name = "elm-test";
    description = "Run unit tests and fuzz tests for Elm code.";
    package = tools.elm-test;
    entry = "${tools.elm-test}/bin/elm-test";
    files = "\.elm$";
    pass_filenames = false;
  };
}