# Writes an Unreal (UE 4.27) save with Gold, PlayerName and Stats.Level for the my-pc-game editor.
import os
import struct
import sys


def fs(text):
    data = text.encode() + b"\0"
    return struct.pack("<i", len(data)) + data


def prop(name, kind, header, body):
    return fs(name) + fs(kind) + struct.pack("<ii", len(body), 0) + header + body


stats = prop("Level", "IntProperty", b"\0", struct.pack("<i", 7)) + prop("Title", "StrProperty", b"\0", fs("Hero")) + fs("None")
inventory_item = prop("Id", "NameProperty", b"\0", fs("Sword")) + prop("Count", "IntProperty", b"\0", struct.pack("<i", 1)) + fs("None")
inventory_item2 = prop("Id", "NameProperty", b"\0", fs("Potion")) + prop("Count", "IntProperty", b"\0", struct.pack("<i", 3)) + fs("None")
elements = inventory_item + inventory_item2
inner = fs("Inventory") + fs("StructProperty") + struct.pack("<ii", len(elements), 0) + fs("InventoryItem") + b"\0" * 17
array_body = struct.pack("<i", 2) + inner + elements
map_body = struct.pack("<ii", 0, 2) + fs("Forest") + struct.pack("<i", 3) + fs("Cave") + struct.pack("<i", 1)

data = b"GVAS" + struct.pack("<iiHHHI", 2, 522, 4, 27, 2, 0) + fs("++UE4+Release-4.27") + struct.pack("<ii", 3, 0) + fs("/Script/Demo.DemoSave")
data += prop("Gold", "IntProperty", b"\0", struct.pack("<i", 250))
data += prop("PlayerName", "StrProperty", b"\0", fs("Rin"))
data += fs("bHardMode") + fs("BoolProperty") + struct.pack("<ii", 0, 0) + b"\0\0"
data += prop("Position", "StructProperty", fs("Vector") + b"\0" * 17, struct.pack("<fff", 100.5, -20.0, 3.25))
data += prop("Stats", "StructProperty", fs("PlayerStats") + b"\0" * 17, stats)
data += prop("Inventory", "ArrayProperty", fs("StructProperty") + b"\0", array_body)
data += prop("Visits", "MapProperty", fs("StrProperty") + fs("IntProperty") + b"\0", map_body)
data += prop("PlayTime", "DoubleProperty", b"\0", struct.pack("<d", 3600.5))
data += fs("None") + struct.pack("<i", 0)
out = sys.argv[1] if len(sys.argv) > 1 else "samples/my-pc-game/save/Slot1.sav"
os.makedirs(os.path.dirname(out), exist_ok=True)
open(out, "wb").write(data)
