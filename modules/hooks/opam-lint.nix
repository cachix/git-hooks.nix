{ tools, lib, config, ... }:
{
  config = {
    package = tools.opam;
    entry = "${config.package}/bin/opam lint";
    files = "opam$";
  };
}
