{ tools, lib, ... }:
{
  config = {
    name = "poetry-check";
    description = "Check the validity of the pyproject.toml file.";
    package = tools.poetry;
    entry = "${tools.poetry}/bin/poetry check";
    files = "pyproject\.toml$";
    pass_filenames = false;
  };
}