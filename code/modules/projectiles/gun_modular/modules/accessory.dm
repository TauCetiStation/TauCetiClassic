/obj/item/weapon/gun_modular/module/accessory
    name = "gun accessory"
    icon_state = "optical_medium_icon"
    icon_overlay_name = "optical_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    prefix = "Accessory"
    action_button_name = "Activate module"
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/accessory/attack_self(mob/user)
    . = ..()
    if(!frame_parent)
        return FALSE
    if(frame_parent.active_accessory == src)
        return deactivate_module(user)
    else if(frame_parent.active_accessory)
        frame_parent.active_accessory.deactivate_module(user)
    if(!frame_parent.active_accessory)
        activate_module(user)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/proc/activate_module(mob/user = null)
    action.background_icon_state = "bg_spell"
    if(user)
        user.update_action_buttons()
    frame_parent.active_accessory = src
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/proc/deactivate_module(mob/user = null)
    action.background_icon_state = "bg_default"
    if(user)
        user.update_action_buttons()
    frame_parent.active_accessory = null
    return TRUE

// It is activated if the module is active and the person tried to shoot, in this case, the code first occurs here, and if it returns FALSE, then the weapon will not fire

/obj/item/weapon/gun_modular/module/accessory/proc/target_activate(atom/A, mob/living/user)
    deactivate_module(user)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!istype(I, /obj/item/weapon/gun_modular/module/frame))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    LAZYINITLIST(frame.accessories)
    if(frame.max_accessory <= frame.accessories.len)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/attach(obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!..())
        return FALSE
    LAZYINITLIST(frame_parent.accessories)
    LAZYADD(frame_parent.accessories, src)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/remove()
    if(frame_parent.active_accessory == src)
        deactivate_module()
    if(frame_parent.accessories)
        LAZYREMOVE(frame_parent.accessories, src)
    ..()
    
/obj/item/weapon/gun_modular/module/accessory/optical
    name = "gun optical accessory"
    icon_state = "optical_large_icon"
    icon_overlay_name = "optical_large"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 3
    prefix = "Optical"
    gun_type = ALL_GUN_TYPE
    var/active = FALSE
    var/size_barrel = 1
    var/view_range = 6

/obj/item/weapon/gun_modular/module/accessory/optical/activate_module(mob/user = null)
    ..()
    if(!activate(user))
        deactivate_module(user)

/obj/item/weapon/gun_modular/module/accessory/optical/deactivate_module(mob/user = null)
    deactivate(user)
    ..()

/obj/item/weapon/gun_modular/module/accessory/optical/deactivate(mob/user, argument = "")
    if(active)
        UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))
        active = FALSE
    user.client.view = world.view
    if(user.hud_used)
        user.hud_used.show_hud(HUD_STYLE_STANDARD)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/optical/activate(mob/user, argument = "")
    if(active)
        deactivate(user, argument)
        return FALSE
    RegisterSignal(user, list(COMSIG_MOVABLE_MOVED), .proc/deactivate_module)
    if(!frame_parent)
        return FALSE
    if(user.stat || !(istype(user ,/mob/living/carbon/human)))
        to_chat(user, "You are unable to focus down the scope of the rifle.")
        return FALSE
    if(user.get_active_hand() != frame_parent)
        to_chat(user, "You are too distracted to look down the scope, perhaps if it was in your active hand this might work better")
        return FALSE
    if(user.hud_used)
        usr.hud_used.show_hud(HUD_STYLE_REDUCED)
    usr.client.view = view_range
    to_chat(usr, "<font color='[active?"blue":"red"]'>Zoom mode [active?"dis":"en"]abled.</font>")
    active = TRUE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/optical/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!I.barrel)
        return FALSE
    if(I.barrel.size_gun < size_barrel)
        return FALSE
    return TRUE
            
/obj/item/weapon/gun_modular/module/accessory/optical/verb/use_optical()
    set src in usr
    set name = "Use optical"
    set category = "Gun"

    if(!active)
        activate(usr)
    else
        deactivate(usr)

/obj/item/weapon/gun_modular/module/accessory/optical/small
    name = "gun optical small accessory"
    icon_state = "optical_small_icon"
    icon_overlay_name = "optical_small"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    view_range = 9
    size_barrel = 1
    
/obj/item/weapon/gun_modular/module/accessory/optical/small/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 1))

/obj/item/weapon/gun_modular/module/accessory/optical/medium
    name = "gun optical medium accessory"
    icon_state = "optical_medium_icon"
    icon_overlay_name = "optical_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1
    size_gun = 2
    gun_type = ALL_GUN_TYPE
    view_range = 11
    size_barrel = 2

/obj/item/weapon/gun_modular/module/accessory/optical/medium/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(6, 1))

/obj/item/weapon/gun_modular/module/accessory/optical/large
    name = "gun optical large accessory"
    icon_state = "optical_large_icon"
    icon_overlay_name = "optical_large"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1
    size_gun = 3
    gun_type = ALL_GUN_TYPE
    view_range = 14
    size_barrel = 3

