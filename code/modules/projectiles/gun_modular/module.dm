/obj/structure/gun_bench
    name = "gun bench"
    icon = 'code/modules/projectiles/gun_modular/modular.dmi'
    icon_state = "bench_open"
    desc = ""
    var/obj/item/weapon/gun_modular/module/frame/frame_parent = null
    var/image/frame_overlay

/obj/structure/gun_bench/attackby(obj/item/weapon/W, mob/user, params)
    ..()
    if(istype(W, /obj/item/weapon/gun_modular/module/frame))
        if(!frame_parent)
            var/obj/item/weapon/gun_modular/module/frame/F = W
            frame_parent = F
            frame_overlay = image(frame_parent.icon_overlay.icon, frame_parent.icon_overlay.icon_state)
            frame_overlay.appearance = frame_parent.icon_overlay.appearance
            frame_overlay.layer = OBJ_LAYER
            var/matrix/frame_change = matrix()
            frame_change.Scale(0.7)
            animate(frame_overlay, transform = frame_change)
            add_overlay(frame_parent.icon_overlay)
    

/obj/item/weapon/gun_modular/module
    name = "gun module"
    icon = 'code/modules/projectiles/gun_modular/modular.dmi'
    desc = ""
    w_class = ITEM_SIZE_SMALL
    var/list/points_of_entry = list()
    var/list/exit_point = "0,0"
    var/image/icon_overlay
    var/icon_overlay_name
    var/icon_overlay_layer
    var/prefix
    var/caliber
    var/lessdamage = 0
    var/lessdispersion = 0
    var/size_gun = 1
    var/gun_type
    var/obj/item/weapon/gun_modular/module/frame/frame_parent = null

/obj/item/weapon/gun_modular/module/update_icon()
    icon_overlay = image(icon, icon_overlay_name, layer = icon_overlay_layer)
    icon_overlay.color = color
    return

/obj/item/weapon/gun_modular/module/atom_init()
    . = ..()
    icon_overlay = image(icon, icon_overlay_name, layer = icon_overlay_layer)
    icon_overlay.appearance_flags |= KEEP_TOGETHER

/obj/item/weapon/gun_modular/module/examine(mob/user)
    . = ..()
    to_chat(user, "[bicon(src)] [name]. <span class='info'>[EMBED_TIP("More info.", get_info_module(user))]</span><br>")

/obj/item/weapon/gun_modular/module/Destroy()
    if(frame_parent)
        remove()
    return ..()

/obj/item/weapon/gun_modular/module/proc/get_delta_offset(var/point = prefix)
    var/list/points_attach = text2numlist(exit_point, ",")
    var/list/points_modify = list(0, 0)
    var/list/points_null = text2numlist(frame_parent.exit_point, ",")
    if(frame_parent.points_of_entry[point])
        points_modify = text2numlist(frame_parent.points_of_entry[point], ",")

    var/delta_x = points_modify[1] - points_attach[1]
    var/delta_y = points_modify[2] - points_attach[2]

    for(var/key in points_of_entry)
        var/list/point_of_entry = text2numlist(points_of_entry[key], ",")
        frame_parent.points_of_entry[key] = "[points_null[1] + (point_of_entry[1] + (delta_x - points_null[1]))],[points_null[2] + (point_of_entry[2] + (delta_y - points_null[2]))]"

    return list(delta_x, delta_y)

// This gives information in the tooltip, here you can talk about additional weapon stats

/obj/item/weapon/gun_modular/module/proc/get_info_module(mob/user = null)
    var/info_module = ""
    if(desc != "")
        info_module += "[desc]\n"
    if(user)
        if(!hasHUD(user, "science") && !hasHUD(user, "security"))
            return info_module
    info_module += "Damage reduction - ([lessdamage])\n"
    info_module += "Increased accuracy - ([lessdispersion])\n"
    info_module += "Module size - ([size_gun])\n"
    info_module += "Compatible caliber - ([caliber])\n"
    info_module += "Compatible weapon type - ([gun_type])\n"
    info_module += "Additional module parameters:\n"
    return info_module

/obj/item/weapon/gun_modular/module/attackby(obj/item/weapon/W, mob/user, params)
    ..()
    if(isscrewdriver(W))
        remove_items(user)
        return TRUE
    if(attach_item_in_module(W, user))
        return TRUE

// Activation of the module, configs are sent to this, as well as deactivation of modules, it is activated to return everything to the past state

/obj/item/weapon/gun_modular/module/proc/activate(mob/user, var/argument="")
    return FALSE

/obj/item/weapon/gun_modular/module/proc/deactivate(mob/user, var/argument="")
    return FALSE

// Removing all items that were installed in the weapon

/obj/item/weapon/gun_modular/module/proc/remove_items(mob/user)
    if(!contents.len)
        return FALSE
    if(in_use_action)
        return FALSE
    if(!do_after(user, 2 SECOND, target = src, needhand = TRUE))
        return FALSE
    for(var/obj/item/I in contents)
        remove_item_in_module(I)
        I.loc = get_turf(src)
        I.update_icon()
    return TRUE

/obj/item/weapon/gun_modular/module/proc/remove_item_in_module(var/obj/item/I)
    return FALSE

/obj/item/weapon/gun_modular/module/proc/attach_item_in_module(var/obj/item/I, mob/user = null)
    if(user)
        if(in_use_action)
            return FALSE
    return can_attach(I)

/obj/item/weapon/gun_modular/module/proc/can_attach(var/obj/item/I)
    return FALSE

// Check for the ability to attach the module to the frame

/obj/item/weapon/gun_modular/module/proc/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
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

// Module attachment procedure

/obj/item/weapon/gun_modular/module/proc/attach(var/obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!istype(I))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    if(frame.modules[prefix] != null)
        return FALSE
    if(!frame.can_attach(src))
        return FALSE
    if(user)
        if(I.in_use_action)
            return FALSE
        if(!do_after(user, 1 SECOND, target = I, needhand = TRUE))
            return FALSE
        if(!in_range(user, frame))
            return FALSE
        user.drop_item()
        to_chat(user, "Module '[name]' was attached")
    src.loc = frame
    frame_parent = frame
    LAZYINITLIST(frame.modules)
    
    var/list/delta_offset = get_delta_offset()

    icon_overlay.pixel_x = delta_offset[1]
    icon_overlay.pixel_y = delta_offset[2]

    frame_parent.add_overlay(icon_overlay)
    frame.modules[prefix] = src
    frame.change_state(src, TRUE)
    return TRUE

// Module removal procedure

/obj/item/weapon/gun_modular/module/proc/remove(mob/user = null)
    for(var/key in points_of_entry)
        if(frame_parent.points_of_entry[key])
            frame_parent.points_of_entry[key] = null
    icon_overlay.pixel_x = 0
    icon_overlay.pixel_y = 0
    frame_parent.modules[prefix] = null
    frame_parent.cut_overlay(icon_overlay)
    frame_parent.update_icon()
    frame_parent.change_state(src, FALSE)
    src.loc = get_turf(frame_parent)
    if(frame_parent)
        for(var/key in frame_parent.modules)
            var/obj/item/weapon/gun_modular/module/module = frame_parent.modules[key]
            if(module && module.check_remove())
                module.remove(user)
    frame_parent = null
    if(user)
        to_chat(user, "Module '[name]' has been removed")

// This check is called for each module when a module is removed from a weapon. This is done to avoid conflicts.

/obj/item/weapon/gun_modular/module/proc/check_remove()
    return !checking_to_attach(frame_parent)