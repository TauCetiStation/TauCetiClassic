obj/item/weapon/gun_modular/module/chamber
    name = "gun bullet chamber"
    desc = "The chamber, requests a cartridge from the magazine holder and, if possible, receives it, upon confirmation of the handle, it fires a shot, the accuracy of which depends on the totality of statistics of all modules. Also in the chamber, there is a default recoil, which must be compensated for by a suitable handle. Also, the frequency of shooting depends on the damage inflicted by the bullet, some types of chamber do not have such a limitation."
    icon_state = "chamber_bullet_icon"
    icon_overlay_name = "chamber_bullet"
    caliber = "9mm"
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = BULLET_GUN
    prefix_radial = "Chamber"
    var/obj/item/ammo_casing/chambered = null
    var/eject_casing = TRUE
    var/empty_chamber = TRUE
    var/no_casing = FALSE
    var/fire_sound = 'sound/weapons/guns/Gunshot.ogg'
    var/bolt_slide_sound = 'sound/weapons/guns/TargetOn.ogg'
    var/fire_delay = 9
    var/fire_delay_default = 9
    var/last_fired = 0
    var/recoil_chamber = 0
    var/pellets

obj/item/weapon/gun_modular/module/chamber/Destroy()
    if(chambered)
        chambered.Destroy()
    chambered = null
    return ..()

obj/item/weapon/gun_modular/module/chamber/get_info_module()
    var/info_module = ..()
    info_module += "Fire delay default - [fire_delay_default]\n"
    info_module += "Recoil - [recoil_chamber]\n"
    if(pellets)
        info_module += "Separation of charges - [pellets]\n"
    info_module += "Standard case actions:\n"
    info_module += "Eject casing - [eject_casing ? "TRUE" : "FALSE"]\n"
    info_module += "Emptying the chamber - [empty_chamber ? "TRUE" : "FALSE"]\n"
    info_module += "Destruction of the cartridge case - [no_casing ? "TRUE" : "FALSE"]\n"
    return info_module

obj/item/weapon/gun_modular/module/chamber/activate(mob/user)
    if(chambered)
        playsound(src, bolt_slide_sound, VOL_EFFECTS_MASTER)
        process_chamber()

obj/item/weapon/gun_modular/module/chamber/proc/ready_to_fire()
    if(world.time >= last_fired + fire_delay)
        last_fired = world.time
        return TRUE
    else
        return FALSE

obj/item/weapon/gun_modular/module/chamber/proc/shoot_with_empty_chamber(mob/living/user)
    to_chat(user, "<span class='warning'>*click*</span>")
    playsound(user, 'sound/weapons/guns/empty.ogg', VOL_EFFECTS_MASTER)
    return

obj/item/weapon/gun_modular/module/chamber/proc/shoot_live_shot(mob/living/user, var/silensed = FALSE)
    var/recoil = 0
    if(frame_parent.handle)
        recoil = max(recoil_chamber - frame_parent.handle.get_recoil_shoot(), 0)
    if(recoil)
        shake_camera(user, recoil + 1, recoil)
        if(recoil >= 3)
            user.drop_item()
            frame_parent.SpinAnimation(10, 1)
        if(recoil >= 4)
            user.Weaken(2)

    if(silensed)
        playsound(user, fire_sound, VOL_EFFECTS_MASTER, 30, null, -4)
    else
        playsound(user, fire_sound, VOL_EFFECTS_MASTER)
        user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a gunshot!")

obj/item/weapon/gun_modular/module/chamber/proc/Fire(atom/target, mob/living/user, params)
    if(!ready_to_fire())
        return
    fire_delay = fire_delay_default 
    if(!chambered)
        process_chamber()
    if(!chambered)
        shoot_with_empty_chamber(user)
    else
        fire_sound = chambered.fire_sound
        if(chambered.BB)
            chambered.BB.damage -= frame_parent.lessdamage
            chambered.BB.dispersion -= frame_parent.lessdispersion
            chambered.BB.dispersion = max(chambered.BB.dispersion, 0)
            chambered.BB.dispersion = min(chambered.BB.dispersion, 5)
            fire_delay = fire_delay_default * (chambered.BB.damage*chambered.pellets/300 + 1)
        var/silensed = FALSE
        if(frame_parent.barrel)
            silensed = frame_parent.barrel.get_silensed_shoot()
        if(!chambered.fire(target, user, params, , silensed))
            shoot_with_empty_chamber(user)
        else
            shoot_live_shot(user, silensed)
            user.newtonian_move(get_dir(target, user))
    process_chamber(TRUE)
    update_icon()

obj/item/weapon/gun_modular/module/chamber/proc/process_chamber(var/chamber_round = FALSE)
    var/obj/item/ammo_casing/AC = chambered //Find chambered round
    if(isnull(AC) || !istype(AC))
        chamber_round()
        return
    if(eject_casing)
        AC.loc = get_turf(src) //Eject casing onto ground.
        AC.SpinAnimation(10, 1) //next gen special effects
        spawn(3) //next gen sound effects
            playsound(src, 'sound/weapons/guns/shell_drop.ogg', VOL_EFFECTS_MASTER, 25)
    else if(frame_parent.magazine)
        frame_parent.magazine.Return_Round(AC)
    if(empty_chamber)
        chambered = null
    if(no_casing)
        qdel(AC)
    if(chamber_round)
        chamber_round()
    return

