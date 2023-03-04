/datum/gun_modular/component/proc_gun/ammoCase_fire
	id_component = "ammoCase_fire"

/datum/gun_modular/component/proc_gun/ammoCase_fire/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/chamber_ammoCase/ammo_fire_data = process.GetCacheData(AMMO_FIRE)
	var/datum/gun_modular/component/data/gun_target/target_fire_data = process.GetCacheData(TARGET_FIRE)
	var/datum/gun_modular/component/data/gun_user/user_fire_data = process.GetCacheData(USER_FIRE)
	var/datum/gun_modular/component/data/gun_params/params_fire_data = process.GetCacheData(PARAMS_FIRE)

	var/datum/gun_modular/component/data/fire_result/result_fire_data = new(parent, FALSE)

	// if(!ammo_fire_data || !target_fire_data || !user_fire_data || !silensed_fire_data || !params_fire_data)
	// 	ChangeNextComponent(result_fire_data)
	// 	return ..()

	var/obj/item/ammo_casing/ammo_case = ammo_fire_data.GetData()
	var/atom/target = target_fire_data.GetData()
	var/mob/user = user_fire_data.GetData()
	var/params = params_fire_data.GetData()

	result_fire_data.value = ammo_case.fire(process, target, user, params, , 0)
	ChangeNextComponent(result_fire_data)

	return ..()

