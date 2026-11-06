"""Bouwt CatchAStorm.rbxlx uit de map src/, zonder dat je Rojo nodig hebt.

Gebruik:  python tools/build_place.py
Daarna open je CatchAStorm.rbxlx in Roblox Studio.
"""

from pathlib import Path
import itertools
import sys

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "src"
OUT = ROOT / "CatchAStorm.rbxlx"

_ids = itertools.count(1)


def ref() -> str:
    return f"RBX{next(_ids):032X}"


def cdata(text: str) -> str:
    return "<![CDATA[" + text.replace("]]>", "]]]]><![CDATA[>") + "]]>"


def item(cls: str, name: str, children: list[str] | None = None, source: str | None = None) -> str:
    props = f'<string name="Name">{name}</string>'
    if source is not None:
        props += f'<ProtectedString name="Source">{cdata(source)}</ProtectedString>'
    inner = "".join(children or [])
    return f'<Item class="{cls}" referent="{ref()}"><Properties>{props}</Properties>{inner}</Item>'


def script_item(path: Path) -> str:
    name = path.name
    source = path.read_text(encoding="utf-8")
    for suffix, cls in ((".server.luau", "Script"), (".client.luau", "LocalScript"), (".luau", "ModuleScript")):
        if name.endswith(suffix):
            return item(cls, name[: -len(suffix)], source=source)
    raise ValueError(f"Onbekend bestand: {path}")


def folder(path: Path, name: str) -> str:
    children = [script_item(p) for p in sorted(path.glob("*.luau"))]
    return item("Folder", name, children)


def main() -> int:
    tree = [
        item("ReplicatedStorage", "ReplicatedStorage", [folder(SRC / "shared", "Shared")]),
        item("ServerScriptService", "ServerScriptService", [folder(SRC / "server", "Server")]),
        item(
            "StarterPlayer",
            "StarterPlayer",
            [item("StarterPlayerScripts", "StarterPlayerScripts", [folder(SRC / "client", "Client")])],
        ),
    ]
    OUT.write_text('<roblox version="4">' + "".join(tree) + "</roblox>\n", encoding="utf-8")
    print(f"Geschreven: {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
