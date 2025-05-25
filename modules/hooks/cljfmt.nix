{ tools, lib, ... }:
{
  config = {
    name = "cljfmt";
    description = "A tool for formatting Clojure code.";
    package = tools.cljfmt;
    entry = "${tools.cljfmt}/bin/cljfmt fix";
    types_or = [ "clojure" "clojurescript" "edn" ];
  };
}