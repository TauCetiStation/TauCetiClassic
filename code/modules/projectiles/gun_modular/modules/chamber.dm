/obj/item/gun_modular/module/chamber
	name = "патронник"
	module_id = CHAMBER_MODULE
	var/recoil_change = 1
	var/click_sound = 'sound/weapons/guns/empty.ogg'
	var/fire_sound = 'sound/weapons/guns/Gunshot.ogg'
	var/obj/item/ammo_casing/chambered = null

/obj/item/gun_modular/module/chamber/atom_init(mapload, ...)
	. = ..()

	var/obj/item/gun_modular/module/magazine_holder/magazine_holder = new(loc)
	attach(magazine_holder)

	var/obj/item/gun_modular/module/barrel/barrel = new(loc)
	attach(barrel)

/obj/item/gun_modular/module/chamber/init_allowed_modules()

	add_allow_module(MAGAZINE_HOLDER)
	add_allow_module(BARREL)

	return TRUE

/obj/item/gun_modular/module/chamber/main_action(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/chamber_ammoCase/chamber_ammoCase_component = new (src, chambered)
	process.AddComponentGun(chamber_ammoCase_component)

	return ..()

/obj/item/gun_modular/module/chamber/init_default_components_module()
	..()

	var/datum/pipe_system/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)

	var/datum/pipe_system/component/data/sound_data/click_sound/click_sound_component = new (src)
	click_sound_component.sound = click_sound
	add_default_component(click_sound_component)

	var/datum/pipe_system/component/data/sound_data/fire_sound/fire_sound_component = new (src)
	fire_sound_component.sound = fire_sound
	add_default_component(fire_sound_component)

	var/datum/pipe_system/component/proc_gun/message_from_user/message_empty_chamber = new (src, "<span class='warning'>*click*</span>")
	var/datum/pipe_system/component/proc_gun/playsound_click/playsound_click = new (src)
	var/datum/pipe_system/component/proc_gun/interrupter/interrupter_empty_chamber = new (src)
	message_empty_chamber.AddLastComponent(playsound_click)
	message_empty_chamber.AddLastComponent(interrupter_empty_chamber)

	var/datum/pipe_system/component/proc_gun/ammoCase_fire/ammoCase_fire_proc = new(src)
	var/datum/pipe_system/component/proc_gun/playsound_fire/playsound_fire = new (src)
	var/datum/pipe_system/component/proc_gun/user_recoil/user_recoil_proc = new (src)
	var/datum/pipe_system/component/proc_gun/visible_message_user/announse_shot_visible_message_user = new(src, "<span class='danger'>КТО ТО fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear a gunshot!")

	playsound_fire.AddLastComponent(user_recoil_proc)
	playsound_fire.AddLastComponent(announse_shot_visible_message_user)

	var/datum/pipe_system/component/check/fire_result/fire_result_check = new(src, playsound_fire, playsound_click)
	ammoCase_fire_proc.AddLastComponent(fire_result_check)

	var/datum/pipe_system/component/proc_gun/add_last_component/add_last_component_proc = new (src, ammoCase_fire_proc)

	var/datum/pipe_system/component/proc_gun/return_ammo_insert_chamber/return_ammo_insert_chamber_proc = new (src)
	var/datum/pipe_system/component/check/ammo_returned/ammo_returned_check = new(src, null, null)
	var/datum/pipe_system/component/awaiter/await_return_ammo = new (src, return_ammo_insert_chamber_proc, ammo_returned_check, list(COMSIG_GUN_CHECK_SUCCESS), null)
	await_return_ammo.id_component = "await return ammo"

	var/datum/pipe_system/component/data/gun_get_ammo/gun_get_ammo_data = new(src, TRUE)
	gun_get_ammo_data.AddLastComponent(await_return_ammo)
	var/datum/pipe_system/component/check/chamber_Chambered/chamber_Chambered_check_from_get_ammo = new (src, null, gun_get_ammo_data)
	add_default_component(chamber_Chambered_check_from_get_ammo)

	var/datum/pipe_system/component/check/chamber_Chambered/chamber_Chambered_check = new (src, null, null)

	var/datum/pipe_system/component/awaiter/await_ammoCase = new (src, add_last_component_proc, chamber_Chambered_check, list(COMSIG_GUN_CHECK_SUCCESS), message_empty_chamber)
	await_ammoCase.id_component = "await chambered"
	add_default_component(await_ammoCase)
