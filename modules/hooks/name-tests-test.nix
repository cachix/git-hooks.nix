{ tools, lib, config, ... }:
{
  config = {
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/tests_should_end_in_test.py";
    files = "(^|/)tests/\.+\\.py$";
  };
}
