{ tools, lib, config, ... }:
{
  config = {
    package = tools.tflint;
    entry = "${config.package}/bin/tflint";
    files = "\\.tf$";
  };
}
