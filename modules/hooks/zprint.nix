{ tools, lib, ... }:
{
  config = {
    name = "zprint";
    description = "Clojure/ClojureScript source code formatting.";
    package = tools.zprint;
    entry = "${tools.zprint}/bin/zprint '{:search-config? true}' -w";
    types_or = [ "clojure" "clojurescript" "edn" ];
  };
}