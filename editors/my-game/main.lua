local SAVE = "save.dat"
local items = st.json.decode(st.data("data/items.json"))

function detect(save)
    if not save:has(SAVE) then return false, "No " .. SAVE .. " in this save." end
    return save:file(SAVE):bytes(0, 4) == "SAVE"
end

function before_save(save)
    local file = save:file(SAVE)
    file:set(0x04, "u32", st.hash.crc32(file:bytes(0x08, file:size() - 0x08)))
end

function build(ui, save)
    local file = save:file(SAVE)

    ui:page("Player", function(page)
        page:text{ label = "Name", bind = file:text(0x10, 16, "utf16le") }
        page:int{ label = "Money", bind = file:field(0x08, "u32"), max = 999999, step = 100,
            actions = { { label = "Max", run = function() file:set(0x08, "u32", 999999) end } } }
        page:toggle{ label = "Hard mode", bind = file:flag(0x0c, 0) }
    end)

    ui:page("Items", function(page)
        for i, name in ipairs(items) do
            page:int{ label = name, bind = file:field(0x40 + (i - 1) * 2, "u16"), max = 99 }
        end
    end)
end
