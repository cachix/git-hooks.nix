{ lib, config, tools, mkCmdArgs, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    additionalPatterns =
      mkOption {
        type = types.listOf types.str;
        description = "Additional regex patterns used to find secrets. If there is a matching group in the regex the matched group will be tested for randomness before being reported as a secret.";
        default = [ ];
      };
  };

  config = {
    package = tools.ripsecrets;
    entry =
      let
        cmdArgs = mkCmdArgs (
          with config.settings; [
            [ true "--strict-ignore" ]
            [
              (additionalPatterns != [ ])
              "--additional-pattern ${lib.strings.concatStringsSep " --additional-pattern " additionalPatterns}"
            ]
          ]
        );
      in
      "${config.package}/bin/ripsecrets ${cmdArgs}";
    types = [ "text" ];
  };
}
