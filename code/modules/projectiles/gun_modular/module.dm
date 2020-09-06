/obj/structure/gun_bench
    name = "gun bench"
    icon = 'code/modules/projectiles/gun_modular/modular.dmi'
    icon_state = "bench_open"
    desc = ""
    density = TRUE
    anchored = TRUE
    var/obj/item/weapon/gun_modular/module/frame/frame_parent = null
    var/image/frame_overlay

/obj/structure/gun_bench/attackby(obj/item/weapon/W, mob/user, params)
    ..()
    if(istype(W, /obj/item/weapon/gun_modular/module/frame))
        if(!frame_parent)
            var/obj/item/weapon/gun_modular/module/frame/F = W
            frame_parent = F
            user.drop_item()
            frame_parent.loc = src
            frame_overlay = image(icon, icon_state = "")
            frame_overlay.appearance = frame_parent.frame_overlays["icon"]
            var/matrix/frame_change = matrix()
            frame_change.Scale(0.5)
            animate(frame_overlay, pixel_y = 6, transform = frame_change)
            add_overlay(frame_overlay)
            return
    if(istype(W, /obj/item/weapon/gun_modular/module))
        if(frame_parent)
            var/obj/item/weapon/gun_modular/module/M = W
            M.attach(frame_parent, user)
            icon_state = "bench_work"
            var/image/work_overlay = image(icon = icon, icon_state = "overlay_work", layer = 5)
            add_overlay(work_overlay)
            if(do_after(user, 2 SECOND, needhand = FALSE, target = src, can_move = FALSE, progress = TRUE))
                icon_state = "bench_open"
                cut_overlays()
            frame_overlay.appearance = frame_parent.frame_overlays["icon"]
            var/matrix/frame_change = matrix()
            frame_change.Scale(0.5)
            animate(frame_overlay, pixel_y = 6, transform = frame_change)
            add_overlay(frame_overlay)

/obj/item/weapon/gun_modular/module
    name = "gun module"
    icon = 'code/modules/projectiles/gun_modular/modular.dmi'
    desc = ""
    w_class = ITEM_SIZE_SMALL
    var/list/points_of_entry = list()
    var/list/exit_point = list()
    var/list/image/icon_overlay = list()
    var/icon_overlay_name
    var/prefix
    var/caliber
    var/lessdamage = 0
    var/lessdispersion = 0
    var/size_gun = 1
    var/gun_type
    var/obj/item/weapon/gun_modular/module/frame/frame_parent = null

/obj/item/weapon/gun_modular/module/examine(mob/user)
    . = ..()
    to_chat(user, "[bicon(src)] [name]. <span class='info'>[EMBED_TIP("More info.", get_info_module(user))]</span><br>")

/obj/item/weapon/gun_modular/module/Destroy()
    if(frame_parent)
        remove()
    return ..()

/obj/item/weapon/gun_modular/module/update_icon()
    for(var/key in icon_overlay)
        if(icon_overlay[key])
            icon_overlay[key].color = color
    return

/obj/item/weapon/gun_modular/module/atom_init()
    . = ..()
    icon_overlay["ICON"] = image(icon, icon_overlay_name)
    icon_overlay["ICON"].appearance_flags |= KEEP_TOGETHER
    icon_overlay["[SPRITE_SHEET_HELD]_l"] = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[icon_overlay_name]_l")
    icon_overlay["[SPRITE_SHEET_HELD]_r"] = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[icon_overlay_name]_r")
    icon_overlay["[SPRITE_SHEET_BELT]"] = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[icon_overlay_name]_belt")
    icon_overlay["[SPRITE_SHEET_BACK]"] = image(icon = 'code/modules/projectiles/gun_modular/modular_overlays.dmi', icon_state = "[icon_overlay_name]_back")
    build_points_list()

/obj/item/weapon/gun_modular/module/proc/build_points_list()
    change_list_exit("ICON", "[SOUTH]", list(0, 0))

    change_list_exit("[SPRITE_SHEET_HELD]_l", "[SOUTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[NORTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[EAST]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[WEST]", list(0, 0))

    change_list_exit("[SPRITE_SHEET_HELD]_r", "[SOUTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[NORTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[EAST]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[WEST]", list(0, 0))

    change_list_exit("[SPRITE_SHEET_BELT]", "[SOUTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_BELT]", "[NORTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_BELT]", "[EAST]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_BELT]", "[WEST]", list(0, 0))

    change_list_exit("[SPRITE_SHEET_BACK]", "[SOUTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_BACK]", "[NORTH]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_BACK]", "[EAST]", list(0, 0))
    change_list_exit("[SPRITE_SHEET_BACK]", "[WEST]", list(0, 0))

    change_list_entry("ICON", "[SOUTH]", null)

    change_list_entry("[SPRITE_SHEET_HELD]_l", "[SOUTH]", null)
    change_list_entry("[SPRITE_SHEET_HELD]_l", "[NORTH]", null)
    change_list_entry("[SPRITE_SHEET_HELD]_l", "[EAST]", null)
    change_list_entry("[SPRITE_SHEET_HELD]_l", "[WEST]", null)

    change_list_entry("[SPRITE_SHEET_HELD]_r", "[SOUTH]", null)
    change_list_entry("[SPRITE_SHEET_HELD]_r", "[NORTH]", null)
    change_list_entry("[SPRITE_SHEET_HELD]_r", "[EAST]", null)
    change_list_entry("[SPRITE_SHEET_HELD]_r", "[WEST]", null)

    change_list_entry("[SPRITE_SHEET_BELT]", "[SOUTH]", null)
    change_list_entry("[SPRITE_SHEET_BELT]", "[NORTH]", null)
    change_list_entry("[SPRITE_SHEET_BELT]", "[EAST]", null)
    change_list_entry("[SPRITE_SHEET_BELT]", "[WEST]", null)

    change_list_entry("[SPRITE_SHEET_BACK]", "[SOUTH]", null)
    change_list_entry("[SPRITE_SHEET_BACK]", "[NORTH]", null)
    change_list_entry("[SPRITE_SHEET_BACK]", "[EAST]", null)
    change_list_entry("[SPRITE_SHEET_BACK]", "[WEST]", null)
    return TRUE

