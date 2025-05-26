{ lib, tools, config, mkCmdArgs, ... }:
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

  config = {
    name = "typos";
    description = "Source code spell checker";
    package = tools.typos;
    entry =
      let
        # Concatenate config in config file with section for ignoring words generated from list of words to ignore
        configuration = "${config.settings.configuration}" + lib.strings.optionalString (config.settings.ignored-words != [ ]) "\n\[default.extend-words\]" + lib.strings.concatMapStrings (x: "\n${x} = \"${x}\"") config.settings.ignored-words;
        configFile = builtins.toFile "typos-config.toml" configuration;
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ binary "--binary" ]
              [ (color != "auto") "--color ${color}" ]
              [ (configuration != "") "--config ${configFile}" ]
              [ (configPath != "" && configuration == "") "--config ${configPath}" ]
              [ diff "--diff" ]
              [ (exclude != "") "--exclude ${exclude} --force-exclude" ]
              [ (format != "long") "--format ${format}" ]
              [ hidden "--hidden" ]
              [ (locale != "en") "--locale ${locale}" ]
              [ no-check-filenames "--no-check-filenames" ]
              [ no-check-files "--no-check-files" ]
              [ no-unicode "--no-unicode" ]
              [ quiet "--quiet" ]
              [ verbose "--verbose" ]
              [ (write && !diff) "--write-changes" ]
            ]);
      in
      "${config.package}/bin/typos ${cmdArgs}";
    types = [ "text" ];
  };
}
