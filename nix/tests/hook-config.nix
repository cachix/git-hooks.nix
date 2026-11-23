{ runCommand, run, lib, pkgs }:
let
  eval = conf: (run ({ src = null; addGcRoot = false; } // conf)).config;

  fakePrek = pkgs.writeShellScriptBin "prek" "" // { pname = "prek"; };
  fakeOldPreCommit = pkgs.writeShellScriptBin "pre-commit" "" // { pname = "pre-commit"; version = "4.3.0"; };
  fakeNewPreCommit = pkgs.writeShellScriptBin "pre-commit" "" // { pname = "pre-commit"; version = "4.4.0"; };

  hookTests = {
    "pre-commit: no priority field when unset" = {
      conf.hooks.shellcheck.enable = true;
      hook = "shellcheck";
      check = raw: !(raw ? priority);
      expected = "'priority' absent from raw config";
    };

    "prek: no priority field when unset" = {
      conf = {
        package = fakePrek;
        hooks.shellcheck.enable = true;
      };
      hook = "shellcheck";
      check = raw: !(raw ? priority);
      expected = "'priority' absent from raw config";
    };

    "prek: priority field serialised when set" = {
      conf = {
        package = fakePrek;
        hooks.shellcheck = { enable = true; priority = 5; };
      };
      hook = "shellcheck";
      check = raw: raw ? priority && raw.priority == 5;
      expected = "priority = 5 in raw config";
    };

    "pre-commit < 4.4.0: language defaults to system" = {
      conf = {
        package = fakeOldPreCommit;
        hooks.shellcheck.enable = true;
      };
      hook = "shellcheck";
      check = raw: raw.language == "system";
      expected = "language = system";
    };

    "pre-commit >= 4.4.0: language defaults to unsupported" = {
      conf = {
        package = fakeNewPreCommit;
        hooks.shellcheck.enable = true;
      };
      hook = "shellcheck";
      check = raw: raw.language == "unsupported";
      expected = "language = unsupported";
    };

    "prek: language defaults to system" = {
      conf = {
        package = fakePrek;
        hooks.shellcheck.enable = true;
      };
      hook = "shellcheck";
      check = raw: raw.language == "system";
      expected = "language = system";
    };
  };

  assertionTests = {
    "pre-commit: setting priority triggers assertion" = {
      conf.hooks.shellcheck = { enable = true; priority = 5; };
      check = assertions: lib.any (a: !a.assertion) assertions;
      expected = "failed assertion about priority requiring prek";
    };

    "prek: setting priority passes assertions" = {
      conf = {
        package = fakePrek;
        hooks.shellcheck = { enable = true; priority = 5; };
      };
      check = assertions: lib.all (a: a.assertion) assertions;
      expected = "all assertions pass";
    };
  };

  runHookTest = name: { conf, hook, check, expected }:
    let raw = (eval conf).hooks.${hook}.raw;
    in lib.optionalString (!(check raw)) ''
      echo "FAILED: ${name}"
      echo "  expected: ${expected}"
      echo "  raw config: ${builtins.toJSON raw}"
      exit 1
    '';

  runAssertionTest = name: { conf, check, expected }:
    let assertions = (eval conf).assertions;
    in lib.optionalString (!(check assertions)) ''
      echo "FAILED: ${name}"
      echo "  expected: ${expected}"
      exit 1
    '';
in
runCommand "hook-config-test" { } (
  ''
    set -e
  '' +
  lib.concatStrings (lib.mapAttrsToList runHookTest hookTests) +
  lib.concatStrings (lib.mapAttrsToList runAssertionTest assertionTests) +
  ''
    ${lib.optionalString (!lib.isDerivation (run { src = null; addGcRoot = false; }).formatter) "echo 'FAILED: res.formatter is not a derivation'; exit 1"}
    ${lib.optionalString (!lib.isDerivation (eval { }).formatter) "echo 'FAILED: (eval {}).formatter is not a derivation'; exit 1"}
    ${lib.optionalString (!lib.isDerivation (eval { hooks.nixpkgs-fmt = { enable = true; formatter = false; }; }).formatter) "echo 'FAILED: (eval { hooks.nixpkgs-fmt.formatter = false; }).formatter is not a derivation'; exit 1"}
    ${lib.optionalString (!lib.isDerivation (eval { hooks.nixpkgs-fmt = { enable = true; formatter = false; }; }).formatterConfigFile) "echo 'FAILED: (eval { hooks.nixpkgs-fmt.formatter = false; }).formatterConfigFile is not a derivation'; exit 1"}
    ${
      let
        conf = eval {
          hooks.nixpkgs-fmt = { enable = true; formatter = false; };
          hooks.shfmt = { enable = true; };
        };
        hooksInFormatter = (builtins.elemAt conf.formatterRawConfig.repos 0).hooks;
        hasShfmt = lib.any (h: h.id == "shfmt") hooksInFormatter;
        hasNixpkgsFmt = lib.any (h: h.id == "nixpkgs-fmt") hooksInFormatter;
      in
      lib.optionalString (!hasShfmt || hasNixpkgsFmt) "echo 'FAILED: formatterRawConfig should include shfmt and exclude nixpkgs-fmt'; exit 1"
    }
    ${
      let
        conf = eval {
          hooks.nixpkgs-fmt = { enable = true; };
        };
        hooksInFormatter = (builtins.elemAt conf.formatterRawConfig.repos 0).hooks;
        hasNixpkgsFmt = lib.any (h: h.id == "nixpkgs-fmt") hooksInFormatter;
      in
      lib.optionalString (!hasNixpkgsFmt) "echo 'FAILED: formatterRawConfig should include nixpkgs-fmt by default'; exit 1"
    }
    echo "All hook config tests passed" > $out
  ''
)
