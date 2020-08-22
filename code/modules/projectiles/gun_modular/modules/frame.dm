obj/item/weapon/gun_modular/module/frame
    name = "gun frame"
    desc = "The frame, the base of the weapon, all parts of the weapon are attached to it, and configuration and interaction of the parts also take place through it. For normal assembly, use the installation order: Chamber, Magazine Holder, Handle, Barrel, Accessories"
    icon_state = "chamber_energy"
    icon_overlay_layer = LAYER_FRAME
    lessdamage = 0
    lessdispersion = -2
    size_gun = 1
    prefix_radial = "Frame"
    var/max_accessory = 3
    var/obj/item/weapon/gun_modular/module/chamber/chamber = null
    var/obj/item/weapon/gun_modular/module/handle/handle = null
    var/obj/item/weapon/gun_modular/module/barrel/barrel = null
    var/obj/item/weapon/gun_modular/module/magazine/magazine = null
    var/list/obj/item/weapon/gun_modular/module/modules = list()
    var/list/obj/item/weapon/gun_modular/module/accessories = list()
    var/obj/item/weapon/gun_modular/module/accessory/active_accessory = null
    var/list/config_user = list()
    var/list/icon/radial_icons = list()
    var/list/image/human_overlays = list()

// When changing weapons, icons are rebuilt to display on a person

obj/item/weapon/gun_modular/module/frame/proc/build_images()
    var/image/l_hand = image(icon = icon, icon_state = "")
    var/image/r_hand = image(icon = icon, icon_state = "")
    var/image/belt = image(icon = icon, icon_state = "")
    var/image/back = image(icon = icon, icon_state = "")
    for(var/key in modules)
        var/obj/item/weapon/gun_modular/module/M = modules[key]
        if(!M)
            continue
        var/image/M_icon_l = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[M.icon_overlay_name]_l", layer = M.icon_overlay_layer)
        var/image/M_icon_r = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[M.icon_overlay_name]_r", layer = M.icon_overlay_layer)
        var/image/M_icon_belt = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[M.icon_overlay_name]_belt", layer = M.icon_overlay_layer)
        var/image/M_icon_back = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[M.icon_overlay_name]_back", layer = M.icon_overlay_layer)
        l_hand.add_overlay(M_icon_l)
        r_hand.add_overlay(M_icon_r)
        belt.add_overlay(M_icon_belt)
        back.add_overlay(M_icon_back)

    human_overlays["[SPRITE_SHEET_HELD]_l"] = l_hand
    human_overlays["[SPRITE_SHEET_HELD]_r"] = r_hand
    human_overlays["[SPRITE_SHEET_BELT]"] = belt
    human_overlays["[SPRITE_SHEET_BACK]"] = back

    update_icon()

obj/item/weapon/gun_modular/module/frame/get_standing_overlay(mob/living/carbon/human/H, def_icon_path, sprite_sheet_slot, layer, bloodied_icon_state = null, icon_state_appendix = null)
    var/image/I = ..()
    src.update_icon()
    I.icon_state = ""
    if(human_overlays["[sprite_sheet_slot][icon_state_appendix]"])
        I.add_overlay(human_overlays["[sprite_sheet_slot][icon_state_appendix]"])
    return I

obj/item/weapon/gun_modular/module/frame/examine(mob/user)
    ..()
    if(!in_range(user, src))
        return
    var/dir = "The weapon consists of:\n"
    for(var/key in modules)
        var/obj/item/weapon/gun_modular/module/M = modules[key]
        if(!M)
            continue
        dir += "[bicon(M)] [M.name]. <span class='info'>[EMBED_TIP("More info.", M.get_info_module())]</span>\n"
    dir += "<br>"
    dir += "Weapon size - [size_gun > SMALL_GUN ? size_gun < LARGE_GUN ? "Medium size" : "Large size" : "Small size"]\n"
    dir += "Reduced spread - [lessdispersion >= CRITICAL_LOW_REDUCED ? lessdispersion < GOOD_REDUCED ? "Low Reduced" : "Good Reduced" : "CRITICAL LOW REDUCED"]\n"
    dir += "<br>"
    dir += "Configs:\n"
    for(var/key in config_user)
        var/config_text = ""
        if(!modules[config_user[key]])
            config_text = "[key] - module not detected\n"
        else
            config_text = "[key] - [modules[config_user[key]].name]\n"
        dir += config_text
    to_chat(user, dir)

