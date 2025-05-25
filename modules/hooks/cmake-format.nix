{ tools, config, lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath = mkOption {
      type = types.str;
      description = "Path to the configuration file (.json,.python,.yaml)";
      default = "";
      example = ".cmake-format.json";
    };
  };

  config = {
    name = "cmake-format";
    description = "A tool for formatting CMake-files.";
    package = tools.cmake-format;
    entry =
      let
        maybeConfigPath =
          if config.settings.configPath == ""
          # Searches automatically for the config path.
          then ""
          else "-C ${config.settings.configPath}";
      in
      "${tools.cmake-format}/bin/cmake-format --check ${maybeConfigPath}";
    files = "\\.cmake$|CMakeLists.txt";
  };
}
