{ config, tools, lib, ... }:
{
  config = {
    package = tools.clang-tools;
    entry = "${config.package}/bin/clang-tidy --fix";
    types_or = [ "c" "c++" "c#" "objective-c" ];
  };
}