/obj/item/weapon/gun_modular/module/accessory/optical/large/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(9, 1))

/obj/item/weapon/gun_modular/module/accessory/core_charger
    name = "gun core charger accessory"
    icon_state = "anomal_charger_icon"
    icon_overlay_name = "anomal_charger"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    prefix = "Core Charger"
    gun_type = ENERGY_GUN
    var/obj/item/device/assembly/signaler/anomaly/core = null
    var/tick = 0
    var/tick_charge = 8
    var/charge = 1000

/obj/item/weapon/gun_modular/module/accessory/core_charger/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(3, 1))

/obj/item/weapon/gun_modular/module/accessory/core_charger/Destroy()
    if(core)
        core.Destroy()
    core = null
    return ..()

/obj/item/weapon/gun_modular/module/accessory/core_charger/process()
    if(!frame_parent)
        return
    if(!frame_parent.magazine)
        return
    var/obj/item/weapon/gun_modular/module/magazine/energy/magazine_holder = frame_parent.magazine
    if(!magazine_holder.magazine)
        return
    tick++
    if(tick >= tick_charge)
        tick = 0
        magazine_holder.Give_Round(charge = src.charge)
        

/obj/item/weapon/gun_modular/module/accessory/core_charger/checking_to_attach(obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!core)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/core_charger/can_attach(obj/item/I)
    if(core)
        return FALSE
    if(!istype(I, /obj/item/device/assembly/signaler/anomaly))
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/core_charger/attach_item_in_module(obj/item/I, mob/user = null)
    if(!..())
        return FALSE
    if(user)
        user.drop_item()
    I.loc = src
    core = I
    icon_state = "anomal_charger_in_core_icon"
    START_PROCESSING(SSobj, src)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/core_charger/remove_item_in_module(obj/item/I)
    I.loc = get_turf(src)
    core = null
    icon_state = "anomal_charger_icon"
    STOP_PROCESSING(SSobj, src)

/obj/item/weapon/gun_modular/module/accessory/silenser
    name = "gun silenser"
    icon_state = "silenser_icon"
    icon_overlay_name = "silenser"
    caliber = ALL_CALIBER
    lessdamage = 6
    lessdispersion = 0.3
    size_gun = 2
    prefix = "Silenser"
    gun_type = BULLET_GUN

/obj/item/weapon/gun_modular/module/accessory/silenser/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 4))

    change_list_exit("[SPRITE_SHEET_HELD]_l", "[SOUTH]", list(6, 2))

/obj/item/weapon/gun_modular/module/accessory/silenser/attach(obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!..())
        return FALSE
    frame_parent.barrel.silensed = TRUE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/silenser/activate(mob/user, argument)
    return remove()

/obj/item/weapon/gun_modular/module/accessory/silenser/remove()
    if(frame_parent.barrel)
        frame_parent.barrel.silensed = initial(frame_parent.barrel.silensed)
    return ..()

/obj/item/weapon/gun_modular/module/accessory/silenser/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!I.barrel)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/bayonet
    name = "gun bayonet"
    icon_state = "bayonet_icon"
    icon_overlay_name = "bayonet"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 2
    prefix = "Bayonet"
    gun_type = ALL_GUN_TYPE
    force = 12
    edge = TRUE
    sharp = TRUE
    var/size_barrel = 2

/obj/item/weapon/gun_modular/module/accessory/bayonet/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(4, 5))

    change_list_exit("[SPRITE_SHEET_HELD]_l", "[SOUTH]", list(7, 2))

/obj/item/weapon/gun_modular/module/accessory/bayonet/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!I.barrel)
        return FALSE
    if(I.barrel.size_gun < size_barrel)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/bayonet/attach(obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!..())
        return FALSE
    frame_parent.force += 12
    frame_parent.edge = TRUE
    frame_parent.sharp = TRUE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/bayonet/activate(mob/user, argument)
    return remove(user)

/obj/item/weapon/gun_modular/module/accessory/bayonet/remove()
    frame_parent.force = initial(frame_parent.force)
    frame_parent.edge = initial(frame_parent.edge)
    frame_parent.sharp = initial(frame_parent.sharp)
    return ..()

/obj/item/weapon/gun_modular/module/accessory/additional_battery
    name = "gun additional battery"
    icon_state = "additional_battery_icon"
    icon_overlay_name = "additional_battery"
    caliber = "energy"
    lessdamage = 0
    lessdispersion = 0
    size_gun = 2
    prefix = "Additional Battery"
    gun_type = ENERGY_GUN
    var/obj/item/weapon/stock_parts/cell/additional_battery = null

/obj/item/weapon/gun_modular/module/accessory/additional_battery/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(15, 13))

/obj/item/weapon/gun_modular/module/accessory/additional_battery/Destroy()
    if(additional_battery)
        additional_battery.Destroy()
    additional_battery = null
    return ..()

