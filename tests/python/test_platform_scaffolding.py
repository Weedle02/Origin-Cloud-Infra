import yaml
from pathlib import Path


def test_platform_manifest_has_required_sections():
    manifest_path = Path(__file__).resolve().parents[2] / "platform" / "config" / "platform.yaml"
    assert manifest_path.exists(), "platform.yaml should exist for subscription factory"

    manifest = yaml.safe_load(manifest_path.read_text())
    for key in ("tenantId", "rootManagementGroupId", "managementGroups", "subscriptions"):
        assert key in manifest, f"Manifest missing required key: {key}"

    assert isinstance(manifest["managementGroups"], list)
    assert isinstance(manifest["subscriptions"], list)
