{ lib, ... }:
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
}
