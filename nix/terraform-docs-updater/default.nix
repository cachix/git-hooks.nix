{ lib, terraform-docs, stdenv, makeWrapper }:

stdenv.mkDerivation {
  name = "terraform-docs-updater";
  src = lib.cleanSource ../../src/terraform-docs-updater;
  nativeBuildInputs = [ makeWrapper ];
  buildPhase = ":";
  installPhase =
    ''
      mkdir -p $out/bin
      install -m 0555 $src/terraform-docs-updater $out/bin
      wrapProgram $out/bin/terraform-docs-updater \
        --prefix PATH : ${lib.makeBinPath [ terraform-docs ]}
    '';
}
