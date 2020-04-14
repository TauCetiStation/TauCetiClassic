obj/item/weapon/gun_modular/module/frame
    name = "gun frame"
    icon_state = "chamber_energy"
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    var/max_accessory = 3
    var/obj/item/weapon/gun_modular/module/chamber/chamber = null
    var/obj/item/weapon/gun_modular/module/handle/handle = null
    var/obj/item/weapon/gun_modular/module/barrel/barrel = null
    var/obj/item/weapon/gun_modular/module/magazine/magazine = null
    var/list/obj/item/weapon/gun_modular/module/modules = list()
    var/list/obj/item/weapon/gun_modular/module/accessories = list()

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

obj/item/weapon/gun_modular/module/frame/attack_self(mob/user)
    . = ..()
    if(magazine)
        magazine.activate(user)

obj/item/weapon/gun_modular/module/frame/AltClick(mob/user)
    . = ..()
    if(chamber)
        chamber.activate(user)

obj/item/weapon/gun_modular/module/frame/attackby(obj/item/weapon/W, mob/user, params)
    . = ..()
    if(istype(W, /obj/item/weapon/gun_modular/module))
        var/obj/item/weapon/gun_modular/module/module = W
        module.attach(src, user)
    if(isscrewdriver(W))
        var/list/current_mounts = list()
        if(!modules)
            return
        if(chamber)
            LAZYADD(current_mounts, "Chamber")
        if(handle)
            LAZYADD(current_mounts, "Handle")
        if(barrel)
            LAZYADD(current_mounts, "Barrel")
        if(magazine)
            LAZYADD(current_mounts, "Magazine holder")
        if(accessories.len)
            LAZYADD(current_mounts, "Accessories")
        var/remove = input("Which would you like to modify?") as null|anything in current_mounts
        if(!remove)
            return
        switch(remove)
            if("Chamber")
                if(chamber)
                    chamber.remove()
            if("Handle")
                if(handle)
                    handle.remove()
            if("Barrel")
                if(barrel)
                    barrel.remove()
            if("Magazine holder")
                if(magazine)
                    magazine.remove()
            if("Accessories")
                if(accessories.len)
                    for(var/obj/item/weapon/gun_modular/module/M in accessories)
                        M.remove()
    else
        for(var/obj/item/weapon/gun_modular/module/M in modules)
            M.attackby(W, user, params)

obj/item/weapon/gun_modular/module/frame/afterattack(atom/A, mob/living/user, flag, params)
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
        lessdamage -= module.lessdamage
        lessdispersion -= module.lessdispersion
        size_gun += module.size_gun
    else
        lessdamage += module.lessdamage
        lessdispersion += module.lessdispersion
        size_gun -= module.size_gun
    return TRUE