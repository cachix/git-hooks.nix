#!/usr/bin/env python3
"""Compare hook evaluation and execution with plain Nix and local sources."""

import argparse
import json
import os
from pathlib import Path
import platform
import random
import statistics
import subprocess
import time


HERE = Path(__file__).resolve().parent
NIX_OPTIONS = [
    "--option", "experimental-features", "",
    "--option", "eval-cache", "false",
    "--eval-profiler", "disabled",
]


def positive(value):
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError("must be positive")
    return number


def source_path(value):
    path = Path(value).resolve()
    if not path.is_dir():
        raise argparse.ArgumentTypeError(f"not a directory: {path}")
    return path


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2) + "\n")


def revision(path):
    result = subprocess.run(
        ["git", "-C", str(path), "rev-parse", "--show-toplevel"],
        capture_output=True, text=True,
    )
    if result.returncode or Path(result.stdout.strip()).resolve() != path:
        return {"path": str(path), "revision": None}
    head = subprocess.check_output(
        ["git", "-C", str(path), "rev-parse", "HEAD"], text=True,
    ).strip()
    status = subprocess.check_output(
        ["git", "-C", str(path), "status", "--porcelain"], text=True,
    )
    return {"path": str(path), "revision": head, "dirty": bool(status)}


class Benchmark:
    def __init__(self, args):
        self.args = args
        self.out = args.output.resolve()
        # Refuse to overwrite samples or reuse old runtime repositories.
        self.out.mkdir(parents=True, exist_ok=False)
        self.backends = ["pre-commit", "prek"]
        if args.nixhooks:
            self.backends.append("nixhooks")
        self.env = dict(os.environ)
        for key in list(self.env):
            prefixes = ("GIT_", "PREK_", "PRE_COMMIT_", "NIX_SHOW_STATS")
            if key.startswith(prefixes):
                del self.env[key]
        self.env.update(
            GIT_CONFIG_GLOBAL=os.devnull,
            GIT_CONFIG_SYSTEM=os.devnull,
            GIT_CONFIG_NOSYSTEM="1",
            PRE_COMMIT_HOME=str(self.out / "pre-commit-cache"),
            PREK_HOME=str(self.out / "prek-cache"),
            TERM="dumb", NO_COLOR="1", NIX_COUNT_CALLS="0",
        )
        self.nix_args = [
            str(HERE / "runner.nix"), *NIX_OPTIONS,
            "--argstr", "nixpkgs", str(args.nixpkgs),
            "--argstr", "source", str(args.source),
        ]
        if args.nixhooks:
            self.nix_args += ["--argstr", "nixhooks", str(args.nixhooks)]
        self.results = []
        metadata = {
            "nix": subprocess.check_output(
                ["nix", "--version"], text=True,
            ).strip(),
            "platform": platform.platform(),
            "versions": json.loads(self.invoke([
                "nix-instantiate", "--eval", "--strict", "--json",
                *self.nix_args, "--argstr", "target", "versions",
            ]).stdout),
            "sources": {
                name: revision(path)
                for name, path in [
                    ("git-hooks", args.source), ("nixpkgs", args.nixpkgs),
                    ("nixhooks", args.nixhooks),
                ] if path
            },
            "arguments": {key: str(value) if isinstance(value, Path) else value
                          for key, value in vars(args).items()},
        }
        # Store paths identify immutable inputs even without .git metadata.
        write_json(self.out / "metadata.json", metadata)

    def invoke(self, cmd, cwd=None, check=True):
        result = subprocess.run(
            cmd, cwd=cwd, env=self.env, capture_output=True,
        )
        if check and result.returncode:
            raise RuntimeError(
                f"Command failed ({result.returncode}): {cmd!r}\n"
                + result.stdout.decode(errors="replace")
                + result.stderr.decode(errors="replace")
            )
        return result

    def save_result(self, result):
        self.results.append(result)
        write_json(self.out / "results.json", self.results)
        print(json.dumps(result), flush=True)

    def evaluate(self):
        for scenario in ["empty", "two"]:
            samples = {backend: [] for backend in self.backends}
            paths = {}
            for iteration in range(self.args.eval_samples + 1):
                offset = iteration % len(self.backends)
                order = self.backends[offset:] + self.backends[:offset]
                for backend in order:
                    stats = self.out / "current-stats.json"
                    stats.unlink(missing_ok=True)
                    env = dict(
                        self.env, NIX_SHOW_STATS="1",
                        NIX_SHOW_STATS_PATH=str(stats),
                    )
                    cmd = [
                        "nix-instantiate", "--eval", "--strict", "--json",
                        *self.nix_args, "--argstr", "backend", backend,
                        "--argstr", "scenario", scenario,
                    ]
                    start = time.perf_counter()
                    with (self.out / "eval.log").open("ab") as log:
                        data = subprocess.check_output(
                            cmd, stderr=log, env=env,
                        )
                    wall = time.perf_counter() - start
                    path = json.loads(data)
                    if backend in paths and paths[backend] != path:
                        raise RuntimeError("derivation changed across samples")
                    paths[backend] = path
                    if iteration:
                        sample = json.loads(stats.read_text())
                        sample["wallTime"] = wall
                        samples[backend].append(sample)
                print(f"evaluation {scenario}: round {iteration}", flush=True)
            write_json(self.out / f"eval-{scenario}-samples.json", samples)
            for backend, values in samples.items():
                cpu = [sample["cpuTime"] for sample in values]
                counts = {
                    (s["nrFunctionCalls"], s["nrThunks"]) for s in values
                }
                self.save_result({
                    "mode": "eval", "scenario": scenario,
                    "backend": backend, "samples": len(values),
                    "cpuMedian": statistics.median(cpu),
                    "cpuMin": min(cpu), "cpuMax": max(cpu),
                    "wallMedian": statistics.median(
                        s["wallTime"] for s in values
                    ),
                    "calls": values[0]["nrFunctionCalls"],
                    "thunks": values[0]["nrThunks"],
                    "countsStable": len(counts) == 1,
                    "drvPath": paths[backend],
                })

    def build(self, backend, target):
        cmd = [
            "nix-build", "--no-out-link", *self.nix_args,
            "--argstr", "backend", backend,
            "--argstr", "target", target,
        ]
        with (self.out / "build.log").open("ab") as log:
            return subprocess.check_output(
                cmd, stderr=log, env=self.env, text=True,
            ).strip()

    def fixture(self, name, count, staged=False):
        repo = self.out / name
        repo.mkdir()
        self.invoke(["git", "init", "-q"], repo)
        for key, value in [
            ("user.name", "Benchmark"),
            ("user.email", "benchmark@example.invalid"),
            ("commit.gpgsign", "false"),
            ("core.hooksPath", str(self.out / "no-hooks")),
        ]:
            self.invoke(["git", "config", key, value], repo)
        names = []
        for i in range(count // 2):
            for extension, contents in [
                ("nix", "{ }\n"),
                ("sh", "#!/usr/bin/env bash\necho hello\n"),
            ]:
                filename = f"example-{i:03}.{extension}"
                (repo / filename).write_text(contents)
                names.append(filename)
        self.invoke(["git", "add", "."], repo)
        self.invoke(["git", "commit", "-qm", "Fixture"], repo)
        if staged:
            for filename in names:
                with (repo / filename).open("a") as file:
                    file.write("# staged change\n")
            self.invoke(["git", "add", "."], repo)
        return repo, names

    def commands(self, backend, mode, names):
        if backend == "direct":
            return [
                [str(self.tools / "nixfmt"), "--check"]
                + [name for name in names if name.endswith(".nix")],
                [str(self.tools / "shellcheck")]
                + [name for name in names if name.endswith(".sh")],
            ]
        if mode == "all":
            target, exe = "run", "run-hooks"
        else:
            target = "staged"
            exe = "pre-commit-hook" if backend == "nixhooks" else "staged-hooks"
        return [[str(Path(self.paths[backend][target]) / "bin" / exe)]]

    def validate_failures(self):
        repo, names = self.fixture("failure-controls", 2)
        for filename, bad in [
            (names[0], "{x=1;}\n"),
            (names[1], "#!/usr/bin/env bash\necho $undefined\n"),
        ]:
            path = repo / filename
            original = path.read_text()
            path.write_text(bad)
            try:
                for backend in self.backends + ["direct"]:
                    results = [
                        self.invoke(cmd, repo, check=False)
                        for cmd in self.commands(backend, "all", names)
                    ]
                    if not any(result.returncode for result in results):
                        raise RuntimeError(f"{backend} missed {filename}")
                    log = self.out / f"failure-{filename}-{backend}.log"
                    log.write_bytes(b"".join(
                        r.stdout + r.stderr for r in results
                    ))
            finally:
                path.write_text(original)
        print("Both failure controls passed for every runner", flush=True)

    def state(self, repo):
        return (
            self.invoke(["git", "diff", "HEAD", "--binary"], repo).stdout,
            self.invoke(["git", "write-tree"], repo).stdout,
        )

    def runtime(self):
        self.paths = {
            backend: {target: self.build(backend, target)
                      for target in ["run", "staged"]}
            for backend in self.backends
        }
        tools = self.build("pre-commit", "tools")
        write_json(self.out / "paths.json", self.paths | {"tools": tools})
        self.tools = Path(tools) / "bin"
        self.env["PATH"] = str(self.tools) + os.pathsep + self.env["PATH"]
        self.validate_failures()
        for mode, count in [("all", 2), ("all", 40), ("all", 200),
                            ("staged", 40)]:
            repo, names = self.fixture(
                f"repo-{mode}-{count}", count, staged=mode == "staged",
            )
            before = self.state(repo)
            samples = {backend: [] for backend in self.backends + ["direct"]}
            for iteration in range(self.args.runtime_samples + 1):
                order = list(samples)
                random.Random(iteration).shuffle(order)
                for backend in order:
                    commands = self.commands(backend, mode, names)
                    start = time.perf_counter()
                    results = [self.invoke(cmd, repo) for cmd in commands]
                    elapsed = time.perf_counter() - start
                    if iteration:
                        samples[backend].append(elapsed)
                    else:
                        log = self.out / f"{mode}-{count}-{backend}-warmup.log"
                        log.write_bytes(b"".join(
                            r.stdout + r.stderr for r in results
                        ))
            if before != self.state(repo):
                raise RuntimeError("benchmark changed tracked files or index")
            write_json(self.out / f"{mode}-{count}-samples.json", samples)
            for backend, values in samples.items():
                self.save_result({
                    "mode": mode, "files": count, "backend": backend,
                    "samples": len(values),
                    "wallMedian": statistics.median(values),
                    "wallMin": min(values), "wallMax": max(values),
                })


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--nixpkgs", type=source_path, required=True)
    parser.add_argument(
        "--source", type=source_path, default=HERE.parent.parent,
    )
    parser.add_argument("--nixhooks", type=source_path)
    parser.add_argument("--output", type=Path, required=True,
                        help="new directory for samples, logs and fixtures")
    parser.add_argument("--mode", choices=["eval", "runtime", "all"],
                        default="eval")
    parser.add_argument("--eval-samples", type=positive, default=10)
    parser.add_argument("--runtime-samples", type=positive, default=20)
    args = parser.parse_args()
    if args.output.exists():
        parser.error("--output must name a new directory")
    bench = Benchmark(args)
    if args.mode in ("eval", "all"):
        bench.evaluate()
    if args.mode in ("runtime", "all"):
        bench.runtime()
    print(f"Results written to {bench.out / 'results.json'}")


if __name__ == "__main__":
    main()
