# Hook runner benchmarks

Compare git-hooks.nix with pre-commit and prek, optionally against
[nixhooks](https://tangled.org/poacher.dev/nixhooks). Measure Nix evaluation and
hook execution separately, using the same nixpkgs and tool commands.

Requirements: Nix 2.30 or newer, Python 3.9 or newer, Git, and a local nixpkgs
source directory containing `pre-commit`, `prek`, `nixfmt`, and `shellcheck`.
Evaluation needs no builds. Runtime benchmarks build the runners and tools first;
this may download dependencies or build missing packages. Builds are not timed.

## Run

Use a pinned nixpkgs checkout or an existing nixpkgs store source. For example:

```sh
git clone --filter=blob:none --no-checkout https://github.com/NixOS/nixpkgs \
  /tmp/benchmark-nixpkgs
git -C /tmp/benchmark-nixpkgs checkout ac6b2166e7a9375683b8e98f860f273222337b16

python3 dev/benchmarks/run.py \
  --nixpkgs /tmp/benchmark-nixpkgs \
  --output /tmp/hooks-evaluation
```

The default mode is evaluation only. To include execution and nixhooks:

```sh
git clone https://tangled.org/poacher.dev/nixhooks /tmp/benchmark-nixhooks
git -C /tmp/benchmark-nixhooks checkout 0a6e47a14e2a5f010017dbca358aa4260b6d1d74

python3 dev/benchmarks/run.py \
  --nixpkgs /tmp/benchmark-nixpkgs \
  --nixhooks /tmp/benchmark-nixhooks \
  --mode all \
  --output /tmp/hooks-comparison
```

`--mode runtime` runs execution benchmarks alone. `--source /path/to/git-hooks`
selects a different git-hooks.nix checkout. `--eval-samples` defaults to 10;
`--runtime-samples` defaults to 20. Each case also gets one unmeasured warmup.
Use a new output directory for each invocation. A quick smoke run can use one
sample per case; use the defaults or more for performance comparisons.

The tool invokes `nix-instantiate` and `nix-build` with flakes and the evaluation
cache disabled. It never uses `getFlake`. The runtime runs in disposable Git
repositories under the output directory, with separate pre-commit and prek
caches and global/system Git configuration disabled. It installs no hooks into
your checkout. Keep the output directory outside the source repositories.

## Results

The output directory contains:

- `metadata.json`: Nix/platform and tool versions, arguments, input paths, Git revisions
  and dirty status where available. Immutable store source paths identify inputs
  without Git metadata. Record their upstream revision separately if needed.
- `results.json`: medians, ranges, evaluator counts, and sample counts. Times are
  seconds. Results are updated after each completed case.
- `*-samples.json`: individual evaluation statistics and runtime wall times.
- `eval.log`, `build.log`, runtime warmup and failure-control logs.
- `paths.json`: realized runtime derivations, when execution was requested.
- Temporary Git repositories and runner caches, for inspection.

For example, with jq:

```sh
jq '.[] | {mode, scenario, files, backend, cpuMedian, wallMedian}' \
  /tmp/hooks-comparison/results.json
```

Run comparisons on an otherwise idle machine. Keep the Nix version, nixpkgs,
platform, and tool configuration fixed. User nixpkgs config and overlays are
ignored. This tool rotates evaluation order and
shuffles runtime order deterministically. Independent invocations for two
`--source` checkouts do not interleave their samples; repeat in reversed order
before interpreting small differences. This direct API benchmark does not
measure sharing between flake output groups.

## Evaluation method

Both empty and two-hook configurations are evaluated in fresh processes. The
endpoint is the derivation path of an executable all-files runner, forcing its
configuration and referenced packages. git-hooks.nix uses its module API with a
small shell wrapper; nixhooks uses its generated script. This measures usable
runners with different implementation costs and features, not identical module
systems or only configuration serialization.

`NIX_SHOW_STATS` records evaluator CPU time, aggregate function calls, and thunks.
Detailed call counting and the sampling profiler are disabled during timing.
`countsStable` reports whether aggregate counts matched across samples. Every
sample must produce the same derivation path for a given configuration.

Package evaluation can dominate the result. Empty-hook comparisons expose
framework and runner-package costs, but subtracting them from two-hook timings
is not an additive cost breakdown because dependencies are shared lazily.

## Runtime method and limits

All runners use identical absolute shellcheck and nixfmt executable paths,
`nixfmt --check`, extension filters, and serial hooks. git-hooks.nix overrides
file types to `file` and sets `require_serial`; nixhooks uses its default serial
mode. No prek priorities are set, preserving sequential hook order.

Fixtures contain 2, 40, or 200 tiny files, split equally between Nix and shell.
All-files runs check every tracked file. The staged case adds a staged comment
to all 40 files with no unstaged edits. pre-commit and prek use their staged
`run` command; nixhooks uses its generated pre-commit script. This excludes Git
commit orchestration and installed-hook launcher overhead. nixhooks creates
and reconciles a temporary worktree, so staging implementations differ.

The direct baseline invokes both tools sequentially with known filenames. It
excludes discovery, filtering, staging isolation, and framework checks. Treat
it as a lower bound on overhead, not equivalent functionality.

Every measured command must succeed. The tool checks that tracked contents and
the Git index remain unchanged, and separately verifies that every runner
rejects unformatted Nix and a shellcheck failure. Failure controls are untimed.
Warmup logs allow checking that both hooks ran.

These are warm-cache synthetic workloads. They do not measure cold starts,
downloads, builds, large real-world lint workloads, remote hooks, parallel
execution, partially staged files, or feature compatibility. A runner can win
all-files checks and lose staged checks. Compare both before drawing conclusions.

## Profile before optimizing

Nix 2.30 and newer provide a
[sampling evaluation profiler](https://nix.dev/manual/nix/2.34/advanced-topics/eval-profiler.html).
Profile the same endpoint separately from timing:

```sh
NIX_COUNT_CALLS=0 NIX_SHOW_STATS=0 \
  nix-instantiate --eval --strict --json dev/benchmarks/runner.nix \
  --option experimental-features '' --option eval-cache false \
  --argstr nixpkgs /tmp/benchmark-nixpkgs \
  --argstr source "$PWD" --argstr backend prek --argstr scenario two \
  --eval-profiler flamegraph --eval-profiler-frequency 999 \
  --eval-profile-file /tmp/hooks.folded > /dev/null

flamegraph.pl --countname samples /tmp/hooks.folded > /tmp/hooks.svg
```

`flamegraph.pl` is available from nixpkgs' `flamegraph` package. Change `backend`
to `pre-commit`, or to `nixhooks` with `--argstr nixhooks /tmp/benchmark-nixhooks`.
Warm up first and repeat with separate profile files to collect more samples.
The default frequency is 99 Hz; 999 Hz collects more samples in short runs.
Frequency 0 samples every function call and is not a time profile.

Flame graph widths include callees. A wide module-system frame may be forcing
package derivations rather than spending that time merging options. Profiling
adds overhead, so establish performance changes with the profiler disabled.
