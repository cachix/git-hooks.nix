{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binary =
      mkOption {
        type = types.bool;
        description = "Whether to search binary files.";
        default = false;
      };
    color =
      mkOption {
        type = types.enum [ "auto" "always" "never" ];
        description = "When to use generate output.";
        default = "auto";
      };
    configuration =
      mkOption {
        type = types.str;
        description = "Multiline-string configuration passed as config file. If set, config set in `typos.settings.configPath` gets ignored.";
        default = "";
        example = ''
          [files]
          ignore-dot = true

          [default]
          binary = false

          [type.py]
          extend-glob = []
        '';
      };

    configPath =
      mkOption {
        type = types.str;
        description = "Path to a custom config file.";
        default = "";
        example = ".typos.toml";
      };

    diff =
      mkOption {
        type = types.bool;
        description = "Print a diff of what would change.";
        default = false;
      };

    exclude =
      mkOption {
        type = types.str;
        description = "Ignore files and directories matching the glob.";
        default = "";
        example = "*.nix";
      };

    format =
      mkOption {
        type = types.enum [ "silent" "brief" "long" "json" ];
        description = "Output format to use.";
        default = "long";
      };

    hidden =
      mkOption {
        type = types.bool;
        description = "Search hidden files and directories.";
        default = false;
      };

    ignored-words =
      mkOption {
        type = types.listOf types.str;
        description = "Spellings and words to ignore.";
        default = [ ];
        example = [
          "MQTT"
          "mosquitto"
        ];
      };

    locale =
      mkOption {
        type = types.enum [ "en" "en-us" "en-gb" "en-ca" "en-au" ];
        description = "Which language to use for spell checking.";
        default = "en";
      };

    no-check-filenames =
      mkOption {
        type = types.bool;
        description = "Skip verifying spelling in file names.";
        default = false;
      };

    no-check-files =
      mkOption {
        type = types.bool;
        description = "Skip verifying spelling in files.";
        default = false;
      };

    no-unicode =
      mkOption {
        type = types.bool;
        description = "Only allow ASCII characters in identifiers.";
        default = false;
      };

    quiet =
      mkOption {
        type = types.bool;
        description = "Less output per occurrence.";
        default = false;
      };

    verbose =
      mkOption {
        type = types.bool;
        description = "More output per occurrence.";
        default = false;
      };

    write =
      mkOption {
        type = types.bool;
        description = "Fix spelling in files by writing them. Cannot be used with `typos.settings.diff`.";
        default = false;
      };
  };
}
