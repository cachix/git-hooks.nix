{
  description = "An internal test flake for git-hooks.nix";

  inputs = {
    git-hooks.url = "path:..";
  };

  outputs =
    { git-hooks
    , ...
    }:
    {
      inherit (git-hooks) legacyPackages checks;
    };
}
