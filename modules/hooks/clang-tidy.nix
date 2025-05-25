{ tools, lib, ... }:
{
  config = {
    name = "clang-tidy";
    description = "Static analyzer for C++ code.";
    package = tools.clang-tools;
    entry = "${tools.clang-tools}/bin/clang-tidy --fix";
    types_or = [ "c" "c++" "c#" "objective-c" ];
  };
}