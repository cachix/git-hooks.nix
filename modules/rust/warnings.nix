{ config, lib, ... }:

let
  inherit (config.hooks) clippy;
in
lib.optional clippy.settings.allFeatures ''
  The option `allFeatures` of `clippy.settings` was renamed to `all-features`.
''
++ lib.optional clippy.settings.denyWarnings ''
  The option `denyWarnings` of `clippy.settings` is deprecated, use `deny = [ "warnings" ]`.
''

++ lib.optional (clippy.settings.extraArgs != "") ''
  The option `extraArgs` of `clippy.settings` was used.
  Perhaps `clippy.settings` already has these options implemented.
  Consider adding these options and upstreaming them otherwise.
''
