{ tools, config, lib, mkCmdArgs, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    aggressive =
      mkOption {
        type = types.bool;
        description = "Include conversions with potentially changed behavior.";
        default = false;
      };
    binPath =
      mkOption {
        type = types.nullOr types.str;
        description = "flynt binary path. Can be used to specify the flynt binary from an existing Python environment.";
        default = null;
      };
    dry-run =
      mkOption {
        type = types.bool;
        description = "Do not change files in-place and print diff instead.";
        default = false;
      };
    exclude =
      mkOption {
        type = types.listOf types.str;
        description = "Ignore files with given strings in their absolute path.";
        default = [ ];
      };
    fail-on-change =
      mkOption {
        type = types.bool;
        description = "Fail when diff is not empty (for linting purposes).";
        default = true;
      };
    line-length =
      mkOption {
        type = types.nullOr types.int;
        description = "Convert expressions spanning multiple lines, only if the resulting single line will fit into this line length limit.";
        default = null;
      };
    no-multiline =
      mkOption {
        type = types.bool;
        description = "Convert only single line expressions.";
        default = false;
      };
    quiet =
      mkOption {
        type = types.bool;
        description = "Run without output.";
        default = false;
      };
    string =
      mkOption {
        type = types.bool;
        description = "Interpret the input as a Python code snippet and print the converted version.";
        default = false;
      };
    transform-concats =
      mkOption {
        type = types.bool;
        description = "Replace string concatenations with f-strings.";
        default = false;
      };
    verbose =
      mkOption {
        type = types.bool;
        description = "Run with verbose output.";
        default = false;
      };
  };

  config = {
    package = tools.flynt;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/flynt";
        cmdArgs =
          mkCmdArgs (with config.settings; [
            [ aggressive "--aggressive" ]
            [ dry-run "--dry-run" ]
            [ (exclude != [ ]) "--exclude ${lib.escapeShellArgs exclude}" ]
            [ fail-on-change "--fail-on-change" ]
            [ (line-length != null) "--line-length ${toString line-length}" ]
            [ no-multiline "--no-multiline" ]
            [ quiet "--quiet" ]
            [ string "--string" ]
            [ transform-concats "--transform-concats" ]
            [ verbose "--verbose" ]
          ]);
      in
      "${binPath} ${cmdArgs}";
    types = [ "python" ];
  };
}
