{ tools, lib, config, ... }:
{
  config = {
    name = "ocp-indent";
    description = "A tool to indent OCaml code.";
    package = tools.ocp-indent;
    entry = "${config.package}/bin/ocp-indent --inplace";
    files = "\.mli?$";
  };
}
