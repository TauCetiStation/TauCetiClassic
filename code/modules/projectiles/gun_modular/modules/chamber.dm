/obj/item/gun_modular/module/chamber
	name = "патронник"
	module_id = CHAMBER_MODULE
	var/recoil_change = 1
	var/obj/item/ammo_casing/chambered = null

/obj/item/gun_modular/module/chamber/main_action(datum/process_fire/process)

	var/datum/gun_modular/component/data/chamber_ammoCase/chamber_ammoCase_component = get_default_component(AMMO_FIRE)
	chamber_ammoCase_component.ChangeData(chambered)

	return ..()

/obj/item/gun_modular/module/chamber/init_default_components_module()
	..()

	var/datum/gun_modular/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)

	var/datum/gun_modular/component/data/chamber_ammoCase/chamber_ammoCase_component = new (src, chambered)
	add_default_component(chambered)

	var/datum/gun_modular/component/check/chamber_Chambered/chamber_Chambered_check = new (src, null, null)
	add_default_component(chamber_Chambered_check)
