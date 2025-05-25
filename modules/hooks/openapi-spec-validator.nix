{ tools, lib, ... }:
{
  config = {
    name = "openapi-spec-validator";
    description = "Validate OpenAPI specifications.";
    package = tools.openapi-spec-validator;
    entry = "${tools.openapi-spec-validator}/bin/openapi-spec-validator";
    files = "\.ya?ml$";
  };
}