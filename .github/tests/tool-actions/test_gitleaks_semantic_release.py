"""Behavior at the public script seams of the Gitleaks and release actions."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[3]


class ActionBehaviorTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.workspace = self.root / "workspace"
        self.workspace.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls.json"
        subprocess.run(["git", "init", "-q"], cwd=self.workspace, check=True)

    def commit(self) -> None:
        subprocess.run(["git", "add", "-A"], cwd=self.workspace, check=True)
        subprocess.run(
            ["git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-qm", "feat: fixture"],
            cwd=self.workspace,
            check=True,
        )

    def tool(self, name: str, body: str) -> Path:
        path = self.bin / name
        path.write_text("#!/usr/bin/env python3\n" + body)
        path.chmod(0o755)
        return path

    def invoke(self, action: str, tool: Path | None = None, **overrides: str) -> subprocess.CompletedProcess[str]:
        env = dict(os.environ)
        env.update(
            GITHUB_WORKSPACE=str(self.workspace),
            RUNNER_TEMP=str(self.root),
            RUNNER_OS="Linux",
            RUNNER_ARCH="X64",
            GITHUB_REF="refs/heads/main",
            GITHUB_TOKEN="fixture-token",
            CONFIG="",
            RELEASE_DIRECTORY=".github/config/release",
            RELEASE_BRANCH="main",
            DRY_RUN="false",
            CALLS_FILE=str(self.log),
            PATH=f"{self.bin}:{os.environ['PATH']}",
        )
        env.update(overrides)
        command = ["bash", str(ROOT / "actions" / action / "run.sh")]
        if tool is not None:
            command.append(str(tool))
        return subprocess.run(command, env=env, cwd=self.workspace, text=True, capture_output=True, check=False)

    def release_fixture(self) -> Path:
        directory = self.workspace / ".github/config/release"
        directory.mkdir(parents=True)
        for name in ("package.json", "package-lock.json", ".releaserc.json"):
            (directory / name).write_text("{}\n")
        executable = directory / "node_modules/.bin/semantic-release"
        executable.parent.mkdir(parents=True)
        executable.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, sys\n"
            "with open(os.environ['CALLS_FILE'], 'w') as stream:\n"
            "  json.dump({'args': sys.argv[1:], 'cwd': os.getcwd(), 'token': bool(os.environ.get('GITHUB_TOKEN'))}, stream)\n"
            "sys.exit(int(os.environ.get('TOOL_EXIT', '0')))\n"
        )
        executable.chmod(0o755)
        self.tool("npm", "import os, sys\nopen(os.environ['CALLS_FILE'] + '.npm', 'w').write(' '.join(sys.argv[1:]))\n")
        return directory

    def test_gitleaks_scans_only_committed_head_with_default_config(self) -> None:
        (self.workspace / "tracked.txt").write_text("committed\n")
        config = self.workspace / ".github/config/.gitleaks.toml"
        config.parent.mkdir(parents=True)
        config.write_text("title = 'fixture'\n")
        self.commit()
        (self.workspace / "untracked.txt").write_text("not committed\n")
        tool = self.tool(
            "gitleaks",
            "import json, os, pathlib, sys\n"
            "source = pathlib.Path(sys.argv[sys.argv.index('--source') + 1])\n"
            "json.dump({'args': sys.argv[1:], 'files': sorted(str(p.relative_to(source)) for p in source.rglob('*') if p.is_file())}, open(os.environ['CALLS_FILE'], 'w'))\n",
        )
        result = self.invoke("gitleaks-scan", tool)
        self.assertEqual(result.returncode, 0, result.stderr)
        call = json.loads(self.log.read_text())
        self.assertIn("--redact", call["args"])
        self.assertIn(str(config.resolve()), call["args"])
        self.assertIn("tracked.txt", call["files"])
        self.assertNotIn("untracked.txt", call["files"])

    def test_gitleaks_explicit_config_and_finding(self) -> None:
        (self.workspace / "tracked.txt").write_text("content\n")
        (self.workspace / "rules.toml").write_text("title = 'custom'\n")
        default = self.workspace / ".github/config/.gitleaks.toml"
        default.parent.mkdir(parents=True)
        default.write_text("title = 'default'\n")
        self.commit()
        tool = self.tool("gitleaks", "import os, sys\nopen(os.environ['CALLS_FILE'], 'w').write(' '.join(sys.argv[1:]))\nsys.exit(1)\n")
        result = self.invoke("gitleaks-scan", tool, CONFIG="rules.toml")
        self.assertEqual(result.returncode, 1)
        self.assertIn(str((self.workspace / "rules.toml").resolve()), self.log.read_text())
        self.assertNotIn(str(default.resolve()), self.log.read_text())

    def test_gitleaks_without_config_keeps_builtin_lookup(self) -> None:
        (self.workspace / "tracked.txt").write_text("content\n")
        (self.workspace / ".gitleaks.toml").write_text("title = 'root'\n")
        self.commit()
        tool = self.tool("gitleaks", "import os, sys\nopen(os.environ['CALLS_FILE'], 'w').write(' '.join(sys.argv[1:]))\n")
        result = self.invoke("gitleaks-scan", tool)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn("--config", self.log.read_text())

    def test_gitleaks_rejects_missing_outside_empty_and_unsupported_platform(self) -> None:
        (self.workspace / "tracked.txt").write_text("content\n")
        self.commit()
        tool = self.tool("gitleaks", "import os\nopen(os.environ['CALLS_FILE'], 'w').write('called')\n")
        for config in ("missing.toml", "../outside.toml", "/etc/passwd"):
            with self.subTest(config=config):
                result = self.invoke("gitleaks-scan", tool, CONFIG=config)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(self.log.exists())
        outside = self.root / "outside.toml"
        outside.write_text("title = 'outside'\n")
        (self.workspace / "link.toml").symlink_to(outside)
        result = self.invoke("gitleaks-scan", tool, CONFIG="link.toml")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())
        result = self.invoke("gitleaks-scan", tool, RUNNER_ARCH="ARM64")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())
        empty = self.root / "empty"
        empty.mkdir()
        subprocess.run(["git", "init", "-q"], cwd=empty, check=True)
        subprocess.run(["git", "-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "--allow-empty", "-qm", "feat: empty"], cwd=empty, check=True)
        result = self.invoke("gitleaks-scan", tool, GITHUB_WORKSPACE=str(empty))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no files", result.stderr.lower())

    def test_semantic_release_installs_lockfile_and_passes_dry_run(self) -> None:
        directory = self.release_fixture()
        result = self.invoke("semantic-release-run", DRY_RUN="true", GITHUB_REF="refs/pull/1/merge")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / "calls.json.npm").read_text(), "ci --ignore-scripts --no-audit --no-fund")
        call = json.loads(self.log.read_text())
        self.assertEqual(call, {"args": ["--dry-run"], "cwd": str(directory.resolve()), "token": True})

    def test_semantic_release_rejects_invalid_inputs_before_install(self) -> None:
        self.release_fixture()
        outside = self.root / "outside"
        outside.mkdir()
        (self.workspace / "release-link").symlink_to(outside, target_is_directory=True)
        for overrides, message in (
            ({"GITHUB_TOKEN": ""}, "GITHUB_TOKEN"),
            ({"DRY_RUN": "maybe"}, "dry-run"),
            ({"DRY_RUN": "false", "GITHUB_REF": "refs/heads/feature"}, "publishing is permitted"),
            ({"RELEASE_DIRECTORY": "../outside"}, "outside GITHUB_WORKSPACE"),
            ({"RELEASE_DIRECTORY": "/etc"}, "relative to GITHUB_WORKSPACE"),
            ({"RELEASE_DIRECTORY": "release-link"}, "outside GITHUB_WORKSPACE"),
            ({"RUNNER_OS": "macOS"}, "Linux x64"),
        ):
            with self.subTest(overrides=overrides):
                result = self.invoke("semantic-release-run", **overrides)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(message, result.stderr)
                self.assertFalse((self.root / "calls.json.npm").exists())

    def test_semantic_release_rejects_missing_lockfile_and_propagates_failure(self) -> None:
        directory = self.release_fixture()
        (directory / "package-lock.json").unlink()
        result = self.invoke("semantic-release-run")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("package-lock.json", result.stderr)
        outside = self.root / "outside-lock.json"
        outside.write_text("{}\n")
        (directory / "package-lock.json").symlink_to(outside)
        result = self.invoke("semantic-release-run")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("outside GITHUB_WORKSPACE", result.stderr)
        (directory / "package-lock.json").unlink()
        (directory / "package-lock.json").write_text("{}\n")
        result = self.invoke("semantic-release-run", TOOL_EXIT="2")
        self.assertEqual(result.returncode, 2)


if __name__ == "__main__":
    unittest.main()
