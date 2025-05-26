{ tools, lib, config, ... }:
{
  config = {
    name = "openapi-spec-validator";
    description = "Validate OpenAPI specifications.";
    package = tools.openapi-spec-validator;
    entry = "${config.package}/bin/openapi-spec-validator";
    files = "\.ya?ml$";
  };
}
