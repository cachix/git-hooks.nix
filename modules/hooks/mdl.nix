{ config, lib, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    configPath =
      mkOption {
        type = types.str;
        description = "The configuration file to use.";
        default = "";
      };
    git-recurse =
      mkOption {
        type = types.bool;
        description = "Only process files known to git when given a directory.";
        default = false;
      };
    ignore-front-matter =
      mkOption {
        type = types.bool;
        description = "Ignore YAML front matter.";
        default = false;
      };
    json =
      mkOption {
        type = types.bool;
        description = "Format output as JSON.";
        default = false;
      };
    rules =
      mkOption {
        type = types.listOf types.str;
        description = "Markdown rules to use for linting. Per default all rules are processed.";
        default = [ ];
      };
    rulesets =
      mkOption {
        type = types.listOf types.str;
        description = "Specify additional ruleset files to load.";
        default = [ ];
      };
    show-aliases =
      mkOption {
        type = types.bool;
        description = "Show rule alias instead of rule ID when viewing rules.";
        default = false;
      };
    warnings =
      mkOption {
        type = types.bool;
        description = "Show Kramdown warnings.";
        default = false;
      };
    skip-default-ruleset =
      mkOption {
        type = types.bool;
        description = "Do not load the default markdownlint ruleset. Use this option if you only want to load custom rulesets.";
        default = false;
      };
    style =
      mkOption {
        type = types.str;
        description = "Select which style mdl uses.";
        default = "default";
      };
    tags =
      mkOption {
        type = types.listOf types.str;
        description = "Markdown rules to use for linting containing the given tags. Per default all rules are processed.";
        default = [ ];
      };
    verbose =
      mkOption {
        type = types.bool;
        description = "Increase verbosity.";
        default = false;
      };
  };

  config = {
    name = "mdl";
    description = "A tool to check markdown files and flag style issues.";
    package = tools.mdl;
    entry =
      let
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ (configPath != "") "--config ${configPath}" ]
              [ git-recurse "--git-recurse" ]
              [ ignore-front-matter "--ignore-front-matter" ]
              [ json "--json" ]
              [ (rules != [ ]) "--rules ${lib.strings.concatStringsSep "," rules}" ]
              [ (rulesets != [ ]) "--rulesets ${lib.strings.concatStringsSep "," rulesets}" ]
              [ show-aliases "--show-aliases" ]
              [ warnings "--warnings" ]
              [ skip-default-ruleset "--skip-default-ruleset" ]
              [ (style != "") "--style ${style}" ]
              [ (tags != [ ]) "--tags ${lib.strings.concatStringsSep "," tags}" ]
              [ verbose "--verbose" ]
            ]);
      in
      "${config.package}/bin/mdl ${cmdArgs}";
    files = "\\.md$";
  };
}
