{ tools, lib, config, ... }:
{
  config = {
    name = "zprint";
    description = "Beautifully format Clojure and Clojurescript source code and s-expressions.";
    package = tools.zprint;
    entry = "${config.package}/bin/zprint '{:search-config? true}' -w";
    types_or = [ "clojure" "clojurescript" "edn" ];
  };
}
