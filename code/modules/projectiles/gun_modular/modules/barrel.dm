/obj/item/weapon/gun_modular/module/barrel
    name = "gun barrel"
    icon_state = "barrel_medium_icon"
    icon_overlay_name = "barrel_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    move_x = 4
    move_y = 4
    gun_type = ALL_GUN_TYPE
    prefix_radial = "Barrel"
    var/silensed = FALSE

/obj/item/weapon/gun_modular/module/barrel/proc/get_silensed_shoot()
    return silensed

/obj/item/weapon/gun_modular/module/barrel/attach(var/obj/item/weapon/gun_modular/module/frame/I, user)
    if(!..())
        return FALSE
    frame_parent.barrel = src
    return TRUE

/obj/item/weapon/gun_modular/module/barrel/remove()
    if(frame_parent)
        frame_parent.barrel = null
    silensed = initial(silensed)
    ..()

/obj/item/weapon/gun_modular/module/barrel/small
    name = "gun barrel small"
    icon_state = "barrel_small_icon"
    icon_overlay_name = "barrel_small"
    caliber = ALL_CALIBER
    lessdamage = 6
    lessdispersion = -0.2
    size_gun = 1
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/barrel/medium
    name = "gun barrel medium"
    icon_state = "barrel_medium_icon"
    icon_overlay_name = "barrel_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0.3
    size_gun = 2
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/barrel/large
    name = "gun barrel large"
    icon_state = "barrel_large_icon"
    icon_overlay_name = "barrel_large"
    caliber = ALL_CALIBER
    lessdamage = -6
    lessdispersion = 1
    size_gun = 3
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/barrel/rifle_bullet
    name = "gun barrel large bullet"
    icon_state = "barrel_large_bullet"
    icon_overlay_name = "barrel_large_bullet"
    caliber = ALL_CALIBER
    lessdamage = -8
    lessdispersion = 1
    size_gun = 4
    gun_type = BULLET_GUN

/obj/item/weapon/gun_modular/module/barrel/rifle_laser
    name = "gun barrel large laser"
    icon_state = "barrel_large_laser"
    icon_overlay_name = "barrel_large_laser"
    caliber = ALL_CALIBER
    lessdamage = -8
    lessdispersion = 3
    size_gun = 4
    gun_type = ENERGY_GUN