-- Author: George Chang (George0828Zhang)
-- Credits:
--  read xml      http://lua-users.org/wiki/LuaXml
--  print table   (hashmal)  https://gist.github.com/hashmal/874792
--  worldpointer  (DDHibiki) https://www.unknowncheats.me/forum/grand-theft-auto-v/496174-worldptr.html
--  offsets       https://github.com/Yimura/GTAV-Classes & https://alexguirre.github.io/rage-parser-dumps/

myTab = gui.get_tab("Weapon Editor") -- or put "GUI_TAB_WEAPONS"
enabled = true
attachmentCB = true
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
    elseif name:find("BoneTag") ~= nil then
        return eAnimBoneTag[value]
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
    local offset = {val=offset_table[key][1]}
    if offset_table[key][2] == "at_array" then
        offset = {ref=offset_table[key][1], val=0}
    end
    if offset_table._base ~= nil then
        offset.val = offset.val + offset_table._base.val
        offset.ref = offset_table._base.ref -- TODO: what if at_array under at_array?
    end

    local inner_table = offset_table[key].ItemTemplate -- should be another table
    local interval = offset_table[key].ItemSize
    local count = 0
    for _, value_item in ipairs(value_pack) do
        if value_item.label == "Item" then
            inner_table._base = {
                val=offset.val + count * interval,
                ref=offset.ref
            }
            recursive_parse_into_gta_form(inner_table, output_table, model_registry, value_item, parent_tag..key)
            count = count + 1
        end
    end
    -- handle count
    local cnt_offset = {val=offset_table[key].Count[1]}
    if offset_table._base ~= nil then
        cnt_offset.val = cnt_offset.val + offset_table._base.val
        cnt_offset.ref = offset_table._base.ref
    end
    table.insert(output_table, {offset=cnt_offset, gtatype="word", val=count})
end

function parse_into_gta_form(offset_table, output_table, model_registry, value_pack, parent_tag)
    local key = value_pack.label
    if offset_table[key] == nil then
        return
    end

    if offset_table[key][1] == nil then
        local inner_table = offset_table[key] -- should be another table
        recursive_parse_into_gta_form(inner_table, output_table, model_registry, value_pack, parent_tag..key)
    elseif offset_table[key][2]:find("array") ~= nil then
        parse_into_gta_form_array(offset_table, output_table, model_registry, value_pack, parent_tag)
    else
        -- has offset + not array
        local offset = {val=offset_table[key][1]}
        local typ = offset_table[key][2]
        local value = value_pack[1]
        if value_pack.empty and value_pack.xarg.value ~= nil then
            value = value_pack.xarg.value -- e.g. <ClipSize value="6" />
        end
        if offset_table._base ~= nil then
            offset.val = offset.val + offset_table._base.val
            offset.ref = offset_table._base.ref
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
            table.insert(output_table, {offset={val=offset.val+4, ref=offset.ref}, gtatype="float", val=tonumber(value_pack.xarg.y)})
        elseif typ == "vec3" then
            value = tonumber(value_pack.xarg.x)
            gta = "float"
            table.insert(output_table, {offset={val=offset.val+4, ref=offset.ref}, gtatype="float", val=tonumber(value_pack.xarg.y)})
            table.insert(output_table, {offset={val=offset.val+8, ref=offset.ref}, gtatype="float", val=tonumber(value_pack.xarg.z)})
        -- elseif typ == "ref_ammo" then
        --     value = joaat(value_pack.xarg.ref)
        --     gta = "ref_ammo"
        elseif typ == "gunbone" then
            gta = "gunbone"
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
    local component_name = nil
    local is_default = false
    for _, item in pairs(xml) do
        if isouter and item.label == "Name" then
            weapon_name = item[1]
        end
        if type(item) == "table" then
            if track[2] == "AttachPoints" and track[4] == "Components" then
                if item.label == "Name" then
                    component_name = item[1]
                elseif item.label == "Default" then
                    is_default = item.xarg.value == "true"
                end
            end
            register_attachments(item, track, depth + 1, components, attachment_registry)
        end
    end
    if component_name ~= nil then
        table.insert(components, {Name=component_name, Default=is_default})
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
function print_offset(offset)
    if offset.ref ~= nil then
        return string.format("0x%x->0x%x", offset.ref, offset.val)
    end
    return string.format("0x%x", offset.val)
end

function restore_patches(patch_registry)
    if patch_registry == nil then return end
    for _, mypatch in pairs(patch_registry) do
        mypatch.obj:restore()
        log_info(string.format(
            "[debug][%s] restore %s (pid=%s)",
            mypatch.type, print_offset(mypatch.offset), mypatch.id
        ))
    end
end

function restore_all_patches()
    for _, patch_registry in pairs(memory_patch_registry) do
        restore_patches(patch_registry)
    end
end

