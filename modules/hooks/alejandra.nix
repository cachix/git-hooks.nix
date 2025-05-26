{ tools, config, lib, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    check =
      mkOption {
        type = types.bool;
        description = "Check if the input is already formatted and disable writing in-place the modified content";
        default = false;
        example = true;
      };
    exclude =
      mkOption {
        type = types.listOf types.str;
        description = "Files or directories to exclude from formatting.";
        default = [ ];
        example = [ "flake.nix" "./templates" ];
      };
    threads =
      mkOption {
        type = types.nullOr types.int;
        description = "Number of formatting threads to spawn.";
        default = null;
        example = 8;
      };
    verbosity =
      mkOption {
        type = types.enum [ "normal" "quiet" "silent" ];
        description = "Whether informational messages or all messages should be hidden or not.";
        default = "normal";
        example = "quiet";
      };
  };

  config = {
    package = tools.alejandra;
    entry =
      let
        cmdArgs =
          mkCmdArgs (with config.settings; [
            [ check "--check" ]
            [ (exclude != [ ]) "--exclude ${lib.strings.concatStringsSep " --exclude " (map lib.escapeShellArg (lib.unique exclude))}" ]
            [ (verbosity == "quiet") "-q" ]
            [ (verbosity == "silent") "-qq" ]
            [ (threads != null) "--threads ${toString threads}" ]
          ]);
      in
      "${config.package}/bin/alejandra ${cmdArgs}";
    files = "\\.nix$";
  };
}
