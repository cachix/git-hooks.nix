{ config, lib, pkgs, ... }:

let
  inherit (builtins) attrValues removeAttrs;
  inherit (config) hooks tools;

  mkAdditionalArgs = args: lib.optionalString (args != "") " -- ${args}";
  toGNUCommandLineShell = lib.cli.toGNUCommandLineShell { };
in
{
  cargo-bench =
    {
      name = "cargo-bench";
      description = "Execute all benchmarks of a local package";
      package = tools.cargo;
      entry =
        let
          inherit (hooks.cargo-bench) package settings;
          benchArgs = toGNUCommandLineShell settings.bench-args;
          cargoArgs = toGNUCommandLineShell (removeAttrs settings [
            "bench-args"
          ]);
        in
        "${package}/bin/cargo bench ${cargoArgs}${mkAdditionalArgs benchArgs}";
      files = "\\.rs$";
      pass_filenames = false;
    };

  cargo-check =
    {
      name = "cargo-check";
      description = "Check the cargo package for errors";
      package = tools.cargo;
      entry =
        let
          inherit (hooks.cargo-check) package settings;
          cargoArgs = toGNUCommandLineShell settings;
        in
        "${package}/bin/cargo check ${cargoArgs}";
      files = "\\.rs$";
      pass_filenames = false;
    };

  cargo-doc =
    {
      name = "cargo-doc";
      description = "Build the documentation for the local package and all dependencies";
      package = tools.cargo;
      entry =
        let
          inherit (hooks.cargo-doc) package settings;
          cargoArgs = toGNUCommandLineShell settings;
        in
        "${package}/bin/cargo doc ${cargoArgs}";
      files = "\\.rs$";
      pass_filenames = false;
    };

  cargo-test =
    {
      name = "cargo-test";
      description = "Execute unit and integration tests of a cargo package";
      package = tools.cargo;
      entry =
        let
          inherit (hooks.cargo-test) package settings;
          cargoArgs = toGNUCommandLineShell (removeAttrs settings [
            "test-args"
          ]);
          testArgs = toGNUCommandLineShell settings.test-args;
        in
        "${package}/bin/cargo test ${cargoArgs}${mkAdditionalArgs testArgs}";
      files = "\\.rs$";
      pass_filenames = false;
    };

  clippy =
    let
      inherit (hooks.clippy) packageOverrides;
      wrapper = pkgs.symlinkJoin {
        name = "clippy-wrapped";
        paths = [ packageOverrides.clippy ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cargo-clippy \
            --prefix PATH : ${lib.makeBinPath [ packageOverrides.cargo ]}
        '';
      };
    in
    {
      name = "clippy";
      description = "Lint Rust code.";
      package = wrapper;
      packageOverrides = { inherit (tools) cargo clippy; };
      entry =
        let
          inherit (hooks.clippy) package settings;
          inherit (settings) extraArgs;
          cargoArgs = toGNUCommandLineShell (removeAttrs settings [
            "allFeatures"
            "allow"
            "deny"
            "denyWarnings"
            "extraArgs"
            "forbid"
            "no-deps"
            "warn"
          ]);
          clippyArgs = toGNUCommandLineShell {
            inherit (settings) allow deny forbid no-deps warn;
          };

          clippyArgs' = mkAdditionalArgs clippyArgs;
          extraArgs' = "${lib.optionalString (extraArgs != "") " "}${extraArgs}";
        in
        "${package}/bin/cargo-clippy clippy ${cargoArgs}${extraArgs'}${clippyArgs'}";
      files = "\\.rs$";
      pass_filenames = false;
    };

  rustfmt =
    let
      inherit (hooks.rustfmt) packageOverrides;
      wrapper = pkgs.symlinkJoin {
        name = "rustfmt-wrapped";
        paths = [ packageOverrides.rustfmt ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cargo-fmt \
          --prefix PATH : ${lib.makeBinPath (attrValues packageOverrides)}
        '';
      };
    in
    {
      name = "rustfmt";
      description = "Format Rust code.";
      package = wrapper;
      packageOverrides = { inherit (tools) cargo rustfmt; };
      entry =
        let
          inherit (hooks) rustfmt;
          inherit (rustfmt) settings;
          cargoArgs = toGNUCommandLineShell {
            inherit (settings) all package verbose;
          };
          rustfmtArgs = toGNUCommandLineShell {
            inherit (settings) check color config emit verbose;
          };
        in
        "${rustfmt.package}/bin/cargo-fmt fmt ${cargoArgs}${mkAdditionalArgs rustfmtArgs}";
      files = "\\.rs$";
      pass_filenames = false;
    };
}
