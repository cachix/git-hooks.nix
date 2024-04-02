{ lib }:
let inherit (lib) types;
  # according to https://pre-commit.com/#supported-git-hooks
  supportedHooks = [
    "commit-msg"
    "post-checkout"
    "post-commit"
    "post-merge"
    "post-rewrite"
    "pre-commit"
    "pre-merge-commit"
    "pre-push"
    "pre-rebase"
    "prepare-commit-msg"
    "manual"
  ];
in
{
  inherit supportedHooks;

  supportedHooksType =
    let
      deprecatedHooks = [
        "commit"
        "push"
        "merge-commit"
      ];
    in
    types.listOf (types.enum (supportedHooks ++ deprecatedHooks));
}
