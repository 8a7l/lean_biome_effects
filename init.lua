-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2026 8a7l

local after = minetest.after

local player_data = {}

local function update_player_biome(player)
    if not player or not player:is_player() then return end
    local p_name = player:get_player_name()
    local pos = player:get_pos()
    
    local is_underground = pos.y < -10

    local biome_data = minetest.get_biome_data(pos)
    local heat, humidity = 50, 50

    if biome_data then
        heat = biome_data.heat
        humidity = biome_data.humidity
    end

    local effect = nil
    local biome_type = "Normal"

    if is_underground then
        biome_type = "Cave"
        effect = nil 
    elseif heat < 25 then
        biome_type = "Snow/Cold"
        effect = { speed = 0.8, jump = 1.0, gravity = 1.0, text = "Cold: Speed -20%", color = 0xAAAAFF }
    elseif heat > 65 and humidity < 35 then
        biome_type = "Desert"
        effect = { speed = 1.15, jump = 1.0, gravity = 1.0, text = "Desert: Speed +15%", color = 0xFFDD88 }
    elseif heat > 65 and humidity > 65 then
        biome_type = "Jungle"
        effect = { speed = 0.9, jump = 0.85, gravity = 1.15, text = "Jungle: Heavy", color = 0x88FF88 }
    end

    local data = player_data[p_name]
    if not data then
        data = { current_type = nil, hud_id = nil }
        player_data[p_name] = data
    end
    
    if data.current_type == biome_type then
        after(2, update_player_biome, player)
        return
    end
    
    data.current_type = biome_type

    if effect then
        -- ВИКОРИСТОВУЄМО LEAN_PHYSICS
        lean_physics.set_modifier(p_name, "biome", {
            speed = effect.speed,
            jump = effect.jump,
            gravity = effect.gravity
        })
        
        if data.hud_id then
            player:hud_change(data.hud_id, "text", effect.text)
            player:hud_change(data.hud_id, "number", effect.color)
        else
            data.hud_id = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.5, y = 0.85},
                alignment = {x = 0, y = 1},
                text = effect.text,
                number = effect.color,
                scale = {x = 100, y = 100},
            })
        end
    else
        -- ВИКОРИСТОВУЄМО LEAN_PHYSICS ДЛЯ СКИДАННЯ
        lean_physics.clear_modifier(p_name, "biome")
        
        if data.hud_id then
            player:hud_remove(data.hud_id)
            data.hud_id = nil
        end
    end
    
    after(2, update_player_biome, player)
end

minetest.register_on_joinplayer(function(player)
    local p_name = player:get_player_name()
    player_data[p_name] = { current_type = nil, hud_id = nil }
    after(1, update_player_biome, player)
end)

minetest.register_on_leaveplayer(function(player)
    local p_name = player:get_player_name()
    local data = player_data[p_name]
    if data then
        if data.hud_id then player:hud_remove(data.hud_id) end
        lean_physics.clear_modifier(p_name, "biome")
        player_data[p_name] = nil
    end
end)

minetest.register_on_shutdown(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        lean_physics.clear_modifier(player:get_player_name(), "biome")
    end
end)