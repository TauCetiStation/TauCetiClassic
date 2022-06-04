/obj/item/gun_modular/module/grip
    name = "рукоять"
    module_id = GRIP_MODULE

/obj/item/gun_modular/module/grip/afterattack(atom/target, mob/user, proximity, params)
    
    var/datum/process_fire/process = new /datum/process_fire()

    process.SetData(ACTIVE_FIRE, FALSE)
    process.SetData(TARGET_FIRE, target)
    process.SetData(USER_FIRE, user)
    process.SetData(PROXIMITY_FIRE, proximity)
    process.SetData(PARAMS_FIRE, params)

    activate(process)

/obj/item/gun_modular/module/grip/activate(datum/process_fire/process)

    if(process.GetData(PROXIMITY_FIRE))	
        return ..()

    var/mob/user = process.GetData(USER_FIRE)

    if(!user || !user.client)
        return ..()

    process.SetData(ACTIVE_FIRE, TRUE)

    return ..()
    