obj/item/weapon/gun_modular/module/frame/atom_init()
    . = ..()
    var/matrix/frame_change = matrix()
    frame_change.Scale(0.85)
    frame_change.Turn(315)
    animate(src, pixel_x = move_x, pixel_y = move_y, transform = frame_change)
    update_icon()
    
obj/item/weapon/gun_modular/module/frame/Destroy()
    for(var/key in modules)
        if(modules[key])
            modules[key].Destroy()
    return ..()

// Generation of icons for the radial menu, generated when creating a configuration for a weapon

obj/item/weapon/gun_modular/module/frame/proc/generate_radial_icon()
    radial_icons = list()
    for(var/key in modules)
        if(modules[key])
            radial_icons[key] = image(modules[key].icon, modules[key].icon_state)

// Weapon configuration by index, you can configure which module to activate during actions. Now done by clicking on the weapon and by CTRL clicking

obj/item/weapon/gun_modular/module/frame/proc/config_user(mob/user, var/index)
    if(!modules[config_user[index]])
        config_user[index] = null
    if(!config_user[index])
        generate_radial_icon()
        var/rezult = show_radial_menu(user, src, radial_icons, tooltips = TRUE)
        config_user[index] = rezult
    else
        modules[config_user[index]].activate(user)

obj/item/weapon/gun_modular/module/frame/verb/reset_config()
    set src in usr
    set name = "Reset Config"
    set category = "Gun"

    config_user = list()

obj/item/weapon/gun_modular/module/frame/verb/select_fire_chamber()
    set src in usr
    set name = "Select fire"
    set category = "Gun"

    if(chamber)
        chamber.activate(usr)

obj/item/weapon/gun_modular/module/frame/verb/eject_magazine()
    set src in usr
    set name = "Eject magazine/ammo"
    set category = "Gun"

    if(magazine)
        magazine.activate(usr)

obj/item/weapon/gun_modular/module/frame/dropped(mob/user)
    . = ..()
    if(accessories)
        for(var/obj/item/weapon/gun_modular/module/accessory/A in accessories)
            A.loc = src
            A.deactivate(user)

obj/item/weapon/gun_modular/module/frame/attack_hand(mob/user)
    . = ..()
    if(accessories)
        for(var/obj/item/weapon/gun_modular/module/accessory/A in accessories)
            A.loc = user

obj/item/weapon/gun_modular/module/frame/attack_self(mob/user)
    . = ..()
    config_user(user, "AttackSelf")

obj/item/weapon/gun_modular/module/frame/AltClick(mob/user)
    . = ..()
    config_user(user, "AltClick")

// Pulling objects out of the frame is done according to a different principle, since this is a common use for all modules, it is activated with a screwdriver. Here, when you click with a screwdriver, a module for pulling out is given

obj/item/weapon/gun_modular/module/frame/remove_items(mob/user)
    if(!modules)
        return
    generate_radial_icon()
    var/remove = show_radial_menu(user, src, radial_icons, tooltips = TRUE)
    if(!remove)
        return
    if(!do_after(user, 2 SECOND, target = src))
        return FALSE
    modules[remove].remove(user)

obj/item/weapon/gun_modular/module/frame/attackby(obj/item/weapon/W, mob/user, params)
    ..()
    if(istype(W, /obj/item/weapon/gun_modular/module))
        var/obj/item/weapon/gun_modular/module/module = W
        module.attach(src, user)
        return TRUE
    else if(active_accessory && active_accessory.attackby(W, user))
        return TRUE
    else if(!isscrewdriver(W))
        for(var/key in modules)
            if(modules[key])
                var/obj/item/weapon/gun_modular/module/M = modules[key]
                if(M.attackby(W, user))
                    break
        return TRUE

obj/item/weapon/gun_modular/module/frame/afterattack(atom/A, mob/living/user, flag, params)
    if(!handle)
        return FALSE
    if(!handle.Special_Check(user))
        return FALSE
    if(active_accessory)
        if(!active_accessory.target_activate(A, user))
            return FALSE
    if(chamber)
        chamber.Fire(A, user, params)

obj/item/weapon/gun_modular/module/frame/attack(mob/living/M, mob/living/user, def_zone)
    if(!handle)
        return FALSE
    if(!handle.Special_Check(user))
        return ..()
    if(user.a_intent == INTENT_HARM)
        if(chamber)
            chamber.Fire(M, user, TRUE)
        return
    return ..()

obj/item/weapon/gun_modular/module/frame/can_attach(var/obj/item/weapon/gun_modular/module/M)
    if(!istype(M, /obj/item/weapon/gun_modular/module))
        return FALSE
    var/obj/item/weapon/gun_modular/module/module = M
    return module.checking_to_attach(src)

