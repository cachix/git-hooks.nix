{ tools, config, lib, migrateBinPathToPackage, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.settings = {
    binPath =
      mkOption {
        type = types.nullOr (types.oneOf [ types.str types.path ]);
        description = ''
          `eslint` binary path.
          For example, if you want to use the `eslint` binary from `node_modules`, use `"./node_modules/.bin/eslint"`.
          Use a string instead of a path to avoid having to Git track the file in projects that use Nix flakes.
        '';
        default = null;
        defaultText = lib.literalExpression ''
          "''${config.package}/bin/eslint"
        '';
        example = lib.literalExpression ''
          "./node_modules/.bin/eslint"
        '';
      };

    extensions =
      mkOption {
        type = types.str;
        description =
          "The pattern of files to run on, see [https://pre-commit.com/#hooks-files](https://pre-commit.com/#hooks-files).";
        default = "\\.js$";
      };
  };

  config = {
    name = "eslint";
    description = "Find and fix problems in your JavaScript code.";
    package = tools.eslint;
    entry =
      let
        binPath = migrateBinPathToPackage config "/bin/eslint";
      in
      "${binPath} --fix";
    files = "${config.settings.extensions}";
  };
}
