local layout = require("layout")

local SAVE = "tour.dat"

function detect(save)
    if not save:has(SAVE) then return false, "No " .. SAVE .. " in this save." end
    local file = save:file(SAVE)
    if file:bytes(0, 4) ~= layout.magic then return false, "Not a Feature Tour save." end
    if file:u32(layout.checksum) ~= layout.checksumOf(file) then
        st.warn("checksum mismatch, it will be fixed on write")
    end
    return true
end

function before_save(save)
    local file = save:file(SAVE)
    file:set(layout.checksum, "u32", layout.checksumOf(file))
end

local function player(page, file)
    page:text{ label = "Name", bind = file:text(layout.name, 16, "utf16le"), help = "Shown on the title screen" }
    page:int{
        label = "Money", bind = file:field(layout.money, "u32"), max = 999999, step = 100,
        actions = {
            { label = "Max", run = function() file:set(layout.money, "u32", 999999) end },
            { label = "Zero", run = function() file:set(layout.money, "u32", 0) end },
        },
    }
    page:float{ label = "Game speed", bind = file:field(layout.speed, "f32"), min = 0.5, max = 2, step = 0.25 }
    page:dropdown{
        label = "Class", bind = file:field(layout.class, "u8"), options = { "Knight", "Mage", "Archer" },
        on_change = function(class) if class == 1 then file:set(layout.money, "u32", math.max(file:u32(layout.money), 500)) end end,
        help = "Mages start with at least 500 money",
    }
    page:segmented{ label = "Difficulty", bind = file:field(layout.difficulty, "u8"), options = { "Easy", "Normal", "Hard" } }
    page:toggle{ label = "Hard mode", bind = file:flag(layout.flags, 0) }
    page:toggle{ label = "Subtitles", bind = file:field(layout.subtitles, "u8"), on = 0x10, off = 0x00 }
    page:int{ label = "World seed", bind = file:field(layout.seed, "u32"), format = "hex" }
    page:label{ label = "Platform", value = st.platform.name }
    page:label{ label = "Save kind", value = st.game.save_kind ~= "" and st.game.save_kind or "unknown" }
end

local function heroes(page, file, names)
    for i, hero in ipairs(layout.Hero:array(file, layout.heroes, layout.heroCount)) do
        page:section({ title = names[i], key = "hero" .. i, collapsed = i > 1, actions = {
            { label = "Max out", run = function()
                -- Several writes in a button already form one undo step; st.transaction does it anywhere.
                st.transaction("Max out " .. names[i], function()
                    hero.level:set(99)
                    hero.hp:set(9999)
                    hero.exp:set(9999999)
                    hero.unlocked:set(1)
                end)
            end },
        } }, function(section)
            section:toggle{ label = "Unlocked", bind = hero.unlocked, key = "unlocked" }
            if hero.unlocked:get() == 0 then
                section:note("Unlock the hero to edit their stats.")
                return
            end
            section:int{ label = "Level", bind = hero.level, min = 1, max = 99, key = "level" }
            section:int{ label = "HP", bind = hero.hp, max = 9999, step = 50, key = "hp" }
            section:int{ label = "Experience", bind = hero.exp, max = 9999999, step = 1000, key = "exp" }
        end)
    end
end

local function inventory(page, file, items)
    local filter = page:state("bag-filter", "all")
    page:segmented{ label = "Show", bind = filter, options = { { value = "all", label = "All" }, { value = "used", label = "Used" } } }
    page:section({ title = "Bag", actions = {
        { label = "Clear", run = function() for i = 0, layout.bagSlots - 1 do file:set(layout.bag + i * 2, "u16", 0) end end },
        { label = "Fill with potions", run = function() for i = 0, layout.bagSlots - 1 do file:set(layout.bag + i * 2, "u16", 1) end end },
    } }, function(bag)
        for i = 0, layout.bagSlots - 1 do
            local slot = file:field(layout.bag + i * 2, "u16")
            if filter:get() == "all" or slot:get() ~= 0 then
                bag:dropdown{ key = "slot" .. i, label = "Slot " .. (i + 1), bind = slot, options = items }
            end
        end
    end)
end

local function world(page, file)
    page:tristate{ label = "Castle door", bind = file:field(layout.door, "u8"), states = { "Locked", "Open", "Broken" } }
    page:multiselect{ label = "Elements", bind = file:field(layout.elements, "u8"),
        bits = { [0] = "Fire", [1] = "Ice", [2] = "Wind", [3] = "Earth" } }
    local expansion = file:flag(layout.flags, 2)
    page:toggle{ label = "Expansion", bind = expansion }
    if expansion:get() and not st.game.has_dlc("1001") then
        page:warning("The expansion is enabled in this save but its DLC is not installed.")
    end
    page:section({ title = "Visited areas", collapsed = true }, function(section)
        for area = 0, 31 do
            section:toggle{ label = "Area " .. (area + 1), bind = file:flag(layout.visited, area), key = "area" .. area }
        end
    end)
    page:separator()
    page:popup({ label = "Danger zone" }, function(popup)
        popup:warning("These change several values at once. Undo with ZL.")
        popup:button{ label = "Unlock everything", run = function()
            file:set(layout.door, "u8", 1)
            file:set(layout.elements, "u8", 0x0F)
            file:setBit(layout.flags, 1, true)
        end }
    end)
