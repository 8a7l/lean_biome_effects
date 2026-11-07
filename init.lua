-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2026 8a7l

local modname = minetest.get_current_modname()
local after = minetest.after

-- ============================================================
-- СТАН ГРАВЦІВ
-- ============================================================
local player_data = {}

-- ============================================================
-- ЛОГІКА ОНОВЛЕННЯ
-- ============================================================
local function update_player_biome(player)
    if not player or not player:is_player() then return end
    local p_name = player:get_player_name()
    local pos = player:get_pos()
    
    -- Визначаємо, чи гравець під землею (печера)
    -- Поріг y < -10 є безпечним для більшості світів Minetest Game / Lean Core
    local is_underground = pos.y < -10

    local biome_data = minetest.get_biome_data(pos)
    local heat, humidity = 50, 50 -- Значення за замовчуванням (нейтральні)

    if biome_data then
        heat = biome_data.heat
        humidity = biome_data.humidity
    end

    -- Визначаємо ефект на основі клімату
    local effect = nil
    local biome_type = "Normal"

    if is_underground then
        -- У печері ігноруємо поверхневий клімат
        biome_type = "Cave"
        -- Ефект для печери: нейтральна швидкість, без HUD
        effect = nil 
    elseif heat < 25 then
        -- Сніг та холод
        biome_type = "Snow/Cold"
        effect = { speed = 0.8, jump = 1.0, gravity = 1.0, text = "Cold: Speed -20%", color = 0xAAAAFF }
    elseif heat > 65 and humidity < 35 then
        -- Пустеля
        biome_type = "Desert"
        effect = { speed = 1.15, jump = 1.0, gravity = 1.0, text = "Desert: Speed +15%", color = 0xFFDD88 }
    elseif heat > 65 and humidity > 65 then
        -- Джунглі
        biome_type = "Jungle"
        effect = { speed = 0.9, jump = 0.85, gravity = 1.15, text = "Jungle: Heavy", color = 0x88FF88 }
    end

    local data = player_data[p_name]
    if not data then
        data = { current_type = nil, hud_id = nil }
        player_data[p_name] = data
    end
    
    -- Якщо тип місцевості не змінився, просто чекаємо
    if data.current_type == biome_type then
        after(2, update_player_biome, player)
        return
    end
    
    -- Тип змінився! Оновлюємо.
    data.current_type = biome_type
    
    -- Дебаг-повідомлення прибрано

    if effect then
        -- Застосовуємо фізику
        player:set_physics_override({
            speed = effect.speed,
            jump = effect.jump,
            gravity = effect.gravity
        })
        
        -- Додаємо HUD
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
        -- Звичайний біом або печера. Скидаємо все.
        player:set_physics_override({ speed = 1.0, jump = 1.0, gravity = 1.0 })
        
        if data.hud_id then
            player:hud_remove(data.hud_id)
            data.hud_id = nil
        end
    end
    
    after(2, update_player_biome, player)
end

-- ============================================================
-- ПОДІЇ ГРАВЦІВ
-- ============================================================
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
        if player and player:is_player() then
            player:set_physics_override({ speed = 1.0, jump = 1.0, gravity = 1.0 })
        end
        player_data[p_name] = nil
    end
end)

minetest.register_on_shutdown(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        if player and player:is_player() then
            player:set_physics_override({ speed = 1.0, jump = 1.0, gravity = 1.0 })
        end
    end
end)