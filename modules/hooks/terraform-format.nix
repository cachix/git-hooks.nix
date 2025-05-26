{ tools, lib, config, ... }:
{
  config = {
    package = tools.opentofu;
    entry = "${lib.getExe config.package} fmt -check -diff";
    files = "\\.tf$";
  };
}
