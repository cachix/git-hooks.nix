{ tools, lib, ... }:
{
  config = {
    name = "opam lint";
    description = "Lint opam package definition files.";
    package = tools.opam;
    entry = "${tools.opam}/bin/opam lint";
    files = "opam$";
  };
}