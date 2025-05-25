{ tools, lib, ... }:
{
  config = {
    name = "terraform-format";
    description = "Format terraform files.";
    package = tools.terraform;
    entry = "${tools.terraform}/bin/terraform fmt";
    files = "\.tf$";
  };
}