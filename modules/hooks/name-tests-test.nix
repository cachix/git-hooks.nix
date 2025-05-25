{ tools, lib, ... }:
{
  config = {
    name = "name-tests-test";
    description = "Verify Python test files are named correctly.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/name-tests-test";
    files = "(^|/)tests/.+\.py$";
  };
}