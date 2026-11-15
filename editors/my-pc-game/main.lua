local gvas = require("st.gvas")

local function find(nodes, name)
    for _, node in ipairs(nodes) do
        if node.name == name then return node end
    end
end

function detect(save)
    for _, name in ipairs(save:files()) do
        if gvas.parse(save:file(name)) then return true end
    end
    return false, "No Unreal save here."
end

function build(ui, save)
    for _, name in ipairs(save:files()) do
        local file = save:file(name)
        local parsed = gvas.parse(file)
        if parsed then
            ui:page(name, function(page)
                local gold = find(parsed.properties, "Gold")
                if gold then page:int{ label = "Gold", bind = gvas.bind(file, gold), max = 999999 } end
                local player = find(parsed.properties, "PlayerName")
                if player then page:text{ label = "Name", bind = gvas.bind(file, player), max_length = 32 } end
                local stats = find(parsed.properties, "Stats")
                local level = stats and find(stats.children, "Level")
                if level then page:int{ label = "Level", bind = gvas.bind(file, level), min = 1, max = 99 } end
            end)
        end
    end
end
