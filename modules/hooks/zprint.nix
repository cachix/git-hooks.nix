{ tools, lib, config, ... }:
{
  config = {
    package = tools.zprint;
    entry = "${config.package}/bin/zprint '{:search-config? true}' -w";
    types_or = [ "clojure" "clojurescript" "edn" ];
  };
}
