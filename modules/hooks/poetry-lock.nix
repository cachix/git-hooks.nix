{ tools, lib, ... }:
{
  config = {
    name = "poetry-lock";
    description = "Update the poetry.lock file.";
    package = tools.poetry;
    entry = "${tools.poetry}/bin/poetry lock";
    files = "pyproject\.toml$";
    pass_filenames = false;
  };
}