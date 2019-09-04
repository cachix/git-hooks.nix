# Seamless integration of [pre-commit](https://pre-commit.com/) git hooks with [Nix](https://nixos.org/nix)

[pre-commit](https://pre-commit.com/) manages a set of hooks that are executed by git before committing code:

![pre-commit.png](pre-commit.png)

The goal is to manage these hooks with Nix and solve the following:

- Simpler integration for Nix projects (wires up a few things behind the scenes)

- Provide a low-overhead build of all the tooling available for the hooks to use
   (naive implementation of calling nix-shell does bring some latency when committing)

- Common package set of hooks for popular languages like Haskell, Elm, etc.

- Two trivial Nix functions to run hooks as part of development and on your CI

# Installation & Usage

1. Create `.pre-commit-config.yaml` with hooks you want to run in your git repository:
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
      pre-commit-check = nix-pre-commit-hooks.run {
        src = gitignoreSource ./.;
      };
    }
   ```

   Run `$ nix-build -A pre-commit-check` to perform the checks as a Nix derivation.

2. Integrate hooks to prepare environment as part of `shell.nix`:
   ```nix
    (import <nixpkgs> {}).mkShell {
      inherit ((import ./. {}).pre-commit-check) shellHook;
    }
   ```

   Run `$ nix-shell` to execute `shellHook` which will:
   - install git hooks
   - symlink hooks to `.pre-commit-hooks/`
   - provide `pre-commit` executable that `git commit` will invoke

# Hooks

## Nix

- [canonix](https://github.com/hercules-ci/canonix/)
- [nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)
- [nixfmt](https://github.com/serokell/nixfmt/)

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
