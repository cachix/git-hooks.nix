Seamless integration of [pre-commit](https://pre-commit.com/) hooks with [Nix](https://nixos.org/nix).

`pre-commit` is a project that manages a set of hooks that are executed by git before committing code.

It allows to always keep the code fresh from linting and formatting issues.

This project's goal is to manage these hooks with Nix and provide:

- Common set of hooks for popular languages like Haskell, Elm, etc.
- Nix function for installing and running your hook as a build (as part of your CI)
- Nix-shell integration to install and run your hooks as part of your development environment.

# Installation & Usage

1. Create `.pre-commit-config.yaml` with hooks you want to run:
   ```yaml
   repos:
   - repo: .pre-commit-hooks/
     rev: master
     hooks:
      -   id: ormolu
      -   id: shellcheck
      -   id: elm-format
   ```

2. (optional) Use binary caches to avoid compilation:

   ```bash
   $ nix-env -iA cachix -f https://cachix.org/api/v1/install
   $ cachix use hercules-ci
   ```

3. Integrate hooks to be built as part of `default.nix`:
   ```nix
    let
      inherit (import (builtins.fetchTarball "https://github.com/hercules-ci/gitignore/tarball/master" {})) gitignoreSource;
      nix-pre-commit-hooks = import (builtins.fetchTarball "https://github.com/hercules-ci/nix-pre-commit-hooks/tarball/master");
    in {
      pre-commit = nix-pre-commit-hooks.run {
        src = gitignoreSource ./.;
      };
    }
   ```

   Run `$ nix-build -A pre-commit`.

2. Integrate hooks to prepare environment as part of `shell.nix`:
   ```nix
    let
      pkgs = import <nixpkgs> {};
    in pkgs.stdenv.mkDerivation {
      shellHook = ''
        ${(import ./. {}).pre-commit.shellHook}
      '';
    }
   ```

   Run `$ nix-shell` to execute `shellHook` which will:
   - install git hooks
   - symlink hooks to `.pre-commit-hooks/`
   - provide `pre-commit` executable that `git commit` will invoke

# Hooks

## Nix

- [canonix](https://github.com/hercules-ci/canonix/)

## Haskell

- [ormolu](https://github.com/tweag/ormolu)
- [hlint](https://github.com/ndmitchell/hlint)
- [cabal-fmt](https://github.com/phadej/cabal-fmt)

## Elm

- [elm-format](https://github.com/avh4/elm-format)

## Shell

- [shellcheck](https://github.com/koalaman/shellcheck)

# Contributing hooks

Everyone is encouraged to add new hooks.

There's no guarantee the hook will be accepted, but the general guidelines are:

- Nix closure of the tool should be small e.g. `< 50MB`
- The tool must not be very specific (e.g. language tooling is OK, but project specific tooling is not)
