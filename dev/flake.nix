{
  description = "A very basic flake";

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
