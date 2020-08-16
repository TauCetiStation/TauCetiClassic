obj/item/weapon/gun_modular/module
    name = "gun module"
    icon = 'code/modules/projectiles/gun_modular/modular.dmi'
    desc = ""
    w_class = ITEM_SIZE_SMALL
    var/icon/icon_overlay
    var/icon_overlay_name
    var/prefix_radial
    var/caliber
    var/lessdamage = 0
    var/lessdispersion = 0
    var/size_gun = 1
    var/gun_type
    var/obj/item/weapon/gun_modular/module/frame/frame_parent = null
    var/move_x = 1
    var/move_y = 1

obj/item/weapon/gun_modular/module/atom_init()
    . = ..()
    icon_overlay = image(icon, icon_overlay_name)

obj/item/weapon/gun_modular/module/examine(mob/user)
    . = ..()
    to_chat(user, "[bicon(src)] [name]. <span class='info'>[EMBED_TIP("More info.", get_info_module())]</span><br>")

obj/item/weapon/gun_modular/module/proc/get_info_module()
    var/info_module = "[desc]"
    info_module += "[lessdamage] - Damage reduction\n"
    info_module += "[lessdispersion] - Increased accuracy\n"
    info_module += "[size_gun] - Module size\n"
    return info_module

obj/item/weapon/gun_modular/module/attackby(obj/item/weapon/W, mob/user, params)
    . = ..()
    if(isscrewdriver(W))
        remove_items()
        return
    attach_item_in_module(W, user)

obj/item/weapon/gun_modular/module/proc/activate(mob/user, var/argument="")
    return FALSE

obj/item/weapon/gun_modular/module/proc/deactivate(mob/user, var/argument="")
    return FALSE

obj/item/weapon/gun_modular/module/proc/remove_items()
    for(var/obj/item/I in contents)
        remove_item_in_module(I)
        I.update_icon()
obj/item/weapon/gun_modular/module/proc/remove_item_in_module(var/obj/item/I)
    return FALSE

obj/item/weapon/gun_modular/module/proc/attach_item_in_module(var/obj/item/I, mob/user = null)
    return can_attach(I)

obj/item/weapon/gun_modular/module/proc/can_attach(var/obj/item/I)
    return FALSE

obj/item/weapon/gun_modular/module/proc/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!istype(I, /obj/item/weapon/gun_modular/module/frame))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    if(isnull(frame.chamber))
        return FALSE
    if(caliber != frame.caliber && caliber != ALL_CALIBER)
        return FALSE
    if(gun_type != frame.gun_type && gun_type != ALL_GUN_TYPE)
        return FALSE
    return TRUE

obj/item/weapon/gun_modular/module/proc/attach(var/obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!istype(I))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    if(frame.modules[prefix_radial] != null)
        return FALSE
    if(!frame.can_attach(src))
        return FALSE
    frame_parent = frame
    LAZYINITLIST(frame.modules)
    frame.modules[prefix_radial] = src
    frame.change_state(src, TRUE)
    if(user)
        user.drop_item()
    src.loc = frame
    animate(icon_overlay, pixel_x = move_x, pixel_y = move_y)
    frame_parent.add_overlay(icon_overlay)
    return TRUE

obj/item/weapon/gun_modular/module/proc/remove()
    frame_parent.modules[prefix_radial] = null
    frame_parent.change_state(src, FALSE)
    src.loc = get_turf(frame_parent)
    frame_parent.cut_overlay(icon_overlay)
    if(frame_parent)
        for(var/key in frame_parent.modules)
            var/obj/item/weapon/gun_modular/module/module = frame_parent.modules[key]
            if(module && module.check_remove())
                module.remove()
    frame_parent = null

obj/item/weapon/gun_modular/module/proc/check_remove()
    return !checking_to_attach(frame_parent)