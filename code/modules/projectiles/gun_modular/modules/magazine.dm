/obj/item/weapon/gun_modular/module/magazine
    name = "gun magazine"
    icon_state = "magazine_external_icon"
    icon_overlay_name = "magazine_external"
    caliber = null
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    var/isinternal = FALSE
    var/eject_casing = TRUE
    var/empty_chamber = TRUE
    var/no_casing = FALSE

/obj/item/weapon/gun_modular/module/magazine/proc/Return_Round(var/obj/item/ammo_casing/ammo)
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/proc/Give_Round(var/obj/item/ammo_casing/ammo, mob/user = null)
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/proc/Ammo_Count(var/obj/item/ammo_casing/ammo = null)
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/proc/Get_Ammo()
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/bullet
    name = "gun bullet magazine"
    gun_type = BULLET_GUN
    var/obj/item/ammo_box/magazine/magazine = null

/obj/item/weapon/gun_modular/module/magazine/bullet/Return_Round(var/obj/item/ammo_casing/ammo)
    if(!magazine)
        return FALSE
    return magazine.give_round(ammo)

/obj/item/weapon/gun_modular/module/magazine/bullet/Give_Round(var/obj/item/ammo_casing/ammo, mob/user = null)
    if(!magazine)
        return FALSE
    return magazine.give_round(ammo, user)

/obj/item/weapon/gun_modular/module/magazine/bullet/Ammo_Count(var/obj/item/ammo_casing/ammo = null)
    if(magazine)
        return magazine.ammo_count()
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/bullet/Get_Ammo()
    if(magazine)
        return magazine.get_round()
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/bullet/attackby(obj/item/weapon/W, mob/user, params)
    . = ..()
    if(isscrewdriver(W))
        if(magazine)
            remove_item_in_module(magazine)
    else if(magazine)
        if(istype(W, /obj/item/ammo_casing))
            Give_Round(W, user)

/obj/item/weapon/gun_modular/module/magazine/bullet/activate(mob/user)
    if(!magazine)
        to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
        return FALSE
    return magazine.eject_ammos(user, src)

/obj/item/weapon/gun_modular/module/magazine/bullet/attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    frame_parent.magazine = src
    if(frame_parent.chamber)
        frame_parent.chamber.eject_casing = eject_casing
        frame_parent.chamber.empty_chamber = empty_chamber
        frame_parent.chamber.no_casing = no_casing
    return TRUE

/obj/item/weapon/gun_modular/module/magazine/bullet/remove()
    if(frame_parent)
        frame_parent.magazine = null
    ..()

/obj/item/weapon/gun_modular/module/magazine/bullet/remove_item_in_module(var/obj/item/ammo_box/magazine/mag)
    mag.loc = get_turf(frame_parent)
    magazine = null

/obj/item/weapon/gun_modular/module/magazine/bullet/attach_item_in_module(var/obj/item/ammo_box/magazine/mag, mob/user)
    if(!..())
        return FALSE
    if(user)
        user.drop_item()
    magazine = mag
    mag.loc = src
    eject_casing = mag.eject_casing
    empty_chamber = mag.empty_chamber
    no_casing = mag.no_casing
    isinternal = mag.isinternal
    if(isinternal)
        icon_overlay_name = "magazine_internal"
    else
        icon_overlay_name = "magazine_external"
    update_icon()
    return TRUE

/obj/item/weapon/gun_modular/module/magazine/bullet/can_attach(var/obj/item/ammo_box/magazine/mag)
    if(!istype(mag, /obj/item/ammo_box/magazine))
        return FALSE
    if(magazine)
        return FALSE
    if(!caliber)
        caliber = mag.caliber
    if(mag.caliber != caliber)
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/magazine/energy
    name = "gun energy magazine"
    caliber = "energy"
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = ENERGY_GUN
    isinternal = FALSE
    var/obj/item/weapon/stock_parts/cell/magazine = null

/obj/item/weapon/gun_modular/module/magazine/energy/attackby(obj/item/weapon/W, mob/user, params)
    . = ..()
    if(isscrewdriver(W))
        if(magazine)
            remove_item_in_module(magazine)

/obj/item/weapon/gun_modular/module/magazine/energy/activate(mob/user)
    if(!magazine)
        return FALSE
    if(!isinternal)
        magazine.loc = get_turf(src.loc)
        user.put_in_hands(magazine)
        magazine.update_icon()
        magazine = null
        update_icon()
        playsound(src, 'sound/weapons/guns/reload_mag_out.ogg', VOL_EFFECTS_MASTER)
        to_chat(user, "<span class='notice'>You pull the energy cell out of \the [src]!</span>")
        return TRUE

/obj/item/weapon/gun_modular/module/magazine/energy/attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    frame_parent.magazine = src
    return TRUE

/obj/item/weapon/gun_modular/module/magazine/energy/Ammo_Count(var/obj/item/ammo_casing/energy/lens)
    if(magazine)
        return magazine.charge > lens.e_cost * frame_parent.chamber.pellets * 5
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/energy/Get_Ammo(var/lens_type)
    if(!magazine)
        return null
    var/obj/item/ammo_casing/energy/ammo = new lens_type(src)
    magazine.use(ammo.e_cost * frame_parent.chamber.pellets * 5)
    return ammo

/obj/item/weapon/gun_modular/module/magazine/energy/remove_item_in_module(var/obj/item/weapon/stock_parts/cell/cell)
    cell.loc = get_turf(frame_parent)
    magazine = null

/obj/item/weapon/gun_modular/module/magazine/energy/attach_item_in_module(var/obj/item/weapon/stock_parts/cell/cell, mob/user)
    if(!..())
        return FALSE
    magazine = cell
    if(user)
        user.drop_item()
    cell.loc = src
    return TRUE

/obj/item/weapon/gun_modular/module/magazine/energy/can_attach(var/obj/item/weapon/stock_parts/cell/cell)
    if(!istype(cell, /obj/item/weapon/stock_parts/cell))
        return FALSE
    if(magazine)
        return FALSE
    return TRUE



/obj/item/weapon/gun_modular/module/magazine/bullet/heavyrifle
    name = "PTR-7 rifle magazine holder"
    lessdamage = 0
    lessdispersion = 10
    size_gun = 2
    caliber = "14.5mm"
    var/open = TRUE

/obj/item/weapon/gun_modular/module/magazine/bullet/heavyrifle/Get_Ammo()
    if(!open)
        return ..()

/obj/item/weapon/gun_modular/module/magazine/bullet/heavyrifle/Give_Round(obj/item/ammo_casing/ammo, mob/user = null)
    if(open)
        if(..())
            playsound(src, 'sound/weapons/guns/heavybolt_in.ogg', VOL_EFFECTS_MASTER)
            to_chat(user, "<span class='notice'>You load shell into [src]!</span>")
            if(frame_parent.chamber)
                frame_parent.chamber.chamber_round()
            return TRUE
    return FALSE

/obj/item/weapon/gun_modular/module/magazine/bullet/heavyrifle/activate(mob/user)
    open = !open
    if(open)
        playsound(src, 'sound/weapons/guns/heavybolt_out.ogg', VOL_EFFECTS_MASTER)
        to_chat(user, "<span class='notice'>You work the bolt open.</span>")
        if(frame_parent.chamber)
            frame_parent.chamber.process_chamber(TRUE)
        return ..()
    else
        playsound(src, 'sound/weapons/guns/heavybolt_reload.ogg', VOL_EFFECTS_MASTER)
        to_chat(user, "<span class='notice'>You work the bolt closed.</span>")
        
            
    