/obj/item/weapon/gun_modular/module/accessory/additional_battery/activate_module(mob/user)
    ..()
    activate(user)
    deactivate_module(user)

/obj/item/weapon/gun_modular/module/accessory/additional_battery/activate(mob/user, argument)
    if(additional_battery)
        var/obj/item/weapon/stock_parts/cell/AB = additional_battery
        remove_item_in_module(AB)
        user.put_in_hands(AB)

/obj/item/weapon/gun_modular/module/accessory/additional_battery/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!additional_battery)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/additional_battery/can_attach(obj/item/I)
    if(additional_battery)
        return FALSE
    if(!istype(I, /obj/item/weapon/stock_parts/cell))
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/additional_battery/attach_item_in_module(obj/item/I, mob/user = null)
    if(!..())
        return FALSE
    if(user)
        user.drop_item()
    I.loc = src
    additional_battery = I
    START_PROCESSING(SSobj, src)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/additional_battery/remove_item_in_module(obj/item/I)
    I.loc = get_turf(src)
    I.update_icon()
    additional_battery = null
    STOP_PROCESSING(SSobj, src)

/obj/item/weapon/gun_modular/module/accessory/additional_battery/process()
    if(!frame_parent)
        return
    if(!frame_parent.magazine)
        return
    var/obj/item/weapon/gun_modular/module/magazine/energy/magazine_holder = frame_parent.magazine
    if(!magazine_holder.magazine)
        return
    var/delta_charge = magazine_holder.magazine.maxcharge - magazine_holder.magazine.charge
    if(delta_charge)
        magazine_holder.Give_Round(charge = additional_battery.use(delta_charge))

/obj/item/weapon/gun_modular/module/accessory/dna_crypter
    name = "gun dna crypter"
    icon_state = "dna_crypter_icon"
    icon_overlay_name = "dna_crypter"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    prefix = "DNA Crypter"
    gun_type = ALL_GUN_TYPE
    var/mob/living/carbon/Owner = null

/obj/item/weapon/gun_modular/module/accessory/dna_crypter/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(9, 5))

/obj/item/weapon/gun_modular/module/accessory/dna_crypter/activate(mob/user, argument)
    if(!Owner)
        Owner = user
    
/obj/item/weapon/gun_modular/module/accessory/dna_crypter/deactivate(mob/user, argument)
    if(!Owner)
        return
    if(user == Owner)
        activate_module()

/obj/item/weapon/gun_modular/module/accessory/dna_crypter/activate_module(mob/user)
    ..()
    if(!user)
        return
    if(!Owner)
        activate(user)
    if(user != Owner)
        return

/obj/item/weapon/gun_modular/module/accessory/dna_crypter/deactivate_module(mob/user)
    if(!user)
        return ..()
    if(user != Owner)
        return
    ..()

/obj/item/weapon/gun_modular/module/accessory/dna_crypter/target_activate(atom/A, mob/living/user)
    if(user == Owner)
        return ..()
    return FALSE

/obj/item/weapon/gun_modular/module/accessory/dna_crypter/remove(mob/user = null)
    if(!Owner || !user)
        Owner = null
        return ..()
    if(Owner != user)
        return FALSE

/obj/item/weapon/gun_modular/module/accessory/butt
    name = "gun butt"
    icon_state = "butt"
    icon_overlay_name = "butt"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1.5
    size_gun = 2
    prefix = "Butt"
    gun_type = ALL_GUN_TYPE
    var/lessrecoil = 2

/obj/item/weapon/gun_modular/module/accessory/butt/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(12, 9))

    change_list_exit("[SPRITE_SHEET_HELD]_l", "[SOUTH]", list(1, 6))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[NORTH]", list(10, 6))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[EAST]", list(1, 6))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[WEST]", list(1, 6))

    change_list_exit("[SPRITE_SHEET_HELD]_r", "[SOUTH]", list(10, 6))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[NORTH]", list(1, 6))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[EAST]", list(6, 6))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[WEST]", list(6, 6))

    change_list_exit("[SPRITE_SHEET_BACK]", "[SOUTH]", list(1, 2))
    change_list_exit("[SPRITE_SHEET_BACK]", "[NORTH]", list(9, 2))
    change_list_exit("[SPRITE_SHEET_BACK]", "[EAST]", list(2, 1))
    change_list_exit("[SPRITE_SHEET_BACK]", "[WEST]", list(2, 1))

/obj/item/weapon/gun_modular/module/accessory/butt/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!I.handle)
        return FALSE
    return TRUE


/obj/item/weapon/gun_modular/module/accessory/butt/attach(obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!..())
        return FALSE
    frame_parent.handle.lessrecoil += lessrecoil

/obj/item/weapon/gun_modular/module/accessory/butt/remove()
    if(frame_parent.handle)
        frame_parent.handle.lessrecoil -= lessrecoil
    return ..()
    