function reapply_patches(patch_registry)
    if patch_registry == nil then return end
    for _, mypatch in ipairs(patch_registry) do
        mypatch.obj:apply()
        log_info(string.format(
            "[debug][%s] apply %s at %s (pid=%s)",
            mypatch.type, mypatch.value, print_offset(mypatch.offset), mypatch.id
        ))
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

memory.pointer.patch_float = function(self, value)
    local back = self:get_dword()
    self:set_float(value)
    local f2d = self:get_dword()
    self:set_dword(back)
    return self:patch_dword(f2d)
end

function apply_weapons_meta(script, lookup, looktype, curr_weap, base_addr, model_registry, memory_patch_registry)
    if memory_patch_registry[curr_weap] == nil then
        memory_patch_registry[curr_weap] = {}
        local data = lookup[looktype][curr_weap]
        for k, v in pairs(data) do
            local wpn_field_addr = base_addr:add(v.offset.val)
            if v.offset.ref ~= nil then
                wpn_field_addr = base_addr:add(v.offset.ref):deref():add(v.offset.val)
            end
            local field_patches = {}
            if v.gtatype == "byte" then
                field_patches[1] = wpn_field_addr:patch_byte(v.val)
            elseif v.gtatype == "word" then
                field_patches[1] = wpn_field_addr:patch_word(v.val)
            elseif v.gtatype == "dword" then
                if model_registry[v.val] ~= nil then
                    try_load(script, v.val, looktype)
                end
                field_patches[1] = wpn_field_addr:patch_dword(v.val)
            elseif v.gtatype == "float" then
                field_patches[1] = wpn_field_addr:patch_float(v.val)
            elseif v.gtatype == "qword" then
                field_patches[1] = wpn_field_addr:patch_qword(v.val)
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
                    field_patches[i] = wpn_field_addr:add((i-1)*8):patch_qword(bitset64s[i])
                end
            elseif v.gtatype == "bitset32" then
                local bitset = 0
                local debugmsg = "[debug]["..looktype.."][flags] bits="
                for _, b in pairs(v.val) do
                    debugmsg = debugmsg..tostring(b).." "
                    bitset = bitset | (1 << b)
                end
                log_info(debugmsg)
                field_patches[1] = wpn_field_addr:patch_dword(bitset)
            -- elseif v.gtatype == "ref_ammo" and looktype == "CWeaponInfo" then
            --     local curr_ammo = v.val
            --     local ammo_info_addr = get_ammo_info_addr(base_addr)
            --     if lookup.CAmmoInfo[curr_ammo] ~= nil then
            --         -- recursive call
            --         apply_weapons_meta(script, lookup, "CAmmoInfo", curr_ammo, ammo_info_addr, model_registry, memory_patch_registry)
            --     end
            elseif v.gtatype == "gunbone" then
                local bone_id = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(
                    get_current_weapon_obj(world_addr), string.lower(v.val))
                if bone_id ~= -1 then
                    -- gunbone is 16bit
                    field_patches[1] = wpn_field_addr:patch_word(bone_id)
                end
            end
            for i,p in ipairs(field_patches) do
                local mypatch = {
                    id=tostring(p):gsub("sol.big::lua_patch.:", "0x"):gsub("%s+0*", ""),
                    offset=v.offset,
                    value=tostring(v.val),
                    type=looktype,
                    obj=p
                }
                table.insert(memory_patch_registry[curr_weap], mypatch)
                log_info(string.format(
                    "[debug][%s] Patch %s at %s",
                    mypatch.type, mypatch.id, print_offset(mypatch.offset)
                ))
            end
        end-- for
    end-- if
    reapply_patches(memory_patch_registry[curr_weap])
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
        has_weap = (cur_weap ~= 0xA2719263)
    end
    return has_weap, cur_weap
end

function get_current_weapon_obj(world_addr)
    local cped = world_addr:add(0x8):deref()
    if cped:is_null() then
        log.warning("CPed address is null! Either the offset changed or something else is wrong.")
        return 0
    end
    local wpn_mgr = cped:add(0x10B8):deref()
    if wpn_mgr:is_null() then
        log.warning("CPedWeaponManager address is null! Either the offset changed or something else is wrong.")
        return 0
    end
    local cur_weap_obj_addr = wpn_mgr:add(0x78):deref()
    if cur_weap_obj_addr:is_null() then
        return 0
    end
    return memory.ptr_to_handle(cur_weap_obj_addr)
end

function toggle_attachment(curr_weap, attachment, force_true)
    local playerPed = PLAYER.PLAYER_PED_ID()
    if WEAPON.HAS_PED_GOT_WEAPON_COMPONENT(playerPed, curr_weap, attachment) then
        if not force_true then
            WEAPON.REMOVE_WEAPON_COMPONENT_FROM_PED(playerPed, curr_weap, attachment)
        end
    else
        WEAPON.GIVE_WEAPON_COMPONENT_TO_PED(playerPed, curr_weap, attachment)
    end
