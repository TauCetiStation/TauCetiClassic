#define ENERGY_GUN 1
#define BULLET_GUN 2
#define ALL_GUN_TYPE 4

#define ALL_CALIBER 1

obj/item/weapon/gun_modular/module
    name = "gun module"
    icon = 'code/modules/projectiles/gun_modular/modular.dmi'
    var/icon/icon_overlay
    var/icon_overlay_name
    var/caliber
    var/lessdamage = 0
    var/lessdispersion = 0
    var/size_gun = 1
    var/gun_type
    var/obj/item/weapon/gun_modular/module/frame/frame_parent = null
    var/parent_module_type = /obj/item/weapon/gun_modular/module

obj/item/weapon/gun_modular/module/atom_init()
    . = ..()
    icon_overlay = image(icon, icon_overlay_name)

obj/item/weapon/gun_modular/module/attackby(obj/item/weapon/W, mob/user, params)
    . = ..()
    attach_item_in_module(W, user)

obj/item/weapon/gun_modular/module/proc/activate(mob/user, var/argument="")
    return FALSE

obj/item/weapon/gun_modular/module/proc/deactivate(mob/user, var/argument="")
    return FALSE

obj/item/weapon/gun_modular/module/proc/remove_item_in_module(var/obj/item/I)
    return FALSE

obj/item/weapon/gun_modular/module/proc/attach_item_in_module(var/obj/item/I, mob/user)
    return can_attach(I)

obj/item/weapon/gun_modular/module/proc/can_attach(var/obj/item/I)
    return FALSE

obj/item/weapon/gun_modular/module/proc/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!istype(I, /obj/item/weapon/gun_modular/module/frame))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    if(caliber != frame.caliber && caliber != ALL_CALIBER)
        return FALSE
    if(gun_type != frame.gun_type && gun_type != ALL_GUN_TYPE)
        return FALSE
    return TRUE

obj/item/weapon/gun_modular/module/proc/attach(var/obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!istype(I, /obj/item/weapon/gun_modular/module/frame))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    for(var/obj/item/weapon/gun_modular/module/module in frame.modules)
        if(parent_module_type == module.parent_module_type)
            return FALSE
    if(!frame.can_attach(src))
        return FALSE
    frame_parent = frame
    LAZYINITLIST(frame.modules)
    LAZYADD(frame.modules, src)
    frame.change_state(src, TRUE)
    if(user)
        user.drop_item()
    src.loc = frame
    frame_parent.add_overlay(icon_overlay)
    return TRUE

obj/item/weapon/gun_modular/module/proc/remove()
    LAZYREMOVE(frame_parent.modules, src)
    if(frame_parent)
        for(var/obj/item/weapon/gun_modular/module/module in frame_parent.modules)
            if(module.check_remove())
                module.remove()
    frame_parent.change_state(src, FALSE)
    src.loc = get_turf(frame_parent)
    frame_parent.cut_overlay(icon_overlay)
    frame_parent = null

obj/item/weapon/gun_modular/module/proc/check_remove()
    return !checking_to_attach(frame_parent)