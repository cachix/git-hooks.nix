pkgs:
pkgs.lib.flip builtins.removeAttrs [ "override" "overrideDerivation" ] (
  pkgs.callPackage ./tools.nix {
    placeholder = name: {
      # Allows checking without forcing evaluation
      meta.isPlaceholder = true;

      # Throw when the package is actually used
      outPath = throw ''
        git-hooks: the package `${name} is not available in your nixpkgs revision.
      '';

      type = "derivation";
      name = name + "placeholder";
    };
  }
)
