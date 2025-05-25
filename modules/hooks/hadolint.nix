{ tools, lib, ... }:
{
  config = {
    name = "hadolint";
    description = "Dockerfile linter, validate inline bash.";
    package = tools.hadolint;
    entry = "${tools.hadolint}/bin/hadolint";
    files = "Dockerfile$";
  };
}