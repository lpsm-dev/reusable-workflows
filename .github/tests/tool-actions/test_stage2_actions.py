"""Observable behavior of the tool-specific stage-two action scripts."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[3]


class ActionScriptTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.workspace = self.root / "workspace"
        self.workspace.mkdir()
        self.calls = self.root / "calls.json"
        self.tool = self.root / "fake-tool"
        self.tool.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, sys\n"
            "with open(os.environ['CALLS_FILE'], 'w') as out: json.dump(sys.argv[1:], out)\n"
            "sys.exit(int(os.environ.get('FAKE_EXIT', '0')))\n"
        )
        self.tool.chmod(0o755)

    def git_add(self) -> None:
        subprocess.run(["git", "init", "-q"], cwd=self.workspace, check=True)
        subprocess.run(["git", "add", "-A"], cwd=self.workspace, check=True)

    def invoke(self, name: str, **overrides: str) -> subprocess.CompletedProcess[str]:
        env = dict(os.environ)
        env.update(
            GITHUB_WORKSPACE=str(self.workspace),
            RUNNER_OS="Linux",
            RUNNER_ARCH="X64",
            TARGET=".",
            CALLS_FILE=str(self.calls),
        )
        env.update(overrides)
        return subprocess.run(
            ["bash", str(ROOT / "actions" / name / "check.sh"), str(self.tool)],
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def arguments(self) -> list[str]:
        return json.loads(self.calls.read_text())

    def test_shellcheck_scans_tracked_shell_files_including_shebangs(self) -> None:
        (self.workspace / "good.sh").write_text("#!/bin/bash\necho ok\n")
        (self.workspace / "runner").write_text("#!/usr/bin/env bash\necho ok\n")
        (self.workspace / "portable").write_text("#!/usr/bin/env -S sh\necho ok\n")
        (self.workspace / "README.md").write_text("Hello\n")
        self.git_add()
        result = self.invoke("shellcheck-check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            set(self.arguments()[3:]),
            {
                str((self.workspace / "good.sh").resolve()),
                str((self.workspace / "runner").resolve()),
                str((self.workspace / "portable").resolve()),
            },
        )

    def test_shellcheck_rejects_missing_files_and_outside_paths(self) -> None:
        self.git_add()
        result = self.invoke("shellcheck-check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No Shell scripts", result.stderr)
        outside = self.root / "outside.sh"
        outside.write_text("#!/bin/sh\n")
        result = self.invoke("shellcheck-check", TARGET=str(outside))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GITHUB_WORKSPACE", result.stderr)
        (self.workspace / "escape.sh").symlink_to(outside)
        result = self.invoke("shellcheck-check", TARGET="escape.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GITHUB_WORKSPACE", result.stderr)

    def test_shellcheck_propagates_findings_and_rejects_other_platforms(self) -> None:
        (self.workspace / "good.sh").write_text("#!/bin/bash\necho ok\n")
        self.git_add()
        result = self.invoke("shellcheck-check", FAKE_EXIT="1")
        self.assertEqual(result.returncode, 1)
        self.calls.unlink()
        result = self.invoke("shellcheck-check", RUNNER_OS="macOS")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls.exists())

    def test_hadolint_scans_tracked_dockerfiles(self) -> None:
        (self.workspace / "Dockerfile").write_text("FROM scratch\n")
        (self.workspace / "Dockerfile.dev").write_text("FROM scratch\n")
        (self.workspace / "ordinary.yaml").write_text("key: value\n")
        self.git_add()
        result = self.invoke("hadolint-check")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            set(self.arguments()),
            {str((self.workspace / "Dockerfile").resolve()), str((self.workspace / "Dockerfile.dev").resolve())},
        )

    def test_hadolint_requires_applicable_files_inside_workspace(self) -> None:
        self.git_add()
        result = self.invoke("hadolint-check")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No Dockerfiles", result.stderr)
        outside = self.root / "Dockerfile"
        outside.write_text("FROM scratch\n")
        result = self.invoke("hadolint-check", TARGET=str(outside))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GITHUB_WORKSPACE", result.stderr)

    def test_hadolint_propagates_findings_and_platform_error(self) -> None:
        (self.workspace / "Dockerfile").write_text("FROM scratch\n")
        self.git_add()
        result = self.invoke("hadolint-check", FAKE_EXIT="1")
        self.assertEqual(result.returncode, 1)
        self.calls.unlink()
        result = self.invoke("hadolint-check", RUNNER_ARCH="ARM64")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.calls.exists())

    def test_kubeconform_validates_rendered_yaml_with_pinned_version_and_local_schema(self) -> None:
        manifests = self.workspace / "rendered"
        manifests.mkdir()
        manifest = manifests / "deployment.yaml"
        manifest.write_text("apiVersion: v1\nkind: Pod\n")
        schema = self.workspace / "schemas"
        schema.mkdir()
        result = self.invoke(
            "kubeconform-validate",
            TARGET="rendered",
            KUBERNETES_VERSION="1.29.0",
            SCHEMA_PATH="schemas",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        args = self.arguments()
        self.assertEqual(args[:4], ["-strict", "-summary", "-kubernetes-version", "1.29.0"])
        self.assertIn(str(schema.resolve()), args)
        self.assertIn(str(manifest.resolve()), args)

    def test_kubeconform_rejects_missing_yaml_version_and_outside_schema(self) -> None:
        manifests = self.workspace / "rendered"
        manifests.mkdir()
        result = self.invoke("kubeconform-validate", TARGET="rendered", KUBERNETES_VERSION="1.29.0")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No YAML manifests", result.stderr)
        manifest = manifests / "deployment.yaml"
        manifest.write_text("apiVersion: v1\nkind: Pod\n")
        result = self.invoke("kubeconform-validate", TARGET="rendered", KUBERNETES_VERSION="")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("kubernetes-version", result.stderr)
        outside = self.root / "schemas"
        outside.mkdir()
        result = self.invoke(
            "kubeconform-validate", TARGET="rendered", KUBERNETES_VERSION="1.29.0", SCHEMA_PATH=str(outside)
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("GITHUB_WORKSPACE", result.stderr)

    def test_kubeconform_propagates_validator_failure(self) -> None:
        manifest = self.workspace / "deployment.yaml"
        manifest.write_text("apiVersion: v1\nkind: Pod\n")
        result = self.invoke(
            "kubeconform-validate", TARGET="deployment.yaml", KUBERNETES_VERSION="1.29.0", FAKE_EXIT="1"
        )
        self.assertEqual(result.returncode, 1)


if __name__ == "__main__":
    unittest.main()
