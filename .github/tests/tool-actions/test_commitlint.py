import os
import pathlib
import subprocess
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[3]
SCRIPT = ROOT / "actions/commitlint-check/run.sh"


class CommitlintBehaviorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.workspace = pathlib.Path(self.temp.name) / "repo"
        self.workspace.mkdir()
        self.tool = pathlib.Path(self.temp.name) / "commitlint"
        self.tool.write_text(
            '#!/usr/bin/env bash\n'
            'printf "%s\\n" "$*" > "$TEST_ARGS"\n'
            'cat > "$TEST_INPUT"\n'
            'exit "${TEST_EXIT:-0}"\n'
        )
        self.tool.chmod(0o755)
        self.args = pathlib.Path(self.temp.name) / "args"
        self.input = pathlib.Path(self.temp.name) / "input"
        subprocess.run(["git", "init", "-q", str(self.workspace)], check=True)
        subprocess.run(["git", "-C", str(self.workspace), "config", "user.name", "Test"], check=True)
        subprocess.run(["git", "-C", str(self.workspace), "config", "user.email", "test@example.invalid"], check=True)
        self.first = self.commit("feat: first")
        self.second = self.commit("fix: second")

    def commit(self, message):
        marker = self.workspace / "marker"
        marker.write_text(message)
        subprocess.run(["git", "-C", str(self.workspace), "add", "marker"], check=True)
        subprocess.run(["git", "-C", str(self.workspace), "commit", "-qm", message], check=True)
        return subprocess.check_output(
            ["git", "-C", str(self.workspace), "rev-parse", "HEAD"], text=True
        ).strip()

    def run_check(self, **overrides):
        env = os.environ.copy()
        env.update({
            "GITHUB_WORKSPACE": str(self.workspace),
            "GITHUB_ACTION_PATH": str(ROOT / "actions/commitlint-check"),
            "RUNNER_OS": "Linux",
            "RUNNER_ARCH": "X64",
            "COMMITLINT_BIN": str(self.tool),
            "TEST_ARGS": str(self.args),
            "TEST_INPUT": str(self.input),
            "INPUT_BASE_SHA": "",
            "INPUT_HEAD_SHA": "",
        })
        env.update(overrides)
        return subprocess.run(["bash", str(SCRIPT)], env=env, text=True, capture_output=True)

    def test_latest_commit(self):
        result = self.run_check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--strict", self.args.read_text())
        self.assertEqual(self.input.read_text().strip(), "fix: second")

    def test_range(self):
        result = self.run_check(INPUT_BASE_SHA=self.first, INPUT_HEAD_SHA=self.second)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"--from {self.first} --to {self.second}", self.args.read_text())

    def test_bad_sha_and_empty_range_fail(self):
        self.assertNotEqual(self.run_check(INPUT_BASE_SHA="abc", INPUT_HEAD_SHA=self.second).returncode, 0)
        self.assertNotEqual(self.run_check(INPUT_BASE_SHA=self.second, INPUT_HEAD_SHA=self.second).returncode, 0)
        self.assertNotEqual(self.run_check(INPUT_BASE_SHA=self.first).returncode, 0)

    def test_findings_fail(self):
        result = self.run_check(TEST_EXIT="3")
        self.assertEqual(result.returncode, 3)

    def test_platform_must_be_ubuntu_x64(self):
        result = self.run_check(RUNNER_OS="macOS")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Ubuntu", result.stderr)


if __name__ == "__main__":
    unittest.main()
