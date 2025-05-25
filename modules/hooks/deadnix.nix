{ tools, config, lib, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    edit =
      mkOption {
        type = types.bool;
        description = "Remove unused code and write to source file.";
        default = false;
      };

    exclude =
      mkOption {
        type = types.listOf types.str;
        description = "Files to exclude from analysis.";
        default = [ ];
      };

    hidden =
      mkOption {
        type = types.bool;
        description = "Recurse into hidden subdirectories and process hidden .*.nix files.";
        default = false;
      };

    noLambdaArg =
      mkOption {
        type = types.bool;
        description = "Don't check lambda parameter arguments.";
        default = false;
      };

    noLambdaPatternNames =
      mkOption {
        type = types.bool;
        description = "Don't check lambda pattern names (don't break nixpkgs `callPackage`).";
        default = false;
      };

    noUnderscore =
      mkOption {
        type = types.bool;
        description = "Don't check any bindings that start with a `_`.";
        default = false;
      };

    quiet =
      mkOption {
        type = types.bool;
        description = "Don't print a dead code report.";
        default = false;
      };
  };

  config = {
    name = "deadnix";
    description = "Scan Nix files for dead code (unused variable bindings).";
    package = tools.deadnix;
    entry =
      let
        cmdArgs =
          mkCmdArgs (with config.settings; [
            [ noLambdaArg "--no-lambda-arg" ]
            [ noLambdaPatternNames "--no-lambda-pattern-names" ]
            [ noUnderscore "--no-underscore" ]
            [ quiet "--quiet" ]
            [ hidden "--hidden" ]
            [ edit "--edit" ]
            [ (exclude != [ ]) "--exclude ${lib.escapeShellArgs exclude}" ]
          ]);
      in
      "${tools.deadnix}/bin/deadnix ${cmdArgs} --fail";
    files = "\\.nix$";
  };
}
