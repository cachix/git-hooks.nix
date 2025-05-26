{ tools, lib, config, ... }:
{
  config = {
    name = "tflint";
    description = "A pluggable Terraform linter.";
    package = tools.tflint;
    entry = "${config.package}/bin/tflint";
    files = "\\.tf$";
  };
}