end

--------------------------------- MAIN INIT
function reload_meta()
    -- reset everything
    prev_weapon = 0 -- forces update on meta changed
    model_registry = {}
    attachment_registry = {}

    restore_all_patches()
    memory_patch_registry = {}

    package.loaded.weaponsmeta = nil
    require("weaponsmeta")
    rawxml = collect(weaponsmeta)
    lookup = transform(rawxml, model_registry)
    register_attachments(rawxml, {}, 0, {}, attachment_registry)
    log_info("weaponsmeta.lua reloaded.")
end

has_weap = false
curr_weap = 0
-- prev_weapon = 0
curr_weap_obj = 0
bone_registry = {}
memory_patch_registry = {}
world_ptr = get_world_addr()
reload_meta()
-- tprint(rawxml)
-- tprint(lookup)
-- tprint(attachment_registry)

--------------------------------- GUI
myTab:add_imgui(function()
    enabled, Toggled = ImGui.Checkbox("Enabled##weaponeditor", enabled)

    if Toggled then
        if enabled then
            prev_weapon = 0 -- force reapply in weaponloop
        else
            restore_all_patches()
        end
    end

    ImGui.SameLine()
    if ImGui.Button("Reload meta") then
        reload_meta()
    end

    attachmentCB, Toggled2 = ImGui.Checkbox("Default Attachments", attachmentCB)
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip('Auto-equip attachments with <Default value="true" /> in weaponsmeta.lua')
    end

    ImGui.Text("Modded Weapon:")
    -- local has_weap, curr_weap = get_current_weapon(world_ptr)
    if has_weap and attachment_registry[curr_weap] ~= nil then
        ImGui.SameLine()
        ImGui.Text(attachment_registry[curr_weap].Name)
    elseif ImGui.IsItemHovered() then
        ImGui.SetTooltip("Current weapon does not have modded attachments in weaponsmeta.lua")
    end
    if ImGui.BeginListBox("##attachlist", 420, 200) then

        if has_weap and attachment_registry[curr_weap] ~= nil then
            for i, pack in ipairs(attachment_registry[curr_weap]) do
                if ImGui.Selectable(pack.Name) then
                    toggle_attachment(curr_weap, joaat(pack.Name))
                end
            end
        end

        ImGui.EndListBox()
    end

    if ImGui.CollapsingHeader("Debug") then
        ImGui.Text(string.format("Current Hash:%d", curr_weap))
        ImGui.Text(string.format("Object Handle:%d", curr_weap_obj))
        ImGui.Text("Bones")
        if ImGui.BeginListBox("##bonelist", 420, 200) then
            local i = 1
            while bone_registry[i] ~= nil do
                ImGui.Selectable(string.format("%s (%d)",
                    bone_registry[i].Name,
                    bone_registry[i].ID
                ))
                i = i + 1
            end
            ImGui.EndListBox()
        end
    end
end)

script.register_looped("weaponloop", function (sc)
    sc:yield() -- necessary for numbers to update

    -- on weapon changed
    has_weap, curr_weap = get_current_weapon(world_ptr)
    if has_weap and curr_weap ~= prev_weapon then
        prev_weapon = curr_weap

        if not enabled then
            goto skipapply
        end
        -- apply CWeaponInfo changes
        local wpn_info_addr = get_wpn_info_addr(world_ptr)
        if wpn_info_addr == nil then
            return
        end
        if lookup.CWeaponInfo[curr_weap] ~= nil then
            apply_weapons_meta(sc, lookup, "CWeaponInfo", curr_weap, wpn_info_addr, model_registry, memory_patch_registry)
        end

        -- apply default components
        if attachmentCB and attachment_registry[curr_weap] ~= nil then
            for i, pack in ipairs(attachment_registry[curr_weap]) do
                if pack.Default then
                    toggle_attachment(curr_weap, joaat(pack.Name), true)
                end
            end
        end

        -- apply CAmmoInfo changes
        local ammo_info_addr = get_ammo_info_addr(wpn_info_addr)
        if ammo_info_addr == nil then
            return
        end
        local curr_ammo = ammo_info_addr:add(0x10):get_dword()
        if lookup.CAmmoInfo[curr_ammo] ~= nil then
            apply_weapons_meta(sc, lookup, "CAmmoInfo", curr_ammo, ammo_info_addr, model_registry, memory_patch_registry)
        end
    end
    ::skipapply::
    -- debug
    -- get bones
    bone_registry = {}
    curr_weap_obj = get_current_weapon_obj(world_ptr)
    if has_weap then
        if curr_weap_obj ~= 0 then
            for _, bone_name in ipairs(CWeaponBoneId) do
                local bone = ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(curr_weap_obj, bone_name)
                if bone ~= -1 then
                    table.insert(bone_registry, {Name=bone_name, ID=bone})
                end
            end
        end
    end
end)

