{ tools, lib, ... }:
{
  config = {
    name = "terraform-validate";
    description = "Validate terraform files.";
    package = tools.terraform-validate;
    entry = "${tools.terraform-validate}/bin/terraform-validate";
    files = "\.tf$";
  };
}