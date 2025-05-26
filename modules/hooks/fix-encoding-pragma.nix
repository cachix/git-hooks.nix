{ config, tools, lib, ... }:
{
  config = {
    name = "fix-encoding-pragma";
    description = "Adds # -*- coding: utf-8 -*- to the top of Python files.'";
    package = tools.pre-commit-hooks;
    entry = "${config.package}/bin/fix-encoding-pragma";
    types = [ "python" ];
  };
}
