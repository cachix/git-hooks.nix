{ config, tools, lib, ... }:
{
  config = {
    package = tools.cljfmt;
    entry = "${config.package}/bin/cljfmt fix";
    types_or = [ "clojure" "clojurescript" "edn" ];
  };
}
