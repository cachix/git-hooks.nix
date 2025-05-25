{ tools, lib, ... }:
{
  config = {
    name = "tflint";
    description = "A Pluggable Terraform Linter.";
    package = tools.tflint;
    entry = "${tools.tflint}/bin/tflint";
    files = "\.tf$";
  };
}