end

-- The notes block has a variable length, so editing it resizes the file with splice.
local function notes(page, file)
    local length = file:u16(layout.notesLength)
    page:text{ label = "Notes", max_length = 200, bind = st.bind(
        function() return file:str(layout.notes, length, "utf8") end,
        function(text)
            file:splice(layout.notes, length, text)
            file:set(layout.notesLength, "u16", #text)
        end) }
    page:label{ label = "File size", value = file:size() .. " bytes" }
    page:label{ label = "Checksum", value = file:u32(layout.checksum), format = "hex" }
    local found = file:find("TOUR")
    page:label{ label = "Magic found at", value = found and string.format("0x%X", found) or "nowhere" }
    page:label{ label = "First bytes", value = st.hex(file:bytes(0, 8)) }
    page:label{ label = "SHA-256", value = st.hex(st.hash.sha256(file:content())):sub(1, 16) .. "..." }
end

local function packing(page, file)
    local pixels = {}
    for y = 0, 15 do
        for x = 0, 15 do
            pixels[#pixels + 1] = ((x // 4 + y // 4) % 2 == 0) and "\0\190\210\255" or "\236\238\242\255"
        end
    end
    page:image{ label = "Thumbnail", pixels = table.concat(pixels), width = 16, height = 16 }

    local content = file:content()
    local packed = st.zlib.compress(content, 9)
    page:label{ label = "zlib size", value = #packed .. " of " .. #content .. " bytes" }
    page:label{ label = "zstd size", value = #st.zstd.compress(content) .. " bytes" }
    page:label{ label = "Round trip", value = st.zlib.decompress(packed) == content and "ok" or "broken" }

    local key, iv = string.rep("k", 16), string.rep("\0", 16)
    local sealed = st.crypto.aes_encrypt("ctr", key, content, iv)
    page:label{ label = "AES-CTR", value = st.hex(sealed:sub(1, 8)) .. "..." }
    page:label{ label = "AES-CMAC", value = st.hex(st.crypto.aes_cmac(key, content)) }
    local es3 = require("st.es3")
    page:label{ label = "Easy Save 3", value = es3.decode(es3.encode('{"gold":5}', "password", { gzip = true }), "password") }
    page:label{ label = "PBKDF2", value = st.hex(st.crypto.pbkdf2("sha1", "password", iv, 100, 16)) }
    page:label{ label = "HMAC-SHA256", value = st.hex(st.hash.hmac_sha256(key, content)):sub(1, 16) .. "..." }
    page:label{ label = "XOR", value = st.hex(st.crypto.xor(content:sub(1, 4), "\255")) }
end

local function gameFiles(page)
    local ok, entries = pcall(st.game_data.list, "")
    if not ok then
        page:note("The game's files are not available here: " .. tostring(entries))
        return
    end
    for _, entry in ipairs(entries) do
        page:label{ label = entry.name, value = entry.directory and "folder" or entry.size .. " bytes", key = entry.name }
    end
    local text = st.game_data.read("Message/Common.msbt", true)
    if text then
        for id, message in pairs(st.format.msbt(text)) do
            page:label{ label = id, value = message, key = "msg-" .. id }
        end
    end
end

local function about(page)
    page:label{ label = "Editor", value = st.editor.name .. " v" .. st.editor.version }
    page:label{ label = "API", value = tostring(st.api_version) }
    page:label{ label = "Game", value = st.game.name .. " (" .. st.game.title_id .. ")" }
    page:label{ label = "Game version", value = st.game.version ~= "" and st.game.version or "unknown" }
    if st.game.version ~= "" and not st.game.version_is(">=1.1.0") then
        page:warning("Version 1.1.0 moved the bag. This editor only shows the old layout.")
    end
    page:label{ label = "Installed DLC", value = #st.game.dlc > 0 and table.concat(st.game.dlc, ", ") or "none" }
    page:label{ label = "Language", value = st.lang }
    page:button{ label = "Write to the log", help = "Press - to open the editor log", run = function()
        print("money is", st.save:file(SAVE):u32(layout.money))
        st.warn("this is a warning")
    end }
    page:page("Raw JSON", function(raw)
        local summary = { name = st.game.name, dlc = st.game.dlc, missing = st.json.null }
        raw:note(st.json.encode(summary))
    end)
end

function build(ui, save)
    local file = save:file(SAVE)
    local items = st.labels("data/items.json")
    local names = st.json.decode(st.data("data/heroes.json"))

    ui:page("Player", function(page) player(page, file) end)
    ui:page("Heroes", function(page) heroes(page, file, names) end)
    ui:page("Inventory", function(page) inventory(page, file, items) end)
    ui:page("World", function(page) world(page, file) end)
    ui:page("Notes and raw data", function(page) notes(page, file) end)
    ui:page("Images, compression, crypto", function(page) packing(page, file) end)
    ui:page("Game files", gameFiles)
    ui:page("About", about)
end
