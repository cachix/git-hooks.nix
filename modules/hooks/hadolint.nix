{ config, tools, lib, ... }:
{
  config = {
    name = "hadolint";
    description = "Dockerfile linter, validate inline bash.";
    package = tools.hadolint;
    entry = "${config.package}/bin/hadolint";
    files = "Dockerfile$";
  };
}
