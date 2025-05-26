{ lib, config, tools, migrateBinPathToPackage, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  # See all CLI flags for prettier [here](https://prettier.io/docs/en/cli.html).
  # See all options for prettier [here](https://prettier.io/docs/en/options.html).
  options.settings = {
    binPath =
      mkOption {
        description = ''
          `prettier` binary path.
          For example, if you want to use the `prettier` binary from `node_modules`, use `"./node_modules/.bin/prettier"`.
          Use a string instead of a path to avoid having to Git track the file in projects that use Nix flakes.
        '';
        type = types.nullOr (types.oneOf [ types.str types.path ]);
        default = null;
        defaultText = lib.literalExpression ''
          "''${config.package}/bin/prettier"
        '';
        example = lib.literalExpression ''
          "./node_modules/.bin/prettier"
        '';
      };
    allow-parens =
      mkOption {
        description = "Include parentheses around a sole arrow function parameter.";
        default = "always";
        type = types.enum [ "always" "avoid" ];
      };
    bracket-same-line =
      mkOption {
        description = "Put > of opening tags on the last line instead of on a new line.";
        type = types.bool;
        default = false;
      };
    cache =
      mkOption {
        description = "Only format changed files.";
        type = types.bool;
        default = false;
      };
    cache-location =
      mkOption {
        description = "Path to the cache file location used by `--cache` flag.";
        type = types.str;
        default = "./node_modules/.cache/prettier/.prettier-cache";
      };
    cache-strategy =
      mkOption {
        description = "Strategy for the cache to use for detecting changed files.";
        type = types.nullOr (types.enum [ "metadata" "content" ]);
        default = null;
      };
    check =
      mkOption {
        description = "Output a human-friendly message and a list of unformatted files, if any.";
        type = types.bool;
        default = false;
      };
    list-different =
      mkOption {
        description = "Print the filenames of files that are different from Prettier formatting.";
        type = types.bool;
        default = true;
      };
    color =
      mkOption {
        description = "Colorize error messages.";
        type = types.bool;
        default = true;
      };
    configPath =
      mkOption {
        description = "Path to a Prettier configuration file (.prettierrc, package.json, prettier.config.js).";
        type = types.str;
        default = "";
      };
    config-precedence =
      mkOption {
        description = "Defines how config file should be evaluated in combination of CLI options.";
        type = types.enum [ "cli-override" "file-override" "prefer-file" ];
        default = "cli-override";
      };
    embedded-language-formatting =
      mkOption {
        description = "Control how Prettier formats quoted code embedded in the file.";
        type = types.enum [ "auto" "off" ];
        default = "auto";
      };
    end-of-line =
      mkOption {
        description = "Which end of line characters to apply.";
        type = types.enum [ "lf" "crlf" "cr" "auto" ];
        default = "lf";
      };
    html-whitespace-sensitivity =
      mkOption {
        description = "How to handle whitespaces in HTML.";
        type = types.enum [ "css" "strict" "ignore" ];
        default = "css";
      };
    ignore-path =
      mkOption {
        description = "Path to a file containing patterns that describe files to ignore.
        By default, prettier looks for `./.gitignore` and `./.prettierignore`.
        Multiple values are accepted.";
        type = types.listOf (types.oneOf [ types.str types.path ]);
        default = [ ];
      };
    ignore-unknown =
      mkOption {
        description = "Ignore unknown files.";
        type = types.bool;
        default = true;
      };
    insert-pragma =
      mkOption {
        description = "Insert @format pragma into file's first docblock comment.";
        type = types.bool;
        default = false;
      };
    jsx-single-quote =
      mkOption {
        description = "Use single quotes in JSX.";
        type = types.bool;
        default = false;
      };
    log-level =
      mkOption {
        description = "What level of logs to report.";
        type = types.enum [ "silent" "error" "warn" "log" "debug" ];
        default = "log";
        example = "debug";
      };
    no-bracket-spacing =
      mkOption {
        description = "Do not print spaces between brackets.";
        type = types.bool;
        default = false;
      };
    no-config =
      mkOption {
        description = "Do not look for a configuration file.";
        type = types.bool;
        default = false;
      };
    no-editorconfig =
      mkOption {
        description = "Don't take .editorconfig into account when parsing configuration.";
        type = types.bool;
        default = false;
      };
    no-error-on-unmatched-pattern =
      mkOption {
        description = "Prevent errors when pattern is unmatched.";
        type = types.bool;
        default = false;
      };
    no-semi =
      mkOption {
        description = "Do not print semicolons, except at the beginning of lines which may need them.";
        type = types.bool;
        default = false;
      };
    parser =
      mkOption {
        description = "Which parser to use.";
        type = types.enum [ "" "flow" "babel" "babel-flow" "babel-ts" "typescript" "acorn" "espree" "meriyah" "css" "less" "scss" "json" "json5" "json-stringify" "graphql" "markdown" "mdx" "vue" "yaml" "glimmer" "html" "angular" "lwc" ];
        default = "";
      };
    print-width =
      mkOption {
        type = types.int;
        description = "Line length that the printer will wrap on.";
        default = 80;
      };
    prose-wrap =
      mkOption {
        description = "When to or if at all hard wrap prose to print width.";
        type = types.enum [ "always" "never" "preserve" ];
        default = "preserve";
      };
    plugins =
      mkOption {
        description = "Add plugins from paths.";
        type = types.listOf types.str;
        default = [ ];
      };
    quote-props =
      mkOption {
        description = "Change when properties in objects are quoted.";
        type = types.enum [ "as-needed" "consistent" "preserve" ];
        default = "as-needed";
      };
    require-pragma =
      mkOption {
        description = "Require either '@prettier' or '@format' to be present in the file's first docblock comment.";
        type = types.bool;
        default = false;
      };
    single-attribute-per-line =
      mkOption {
        description = "Enforce single attribute per line in HTML, Vue andJSX.";
        type = types.bool;
        default = false;
      };
    single-quote =
      mkOption {
        description = "Number of spaces per indentation-level.";
        type = types.bool;
        default = false;
      };
    tab-width =
      mkOption {
        description = "Line length that the printer will wrap on.";
        type = types.int;
        default = 2;
      };
    trailing-comma =
      mkOption {
        description = "Print trailing commas wherever possible in multi-line comma-separated syntactic structures.";
        type = types.enum [ "all" "es5" "none" ];
        default = "all";
      };
    use-tabs =
      mkOption {
        type = types.bool;
        description = "Indent with tabs instead of spaces.";
        default = false;
      };
    vue-indent-script-and-style =
      mkOption {
        description = "Indent script and style tags in Vue files.";
        type = types.bool;
        default = false;
      };
    with-node-modules =
      mkOption {
        type = types.bool;
        description = "Process files inside 'node_modules' directory.";
        default = false;
      };
    write =
      mkOption {
        description = "Edit files in-place.";
        type = types.bool;
        default = true;
      };
  };

  config = {
    types = [ "text" ];
    package = tools.prettier;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/prettier";
        cmdArgs =
          mkCmdArgs
            (with config.settings; [
              [ (allow-parens != "always") "--allow-parens ${allow-parens}" ]
              [ bracket-same-line "--bracket-same-line" ]
              [ cache "--cache" ]
              [ (cache-location != "./node_modules/.cache/prettier/.prettier-cache") "--cache-location ${cache-location}" ]
              [ (cache-strategy != null) "--cache-strategy ${cache-strategy}" ]
              [ check "--check" ]
              [ (!color) "--no-color" ]
              [ (configPath != "") "--config ${configPath}" ]
              [ (config-precedence != "cli-override") "--config-precedence ${config-precedence}" ]
              [ (embedded-language-formatting != "auto") "--embedded-language-formatting ${embedded-language-formatting}" ]
              [ (end-of-line != "lf") "--end-of-line ${end-of-line}" ]
              [ (html-whitespace-sensitivity != "css") "--html-whitespace-sensitivity ${html-whitespace-sensitivity}" ]
              [ (ignore-path != [ ]) "--ignore-path ${lib.escapeShellArgs ignore-path}" ]
              [ ignore-unknown "--ignore-unknown" ]
              [ insert-pragma "--insert-pragma" ]
              [ jsx-single-quote "--jsx-single-quote" ]
              [ list-different "--list-different" ]
              [ (log-level != "log") "--log-level ${log-level}" ]
              [ no-bracket-spacing "--no-bracket-spacing" ]
              [ no-config "--no-config" ]
              [ no-editorconfig "--no-editorconfig" ]
              [ no-error-on-unmatched-pattern "--no-error-on-unmatched-pattern" ]
              [ no-semi "--no-semi" ]
              [ (parser != "") "--parser ${parser}" ]
              [ (print-width != 80) "--print-width ${toString print-width}" ]
              [ (prose-wrap != "preserve") "--prose-wrap ${prose-wrap}" ]
              [ (plugins != [ ]) "--plugin ${lib.strings.concatStringsSep " --plugin " plugins}" ]
              [ (quote-props != "as-needed") "--quote-props ${quote-props}" ]
              [ require-pragma "--require-pragma" ]
              [ single-attribute-per-line "--single-attribute-per-line" ]
              [ single-quote "--single-quote" ]
              [ (tab-width != 2) "--tab-width ${toString tab-width}" ]
              [ (trailing-comma != "all") "--trailing-comma ${trailing-comma}" ]
              [ use-tabs "--use-tabs" ]
              [ vue-indent-script-and-style "--vue-indent-script-and-style" ]
              [ with-node-modules "--with-node-modules" ]
              [ write "--write" ]
            ]);
      in
      "${binPath} ${cmdArgs}";
  };
}
