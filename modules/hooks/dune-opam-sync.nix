{ tools, lib, ... }:
{
  config = {
    name = "dune/opam sync";
    description = "Check that Dune-generated OPAM files are in sync.";
    package = tools.dune-build-opam-files;
    entry = "${tools.dune-build-opam-files}/bin/dune-build-opam-files";
    files = "(\.opam$)|(\.opam.template$)|((^|/)dune-project$)";
    ## We don't pass filenames because they can only be misleading. Indeed,
    ## we need to re-run `dune build` for every `*.opam` file, but also when
    ## the `dune-project` file has changed.
    pass_filenames = false;
  };
}