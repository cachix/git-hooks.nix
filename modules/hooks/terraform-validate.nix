{ tools, lib, config, ... }:
{
  config = {
    package = tools.terraform-validate;
    entry = "${config.package}/bin/terraform-validate";
    files = "\\.(tf(vars)?|terraform\\.lock\\.hcl)$";
    excludes = [ "\\.terraform/.*$" ];
    require_serial = true;
  };
}
