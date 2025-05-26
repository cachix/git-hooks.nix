{ tools, lib, config, ... }:
{
  config = {
    name = "poetry lock";
    description = "Update the poetry.lock file";
    package = tools.poetry;
    entry = "${config.package}/bin/poetry lock";
    files = "^(poetry\\.lock$|pyproject\\.toml)$";
    pass_filenames = false;
  };
}
