{ config, tools, lib, ... }:
{
  config = {
    package = tools.clang-tools;
    entry = "${config.package}/bin/clang-format -style=file -i";
    # Source:
    # https://github.com/pre-commit/mirrors-clang-format/blob/46516e8f532c8f2d55e801c34a740ebb8036365c/.pre-commit-hooks.yaml
    types_or = [
      "c"
      "c++"
      "c#"
      "cuda"
      "java"
      "javascript"
      "json"
      "objective-c"
      "proto"
    ];
  };
}
