/*
  This module is picked up by project.nix but is also used internally
  to find these imported modules.
 */
{
  imports =
    [
      ../modules/pre-commit.nix
      ../modules/hooks.nix
    ];
}
