/obj/item/gun_modular/module/grip
	name = "рукоять"
	module_id = GRIP_MODULE
	var/recoil_change = -1;

/obj/item/gun_modular/module/grip/atom_init(mapload, ...)
	. = ..()

	var/obj/item/gun_modular/module/chamber/chamber = new(loc)
	attach(chamber)

/obj/item/gun_modular/module/grip/init_allowed_modules()

	add_allow_module(CHAMBER_MODULE)

	return TRUE

/obj/item/gun_modular/module/grip/afterattack(atom/target, mob/user, proximity, params)

	var/datum/pipe_system/process/process = new /datum/pipe_system/process()

	var/datum/pipe_system/component/data/gun_user/user_data = new (src, user)
	process.AddComponentGun(user_data)

	var/datum/pipe_system/component/data/gun_target/target_data = new (src, target)
	process.AddComponentGun(target_data)

	var/datum/pipe_system/component/data/gun_params/params_data = new (src, params)
	process.AddComponentGun(params_data)

	var/datum/pipe_system/component/data/start_fire_loc/start_fire_loc_data = new (src, get_turf(src))
	process.AddComponentGun(start_fire_loc_data)

	main_action(process)
	process.RunComponents()

/obj/item/gun_modular/module/grip/init_default_components_module()
	..()

	var/datum/pipe_system/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)

	var/datum/pipe_system/component/proc_gun/message_from_user/message_fail_advansedToolCheck = new (src, "<span class='red'>You don't have the dexterity to do this!</span>")
	var/datum/pipe_system/component/proc_gun/interrupter/interrupter_message_fail_advansedToolCheck = new (src)
	message_fail_advansedToolCheck.AddLastComponent(interrupter_message_fail_advansedToolCheck)

	var/datum/pipe_system/component/check/user_advansedTool/user_advansedToolCheck = new (src, null, message_fail_advansedToolCheck)
	add_default_component(user_advansedToolCheck)

	var/datum/pipe_system/component/proc_gun/message_from_user/message_success_isHULKCheck = new (src, "<span class='red'>Your meaty finger is much too large for the trigger guard!</span>")
	var/datum/pipe_system/component/proc_gun/interrupter/interrupter_message_success_isHULKCheck = new (src)
	message_success_isHULKCheck.AddLastComponent(interrupter_message_success_isHULKCheck)

	var/datum/pipe_system/component/check/user_isHuman/user_isHumanCheck = new (src, null, null)

	var/datum/pipe_system/component/check/user_isHULK/user_isHULKCheck = new (src, message_success_isHULKCheck, user_isHumanCheck)

	var/datum/pipe_system/component/check/user_isLiving/user_isLivingCheck = new (src, user_isHULKCheck, null)
	add_default_component(user_isLivingCheck)

	var/datum/pipe_system/component/proc_gun/user_addFingerptint/user_addFingerptint = new (src)
	add_default_component(user_addFingerptint)


/obj/item/gun_modular/module/grip/main_action(datum/pipe_system/process/process)
	return ..()