// Changing the stats of weapons, called when the module is attached, as well as when it is pulled

obj/item/weapon/gun_modular/module/frame/proc/change_state(var/obj/item/weapon/gun_modular/module/M, var/attach = TRUE)
    if(!istype(M, /obj/item/weapon/gun_modular/module))
        return FALSE
    var/obj/item/weapon/gun_modular/module/module = M
    if(attach)
        lessdamage += module.lessdamage
        lessdispersion += module.lessdispersion
        size_gun += module.size_gun
    else
        lessdamage -= module.lessdamage
        lessdispersion -= module.lessdispersion
        size_gun -= module.size_gun
        if(size_gun >= SMALL_GUN)
            w_class = ITEM_SIZE_SMALL
        if(size_gun >= MEDIUM_GUN)
            w_class = ITEM_SIZE_NORMAL
        if(size_gun >= LARGE_GUN)
            w_class = ITEM_SIZE_LARGE
    build_images()
    update_icon()
    return TRUE

// These are weapon presets for testing, and can be used to create station or spawn weapon presets. The main thing is to observe the order as when assembling

obj/item/weapon/gun_modular/module/frame/ptr_heavyrifle/atom_init()
    . = ..()
    var/obj/item/weapon/gun_modular/module/chamber/heavyrifle/new_chamber = new(src)
    var/obj/item/weapon/gun_modular/module/magazine/bullet/heavyrifle/new_magazine = new(src)
    var/obj/item/ammo_box/magazine/internal/heavyrifle/internal_magazine = new(src)
    var/obj/item/weapon/gun_modular/module/handle/rifle/new_handle = new(src)
    var/obj/item/weapon/gun_modular/module/barrel/rifle_bullet/new_barrel = new(src)
    var/obj/item/weapon/gun_modular/module/accessory/optical/large/new_optical = new(src)
    new_chamber.attach(src)
    new_magazine.attach_item_in_module(internal_magazine)
    new_magazine.attach(src)
    new_handle.attach(src)
    new_barrel.attach(src)
    new_optical.attach(src)

obj/item/weapon/gun_modular/module/frame/energy_shotgun/atom_init()
    . = ..()
    var/obj/item/weapon/gun_modular/module/chamber/energy/shotgun/new_chamber = new(src)
    var/obj/item/weapon/gun_modular/module/magazine/energy/new_magazine = new(src)
    var/obj/item/weapon/stock_parts/cell/bluespace/internal_magazine = new(src)
    var/obj/item/weapon/gun_modular/module/handle/shotgun/new_handle = new(src)
    var/obj/item/weapon/gun_modular/module/barrel/rifle_laser/new_barrel = new(src)
    var/obj/item/weapon/gun_modular/module/accessory/optical/large/new_optical = new(src)
    var/obj/item/weapon/gun_modular/module/accessory/additional_battery/new_additional = new(src)
    var/obj/item/weapon/stock_parts/cell/bluespace/internal_magazine2 = new(src)
    var/obj/item/ammo_casing/energy/laser/ammo_case1 = new(src)
    var/obj/item/ammo_casing/energy/xray/ammo_case2 = new(src)
    var/obj/item/weapon/gun_modular/module/accessory/core_charger/core_charger = new(src)
    var/obj/item/device/assembly/signaler/anomaly/core = new(src)
    new_chamber.attach_item_in_module(ammo_case1)
    new_chamber.attach_item_in_module(ammo_case2)
    new_chamber.attach(src)
    new_magazine.attach_item_in_module(internal_magazine)
    new_magazine.attach(src)
    new_handle.attach(src)
    new_barrel.attach(src)
    new_optical.attach(src)
    new_additional.attach_item_in_module(internal_magazine2)
    new_additional.attach(src)
    core_charger.attach_item_in_module(core)
    core_charger.attach(src)

obj/item/weapon/gun_modular/module/frame/pistol_9mm/atom_init()
    . = ..()
    var/obj/item/weapon/gun_modular/module/chamber/new_chamber = new(src)
    var/obj/item/weapon/gun_modular/module/magazine/bullet/new_magazine = new(src)
    var/obj/item/ammo_box/magazine/m9mm/internal_magazine = new(src)
    var/obj/item/weapon/gun_modular/module/handle/new_handle = new(src)
    var/obj/item/weapon/gun_modular/module/barrel/medium/new_barrel = new(src)
    new_chamber.attach(src)
    new_magazine.attach_item_in_module(internal_magazine)
    new_magazine.attach(src)
    new_handle.attach(src)
    new_barrel.attach(src)
