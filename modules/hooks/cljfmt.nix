{ config, tools, lib, ... }:
{
  config = {
    name = "cljfmt";
    description = "A tool for formatting Clojure code.";
    package = tools.cljfmt;
    entry = "${config.package}/bin/cljfmt fix";
    types_or = [ "clojure" "clojurescript" "edn" ];
  };
}
