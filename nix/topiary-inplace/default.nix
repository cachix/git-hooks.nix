{ writeShellApplication, topiary }:

writeShellApplication {
  name = "topiary-inplace";
  text = ''
    for file; do
      ${topiary}/bin/topiary --in-place --input-file "$file"
    done
  '';
}
