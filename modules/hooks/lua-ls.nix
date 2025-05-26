{ config, lib, pkgs, tools, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    checklevel = mkOption {
      type = types.enum [ "Error" "Warning" "Information" "Hint" ];
      description =
        "The diagnostic check level";
      default = "Warning";
    };
    configuration = mkOption {
      type = types.attrs;
      description =
        "See https://github.com/LuaLS/lua-language-server/wiki/Configuration-File#luarcjson";
      default = { };
    };
  };

  config =
    let
      # .luarc.json has to be in a directory,
      # or lua-language-server will hang forever.
      luarc = pkgs.writeText ".luarc.json" (builtins.toJSON config.settings.configuration);
      luarc-dir = pkgs.stdenv.mkDerivation {
        name = "luarc";
        unpackPhase = "true";
        installPhase = ''
          mkdir $out
          cp ${luarc} $out/.luarc.json
        '';
      };
      script = pkgs.writeShellApplication {
        name = "lua-ls-lint";
        runtimeInputs = [ config.package pkgs.jq ];
        checkPhase = ""; # The default checkPhase depends on GHC
        text = ''
          set -e
          export logpath="$(mktemp -d)"
          lua-language-server --check $(realpath .) \
            --checklevel="${config.settings.checklevel}" \
            --configpath="${luarc-dir}/.luarc.json" \
            --logpath="$logpath"
          if [[ -f $logpath/check.json ]]; then
            echo "+++++++++++++++ lua-language-server diagnostics +++++++++++++++"
            cat $logpath/check.json
            diagnostic_count=$(jq 'length' $logpath/check.json)
            if [ "$diagnostic_count" -gt 0 ]; then
              exit 1
            fi
          fi
        '';
      };
    in
    {
      name = "lua-ls";
      description = "Uses the lua-language-server CLI to statically type-check and lint Lua code.";
      package = tools.lua-language-server;
      entry = "${script}/bin/lua-ls-lint";
      files = "\\.lua$";
      pass_filenames = false;
    };
}
