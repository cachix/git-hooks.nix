{ config, lib, ... }:

let
  cargoHooks = { inherit (config.hooks) cargo-bench cargo-check cargo-test clippy; };

  forAllCargoHooks = assertions:
    lib.mapAttrsToList
      (hook: { settings, ... }: assertions "${hook}.settings" settings)
      cargoHooks;
in
[ ]
++ forAllCargoHooks (hook: { profile ? null, release ? false, ... }: {
  assertion = release -> profile == null;
  message = "Options `${hook}.release` and `${hook}.profile` are mutually exclusive";
})
++ forAllCargoHooks (hook: { exclude ? [ ], workspace ? false, ... }: {
  assertion = exclude != [ ] -> workspace;
  message = "Option `${hook}.exclude` requires `${hook}.workspace == true`";
})
++ forAllCargoHooks (hook: { package ? [ ], workspace ? false, ... }: {
  assertion = package != [ ] -> workspace;
  message = "Option `${hook}.package` requires `${hook}.workspace == true`";
})
++ forAllCargoHooks (hook: { bench ? [ ], benches ? false, ... }: {
  assertion = benches -> bench == [ ];
  message = "Options `${hook}.bench` and `${hook}.benches` are mutually exclusive";
})
++ forAllCargoHooks (hook: { bin ? [ ], bins ? false, ... }: {
  assertion = bins -> bin == [ ];
  message = "Options `${hook}.bin` and `${hook}.bins` are mutually exclusive";
})
++ forAllCargoHooks (hook: { example ? [ ], examples ? false, ... }: {
  assertion = examples -> example == [ ];
  message = "Options `${hook}.example` and `${hook}.examples` are mutually exclusive";
})
++ forAllCargoHooks (hook: { test ? [ ], tests ? false, ... }: {
  assertion = tests -> test == [ ];
  message = "Options `${hook}.test` and `${hook}.tests` are mutually exclusive";
})
++ forAllCargoHooks (
  hook:
  { all-targets ? false
  , bench ? [ ]
  , benches ? false
  , bin ? [ ]
  , bins ? false
  , example ? [ ]
  , examples ? false
  , lib ? false
  , test ? [ ]
  , tests ? false
  , ...
  }: {
    assertion = all-targets -> (
      !lib
      && bench == [ ] && !benches
      && bin == [ ] && !bins
      && example == [ ] && !examples
      && test == [ ] && !tests
    );
    message = "The `${hook}.all-targets` option and other target options are mutually exclusive";
  }
)
++ forAllCargoHooks (hook: { all-features ? false, features ? [ ], ... }: {
  assertion = all-features -> features == [ ];
  message = "Options `${hook}.all-features` and `${hook}.features` are mutually exclusive";
})
++ forAllCargoHooks (hook: { all-features ? false, no-default-features ? false, ... }: {
  assertion = all-features -> !no-default-features;
  message = "Options `${hook}.all-features` and `${hook}.no-default-features` are mutually exclusive";
})
++ forAllCargoHooks (hook: { frozen ? false, locked ? false, ... }: {
  assertion = locked -> !frozen;
  message = "Options `${hook}.locked` and `${hook}.frozen` are mutually exclusive";
})
