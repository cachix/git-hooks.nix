{ tools, lib, config, ... }:
{
  config = {
    name = "name-tests-test";
    description = "Verify that Python test files are named correctly.";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/tests_should_end_in_test.py";
    files = "(^|/)tests/\.+\\.py$";
  };
}
