-- tour.dat, little endian.
local layout = {
    magic = "TOUR",
    checksum = 0x04,   -- crc32 of 0x08..end
    money = 0x08,      -- u32
    flags = 0x0C,      -- bit 0 hard mode, bit 1 tutorial done, bit 2 expansion
    difficulty = 0x0D, -- u8: 0 easy, 1 normal, 2 hard
    class = 0x0E,      -- u8
    elements = 0x0F,   -- bit flags
    name = 0x10,       -- utf16le, 16 units
    speed = 0x30,      -- f32
    subtitles = 0x34,  -- u8: 0x10 on, 0x00 off
    door = 0x35,       -- u8: 0 locked, 1 open, 2 broken
    seed = 0x38,       -- u32, shown in hex
    heroes = 0x40,     -- 3 x { u8 level, u8 unlocked, u16 hp, u32 exp }
    heroSize = 8,
    heroCount = 3,
    bag = 0x60,        -- 8 x u16 item ids
    bagSlots = 8,
    notesLength = 0x80, -- u16, then that many utf8 bytes
    notes = 0x82,
}

function layout.checksumOf(file)
    return st.hash.crc32(file:bytes(0x08, file:size() - 0x08))
end

function layout.hero(index)
    return layout.heroes + index * layout.heroSize
end

return layout
