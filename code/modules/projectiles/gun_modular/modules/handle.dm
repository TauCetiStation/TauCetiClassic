/obj/item/weapon/gun_modular/module/handle
    name = "gun handle"
    desc = "The handle, the ability to fire a weapon depends on it, different types of handles give different bonuses and problems. Also, the recoil of the weapon depends on the handle, if the recoil is too strong for the shooter, the weapon can fly out of the hand"
    icon_state = "grip_normal"
    icon_overlay_name = "grip_normal"
    icon_overlay_layer = LAYER_HANDLE
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    prefix = HANDLE
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(13, 12),
            NORTH_DIR = list(13, 12),
            WEST_DIR = list(13, 12),
            EAST_DIR = list(13, 12)
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
            SOUTH_DIR = list("Butt" = list(3, 12)),
            NORTH_DIR = list("Butt" = list(3, 12)),
            WEST_DIR = list("Butt" = list(3, 12)),
            EAST_DIR = list("Butt" = list(3, 12))
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
    var/lessrecoil = 0
    var/clumsy_check = TRUE

/obj/item/weapon/gun_modular/module/handle/get_info_module(mob/user = null)
    var/info_module = ..()
    if(user)
        if(!hasHUD(user, "science") && !hasHUD(user, "security"))
            return info_module
    info_module += "Reducing recoil - [lessrecoil]\n"
    return info_module

/obj/item/weapon/gun_modular/module/handle/proc/Special_Check(mob/user)
    if(user.mind.special_role == "Wizard")
        return FALSE
    if(!user.IsAdvancedToolUser())
        to_chat(user, "<span class='red'>You don't have the dexterity to do this!</span>")
        return FALSE
    if(isliving(user))
        var/mob/living/M = user
        if (HULK in M.mutations)
            to_chat(M, "<span class='red'>Your meaty finger is much too large for the trigger guard!</span>")
            return FALSE
        if(ishuman(user))
            var/mob/living/carbon/human/H = user
            if(H.species.name == SHADOWLING)
                to_chat(H, "<span class='notice'>Your fingers don't fit in the trigger guard!</span>")
                return FALSE
            if(H.dna && H.dna.mutantrace == "adamantine")
                to_chat(H, "<span class='red'>Your metal fingers don't fit in the trigger guard!</span>")
                return FALSE
            if(clumsy_check) //it should be AFTER hulk or monkey check.
                var/going_to_explode = FALSE
                if ((CLUMSY in H.mutations) && prob(50))
                    going_to_explode = TRUE
                if(frame_parent.chamber)
                    if(frame_parent.chamber.chambered && frame_parent.chamber.chambered.crit_fail && prob(10))
                        going_to_explode = TRUE
                if(going_to_explode)
                    explosion(user.loc, 0, 0, 1, 1)
                    to_chat(H, "<span class='danger'>[src] blows up in your face.</span>")
                    H.take_bodypart_damage(0, 20)
                    H.drop_item()
                    qdel(frame_parent)
                    return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/handle/proc/get_recoil_shoot()
    return lessrecoil

/obj/item/weapon/gun_modular/module/handle/attach(var/obj/item/weapon/gun_modular/module/frame/I, user)
    if(!..())
        return FALSE
    frame_parent.handle = src
    return TRUE

/obj/item/weapon/gun_modular/module/handle/remove()
    lessrecoil = initial(lessrecoil)
    clumsy_check = initial(clumsy_check)
    if(frame_parent)
        frame_parent.handle = null
    ..()

/obj/item/weapon/gun_modular/module/handle/weighted
    name = "gun handle weighted"
    icon_state = "grip_weighted"
    icon_overlay_name = "grip_weighted"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1.5
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    lessrecoil = 1
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(9, 11),
            NORTH_DIR = list(9, 11),
            WEST_DIR = list(9, 11),
            EAST_DIR = list(9, 11)
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
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
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

/obj/item/weapon/gun_modular/module/handle/resilient
    name = "gun handle resilient"
    icon_state = "grip_resilient"
    icon_overlay_name = "grip_resilient"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1
    size_gun = 2
    gun_type = ALL_GUN_TYPE
    lessrecoil = 3
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(19, 9),
            NORTH_DIR = list(19, 9),
            WEST_DIR = list(19, 9),
            EAST_DIR = list(19, 9)
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
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
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

/obj/item/weapon/gun_modular/module/handle/resilient/Special_Check(mob/user)
    if(!..())
        return FALSE
    if(user.get_inactive_hand())
        to_chat(user, "<span class='notice'>Your other hand must be free before firing! This weapon requires both hands to use.</span>")
        return FALSE
    return TRUE

/obj/item/weapon/gun_modular/module/handle/rifle
    name = "gun handle rifle"
    icon_state = "grip_rifle"
    icon_overlay_name = "grip_rifle"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 2.5
    size_gun = 3
    gun_type = ALL_GUN_TYPE
    lessrecoil = 4
    exit_point = list(
        "ICON" = list(
            SOUTH_DIR = list(22, 10),
            NORTH_DIR = list(22, 10),
            WEST_DIR = list(22, 10),
            EAST_DIR = list(22, 10)
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
            SOUTH_DIR = null,
            NORTH_DIR = null,
            WEST_DIR = null,
            EAST_DIR = null
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

/obj/item/weapon/gun_modular/module/handle/rifle/Special_Check(mob/user)
    if(!..())
        return FALSE
    if(user.get_inactive_hand())
        to_chat(user, "<span class='notice'>Your other hand must be free before firing! This weapon requires both hands to use.</span>")
        return FALSE
    return TRUE