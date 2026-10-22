from datetime import datetime, timezone
from pathlib import Path
from string import Template
from tempfile import TemporaryDirectory
import shutil
import subprocess
import sys


def main():
    root = Path(__file__).resolve().parents[1]
    source = root / "src/library.luau"
    example = root / "examples/basic.luau"
    missing = [path.relative_to(root) for path in (source, example) if not path.is_file()]
    if missing:
        raise SystemExit("Build unavailable; missing source: " + ", ".join(map(str, missing)))

    darklua = shutil.which("darklua")
    if darklua is None:
        raise SystemExit("Darklua is missing. Run mise install, then mise run build.")

    version_result = subprocess.run(
        [darklua, "--version"], capture_output=True, text=True, check=True
    )
    if version_result.stdout.strip() != "darklua 0.19.0":
        raise SystemExit("Darklua 0.19.0 is required. Run mise install, then mise run build.")

    header = Template((root / "build/header.luau").read_text(encoding="utf-8"))
    version = (root / "build/version.txt").read_text(encoding="utf-8").strip()
    build_date = datetime.now(timezone.utc).date().isoformat()
    builds = [
        (source, "library.luau", "readable", "readable"),
        (source, "library.compact.luau", "compact", "compact"),
        (example, "example.luau", "readable", "example"),
    ]

    with TemporaryDirectory(prefix=".esp-build-", dir=root) as temporary:
        staging = Path(temporary)
        for entry, filename, config, variant in builds:
            output = staging / filename
            subprocess.run(
                [darklua, "process", str(entry), str(output), "--config", f"build/{config}.json"],
                cwd=root,
                check=True,
            )
            generated_header = header.substitute(version=version, build=variant, date=build_date)
            output.write_text(
                generated_header + "\n" + output.read_text(encoding="utf-8"),
                encoding="utf-8",
                newline="\n",
            )

        dist = root / "dist"
        dist.mkdir(exist_ok=True)
        for _, filename, _, _ in builds:
            (staging / filename).replace(dist / filename)

    print("Built dist/library.luau, dist/library.compact.luau and dist/example.luau")


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"Build failed: {error}", file=sys.stderr)
        raise SystemExit(1)
