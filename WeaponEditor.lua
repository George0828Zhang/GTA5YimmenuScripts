-- Author: George Chang (George0828Zhang)
-- Credits:
--  read xml      http://lua-users.org/wiki/LuaXml
--  print table   (hashmal)  https://gist.github.com/hashmal/874792
--  worldpointer  (DDHibiki) https://www.unknowncheats.me/forum/grand-theft-auto-v/496174-worldptr.html
--  offsets       https://github.com/Yimura/GTAV-Classes & https://alexguirre.github.io/rage-parser-dumps/

myTab = gui.get_tab("Weapon Editor") -- or put "GUI_TAB_WEAPONS"
enabled = true
verbose = true

require("lib/xmlreader")
require("lib/gtaenums")
require("lib/gtaoffsets")
require("weaponsmeta")

--------------------------------- DEBUG
function log_info(msg)
    if verbose then
        log.info(msg)
    end
end

function tprint(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. tostring(k) .. ": "
        if type(v) == "table" then
            log_info(formatting)
            tprint(v, indent+1)
        else
            log_info(formatting .. tostring(v))
        end
    end
end

function print_hash(name)
    log_info(name .. " hash is "..tostring(joaat(name)))
end

--------------------------------- PARSING
function _handle_enum(name, value)
    if name == "DamageType" then
        return eDamageType[value]
    elseif name:find("Explosion") ~= nil then
        value = value:gsub("EXP_TAG_", "")
        return eExplosion[value]
    elseif name == "FireType" then
        return eFireType[value]
    elseif name == "EffectGroup" then
        return eEffectGroup[value]
    elseif name == "WeaponFlags" then
        return eWeaponFlags[value]
    elseif name == "AmmoSpecialType" then
        return eAmmoSpecialType[value]
    elseif name == "AmmoFlags" then
        return eAmmoFlags[value]
    elseif name == "ProjectileFlags" then
        return eProjectileFlags[value]
    end
end

function handle_enum(name, value)
    local out = _handle_enum(name, value)
    if out == nil then
        log_info("[debug][enum] Unseen enum/flag: "..value.." in "..name)
    end
    return out
end

function recursive_parse_into_gta_form(inner_table, output_table, model_registry, value_pack, next_tag)
    -- recursive call
    for sub_k, sub_v in pairs(value_pack) do
        parse_into_gta_form(inner_table, output_table, model_registry, sub_v, next_tag)
    end
end

function parse_into_gta_form_array(offset_table, output_table, model_registry, value_pack, parent_tag)
    -- array syntax
    -- base, "array", ItemTemplate, count
    local key = value_pack.label
    local offset = offset_table[key][1]
    if offset_table._base ~= nil then
        offset = offset + offset_table._base
    end

    local inner_table = offset_table[key].ItemTemplate -- should be another table
    local interval = offset_table[key].ItemSize
    local count = 0
    for _, value_item in pairs(value_pack) do
        if value_item.label == "Item" then
            inner_table._base = offset + count * interval
            recursive_parse_into_gta_form(inner_table, output_table, model_registry, value_item, parent_tag..key)
            count = count + 1
        end
    end
    -- handle count
    local count_pack = {label="Count", count}
    if offset_table._base ~= nil then
        offset_table[key]._base = offset_table._base
    end
    parse_into_gta_form(offset_table[key], output_table, model_registry, count_pack, parent_tag)
end

function parse_into_gta_form(offset_table, output_table, model_registry, value_pack, parent_tag)
    local key = value_pack.label
    if offset_table[key] == nil then
        return
    end

    if offset_table[key][1] == nil then
        local inner_table = offset_table[key] -- should be another table
        recursive_parse_into_gta_form(inner_table, output_table, model_registry, value_pack, parent_tag..key)
    elseif offset_table[key][2] == "array" then
        parse_into_gta_form_array(offset_table, output_table, model_registry, value_pack, parent_tag)
    else
        -- has offset + not array
        local offset = offset_table[key][1]
        local typ = offset_table[key][2]
        local value = value_pack[1]
        if value_pack.empty and value_pack.xarg.value ~= nil then
            value = value_pack.xarg.value -- e.g. <ClipSize value="6" />
        end
        if offset_table._base ~= nil then
            offset = offset + offset_table._base
        end
        local gta = "dword" -- default
        if typ == "hash" then
            value = joaat(value)
            model_registry[value] = 1
        elseif typ == "enum" then
            value = handle_enum(parent_tag..key, value)
        elseif typ == "enum16" then
            value = handle_enum(parent_tag..key, value)
            gta = "word"
        elseif typ == "int" then
            value = tonumber(value)
        elseif typ == "byte" then
            value = tonumber(value)
            gta = "byte"
        elseif typ == "bool" then
            value = (value == "true")
            gta = "byte"
        elseif typ:find("^flags") ~= nil then -- flags32, flags192 etc
            bits = {}
            for w in value:gmatch("%S+") do
                table.insert(bits, handle_enum(key, w))
            end
            value = bits
            gta = typ:gsub("flags", "bitset")
        elseif typ == "vec2" then
            value = tonumber(value_pack.xarg.x)
            gta = "float"
            table.insert(output_table, {offset=offset + 4, gtatype="float", val=tonumber(value_pack.xarg.y)})
        elseif typ == "vec3" then
            value = tonumber(value_pack.xarg.x)
            gta = "float"
            table.insert(output_table, {offset=offset + 4, gtatype="float", val=tonumber(value_pack.xarg.y)})
            table.insert(output_table, {offset=offset + 8, gtatype="float", val=tonumber(value_pack.xarg.z)})
        elseif typ == "ref_ammo" then
            value = joaat(value_pack.xarg.ref)
            gta = "ref_ammo"
        else
            value = tonumber(value)
            gta = "float"
        end
        table.insert(output_table, {offset=offset, gtatype=gta, val=value})
    end
end

function transform(meta, model_registry)
    -- transform table into efficient lookup
    local lookup = {
        CWeaponInfo={},
        CAmmoInfo={}
    }
    local alias = {
        CWeaponInfo="CWeaponInfo",
        CAmmoInfo="CAmmoInfo",
        CAmmoProjectileInfo="CAmmoInfo",
        CAmmoThrownInfo="CAmmoInfo",
        CAmmoRocketInfo="CAmmoInfo"
    }
    for _, item in pairs(meta) do -- each <Item type=...>
        if item.xarg ~= nil and item.xarg.type ~= nil then
            local key = alias[item.xarg.type]
            if lookup[key] ~= nil then
                local item_hash = nil
                local item_type = key
                local data = {} -- {offset=, gtatype=, val=}
                for _, value_pack in pairs(item) do -- each <Field>
                    if value_pack.label == "Name" then
                        item_hash = joaat(value_pack[1]) -- e.g. WEAPON_PISTOL
                    elseif gta_offset_types[item_type] ~= nil then
                        parse_into_gta_form(gta_offset_types[item_type], data, model_registry, value_pack, "")
                    end
                end
                lookup[item_type][item_hash] = data
            end
        end
    end 
    return lookup
end

function register_attachments(xml, track, depth, components, attachment_registry)
    track[depth] = xml.label
    local isouter = false
    if xml.xarg ~= nil and xml.xarg.type == "CWeaponInfo" then
        track[depth] = xml.xarg.type
        isouter = true
    end
    local weapon_name = nil
    for _, item in pairs(xml) do
        if isouter and item.label == "Name" then
            weapon_name = item[1]
        end
        if type(item) == "table" then
            if item.label == "Name" and track[2] == "AttachPoints" and track[4] == "Components" then
                table.insert(components, item[1])
            end
            register_attachments(item, track, depth + 1, components, attachment_registry)
        end
    end
    if isouter and weapon_name ~= nil then
        local weapon_hash = joaat(weapon_name)
        for k, item in pairs(components) do
            if attachment_registry[weapon_hash] == nil then
                attachment_registry[weapon_hash] = {Name=weapon_name}
            end
            table.insert(attachment_registry[weapon_hash], item)
            components[k] = nil
        end
    end
    track[depth] = nil
end

--------------------------------- MEMORY PATCHING
function restore_patches()
    for i,p in ipairs(memory_patch_registry) do
        p:restore()
    end
end

function try_load(script, model, looktype)
    if not STREAMING.IS_MODEL_VALID(model) then
        return
    end
    STREAMING.REQUEST_MODEL(model)
    while not STREAMING.HAS_MODEL_LOADED(model) do script:yield() end
    log_info("[debug]["..looktype.."] loaded model "..tostring(model))
end

function apply_weapons_meta(script, lookup, looktype, curr_weap, base_addr, model_registry, memory_patch_registry)
    local data = lookup[looktype][curr_weap]
    for k, v in pairs(data) do
        local wpn_field_addr = base_addr:add(v.offset)
        local patches = {}
        if v.gtatype == "byte" then
            patches[1] = wpn_field_addr:patch_byte(v.val)
        elseif v.gtatype == "word" then
            patches[1] = wpn_field_addr:patch_word(v.val)
        elseif v.gtatype == "dword" then
            if model_registry[v.val] ~= nil then
                try_load(script, v.val, looktype)
            end
            patches[1] = wpn_field_addr:patch_dword(v.val)
        elseif v.gtatype == "float" then
            local back = wpn_field_addr:get_dword()
            wpn_field_addr:set_float(v.val)
            local f2d = wpn_field_addr:get_dword()
            wpn_field_addr:set_dword(back)
            patches[1] = wpn_field_addr:patch_dword(f2d)
        elseif v.gtatype == "qword" then
            patches[1] = wpn_field_addr:patch_qword(v.val)
        elseif v.gtatype == "bitset192" then
            local bitset64s = {0, 0, 0}
            local debugmsg = "[debug]["..looktype.."][flags] bits="
            for _, b in pairs(v.val) do
                local q = b // 64 + 1 -- lua 1-indexed
                local r = b % 64
                debugmsg = debugmsg..tostring(b).." "
                bitset64s[q] = bitset64s[q] | (1 << r)
            end
            log_info(debugmsg)
            -- log_info("[debug]["..looktype.."][flags] bitset1="..tostring(bitset64s[1]))
            for i = 1, 3 do
                patches[i] = wpn_field_addr:add((i-1)*8):patch_qword(bitset64s[i])
            end
        elseif v.gtatype == "bitset32" then
            local bitset = 0
            local debugmsg = "[debug]["..looktype.."][flags] bits="
            for _, b in pairs(v.val) do
                debugmsg = debugmsg..tostring(b).." "
                bitset = bitset | (1 << b)
            end
            log_info(debugmsg)
            patches[1] = wpn_field_addr:patch_dword(bitset)
        elseif v.gtatype == "ref_ammo" and looktype == "CWeaponInfo" then
            local curr_ammo = v.val
            local ammo_info_addr = get_ammo_info_addr(base_addr)
            if lookup.CAmmoInfo[curr_ammo] ~= nil then
                -- recursive call
                apply_weapons_meta(script, lookup, "CAmmoInfo", curr_ammo, ammo_info_addr, model_registry, memory_patch_registry)
            end
        end
        local _addr = wpn_field_addr:get_address()
        for i,p in ipairs(patches) do
            p:apply()
            memory_patch_registry[_addr] = p
            _addr = _addr + 8
        end
        log_info("[debug]["..looktype.."] Applied "..tostring(v.val).." at "..string.format("0x%x", v.offset))
    end
end

--------------------------------- GAMEPLAY
function get_current_weapon(world_addr)
    local cped = world_addr:add(0x8):deref()
    if cped:is_null() then
        log.warning("CPed address is null! Either the offset changed or something else is wrong.")
        return false, 0
    end
    local wpn_mgr = cped:add(0x10B8):deref()
    if wpn_mgr:is_null() then
        log.warning("CPedWeaponManager address is null! Either the offset changed or something else is wrong.")
        return false, 0
    end
    local cur_weap = wpn_mgr:add(0x18):get_dword()
    local has_weap = false
    if wpn_mgr:add(0x20):deref():is_valid() or wpn_mgr:add(0x70):deref():is_valid() then
        has_weap = true
    end
    return has_weap, cur_weap
end

function toggle_attachment(curr_weap, attachment)
    local playerPed = PLAYER.PLAYER_PED_ID()
    if WEAPON.HAS_PED_GOT_WEAPON_COMPONENT(playerPed, curr_weap, attachment) then
        WEAPON.REMOVE_WEAPON_COMPONENT_FROM_PED(playerPed, curr_weap, attachment)
    else
        WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(playerPed, curr_weap, attachment)
    end
end

--------------------------------- MAIN INIT
rawxml = ""
lookup = {}
prev_weapon = 0
model_registry = {}
attachment_registry = {}
memory_patch_registry = {}
world_ptr = get_world_addr()

function reload_meta()
    -- reset everything
    restore_patches()
    prev_weapon = 0
    model_registry = {}
    attachment_registry = {}
    memory_patch_registry = {}

    package.loaded.weaponsmeta = nil
    require("weaponsmeta")
    rawxml = collect(weaponsmeta)
    lookup = transform(rawxml, model_registry)
    register_attachments(rawxml, {}, 0, {}, attachment_registry)
    log_info("weaponsmeta.lua reloaded.")
end

reload_meta()
-- tprint(rawxml)
-- tprint(lookup)
-- tprint(attachment_registry)

--------------------------------- GUI
myTab:add_imgui(function()
    enabled, Toggled = ImGui.Checkbox("Enabled##weaponeditor", enabled)

    if Toggled and not enabled then
        restore_patches(memory_patch_registry)
    end

    ImGui.SameLine()
    if ImGui.Button("Reload meta") then
        reload_meta()
    end

    ImGui.Text("Current Weapon:")
    local has_weap, curr_weap = get_current_weapon(world_ptr)
    if has_weap and attachment_registry[curr_weap] ~= nil then
        ImGui.SameLine()
        ImGui.Text(attachment_registry[curr_weap].Name)
    elseif ImGui.IsItemHovered() then
        ImGui.SetTooltip("Current weapon does not have attachments specified in custom weaponsmeta.lua")
    end
    if ImGui.BeginListBox("##attachlist", 420, 200) then

        if has_weap and attachment_registry[curr_weap] ~= nil then
            for i, name in ipairs(attachment_registry[curr_weap]) do
                if ImGui.Selectable(name) then
                    toggle_attachment(curr_weap, joaat(name))
                end
            end
        end

        ImGui.EndListBox()
    end
end)

event.register_handler(menu_event.PlayerMgrInit, function ()
    world_ptr = get_world_addr()
end)

script.register_looped("weaponloop", function (sc)
    sc:yield() -- necessary for numbers to update

    if not enabled then
        return
    end
    -- on weapon changed
    local has_weap, curr_weap = get_current_weapon(world_ptr)
    if has_weap and curr_weap ~= prev_weapon then
        prev_weapon = curr_weap
        local wpn_info_addr = get_wpn_info_addr(world_ptr)
        if wpn_info_addr == nil then
            return
        end
        if lookup.CWeaponInfo[curr_weap] ~= nil then
            -- apply CWeaponInfo changes
            apply_weapons_meta(script, lookup, "CWeaponInfo", curr_weap, wpn_info_addr, model_registry, memory_patch_registry)
        end
        local ammo_info_addr = get_ammo_info_addr(wpn_info_addr)
        if ammo_info_addr == nil then
            return
        end
        local curr_ammo = ammo_info_addr:add(0x10):get_dword()
        if lookup.CAmmoInfo[curr_ammo] ~= nil then
            -- apply CAmmoInfo changes
            apply_weapons_meta(script, lookup, "CAmmoInfo", curr_ammo, ammo_info_addr, model_registry, memory_patch_registry)
        end
    end
end)

