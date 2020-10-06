{ lib, ... }:
let
  inherit (lib) mapAttrs mergeDefinitions zipAttrsWith types;

  # Disallows mkIf, checks only before use.
  #
  # Design note:
  #
  # If using lib.optionalAttrs is not feasible (possibly because of
  # infinite recursions), the way forward is to extend lazyAttrsOf
  # with a default value for "missing" values.
  #
  # Alternatively, if the set of keys is unimportant, one can write
  # a variation of this type that hides the set of keys by always
  # applying (attrs: key: attrs.${key}) - so returning a function
  # from key to value. See types.coercedTo for how such postprocessing
  # can be done. This is merely encapsulation and not a real solution
  # to the problem which is fundamentally unsolvable as long as
  # checking mkIf requires evaluating the same thunk that forces the
  # option value.
  lazyAttrsOf =
    args@
    { elemType
    , default ? # ^ A default value in case an attribute was retroactively undefined
      #   by `mkIf false`.
      #   Default: an exception.

      # This default is only here to mark it as optional. We use defaultFunction instead.
      abort "No default provided for mkIf false in lazyAttrsOf"
    , defaultFunction ? # ^ Function to call when a value is missing due to mkIf false.
      #   Default: an exception.
      #
      #   Parameters:
      #     - option location (list of strings)
      #     - definitions for this option (list of { file : string })
      #     - name of the attribute
      if args?default
      then _loc: _defs: _n: args.default
      else defaultLazyAttrsOfDefaultFunction
    }:
    let
      ao = types.attrsOf elemType;
    in
    ao // {
      name = "lazyAttrsOf";
      description = "attribute set of lazily merged ${elemType.description}s";
      check = lib.isAttrs;

      # TODO: add v location to mkIf error message
      # TODO: allow specifying a default value in such cases
      merge = loc: defs:
        mapAttrs
          (
            n: v:
              let
                defFiles = lib.showFiles (map (def: def.file) defs);
              in
              builtins.addErrorContext
                "while evaluating the '${n}' attribute of ${lib.showOption loc} defined in ${defFiles}"
                v.value or (defaultFunction loc defs n)
          )
          (
            zipAttrsWith
              (
                name: defs:
                  (mergeDefinitions (loc ++ [ name ]) elemType defs).optionalValue // { inherit defs; }
              )
              # Push down position info.
              (
                map (def: mapAttrs (n: v: { inherit (def) file; value = v; }) def.value)
                  defs
              )
          );
    };

  defaultLazyAttrsOfDefaultFunction =
    loc: defs: n:
    let
      defFiles = lib.showFiles (map (def: def.file) defs);
    in
    throw ''
      A value is missing from a lazy attribute set.
        in option ${lib.showOption loc}
        defined in ${defFiles}

      Module users:
        Please use lib.optionalAttrs instead of mkIf when defining conditional values
        for lazyAttrsOf options.

        The purpose of a lazy attribute set option is to allow the set of keys to be
        determined without evaluating the values. This can only be done by ignoring
        any mkIfs until it's too late.

      Module authors:
        In some cases, this problem can be worked around by adding a default value,
        but do consider that the key set is going to be different for {} as opposed
        to { x = mkIf false y; }!
        Only add a default if you know that the set of attribute names is not used
        in any significant way.
    '';


  # TODO when upstreaming, add automated tests, with cases
  #   - without mkIf:
  #     - exception in value to test non-strictness (laziness)
  #     - normal case
  #   - with mkIf true
  #     - normal case
  #   - with mkIf false, no default
  #     - normal case
  #     - no exception if not used
  #     - exception if used
  #   - with mkIf false, with default
  #     - no exception
  #   - with invalid value according to elemType.check
  #     - exception when value is used

in
{
  inherit lazyAttrsOf;
}
