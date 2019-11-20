# Changelog

All notable changes to this project will be documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and is a rolling release.

## 2019-11-06

### Changed

 - **BREAKING:** Add `/.pre-commit-config.yaml` to `/.gitignore`

 - Do not generate `.pre-commit-hooks` fake repo

## 2019-10-02

### Added

- The `run` derivation now uses [gitignore](https://github.com/hercules-ci/gitignore#readme)

- Custom hooks can now be added

### Changed

- Hooks configuration is now module-based (using the module system, like NixOS).
  `.pre-commit-config.yaml` is now obsolete with `nix-pre-commit-hooks`. Translate it to the `hooks` argument. For example:

  ```
  pre-commit-check = nix-pre-commit-hooks.run {
    src = ./.;
    hooks = {
      elm-format.enable = true;
      ormolu.enable = true;
      shellcheck.enable = true;
    };
  };
  ```

### Fixed

- Some small improvements to the installation script (`shellHook`)
