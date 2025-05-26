{ tools, lib, config, ... }:
{
  config = {
    name = "terraform-format";
    description = "Format Terraform (`.tf`) files.";
    package = tools.opentofu;
    entry = "${lib.getExe config.package} fmt -check -diff";
    files = "\\.tf$";
  };
}
