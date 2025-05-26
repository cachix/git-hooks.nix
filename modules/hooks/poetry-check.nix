{ tools, lib, config, ... }:
{
  config = {
    name = "poetry check";
    description = "Check the validity of the pyproject.toml file.";
    package = tools.poetry;
    entry = "${config.package}/bin/poetry check";
    files = "^(poetry\\.lock$|pyproject\\.toml)$";
    pass_filenames = false;
  };
}
