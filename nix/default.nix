{ system ? builtins.currentSystem
, nixpkgs
, gitignore-nix-src
, isFlakes ? false
,
}:
let
  overlay =
    self: pkgs:
    let
      inherit (pkgs) lib;
      tools = import ./call-tools.nix pkgs;
      run = pkgs.callPackage ./run.nix {
        inherit
          pkgs
          tools
          isFlakes
          gitignore-nix-src
          ;
      };

      removeInvalidPackage = removeInvalidPackageWith { };
      removeInvalidPackageQuiet = removeInvalidPackageWith { warn = false; };

      # Filter out broken and placeholder packages.
      removeInvalidPackageWith =
        { warn ? true
        ,
        }:
        name: package:
        let
          isPlaceholder = package.meta.isPlaceholder or false;
          isBroken = package.meta.broken or false;

          check = builtins.tryEval (!(isPlaceholder || isBroken));
          result = check.success && check.value;

          message =
            if !check.success then
              ''
                Skipping ${name} because it failed to evaluate.
              ''
            else if !check.value && isPlaceholder then
              ''
                Skipping ${name} because it is missing from this nixpkgs revision.
              ''
            else if !check.value && isBroken then
              ''
                Skipping ${name} because it is marked as broken.
              ''
            else
              ""; # Not used

        in
        if warn then lib.warnIfNot result message result else result;
    in
    {
      inherit tools run;

      # Flake-style attributes
      # Each should strictly be a valid derivation that evaluates.
      packages = (lib.filterAttrs removeInvalidPackageQuiet tools) // {
        inherit (pkgs) pre-commit;
      };

      checks = (lib.filterAttrs removeInvalidPackage tools) // {
        # A pre-commit-check for nix-pre-commit itself
        pre-commit-check = run {
          src = ../.;
          hooks = {
            nixpkgs-fmt.enable = true;
            typos.enable = true;
          };
        };
        installation-test = pkgs.callPackage ./installation-test.nix { inherit run; };
        all-tools-eval =
          let
            config = lib.evalModules {
              modules = [
                ../modules/all-modules.nix
                {
                  inherit tools;
                }
              ];
              specialArgs = { inherit pkgs; };
            };
            allHooks = config.config.hooks;

            getEntry = n: v: v.entry;
            getPackage =
              f: n: h:
              f n h.package;

            allEntryPoints = lib.pipe allHooks [
              (lib.filterAttrs (getPackage (removeInvalidPackageQuiet)))
              (lib.mapAttrsToList getEntry)
            ];
          in
          pkgs.runCommand "all-tools-eval"
            {
              inherit allEntryPoints;
            }
            ''
              touch $out
            '';
        doc-check =
          let
            # We might add that it keeps rendering fast and robust,
            # and we want to teach `defaultText` which is more broadly applicable,
            # but the message is long enough.
            failPkgAttr =
              name: _v:
              throw ''
                While generating documentation, we found that `pkgs` was used. To avoid rendering store paths in the documentation, this is forbidden.

                Usually when this happens, you need to add `defaultText` to an option declaration, or escape an example with `lib.literalExpression`.

                The `pkgs` attribute that was accessed is

                    pkgs.${lib.strings.escapeNixIdentifier name}

                If necessary, you can also find the offending option by evaluating with `--show-trace` and then look for occurrences of `option`.
              '';
            pkgsStub = lib.mapAttrs failPkgAttr pkgs;
            configuration = lib.evalModules {
              modules = [
                ../modules/all-modules.nix
                {
                  _file = "doc-check";
                  config = {
                    _module.args.pkgs = pkgsStub // {
                      _type = "pkgs";
                      inherit lib;
                      formats = lib.mapAttrs
                        (
                          formatName: formatFn: formatArgs:
                            let
                              result = formatFn formatArgs;
                              stubs = lib.mapAttrs
                                (
                                  name: _:
                                    throw "The attribute `(pkgs.formats.${lib.strings.escapeNixIdentifier formatName} x).${lib.strings.escapeNixIdentifier name}` is not supported during documentation generation. Please check with `--show-trace` to see which option leads to this `${lib.strings.escapeNixIdentifier name}` reference. Often it can be cut short with a `defaultText` argument to `lib.mkOption`, or by escaping an option `example` using `lib.literalExpression`."
                                )
                                result;
                            in
                            stubs
                              // {
                              inherit (result) type;
                            }
                        )
                        pkgs.formats;
                    };
                  };
                }
              ];
            };
            doc = pkgs.nixosOptionsDoc {
              inherit (configuration) options;
            };
          in
          doc.optionsCommonMark;
      };
    };
in
import nixpkgs {
  overlays = [ overlay ];
  # broken is needed for hindent to build
  config = {
    allowBroken = true;
  };
  inherit system;
}
