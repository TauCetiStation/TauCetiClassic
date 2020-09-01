/obj/item/weapon/gun_modular/module/barrel
    name = "gun barrel"
    desc = "The barrel of the weapon has a greater effect on the accuracy of shooting, as well as the damage of the weapon, it also depends on the barrel which accessories can be attached to it"
    icon_state = "barrel_medium_icon"
    icon_overlay_name = "barrel_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    prefix = BARREL
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
    lessdispersion = 1
    size_gun = 1
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/barrel/small/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 3))
    change_list_entry("ICON", "[SOUTH]", list("Silenser" = list(4, 3, -3)))

/obj/item/weapon/gun_modular/module/barrel/medium
    name = "gun barrel medium"
    icon_state = "barrel_medium_icon"
    icon_overlay_name = "barrel_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 2
    size_gun = 2
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/barrel/medium/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 4))
    change_list_entry("ICON", "[SOUTH]", list("Bayonet" = list(7, 1, -3),
                                                "Silenser" = list(9, 4, -3)))

/obj/item/weapon/gun_modular/module/barrel/large
    name = "gun barrel large"
    icon_state = "barrel_large_icon"
    icon_overlay_name = "barrel_large"
    caliber = ALL_CALIBER
    lessdamage = -6
    lessdispersion = 3
    size_gun = 3
    gun_type = ALL_GUN_TYPE

/obj/item/weapon/gun_modular/module/barrel/large/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 4))
    change_list_entry("ICON", "[SOUTH]", list("Bayonet" = list(11, 1, -3),
                                                "Silenser" = list(13, 4, -3)))
    
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[SOUTH]", list(7, 3))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[NORTH]", list(1, 3))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[EAST]", list(7, 3))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[WEST]", list(9, 3))

    change_list_exit("[SPRITE_SHEET_HELD]_r", "[SOUTH]", list(1, 3))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[NORTH]", list(7, 3))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[EAST]", list(2, 3))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[WEST]", list(1, 3))

    change_list_exit("[SPRITE_SHEET_BACK]", "[SOUTH]", list(6, 6))
    change_list_exit("[SPRITE_SHEET_BACK]", "[NORTH]", list(1, 6))
    change_list_exit("[SPRITE_SHEET_BACK]", "[EAST]", list(3, 6))
    change_list_exit("[SPRITE_SHEET_BACK]", "[WEST]", list(3, 6))

/obj/item/weapon/gun_modular/module/barrel/rifle_bullet
    name = "gun barrel large bullet"
    icon_state = "barrel_large_bullet"
    icon_overlay_name = "barrel_large_bullet"
    caliber = ALL_CALIBER
    lessdamage = -8
    lessdispersion = 4
    size_gun = 4
    gun_type = BULLET_GUN

/obj/item/weapon/gun_modular/module/barrel/rifle_bullet/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 7))
    change_list_entry("ICON", "[SOUTH]", list("Bayonet" = list(16, 3, -3),
                                            "Silenser" = list(16, 7, -3)))                          

/obj/item/weapon/gun_modular/module/barrel/rifle_laser
    name = "gun barrel large laser"
    icon_state = "barrel_large_laser"
    icon_overlay_name = "barrel_large_laser"
    caliber = ALL_CALIBER
    lessdamage = -8
    lessdispersion = 4
    size_gun = 4
    gun_type = ENERGY_GUN

/obj/item/weapon/gun_modular/module/barrel/rifle_laser/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(1, 11))
    change_list_entry("ICON", "[SOUTH]", list("Bayonet" = list(13, 5, -3)))