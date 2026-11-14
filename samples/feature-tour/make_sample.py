"""Writes samples/save/tour.dat, a save the Feature Tour editor can open with savetinker-cli."""
import pathlib
import struct
import zlib

notes = "Remember to buy bombs.".encode()
data = bytearray(0x82 + len(notes))
data[0:4] = b"TOUR"
struct.pack_into("<IBBBB", data, 0x08, 1200, 0b010, 1, 0, 0b0011)
data[0x10:0x10 + 8] = "Hero".encode("utf-16le")
struct.pack_into("<fBB", data, 0x30, 1.0, 0x10, 0)
struct.pack_into("<I", data, 0x38, 0xC0FFEE)
for index, (level, unlocked, hp, exp) in enumerate([(12, 1, 340, 5400), (1, 0, 100, 0), (1, 0, 100, 0)]):
    struct.pack_into("<BBHI", data, 0x40 + index * 8, level, unlocked, hp, exp)
struct.pack_into("<8H", data, 0x60, 1, 1, 3, 0, 0, 4, 0, 0)
struct.pack_into("<H", data, 0x80, len(notes))
data[0x82:] = notes
struct.pack_into("<I", data, 0x04, zlib.crc32(data[0x08:]))

out = pathlib.Path(__file__).parent / "save"
out.mkdir(exist_ok=True)
(out / "tour.dat").write_bytes(data)
