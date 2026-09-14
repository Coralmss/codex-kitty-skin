"""Offline release integrity checks; no install or network operations."""
from pathlib import Path, PurePosixPath
import hashlib, json, zipfile
root = Path(__file__).resolve().parent
lock = json.loads((root / 'bundle.json').read_text())
sha = lambda b: hashlib.sha256(b).hexdigest()
assert sha((root/'payload.zip').read_bytes()) == lock['payloadSha256'], 'payload checksum'
with zipfile.ZipFile(root/'payload.zip') as z:
    assert len(z.namelist()) == len(set(z.namelist())), 'duplicate entries'
    assert set(z.namelist()) == set(lock['files']), 'file inventory'
    for name in z.namelist():
        p = PurePosixPath(name)
        assert not p.is_absolute() and '..' not in p.parts, name
        assert (z.getinfo(name).external_attr >> 16) & 0o170000 != 0o120000, 'symlink'
        assert sha(z.read(name)) == lock['files'][name], name
    assert len(z.read('kitty-theme.zip')) == lock['themeBytes']
    assert sha(z.read('kitty-theme.zip')) == lock['themeSha256']
    pet = json.loads(z.read('pet/pet.json'))
    assert pet['spriteVersionNumber'] == 2
    assert pet['spritesheetPath'] == 'spritesheet.webp'
print('PASS: archive, inventory, all file hashes, safe paths, theme and pet metadata.')
