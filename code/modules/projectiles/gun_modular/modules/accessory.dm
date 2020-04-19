/obj/item/weapon/gun_modular/module/accessory
    name = "gun accessory"
    icon_state = "optical_medium_icon"
    icon_overlay_name = "optical_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    var/active = FALSE
    parent_module_type = /obj/item/weapon/gun_modular/module/accessory

/obj/item/weapon/gun_modular/module/accessory/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    if(!istype(I, /obj/item/weapon/gun_modular/module/frame))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    LAZYINITLIST(frame.accessories)
    if(frame.max_accessory < frame.accessories.len)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/attach(obj/item/weapon/gun_modular/module/frame/I, mob/user)
    if(!..())
        return FALSE
    LAZYINITLIST(frame_parent.accessories)
    LAZYADD(frame_parent.accessories, src)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/remove()
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
    gun_type = ALL_GUN_TYPE
    parent_module_type = /obj/item/weapon/gun_modular/module/accessory/optical
    var/size_barrel = 1
    var/view_range = 6
    var/location_active = null

/obj/item/weapon/gun_modular/module/accessory/optical/deactivate(mob/user, argument = "")
    active = FALSE
    user.client.view = world.view
    if(user.hud_used)
        user.hud_used.show_hud(HUD_STYLE_STANDARD)
    return TRUE

/obj/item/weapon/gun_modular/module/accessory/optical/activate(mob/user, argument = "")
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
    location_active = get_turf(src)
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
    view_range = 8
    size_barrel = 1

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

/obj/item/weapon/gun_modular/module/accessory/core_charger
    name = "gun core charger accessory"
    icon_state = "anomal_charger_icon"
    icon_overlay_name = "anomal_charger"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = ENERGY_GUN
    parent_module_type = /obj/item/weapon/gun_modular/module/accessory/core_charger
    var/obj/item/device/assembly/signaler/anomaly/core = null
    var/tick = 0
    var/tick_charge = 8
    var/charge = 1000

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

/obj/item/weapon/gun_modular/module/accessory/core_charger/attach_item_in_module(obj/item/I, mob/user)
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
    
    