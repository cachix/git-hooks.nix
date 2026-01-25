# Seamless integration of [git hooks](https://pre-commit.com/) with [Nix](https://nixos.org/nix)

![pre-commit.png](pre-commit.png)

## Features

- **Trivial integration for Nix projects** (wires up a few things behind the scenes)

- Provide a low-overhead build of all the tooling available for the hooks to use
  (naive implementation of calling nix-shell does bring some latency when committing)

- **Common hooks for languages** like Python, Haskell, Elm, etc. [See all hook options](https://devenv.sh/?q=git-hooks.hooks)

- Run hooks **as part of development** and **during CI**

- Support for alternative `pre-commit` implementations, like [prek](https://github.com/j178/prek).

## Getting started

### devenv.sh

```nix
{ inputs, ... }:

{
  git-hooks.hooks = {
    # Format Nix code
    nixfmt.enable = true;

    # Format Python code
    black.enable = true;

    # Lint shell scripts
    shellcheck.enable = true;

    # Execute shell examples in Markdown files
    mdsh.enable = true;

    # Override a package with a different version
    ormolu.enable = true;
    ormolu.package = pkgs.haskellPackages.ormolu;

    # Some hooks have more than one package, like clippy:
    clippy.enable = true;
    clippy.packageOverrides.cargo = pkgs.cargo;
    clippy.packageOverrides.clippy = pkgs.clippy;
    # Some hooks provide settings
    clippy.settings.allFeatures = true;

    # Define your own custom hooks
    my-custom-hook = {
      name = "My own hook";
      exec = "on-pre-commit.sh";
    };
  };

  # Use alternative pre-commit implementations
  git-hooks.package = pkgs.prek;
}
```

See [getting started](https://devenv.sh/getting-started/).

## Flakes support

Given the following `flake.nix` example:

```nix
{
  description = "An example project";

  inputs = {
    systems.url = "github:nix-systems/default";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      ...
    }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      # Run the hooks with `nix fmt`.
      formatter = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          config = self.checks.${system}.pre-commit-check.config;
          inherit (config) package configFile;
          script = ''
            ${pkgs.lib.getExe package} run --all-files --config ${configFile}
          '';
        in
        pkgs.writeShellScriptBin "pre-commit-run" script
      );

      # Run the hooks in a sandbox with `nix flake check`.
      # Read-only filesystem and no internet access.
      checks = forEachSystem (system: {
        pre-commit-check = inputs.git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt.enable = true;
          };
        };
      });

      # Enter a development shell with `nix develop`.
      # The hooks will be installed automatically.
      # Or run pre-commit manually with `nix develop -c pre-commit run --all-files`
      devShells = forEachSystem (system: {
        default =
          let
            pkgs = nixpkgs.legacyPackages.${system};
            inherit (self.checks.${system}.pre-commit-check) shellHook enabledPackages;
          in
          pkgs.mkShell {
            inherit shellHook;
            buildInputs = enabledPackages;
          };
      });
    };
}
```

Add `/.pre-commit-config.yaml` to `.gitignore`.
This file is auto-generated from the Nix configuration and doesn't need to be committed.

Enter a development shell with pre-commit hooks enabled:

```shell
nix develop
```

Run all hooks sandboxed:

```shell
nix flake check
```

Keep in mind that `nix flake check` runs in a sandbox.
It doesn't have access to the internet and cannot modify files.
This makes it a poor choice for formatting hooks that attempt to fix files automatically, or hooks that cannot easily be packaged to avoid impure access to the internet.

A better alternative in such cases is to run `pre-commit` through `nix develop`:

```shell
nix develop -c pre-commit run -a
```

Or configure a `formatter` like in the example above and use `nix fmt`:

```shell
nix fmt
```

### flake-parts

If your flake uses [flake-parts](https://flake.parts/), we provide a flake-parts module as well. Checkout [`./template/flake.nix`](https://github.com/cachix/git-hooks.nix/blob/master/template/flake.nix) for an example.

## Nix

1. **Optionally** use binary caches to avoid compilation:

   ```sh
   nix-env -iA cachix -f https://cachix.org/api/v1/install
   cachix use pre-commit-hooks
   ```

1. Integrate hooks to be built as part of `default.nix`:

   ```nix
    let
      nix-pre-commit-hooks = import (builtins.fetchTarball "https://github.com/cachix/git-hooks.nix/tarball/master");
    in {
      # Configured with the module options defined in `modules/pre-commit.nix`:
      pre-commit-check = nix-pre-commit-hooks.run {
        src = ./.;
        # If your hooks are intrusive, avoid running on each commit with a default_states like this:
        # default_stages = ["manual" "pre-push"];
        hooks = {
          elm-format.enable = true;

          # override a package with a different version
          ormolu.enable = true;
          ormolu.package = pkgs.haskellPackages.ormolu;
          ormolu.settings.defaultExtensions = [ "lhs" "hs" ];

          # some hooks have more than one package, like clippy:
          clippy.enable = true;
          clippy.packageOverrides.cargo = pkgs.cargo;
          clippy.packageOverrides.clippy = tools.clippy;
          # some hooks provide settings
          clippy.settings.allFeatures = true;
        };
      };
    }
   ```

   Run `$ nix-build -A pre-commit-check` to perform the checks as a Nix derivation.

1. Integrate hooks to prepare environment as part of `shell.nix`:

   ```nix
    let
      pre-commit = import ./default.nix;
    in (import <nixpkgs> {}).mkShell {
      shellHook = ''
        ${pre-commit.pre-commit-check.shellHook}
      '';
      buildInputs = pre-commit.pre-commit-check.enabledPackages;
    }
   ```

   Add `/.pre-commit-config.yaml` to `.gitignore`.

   Run `$ nix-shell` to execute `shellHook` which will:

   - build the tools and `.pre-commit-config.yaml` config file symlink which
     references the binaries, for speed and safe garbage collection
   - provide the `pre-commit` executable that `git commit` will invoke

## Optional

### Direnv

`.envrc`:

```conf
use nix
```

## Hooks

### Ansible

- [ansible-lint](https://github.com/ansible/ansible-lint)

### C/C++/C#/ObjC

- [clang-format](https://clang.llvm.org/docs/ClangFormat.html).\
  You may restrict which languages should be formatted by `clang-format` using
  `clang-format.types_or`. For example to check only C and C++ files:

  ```nix
  clang-format = {
    enable = true;
    types_or = lib.mkForce [ "c" "c++" ];
  };
  ```

  Otherwise, the default internal list is used which includes everything that
  clang-format supports.

- [clang-tidy](https://clang.llvm.org/extra/clang-tidy/)
- [cmake-format](https://cmake-format.readthedocs.io/en/latest/)

### Clojure

- [cljfmt](https://github.com/weavejester/cljfmt)
- [zprint](https://github.com/kkinnear/zprint)

### Crystal

- [crystal](https://crystal-lang.org/reference/man/crystal#crystal-tool-format)

### CUE

- [cue-fmt](https://github.com/cue-lang/cue)

### Dart

- [dart analyze](https://dart.dev/tools/dart-analyze)
- [dart format](https://dart.dev/tools/dart-format)

### Dhall

- [dhall format](https://github.com/dhall-lang/dhall-lang)

### Dockerfile

- [hadolint](https://github.com/hadolint/hadolint)

### Editorconfig

- [eclint](https://github.com/jednano/eclint)
- [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker)

### Elm

- [elm-format](https://github.com/avh4/elm-format)
- [elm-review](https://github.com/jfmengels/elm-review)
- [elm-test](https://github.com/rtfeldman/node-test-runner)

### Elixir

- [credo](https://github.com/rrrene/credo)
- [dialyzer](https://github.com/jeremyjh/dialyxir)
- [mix-format](https://hexdocs.pm/mix/main/Mix.Tasks.Format.html)
- [mix-test](https://hexdocs.pm/mix/1.13/Mix.Tasks.Test.html)

### Fortran

- [fprettify](https://github.com/pseewald/fprettify)

### Git

- [annex](https://git-annex.branchable.com/)
- [check-merge-conflicts](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_merge_conflict.py)
- [commitizen](https://github.com/commitizen-tools/commitizen)
- [convco](https://github.com/convco/convco)
- [forbid-new-submodules](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/forbid_new_submodules.py)
- [gitlint](https://github.com/jorisroovers/gitlint)
- [gptcommit](https://github.com/zurawiki/gptcommit)
- [no-commit-to-branch](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/no_commit_to_branch.py)

### Golang

- gofmt: Runs `go fmt`
- [golangci-lint](https://golangci-lint.run/)
- [golines](https://github.com/segmentio/golines)
- gotest: Runs `go test`
- [govet](https://pkg.go.dev/cmd/vet)
- [revive](https://github.com/mgechev/revive)
- [staticcheck](https://github.com/dominikh/go-tools)

### Haskell

- [cabal-fmt](https://github.com/phadej/cabal-fmt)
- [cabal-gild](https://github.com/tfausak/cabal-gild)
- [cabal2nix](https://github.com/NixOS/cabal2nix)
- [fourmolu](https://github.com/parsonsmatt/fourmolu)
- [hindent](https://github.com/chrisdone/hindent)
- [hlint](https://github.com/ndmitchell/hlint)
- [hpack](https://github.com/sol/hpack)
- [ormolu](https://github.com/tweag/ormolu)
- [stylish-haskell](https://github.com/jaspervdj/stylish-haskell)

### HTML

- [html-tidy](https://github.com/htacg/tidy-html5)

### JavaScript/TypeScript

- [biome](https://biomejs.dev/)
- [denofmt](https://docs.deno.com/runtime/reference/cli/fmt/)
- [denolint](https://docs.deno.com/runtime/reference/cli/lint/)
- [eslint](https://github.com/eslint/eslint)
- rome: (alias to the biome hook)

### JSON

- [check-json](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_json.py)
- [pretty-format-json](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/pretty_format_json.py)

### Julia

- [JuiaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl)

### LaTeX

- [chktex](https://www.nongnu.org/chktex/)
- [lacheck](https://ctan.org/pkg/lacheck)
- [latexindent](https://github.com/cmhughes/latexindent.pl)

### Link checker

- [lychee](https://github.com/lycheeverse/lychee)
- [mkdocs-linkcheck](https://github.com/byrnereese/linkchecker-mkdocs)

### Lua

- [luacheck](https://github.com/mpeterv/luacheck)
- [lua-ls](https://github.com/LuaLS/lua-language-server)
- [selene](https://github.com/Kampfkarren/selene)
- [stylua](https://github.com/JohnnyMorganz/StyLua)

### Markdown

- [comrak](https://github.com/kivikakk/comrak)
- [markdownlint](https://github.com/DavidAnson/markdownlint)
- [mdformat](https://github.com/hukkin/mdformat)
- [mdl](https://github.com/markdownlint/markdownlint/)
- [mdsh](https://zimbatm.github.io/mdsh/)
- [rumdl](https://github.com/rvben/rumdl)

### Nix

- [alejandra](https://github.com/kamadorueda/alejandra)
- [deadnix](https://github.com/astro/deadnix)
- [flake-checker](https://github.com/DeterminateSystems/flake-checker)
- [nil](https://github.com/oxalica/nil)
- [nixf-diagnose](https://github.com/inclyc/nixf-diagnose)
- [nixfmt](https://github.com/NixOS/nixfmt/) (supports `nixfmt` >=v1.0)
- [nixfmt-classic](https://github.com/NixOS/nixfmt/tree/v0.6.0)
- [nixfmt-rfc-style](https://github.com/NixOS/nixfmt/)
- [nixpkgs-fmt](https://github.com/nix-community/nixpkgs-fmt)
- [statix](https://github.com/nerdypepper/statix)

### OCaml

- [dune-fmt](https://dune.build/)
- [dune-opam-sync](https://dune.build/)
- [ocp-indent](http://www.typerex.org/ocp-indent.html)
- [opam-lint](https://opam.ocaml.org/)

### PHP

- [phpcbf](https://github.com/squizlabs/PHP_CodeSniffer)
- [php-cs-fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer)
- [phpcs](https://github.com/squizlabs/PHP_CodeSniffer)
- [phpstan](https://github.com/phpstan/phpstan)
- [psalm](https://github.com/vimeo/psalm)

### Purescript

- [purs-tidy](https://github.com/natefaubion/purescript-tidy)

### Python

- [autoflake](https://github.com/PyCQA/autoflake)
- [black](https://github.com/psf/black)
- [check-builtin-literals](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_builtin_literals.py)
- [check-docstring-first](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_docstring_first.py)
- [check-python](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_ast.py)
- [fix-encoding-pragma](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/fix_encoding_pragma.py)
- [flake8](https://github.com/PyCQA/flake8)
- [flynt](https://github.com/ikamensh/flynt)
- [isort](https://github.com/PyCQA/isort)
- [mypy](https://github.com/python/mypy)
- [name-tests-test](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/tests_should_end_in_test.py)
- [poetry-check](https://python-poetry.org/docs/pre-commit-hooks): Run `poetry check`.
- [poetry-lock](https://python-poetry.org/docs/pre-commit-hooks): Run `poetry lock`.
- [pylint](https://github.com/PyCQA/pylint)
- [pyright](https://github.com/microsoft/pyright)
- [python-debug-statements](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/debug_statement_hook.py)
- [pyupgrade](https://github.com/asottile/pyupgrade)
- [ruff](https://github.com/charliermarsh/ruff)
- [ruff-format](https://github.com/charliermarsh/ruff)
- [single-quoted-strings](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/string_fixer.py)
- [sort-requirements-txt](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/requirements_txt_fixer.py)
- [uv](https://github.com/astral-sh/uv)

### Rego (Open Policy Agent)

- [regal](https://www.openpolicyagent.org/projects/regal)

### Rust

- [cargo-check](https://doc.rust-lang.org/cargo/commands/cargo-check.html)
- [clippy](https://github.com/rust-lang/rust-clippy)
- [rustfmt](https://github.com/rust-lang/rustfmt)

### Secret detection

- [pre-commit-ensure-sops](https://github.com/yuvipanda/pre-commit-hook-ensure-sops)
- [ripsecrets](https://github.com/sirwart/ripsecrets)
- [trufflehog](https://github.com/trufflesecurity/trufflehog): Secret scanner

### Shell

- [bats](https://github.com/bats-core/bats-core)
- [beautysh](https://github.com/lovesegfault/beautysh)
- [shellcheck](https://github.com/koalaman/shellcheck)
- [shfmt](https://github.com/mvdan/sh)

### Spell checker

- [cspell](https://cspell.org/)
- [hunspell](https://github.com/hunspell/hunspell)
- [proselint](https://github.com/amperser/proselint)
- [typos](https://github.com/crate-ci/typos)
- [vale](https://github.com/errata-ai/vale)

### Terraform

- `terraform-format`: built-in formatter (using
  [OpenTofu](https://opentofu.org/)'s
  [`fmt`](https://opentofu.org/docs/cli/commands/fmt/) or
  [Terraform](https://developer.hashicorp.com/terraform)'s
  [`fmt`](https://developer.hashicorp.com/terraform/cli/commands/fmt))
- `terraform-validate`: built-in validator (using
  [OpenTofu](https://opentofu.org/)'s
  [`validate`](https://opentofu.org/docs/cli/commands/validate/)
  [Terraform](https://developer.hashicorp.com/terraform)'s
  [`validate`](https://developer.hashicorp.com/terraform/cli/commands/validate))
- [tflint](https://github.com/terraform-linters/tflint)

### TOML

- [check-toml](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_toml.py)
- [taplo fmt](https://github.com/tamasfe/taplo)

### Typst

- [typstyle](https://github.com/Enter-tainer/typstyle)

### YAML

- [check-yaml](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_yaml.py)
- [sort-simple-yaml](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/sort_simple_yaml.py)
- [yamlfmt](https://github.com/google/yamlfmt)
- [yamllint](https://github.com/adrienverge/yamllint)

### Various other hooks

- [actionlint](https://github.com/rhysd/actionlint)
- [action-validator](https://github.com/mpalmer/action-validator)
- [chart-testing](https://github.com/helm/chart-testing)
- [check-added-large-files](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_added_large_files.py)
- [check-case-conflicts](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_case_conflict.py)
- [check-executables-have-shebangs](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_executables_have_shebangs.py)
- [checkmake](https://github.com/mrtazz/checkmake)
- [check-shebang-scripts-are-executable](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_shebang_scripts_are_executable.py)
- [check-symlinks](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_symlinks.py)
- [check-vcs-permalinks](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_vcs_permalinks.py)
- [check-xml](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/check_xml.py)
- [circleci](https://circleci.com/)
- [conform](https://github.com/edmundhung/conform)
- [detect-aws-credentials](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/detect_aws_credentials.py)
- [detect-private-keys](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/detect_private_key.py)
- [end-of-file-fixer](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/end_of_file_fixer.py)
- [fix-byte-order-marker](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/fix_byte_order_marker.py)
- [headache](https://github.com/frama-c/headache)
- [hledger-fmt](https://github.com/mondeja/hledger-fmt)
- [keep-sorted](https://github.com/google/keep-sorted)
- [mixed-line-endings](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/mixed_line_ending.py)
- [mkdocs-linkcheck](https://github.com/byrnereese/linkchecker-mkdocs)
- [openapi-spec-validator](https://github.com/python-openapi/openapi-spec-validator)
- [prettier](https://prettier.io)
- [reuse](https://github.com/fsfe/reuse-tool)
- [sort-file-contents](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/file_contents_sorter.py)
- [tagref](https://github.com/stepchowfun/tagref)
- [topiary](https://github.com/tweag/topiary)
- [treefmt](https://github.com/numtide/treefmt)
- [trim-trailing-whitespace](https://github.com/pre-commit/pre-commit-hooks/blob/main/pre_commit_hooks/trailing_whitespace_fixer.py)
- [woodpecker-cli-lint](https://woodpecker-ci.org/docs/cli#lint)
- [zizmor](https://github.com/zizmorcore/zizmor)

### Custom hooks

Sometimes it is useful to add a project specific command as an extra check that
is not part of the pre-defined set of hooks provided by this project.

Example configuration:

```nix
 let
   nix-pre-commit-hooks = import (builtins.fetchTarball "https://github.com/cachix/git-hooks.nix/tarball/master");
 in {
   pre-commit-check = nix-pre-commit-hooks.run {
     hooks = {
       # ...

       # Example custom hook for a C project using Make:
       unit-tests = {
         enable = true;

         # The name of the hook (appears on the report table):
         name = "Unit tests";

         # The command to execute (mandatory):
         entry = "make check";

         # The pattern of files to run on (default: "" (all))
         # see also https://pre-commit.com/#hooks-files
         files = "\\.(c|h)$";

         # List of file types to run on (default: [ "file" ] (all files))
         # see also https://pre-commit.com/#filtering-files-with-types
         # You probably only need to specify one of `files` or `types`:
         types = [ "text" "c" ];

         # Exclude files that were matched by these patterns (default: [ ] (none)):
         excludes = [ "irrelevant\\.c" ];

         # The language of the hook - tells pre-commit
         # how to install the hook (default: "system")
         # see also https://pre-commit.com/#supported-languages
         language = "system";

         # Set this to false to not pass the changed files
         # to the command (default: true):
         pass_filenames = false;

         # Which git hooks the command should run for (default: [ "pre-commit" ]):
         stages = ["pre-push"];
       };
     };
   };
 }
```

Custom hooks are defined with the same schema as [pre-defined
hooks](modules/pre-commit.nix).

## Contributing hooks

Everyone is encouraged to add new hooks.

<!-- TODO generate option docs -->

Have a look at the [existing hooks](modules/hooks.nix) and the [options](modules/pre-commit.nix).

There's no guarantee the hook will be accepted, but the general guidelines are:

- Nix closure of the tool should be small e.g. `< 50MB`. A problematic example:

```sh
  $ du -sh $(nix-build -A go)
  463M  /nix/store/v4ys4lrjngf62lvvrdbs7r9kbxh9nqaa-go-1.18.6
```

- The tool must not be very specific (e.g. language tooling is OK, but project specific tooling is not)
- The tool needs to live in a separate repository (even if a simple bash script, unless it's a oneliner)
