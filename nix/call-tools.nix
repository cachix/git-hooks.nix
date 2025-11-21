pkgs:
pkgs.lib.flip builtins.removeAttrs [ "override" "overrideDerivation" ] (
  pkgs.callPackage ./tools.nix {
    placeholder =
      name:
      let
        errorMsg = ''
          git-hooks: the package `${name}` is not available in your nixpkgs revision.
        '';
      in
      {
        # Allows checking without forcing evaluation
        meta.isPlaceholder = true;

        type = "derivation";
        name = name + "-placeholder";
        outPath = throw errorMsg;
        drvPath = throw errorMsg;
      };
  }
)
