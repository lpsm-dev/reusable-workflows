"""Behavior checks for the shared, verified binary installer."""

from __future__ import annotations

import hashlib
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[3]
INSTALL = ROOT / "actions/_lib/install-verified.sh"


class InstallVerifiedTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.runner_temp = self.root / "runner"
        self.runner_temp.mkdir()
        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        self.fake_asset = self.root / "asset.tar.gz"
        payload = self.root / "tool"
        payload.write_text("#!/bin/sh\necho ready\n")
        with tarfile.open(self.fake_asset, "w:gz") as archive:
            archive.add(payload, arcname="release/tool")
        fake_curl = self.bin_dir / "curl"
        fake_curl.write_text(
            "#!/bin/sh\n"
            "while [ \"$#\" -gt 0 ]; do\n"
            "  if [ \"$1\" = -o ]; then shift; cp \"$FAKE_ASSET\" \"$1\"; exit 0; fi\n"
            "  shift\n"
            "done\nexit 2\n"
        )
        fake_curl.chmod(0o755)

    def invoke(
        self,
        digest: str,
        *,
        url: str = "https://example.invalid/tool.tar.gz",
        dest: Path | None = None,
        asset_format: str = "tar.gz",
        member: str = "release/tool",
    ) -> subprocess.CompletedProcess[str]:
        env = dict(os.environ)
        env["PATH"] = f"{self.bin_dir}:{env['PATH']}"
        env["RUNNER_TEMP"] = str(self.runner_temp)
        env["FAKE_ASSET"] = str(self.fake_asset)
        target = dest or self.runner_temp / "installed/tool"
        return subprocess.run(
            ["bash", str(INSTALL), url, digest, asset_format, member, str(target)],
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_verified_archive_installs_executable_inside_runner_temp(self) -> None:
        digest = hashlib.sha256(self.fake_asset.read_bytes()).hexdigest()
        result = self.invoke(digest)
        target = self.runner_temp / "installed/tool"
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(target.read_text(), "#!/bin/sh\necho ready\n")
        self.assertTrue(os.access(target, os.X_OK))

    def test_bad_digest_does_not_install(self) -> None:
        result = self.invoke("0" * 64)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("SHA-256 verification failed", result.stderr)
        self.assertFalse((self.runner_temp / "installed/tool").exists())

    def test_raw_asset_is_installed_after_verification(self) -> None:
        self.fake_asset.write_text("#!/bin/sh\necho raw\n")
        digest = hashlib.sha256(self.fake_asset.read_bytes()).hexdigest()
        result = self.invoke(digest, asset_format="raw", member="")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.runner_temp / "installed/tool").read_text(), "#!/bin/sh\necho raw\n")

    def test_xz_archive_is_installed_after_verification(self) -> None:
        payload = self.root / "tool"
        with tarfile.open(self.fake_asset, "w:xz") as archive:
            archive.add(payload, arcname="release/tool")
        digest = hashlib.sha256(self.fake_asset.read_bytes()).hexdigest()
        result = self.invoke(digest, asset_format="tar.xz")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.runner_temp / "installed/tool").exists())

    def test_rejects_http_and_outside_destination(self) -> None:
        digest = hashlib.sha256(self.fake_asset.read_bytes()).hexdigest()
        for url, dest in (
            ("http://example.invalid/tool.tar.gz", self.runner_temp / "installed/tool"),
            ("https://example.invalid/tool.tar.gz", self.root / "outside/tool"),
        ):
            with self.subTest(url=url, dest=dest):
                result = self.invoke(digest, url=url, dest=dest)
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse(dest.exists())

    def test_rejects_destination_through_symlink(self) -> None:
        outside = self.root / "outside"
        outside.mkdir()
        (self.runner_temp / "link").symlink_to(outside, target_is_directory=True)
        digest = hashlib.sha256(self.fake_asset.read_bytes()).hexdigest()
        result = self.invoke(digest, dest=self.runner_temp / "link/tool")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((outside / "tool").exists())


if __name__ == "__main__":
    unittest.main()
