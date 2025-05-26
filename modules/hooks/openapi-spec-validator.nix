{ tools, lib, config, ... }:
{
  config = {
    package = tools.openapi-spec-validator;
    entry = "${config.package}/bin/openapi-spec-validator";
    files = "\.ya?ml$";
  };
}
