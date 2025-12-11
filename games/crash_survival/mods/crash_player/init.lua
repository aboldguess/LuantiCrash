--[[
Mini README - crash_player/init.lua
Purpose: Configures player defaults (spawn, physics, inventory) to support walking, jumping, and building on generated voxels.
Contents: Spawn positioning helpers, player initialization hooks, and lightweight debug tracing.
Usage: Loaded automatically with the crash_survival game; players receive starter tools and a stable spawn location.
Structure: dependencies -> logging helpers -> spawn helpers -> player registration hooks.
]]

local modname = minetest.get_current_modname()
local debug_enabled = minetest.settings:get_bool("crash_player_debug", false)

local function log_debug(msg)
    if debug_enabled then
        minetest.log("action", string.format("[%s] %s", modname, msg))
    end
end

local function get_spawn_pos()
    local surface = crash_world.find_surface(0)
    return { x = surface.x, y = surface.y + 2, z = surface.z }
end

minetest.register_on_newplayer(function(player)
    local spawn_pos = get_spawn_pos()
    player:set_pos(spawn_pos)
    player:set_physics_override({
        speed = 1.0,
        jump = 1.1,
    })

    local inv = player:get_inventory()
    inv:set_size("main", 32)
    inv:add_item("main", "crash_world:builder_pick")
    inv:add_item("main", "crash_world:stick 4")
    log_debug("Spawned player at " .. minetest.pos_to_string(spawn_pos))
end)

minetest.register_on_respawnplayer(function(player)
    local spawn_pos = get_spawn_pos()
    player:set_pos(spawn_pos)
    log_debug("Respawned player at " .. minetest.pos_to_string(spawn_pos))
    return true
end)

minetest.register_globalstep(function()
    -- Future hooks: stamina drain, hunger, collar damage. Left lightweight for now.
end)

log_debug("Crash Player module loaded")
