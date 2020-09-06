/obj/item/weapon/gun_modular/module/handle
    name = "gun handle"
    desc = "The handle, the ability to fire a weapon depends on it, different types of handles give different bonuses and problems. Also, the recoil of the weapon depends on the handle, if the recoil is too strong for the shooter, the weapon can fly out of the hand"
    icon_state = "grip_normal"
    icon_overlay_name = "grip_normal"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 1
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    prefix = HANDLE
    var/lessrecoil = 1
    var/clumsy_check = TRUE

/obj/item/weapon/gun_modular/module/handle/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(6, 7))

    change_list_exit("[SPRITE_SHEET_HELD]_l", "[SOUTH]", list(3, 5))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[NORTH]", list(4, 5))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[EAST]", list(2, 4))
    change_list_exit("[SPRITE_SHEET_HELD]_l", "[WEST]", list(2, 4))

    change_list_exit("[SPRITE_SHEET_HELD]_r", "[SOUTH]", list(4, 5))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[NORTH]", list(3, 5))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[EAST]", list(2, 4))
    change_list_exit("[SPRITE_SHEET_HELD]_r", "[WEST]", list(2, 4))

    change_list_exit("[SPRITE_SHEET_BACK]", "[SOUTH]", list(1, 2))
    change_list_exit("[SPRITE_SHEET_BACK]", "[NORTH]", list(3, 2))
    change_list_exit("[SPRITE_SHEET_BACK]", "[EAST]", list(2, 1))
    change_list_exit("[SPRITE_SHEET_BACK]", "[WEST]", list(2, 2))
    
    change_list_exit("[SPRITE_SHEET_BELT]", "[SOUTH]", list(2, 2))
    change_list_exit("[SPRITE_SHEET_BELT]", "[NORTH]", list(2, 1))
    change_list_exit("[SPRITE_SHEET_BELT]", "[EAST]", list(3, 2))
    change_list_exit("[SPRITE_SHEET_BELT]", "[WEST]", list(1, 2))

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

/obj/item/weapon/gun_modular/module/handle/weighted/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(9, 11))
    change_list_entry("ICON", "[SOUTH]", null)

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

/obj/item/weapon/gun_modular/module/handle/resilient/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(19, 9))
    change_list_entry("ICON", "[SOUTH]", null)

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

/obj/item/weapon/gun_modular/module/handle/rifle/build_points_list()
    ..()
    change_list_exit("ICON", "[SOUTH]", list(22, 10))
    change_list_entry("ICON", "[SOUTH]", null)

/obj/item/weapon/gun_modular/module/handle/rifle/Special_Check(mob/user)
    if(!..())
        return FALSE
    if(user.get_inactive_hand())
        to_chat(user, "<span class='notice'>Your other hand must be free before firing! This weapon requires both hands to use.</span>")
        return FALSE
    return TRUE