obj/item/weapon/gun_modular/module/chamber/proc/chamber_round()
    if (chambered || !frame_parent.magazine)
        return
    if (frame_parent.magazine.Ammo_Count())
        chambered = frame_parent.magazine.Get_Ammo()
        if(!chambered)
            return
        chambered.loc = src
        if(chambered.BB)
            if(chambered.reagents && chambered.BB.reagents)
                var/datum/reagents/casting_reagents = chambered.reagents
                casting_reagents.trans_to(chambered.BB, casting_reagents.total_volume) //For chemical darts/bullets
                casting_reagents.delete()
    return



obj/item/weapon/gun_modular/module/chamber/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!istype(I, /obj/item/weapon/gun_modular/module/frame))
        return FALSE
    var/obj/item/weapon/gun_modular/module/frame/frame = I
    if(!isnull(frame.chamber))
        return FALSE
    return TRUE

obj/item/weapon/gun_modular/module/chamber/check_remove()
    return FALSE

obj/item/weapon/gun_modular/module/chamber/attach(var/obj/item/weapon/gun_modular/module/frame/I, user)
    if(!..())
        return FALSE
    frame_parent.gun_type = gun_type
    frame_parent.caliber = caliber
    frame_parent.chamber = src
    return TRUE

obj/item/weapon/gun_modular/module/chamber/remove()
    if(frame_parent)
        frame_parent.gun_type = null
        frame_parent.caliber = null
        frame_parent.chamber = null
    ..()

obj/item/weapon/gun_modular/module/chamber/energy
    name = "gun energy chamber"
    icon_state = "chamber_laser"
    caliber = "energy"
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = ENERGY_GUN
    pellets = 1
    var/max_lens = 1
    var/lens_select = 1
    var/list/obj/item/ammo_casing/energy/lenses = list()

obj/item/weapon/gun_modular/module/chamber/energy/activate(mob/user)
    select_fire(user)

obj/item/weapon/gun_modular/module/chamber/energy/proc/select_fire(mob/living/user)
    if(lenses.len < 1)
        return
    if(lens_select >= lenses.len)
        lens_select = 1
    else
        lens_select += 1
    if (lenses[lens_select].select_name)
        to_chat(user, "<span class='warning'>[src] is now set to [lenses[lens_select].select_name].</span>")

obj/item/weapon/gun_modular/module/chamber/energy/Fire(atom/target, mob/living/user, params)
    chamber_round()
    if(chambered)
        chambered.pellets = pellets
        if(chambered.BB)
            chambered.BB.damage /= pellets
            chambered.BB.lesseffect = pellets*2
            chambered.BB.dispersion = 0.5 * pellets
    ..()

obj/item/weapon/gun_modular/module/chamber/energy/process_chamber()
    if(chambered)
        qdel(chambered)
        chambered = null

obj/item/weapon/gun_modular/module/chamber/energy/chamber_round()
    if(!frame_parent.magazine)
        return FALSE
    if(chambered)
        return FALSE
    var/obj/item/ammo_casing/energy/lens = lenses[lens_select]
    if(frame_parent.magazine.Ammo_Count(lens))
        chambered = frame_parent.magazine.Get_Ammo(lens.type)
        if(chambered)
            chambered.loc = src

obj/item/weapon/gun_modular/module/chamber/energy/checking_to_attach(var/obj/item/weapon/gun_modular/module/frame/I)
    if(!..())
        return FALSE
    LAZYINITLIST(lenses)
    if(lenses.len == 0)
        return FALSE
    return TRUE

obj/item/weapon/gun_modular/module/chamber/energy/remove_item_in_module(var/obj/item/ammo_casing/energy/I)
    I.loc = get_turf(src)
    LAZYREMOVE(lenses, I)

obj/item/weapon/gun_modular/module/chamber/energy/attach_item_in_module(var/obj/item/ammo_casing/energy/I, mob/user = null)
    if(!..())
        return FALSE
    if(I.caliber != caliber)
        return FALSE
    LAZYINITLIST(lenses)
    LAZYADD(lenses, I)
    if(user)
        user.drop_item()
    I.loc = src
    return TRUE

obj/item/weapon/gun_modular/module/chamber/energy/can_attach(var/obj/item/ammo_casing/energy/I)
    if(!istype(I, /obj/item/ammo_casing/energy))
        return FALSE
    LAZYINITLIST(lenses)
    if(lenses.len >= max_lens)
        return FALSE
    return TRUE


obj/item/weapon/gun_modular/module/chamber/energy/shotgun
    name = "gun energy shotgun chamber"
    icon_state = "chamber_laser1"
    icon_overlay_name = "chamber_laser1"
    caliber = "energy"
    lessdamage = 0
    lessdispersion = -0.8
    size_gun = 4
    gun_type = ENERGY_GUN
    pellets = 5
    max_lens = 2
    fire_delay_default = 15


obj/item/weapon/gun_modular/module/chamber/heavyrifle
    name = "PTR-7 rifle chamber"
    icon_state = "chamber_bullet_PTR_icon"
    icon_overlay_name = "chamber_bullet_PTR"
    lessdamage = 0
    lessdispersion = 0.8
    size_gun = 3
    caliber = "14.5mm"
    fire_delay_default = 0
    recoil_chamber = 5

obj/item/weapon/gun_modular/module/chamber/shotgun
    name = "gun shotgun chamber"
    caliber = "shotgun"
    lessdamage = 0
    lessdispersion = -0.8
    size_gun = 4
    gun_type = BULLET_GUN
    fire_delay_default = 15
    eject_casing = FALSE
    empty_chamber = FALSE
    no_casing = FALSE