--[[
Mini README - crash_world/init.lua
Purpose: Defines destructible/buildable voxel materials and procedural terrain generation for the Crash Survival prototype.
Contents: Node registrations, deterministic Perlin-based chunk generator, and helper utilities for debug logging.
Usage: Loaded automatically by Luanti when the crash_world mod is present in a game; no manual invocation required.
Structure: configuration constants -> node definitions -> helper utilities -> mapgen hooks -> spawn utilities.
]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- Configuration for terrain and logging behavior.
local noise_def = {
    offset = 8,
    scale = 18,
    spread = { x = 64, y = 64, z = 64 },
    seed = 20240618,
    octaves = 4,
    persist = 0.55,
}

local grass_color = "#6da34d"
local debug_enabled = minetest.settings:get_bool("crash_world_debug", false)

local function log_debug(msg)
    if debug_enabled then
        minetest.log("action", string.format("[%s] %s", modname, msg))
    end
end

-- Node registrations: lightweight, destructible, and rebuildable.
minetest.register_node("crash_world:stone", {
    description = "Crash Stone",
    tiles = { "crash_stone.png" },
    groups = { cracky = 3, stone = 1 },
    is_ground_content = true,
    drop = "crash_world:cobble",
})

minetest.register_node("crash_world:cobble", {
    description = "Crash Cobblestone",
    tiles = { "crash_cobble.png" },
    groups = { cracky = 3, stone = 1 },
})

minetest.register_node("crash_world:dirt", {
    description = "Crash Dirt",
    tiles = { "crash_dirt.png" },
    groups = { crumbly = 3, soil = 1 },
    is_ground_content = true,
})

minetest.register_node("crash_world:dirt_with_grass", {
    description = "Crash Dirt with Grass",
    tiles = {
        { name = "crash_grass_top.png", color = grass_color },
        "crash_dirt.png",
        { name = "crash_grass_side.png", color = grass_color },
    },
    groups = { crumbly = 3, soil = 1 },
    drop = "crash_world:dirt",
    is_ground_content = true,
})

minetest.register_node("crash_world:wood", {
    description = "Crash Timber",
    tiles = { "crash_wood.png" },
    groups = { choppy = 2, flammable = 2, oddly_breakable_by_hand = 2 },
})

minetest.register_craftitem("crash_world:stick", {
    description = "Crash Stick",
    inventory_image = "crash_stick.png",
})

minetest.register_tool("crash_world:builder_pick", {
    description = "Starter Builder Pick",
    inventory_image = "crash_builder_pick.png",
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 0,
        groupcaps = {
            cracky = { times = { [1] = 3.0, [2] = 1.5, [3] = 0.5 }, uses = 100, maxlevel = 1 },
            crumbly = { times = { [1] = 2.5, [2] = 1.2, [3] = 0.3 }, uses = 100, maxlevel = 1 },
            choppy = { times = { [1] = 3.0, [2] = 1.6, [3] = 0.7 }, uses = 100, maxlevel = 1 },
        },
        damage_groups = { fleshy = 2 },
    },
})

-- Utility to generate a consistent height value for an (x, z) pair.
local function get_surface_height(noise_obj, x, z)
    local noise_val = noise_obj:get_2d({ x = x, y = z })
    return math.floor(noise_val)
end

-- Terrain generation core: fills each generated chunk with layered stone/dirt/grass and sparse trees.
local noise_handle = minetest.get_perlin(noise_def)
local tree_chance = 0.08
local chunk_cache = {}

local function chunk_key(minp)
    return string.format("%d_%d", minp.x, minp.z)
end

local function generate_tree(vm, data, area, pos)
    local trunk_height = math.random(3, 5)
    for y = 0, trunk_height do
        local p = { x = pos.x, y = pos.y + y, z = pos.z }
        local vi = area:indexp(p)
        data[vi] = minetest.get_content_id("crash_world:wood")
    end
end

local function generate_chunk(minp, maxp, seed)
    local key = chunk_key(minp)
    if chunk_cache[key] then
        log_debug("Reusing cached terrain for chunk " .. key)
        return
    end

    log_debug(string.format("Generating chunk at %s", minetest.pos_to_string(minp)))

    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({ MinEdge = emin, MaxEdge = emax })
    local data = vm:get_data()

    local c_stone = minetest.get_content_id("crash_world:stone")
    local c_dirt = minetest.get_content_id("crash_world:dirt")
    local c_grass = minetest.get_content_id("crash_world:dirt_with_grass")
    local c_air = minetest.CONTENT_AIR

    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local surface_y = get_surface_height(noise_handle, x, z)
            for y = minp.y, maxp.y do
                local vi = area:index(x, y, z)
                if y <= surface_y - 3 then
                    data[vi] = c_stone
                elseif y <= surface_y - 1 then
                    data[vi] = c_dirt
                elseif y == surface_y then
                    data[vi] = c_grass
                else
                    data[vi] = c_air
                end
            end

            if surface_y >= minp.y and surface_y <= maxp.y and math.random() < tree_chance then
                generate_tree(vm, data, area, { x = x, y = surface_y + 1, z = z })
            end
        end
    end

    vm:set_data(data)
    vm:calc_lighting()
    vm:write_to_map(true)

    chunk_cache[key] = true
end

minetest.register_on_generated(function(minp, maxp, blockseed)
    generate_chunk(minp, maxp, blockseed)
end)

-- Provide a simple spawn surface locator used by the player module.
local function find_surface(y_start)
    local pos = { x = 0, y = y_start, z = 0 }
    local node = minetest.get_node_or_nil(pos)
    while pos.y < 128 and node and node.name == "air" do
        pos.y = pos.y + 1
        node = minetest.get_node_or_nil(pos)
    end
    return pos
end

crash_world = {
    find_surface = find_surface,
}

log_debug("Crash World terrain module loaded")
