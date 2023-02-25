/obj/item/gun_modular/module/grip
	name = "рукоять"
	module_id = GRIP_MODULE
	var/recoil_change = 1;

/obj/item/gun_modular/module/grip/afterattack(atom/target, mob/user, proximity, params)

	var/datum/process_fire/process = new /datum/process_fire()

	var/datum/gun_modular/component/data/gun_user/user_data = get_default_component(USER_FIRE)
	user_data.ChangeData(user)

	var/datum/gun_modular/component/data/gun_target/target_data = get_default_component(TARGET_FIRE)
	target_data.ChangeData(target)

	main_action(process)

/obj/item/gun_modular/module/grip/init_default_components_module()
	..()

	var/datum/gun_modular/component/data/gun_user/user_component = new (src)
	add_default_component(user_component)

	var/datum/gun_modular/component/data/gun_target/target_component = new (src)
	add_default_component(target_component)

	var/datum/gun_modular/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)

	var/datum/gun_modular/component/proc_gun/message_from_user/message_fail_advansedToolCheck = new (src, "<span class='red'>You don't have the dexterity to do this!</span>")
	var/datum/gun_modular/component/proc_gun/interrupter/interrupter_message_fail_advansedToolCheck = new (src)
	message_fail_advansedToolCheck.AddLastComponent(interrupter_message_fail_advansedToolCheck)

	var/datum/gun_modular/component/proc_gun/message_from_user/message_success_isHULKCheck = new (src, "<span class='red'>Your meaty finger is much too large for the trigger guard!</span>")
	var/datum/gun_modular/component/proc_gun/interrupter/interrupter_message_success_isHULKCheck = new (src)
	message_success_isHULKCheck.AddLastComponent(interrupter_message_success_isHULKCheck)

	var/datum/gun_modular/component/check/user_isHULK/user_isHULKCheck = new (src, message_success_isHULKCheck, null)

	var/datum/gun_modular/component/check/user_isLiving/user_isLivingCheck = new (src, user_isHULKCheck, null)

	var/datum/gun_modular/component/check/user_advansedTool/user_advansedToolCheck = new (src, user_isLivingCheck, message_fail_advansedToolCheck)
	add_default_component(user_advansedToolCheck)


/obj/item/gun_modular/module/grip/main_action(datum/process_fire/process)
	return ..()
