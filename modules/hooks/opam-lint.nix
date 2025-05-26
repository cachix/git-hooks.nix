{ tools, lib, config, ... }:
{
  config = {
    name = "opam lint";
    description = "OCaml package manager configuration checker";
    package = tools.opam;
    entry = "${config.package}/bin/opam lint";
    files = "opam$";
  };
}
