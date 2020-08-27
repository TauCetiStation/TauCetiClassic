/obj/item/weapon/gun_modular/module/barrel
    name = "gun barrel"
    desc = "The barrel of the weapon has a greater effect on the accuracy of shooting, as well as the damage of the weapon, it also depends on the barrel which accessories can be attached to it"
    icon_state = "barrel_medium_icon"
    icon_overlay_name = "barrel_medium"
    icon_overlay_layer = LAYER_BARREL
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
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(1, 2),
            NORTH_DIR = list(1, 2),
            WEST_DIR = list(1, 2),
            EAST_DIR = list(1, 2)
        ),
        "hand_l" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "hand_r" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "belt"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "back"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        )
    )
    points_of_entry = list(
        "ICON" = list(
            SOUTH_DIR = list("Silenser" = list(8, 2)),
            NORTH_DIR = list("Silenser" = list(8, 2)),
            WEST_DIR = list("Silenser" = list(8, 2)),
            EAST_DIR = list("Silenser" = list(8, 2))
        ),
        "hand_l" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "hand_r" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "belt"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "back"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        )
    )

/obj/item/weapon/gun_modular/module/barrel/medium
    name = "gun barrel medium"
    icon_state = "barrel_medium_icon"
    icon_overlay_name = "barrel_medium"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 2
    size_gun = 2
    gun_type = ALL_GUN_TYPE
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(1, 2),
            NORTH_DIR = list(1, 2),
            WEST_DIR = list(1, 2),
            EAST_DIR = list(1, 2)
        ),
        "hand_l" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "hand_r" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "belt"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "back"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        )
    )
    points_of_entry = list(
        "ICON" = list(
            SOUTH_DIR = list("Bayonet" = list(11, 1),
                            "Silenser" = list(12, 2)),
            NORTH_DIR = list("Bayonet" = list(11, 1),
                            "Silenser" = list(12, 2)),
            WEST_DIR = list("Bayonet" = list(11, 1),
                            "Silenser" = list(12, 2)),
            EAST_DIR = list("Bayonet" = list(11, 1),
                            "Silenser" = list(12, 2))
        ),
        "hand_l" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "hand_r" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "belt"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "back"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        )
    )

/obj/item/weapon/gun_modular/module/barrel/large
    name = "gun barrel large"
    icon_state = "barrel_large_icon"
    icon_overlay_name = "barrel_large"
    caliber = ALL_CALIBER
    lessdamage = -6
    lessdispersion = 3
    size_gun = 3
    gun_type = ALL_GUN_TYPE
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(1, 2),
            NORTH_DIR = list(1, 2),
            WEST_DIR = list(1, 2),
            EAST_DIR = list(1, 2)
        ),
        "hand_l" = list(
            SOUTH_DIR = list(9, 1),
            NORTH_DIR = list(2, 1),
            WEST_DIR = list(1, 1),
            EAST_DIR = list(7, 1)
        ),
        "hand_r" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "belt"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "back"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        )
    )
    points_of_entry = list(
        "ICON" = list(
            SOUTH_DIR = list("Bayonet" = list(16, 1),
                            "Silenser" = list(17, 2)),
            NORTH_DIR = list("Bayonet" = list(16, 1),
                            "Silenser" = list(17, 2)),
            WEST_DIR = list("Bayonet" = list(16, 1),
                            "Silenser" = list(17, 2)),
            EAST_DIR = list("Bayonet" = list(16, 1),
                            "Silenser" = list(17, 2))
        ),
        "hand_l" = list(
            SOUTH_DIR = list("Bayonet" = list(2, 1),
                            "Silenser" = list(1, 2)),
            NORTH_DIR = list("Bayonet" = list(9, 1),
                            "Silenser" = list(10, 2)),
            WEST_DIR = list("Bayonet" = list(3, 1),
                            "Silenser" = list(1, 2)),
            EAST_DIR = list("Bayonet" = list(6, 1),
                            "Silenser" = list(7, 2))
        ),
        "hand_r" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "belt"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "back"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        )
    )

/obj/item/weapon/gun_modular/module/barrel/rifle_bullet
    name = "gun barrel large bullet"
    icon_state = "barrel_large_bullet"
    icon_overlay_name = "barrel_large_bullet"
    caliber = ALL_CALIBER
    lessdamage = -8
    lessdispersion = 4
    size_gun = 4
    gun_type = BULLET_GUN
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(1, 7),
            NORTH_DIR = list(1, 7),
            WEST_DIR = list(1, 7),
            EAST_DIR = list(1, 7)
        ),
        "hand_l" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "hand_r" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "belt"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "back"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        )
    )
    points_of_entry = list(
        "ICON" = list(
            SOUTH_DIR = list("Bayonet" = list(16, 3),
                            "Silenser" = list(16, 7)),
            NORTH_DIR = list("Bayonet" = list(16, 3),
                            "Silenser" = list(16, 7)),
            WEST_DIR = list("Bayonet" = list(16, 3),
                            "Silenser" = list(16, 7)),
            EAST_DIR = list("Bayonet" = list(16, 3),
                            "Silenser" = list(16, 7))
        ),
        "hand_l" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "hand_r" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "belt"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "back"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        )
    )
                            

/obj/item/weapon/gun_modular/module/barrel/rifle_laser
    name = "gun barrel large laser"
    icon_state = "barrel_large_laser"
    icon_overlay_name = "barrel_large_laser"
    caliber = ALL_CALIBER
    lessdamage = -8
    lessdispersion = 4
    size_gun = 4
    gun_type = ENERGY_GUN
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(1, 11),
            NORTH_DIR = list(1, 11),
            WEST_DIR = list(1, 11),
            EAST_DIR = list(1, 11)
        ),
        "hand_l" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "hand_r" = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "belt"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        ),
        "back"  = list(
            SOUTH_DIR = list(0, 0),
            NORTH_DIR = list(0, 0),
            WEST_DIR = list(0, 0),
            EAST_DIR = list(0, 0)
        )
    )
    points_of_entry = list(
        "ICON" = list(
            SOUTH_DIR = list("Bayonet" = list(13, 5)),
            NORTH_DIR = list("Bayonet" = list(13, 5)),
            WEST_DIR = list("Bayonet" = list(13, 5)),
            EAST_DIR = list("Bayonet" = list(13, 5))
        ),
        "hand_l" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "hand_r" = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "belt"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        ),
        "back"  = list(
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
        )
    )