/obj/item/gun_modular/module/magazine_holder
	name = "держатель магазина"
	module_id = MAGAZINE_HOLDER

/obj/item/gun_modular/module/chamber/main_action(datum/process_fire/process)

	var/datum/gun_modular/component/data/chamber_ammoCase/chamber_ammoCase_component = get_default_component(AMMO_FIRE)
	chamber_ammoCase_component.value = chambered

	return ..()

/obj/item/gun_modular/module/chamber/init_default_components_module()
	..()

	var/datum/gun_modular/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)

	var/datum/gun_modular/component/data/chamber_ammoCase/chamber_ammoCase_component = new (src, chambered)
	add_default_component(chamber_ammoCase_component)

	var/datum/gun_modular/component/data/sound_data/click_sound/click_sound_component = new (src)
	click_sound_component.sound = click_sound
	add_default_component(click_sound_component)

	var/datum/gun_modular/component/data/sound_data/fire_sound/fire_sound_component = new (src)
	fire_sound_component.sound = fire_sound
	add_default_component(fire_sound_component)

	var/datum/gun_modular/component/proc_gun/message_from_user/message_empty_chamber = new (src, "<span class='warning'>*click*</span>")
	var/datum/gun_modular/component/proc_gun/playsound_click/playsound_click = new (src)
	var/datum/gun_modular/component/proc_gun/interrupter/interrupter_empty_chamber = new (src)
	message_empty_chamber.AddLastComponent(playsound_click)
	message_empty_chamber.AddLastComponent(interrupter_empty_chamber)

	var/datum/gun_modular/component/proc_gun/ammoCase_fire/ammoCase_fire_proc = new(src)
	var/datum/gun_modular/component/proc_gun/playsound_fire/playsound_fire = new (src)
	var/datum/gun_modular/component/check/fire_result/fire_result_check = new(src, playsound_fire, playsound_click)
	ammoCase_fire_proc.AddLastComponent(fire_result_check)

	var/datum/gun_modular/component/proc_gun/add_last_component/add_last_component_proc = new (src, ammoCase_fire_proc)

	var/datum/gun_modular/component/check/chamber_Chambered/chamber_Chambered_check = new (src, null, null)

	var/datum/gun_modular/component/awaiter/await_ammoCase = new (src, add_last_component_proc, chamber_Chambered_check, list(COMSIG_GUN_CHECK_SUCCESS), message_empty_chamber)
	add_default_component(await_ammoCase)
