{ tools, pre-commit, git, runCommand, writeText, writeScript }:

{ src
, hooks ? null
}:

let
  hooksYaml =
    writeText "pre-commit-hooks" ''
  -   id: hlint
      name: hlint
      description: HLint gives suggestions on how to improve your source code.
      entry: ${tools.hlint}/bin/hlint
      language: system
      files: '\.l?hs$'
  -   id: ormolu
      name: ormolu
      description: Haskell code prettifier.
      entry: ${tools.ormolu}/bin/ormolu --mode inplace
      language: script
      files: '\.l?hs$'
  -   id: cabal-fmt
      name: cabal-fmt
      description: Format Cabal files
      entry: ${tools.cabal-fmt}/bin/cabal-fmt --inplace 
      language: script
      files: '\.cabal$'
  -   id: canonix
      name: canonix
      description: Nix code prettifier.
      entry: ${tools.canonix}/bin/canonix
      language: system
      files: '\.nix$'
  -   id: nixfmt
      name: nixfmt
      description: Nix code prettifier.
      entry: ${tools.nixfmt}/bin/nixfmt
      language: script
      files: '\.nix$'
  -   id: nixpkgs-fmt
      name: nixpkgs-fmt
      description: Nix code prettifier.
      entry: ${tools.nixpkgs-fmt}/bin/nixpkgs-fmt -i
      language: script
      files: '\.nix$'
  -   id: elm-format
      name: elm-format
      description: Format Elm files
      entry: ${tools.elm-format}/bin/elm-format --yes --elm-version=0.19
      language: script
      files: \.elm$
  -   id: shellcheck
      name: shellcheck
      description: Format shell files
      types: [bash]
      entry: ${tools.shellcheck}/bin/shellcheck
      language: system
  '';

  hooks =
    runCommand "pre-commit-hooks-dir" { buildInputs = [ git ]; } ''
    HOME=$PWD
    mkdir -p $out
    ln -s ${hooksYaml} $out/.pre-commit-hooks.yaml
    cd $out
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    git init
    git add .
    git commit -m "init"
  '';

  run =
    runCommand "pre-commit-run" { buildInputs = [ git ]; } ''
    set +e
    HOME=$PWD
    cp --no-preserve=mode -R ${src} src
    unlink src/.pre-commit-hooks || true
    ln -fs ${hooks} src/.pre-commit-hooks
    cd src
    rm -rf src/.git
    git init
    git add .
    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
    git commit -m "init"
    echo "Running: $ pre-commit run --all-files"
    ${pre-commit}/bin/pre-commit run --all-files
    exitcode=$?
    git diff
    touch $out
    [ $? -eq 0 ] && exit $exitcode
  '';
in
  run // {
  shellHook = ''
    [ -L .pre-commit-hooks ] && unlink .pre-commit-hooks
    ln -s ${hooks} .pre-commit-hooks
    export PATH=$PATH:${pre-commit}/bin
    pre-commit install
    # this is needed as the hook repo configuration is cached
    pre-commit clean
  '';
}
