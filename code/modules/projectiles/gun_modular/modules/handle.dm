/obj/item/weapon/gun_modular/module/handle
    name = "gun handle"
    icon_state = "grip_normal"
    icon_overlay_name = "grip_normal"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 1
    gun_type = ALL_GUN_TYPE
    var/lessrecoil = 0

/obj/item/weapon/gun_modular/module/handle/proc/get_recoil_shoot()
    return lessrecoil

/obj/item/weapon/gun_modular/module/handle/attach(var/obj/item/weapon/gun_modular/module/frame/I, user)
    if(!..())
        return FALSE
    frame_parent.handle = src
    return TRUE

/obj/item/weapon/gun_modular/module/handle/remove()
    if(frame_parent)
        frame_parent.handle = null
    ..()


/obj/item/weapon/gun_modular/module/handle/resilient
    name = "gun handle resilient"
    icon_state = "grip_resilient"
    icon_overlay_name = "grip_resilient"
    caliber = ALL_CALIBER
    lessdamage = 0
    lessdispersion = 0
    size_gun = 2
    gun_type = ALL_GUN_TYPE
    lessrecoil = 2


/obj/item/weapon/gun_modular/module/handle/shotgun
    name = "gun handle shotgun"
    icon_state = "grip_shotgun"
    icon_overlay_name = "grip_shotgun"
    caliber = ALL_CALIBER
    lessdamage = 5
    lessdispersion = -2
    size_gun = 3
    gun_type = ALL_GUN_TYPE
    lessrecoil = 3

/obj/item/weapon/gun_modular/module/handle/rifle
    name = "gun handle rifle"
    icon_state = "grip_rifle"
    icon_overlay_name = "grip_rifle"
    caliber = ALL_CALIBER
    lessdamage = -3
    lessdispersion = 5
    size_gun = 3
    gun_type = ALL_GUN_TYPE
    lessrecoil = 3