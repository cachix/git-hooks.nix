/*
  This module is picked up by project.nix but is also used internally
  to find these imported modules.
 */
{
  imports =
    [
      ../modules/all-modules.nix
    ];

  # TODO: move project.nix/modules/pre-commit.nix here
}
