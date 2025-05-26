{ tools, lib, config, ... }:
{
  config = {
    package = tools.poetry;
    entry = "${config.package}/bin/poetry check";
    files = "^(poetry\\.lock$|pyproject\\.toml)$";
    pass_filenames = false;
  };
}