/obj/item/weapon/gun_modular/module/proc/change_list_entry(var/type, var/direct, var/list/points, var/key = null)
    LAZYINITLIST(points_of_entry)
    LAZYINITLIST(points_of_entry[type])
    LAZYINITLIST(points_of_entry[type][direct])
    if(key)
        points_of_entry[type][direct][key] = points
        return TRUE
    for(var/key_tmp in points)
        points_of_entry[type][direct][key_tmp] = points[key_tmp]
    return TRUE

/obj/item/weapon/gun_modular/module/proc/change_list_exit(var/type, var/direct, var/list/points)
    LAZYINITLIST(exit_point)
    LAZYINITLIST(exit_point[type])
    LAZYINITLIST(exit_point[type][direct])
    exit_point[type][direct] = points
    return TRUE

/obj/item/weapon/gun_modular/module/proc/check_list_point(var/list/changed_list, var/type, var/direct, var/point = null)
    if(!changed_list)
        return FALSE
    if(!changed_list[type])
        return FALSE
    if(!changed_list[type][direct])
        return FALSE
    if(point)
        if(!changed_list[type][direct][point])
            return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/proc/get_delta_offset(var/type = "ICON", var/direct = "[SOUTH]", var/point = prefix)
    var/list/points_modify = list(0, 0, -3)
    if(frame_parent.check_list_point(frame_parent.points_of_entry, type, direct, point))
        points_modify = frame_parent.points_of_entry[type][direct][point]

    var/delta_x = 0
    var/delta_y = 0
    var/layer_overlay = points_modify[3]

    delta_x = points_modify[1] - exit_point[type][direct][1]
    delta_y = points_modify[2] - exit_point[type][direct][2]
    
    if(check_list_point(points_of_entry, type, direct))
        for(var/key in points_of_entry[type][direct])
            if(frame_parent.check_list_point(frame_parent.points_of_entry, type, direct, key))
                continue
            frame_parent.change_list_entry(type, direct, list(points_of_entry[type][direct][key][1] + delta_x, points_of_entry[type][direct][key][2] + delta_y, points_of_entry[type][direct][key][3]), key)

    return list(delta_x, delta_y, layer_overlay)

// This gives information in the tooltip, here you can talk about additional weapon stats

/obj/item/weapon/gun_modular/module/proc/get_info_module(mob/user = null)
    var/info_module = ""
    if(desc != "")
        info_module += "[desc]\n"
    if(user)
        if(!hasHUD(user, "science") && !hasHUD(user, "security"))
            info_module += "Nothing interesting..."
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
    if(!frame.check_list_point(frame.points_of_entry, "ICON", "[SOUTH]", prefix))
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

    icon_overlay["ICON"].pixel_x = delta_offset[1]
    icon_overlay["ICON"].pixel_y = delta_offset[2]

    frame.modules[prefix] = src
    frame.change_state(src, TRUE)
    return TRUE

// Module removal procedure

/obj/item/weapon/gun_modular/module/proc/remove(mob/user = null)
    for(var/key_type in points_of_entry)
        for(var/key_dir in points_of_entry[key_type])
            for(var/key in points_of_entry[key_type][key_dir])
                frame_parent.change_list_entry(key_type, key_dir, null, key)
    frame_parent.modules[prefix] = null
    src.loc = get_turf(frame_parent)
    if(frame_parent)
        for(var/key in frame_parent.modules)
            var/obj/item/weapon/gun_modular/module/module = frame_parent.modules[key]
            if(!module)
                continue
            module.deactivate(user)
            if(module.check_remove())
                module.remove(user)
    frame_parent.change_state(src, FALSE)
    update_icon()
    frame_parent = null
    if(user)
        to_chat(user, "Module '[name]' has been removed")

// This check is called for each module when a module is removed from a weapon. This is done to avoid conflicts.

/obj/item/weapon/gun_modular/module/proc/check_remove()
    return !checking_to_attach(frame_parent)