#define SMALL_GUN 5
#define MEDIUM_GUN 9
#define LARGE_GUN 12
#define GOOD_REDUCED 0
#define LOW_REDUCED -2
#define CRITICAL_LOW_REDUCED -4
obj/item/weapon/gun_modular/module/frame
    name = "gun frame"
    icon_state = "chamber_energy"
    lessdamage = 0
    lessdispersion = -4
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

obj/item/weapon/gun_modular/module/frame/examine(mob/user)
    . = ..()
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

obj/item/weapon/gun_modular/module/frame/proc/generate_radial_icon()
    radial_icons = list()
    for(var/key in modules)
        if(modules[key])
            radial_icons[key] = image(modules[key].icon, modules[key].icon_state)

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

obj/item/weapon/gun_modular/module/frame/attackby(obj/item/weapon/W, mob/user, params)
    . = ..()
    if(istype(W, /obj/item/weapon/gun_modular/module))
        var/obj/item/weapon/gun_modular/module/module = W
        module.attach(src, user)
    if(isscrewdriver(W))
        if(!modules)
            return
        generate_radial_icon()
        var/remove = show_radial_menu(user, src, radial_icons, tooltips = TRUE)
        if(!remove)
            return
        modules[remove].remove()
    else if(active_accessory && active_accessory.attach_item_in_module(W, user))
        return
    else
        for(var/key in modules)
            if(modules[key])
                var/obj/item/weapon/gun_modular/module/M = modules[key]
                if(M.attach_item_in_module(W, user))
                    break

obj/item/weapon/gun_modular/module/frame/afterattack(atom/A, mob/living/user, flag, params)
    if(!handle)
        return FALSE
    if(!handle.Special_Check(user))
        return FALSE
    if(active_accessory)
        active_accessory.target_activate(A, user)
    if(chamber)
        chamber.Fire(A, user, params)

obj/item/weapon/gun_modular/module/frame/can_attach(var/obj/item/weapon/gun_modular/module/M)
    if(!istype(M, /obj/item/weapon/gun_modular/module))
        return FALSE
    var/obj/item/weapon/gun_modular/module/module = M
    return module.checking_to_attach(src)

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
    return TRUE

///////////////////////////////////////////set up

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
