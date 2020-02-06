{ config, lib, pkgs, ... }:
let
  inherit (config.pre-commit) tools settings;
  inherit (lib) mkOption types;
in
{
  options.pre-commit.settings =
    {
      ormolu =
        {
          defaultExtensions =
            mkOption {
              type = types.listOf types.str;
              description = "Haskell language extensions to enable";
              default = [];
            };
        };
    };

  config.pre-commit.hooks =
    {
      ansible-lint =
        {
          name = "ansible-lint";
          description =
            "Ansible linter";
          entry = "${tools.ansible-lint}/bin/ansible-lint";
        };
      hlint =
        {
          name = "hlint";
          description =
            "HLint gives suggestions on how to improve your source code.";
          entry = "${tools.hlint}/bin/hlint";
          files = "\\.l?hs$";
        };
      ormolu =
        {
          name = "ormolu";
          description = "Haskell code prettifier.";
          entry =
            "${tools.ormolu}/bin/ormolu --mode inplace ${
            lib.escapeShellArgs (lib.concatMap (ext: [ "--ghc-opt" "-X${ext}" ]) settings.ormolu.defaultExtensions)
            }";
          files = "\\.l?hs$";
        };
      hindent =
        {
          name = "hindent";
          description = "Haskell code prettifier.";
          entry = "${tools.hindent}/bin/hindent";
          files = "\\.l?hs$";
        };
      cabal-fmt =
        {
          name = "cabal-fmt";
          description = "Format Cabal files";
          entry = "${tools.cabal-fmt}/bin/cabal-fmt --inplace";
          files = "\\.cabal$";
        };
      nixfmt =
        {
          name = "nixfmt";
          description = "Nix code prettifier.";
          entry = "${tools.nixfmt}/bin/nixfmt";
          files = "\\.nix$";
        };
      nixpkgs-fmt =
        {
          name = "nixpkgs-fmt";
          description = "Nix code prettifier.";
          entry = "${tools.nixpkgs-fmt}/bin/nixpkgs-fmt";
          files = "\\.nix$";
        };
      elm-format =
        {
          name = "elm-format";
          description = "Format Elm files";
          entry =
            "${tools.elm-format}/bin/elm-format --yes --elm-version=0.19";
          files = "\\.elm$";
        };
      shellcheck =
        {
          name = "shellcheck";
          description = "Format shell files";
          types =
            [
              "bash"
            ];
          entry = "${tools.shellcheck}/bin/shellcheck";
        };
      terraform-format =
        {
          name = "terraform-format";
          description = "Format terraform (.tf) files";
          entry = "${tools.terraform-fmt}/bin/terraform-fmt";
          files = "\\.tf$";
        };
      yamllint =
        {
          name = "yamllint";
          description = "Yaml linter";
          types = [ "file" "yaml" ];
          entry = "${tools.yamllint}/bin/yamllint";
        };
    };
}
