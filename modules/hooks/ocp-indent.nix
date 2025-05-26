{ tools, lib, config, ... }:
{
  config = {
    package = tools.ocp-indent;
    entry = "${config.package}/bin/ocp-indent --inplace";
    files = "\.mli?$";
  };
}
