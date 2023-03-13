/obj/item/gun_modular/module/chamber/revolver_chamber
	name = "револьверный патронник"
	module_id = CHAMBER_MODULE
	var/recoil_change = 2
	var/click_sound = 'sound/weapons/guns/empty.ogg'
	var/fire_sound = 'sound/weapons/guns/gunshot_heavy.ogg'
	var/obj/item/ammo_casing/chambered = null

/obj/item/gun_modular/module/chamber/revolver_chamber/main_action(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/chamber_ammoCase/chamber_ammoCase_component = new (src, chambered)
	process.AddComponentGun(chamber_ammoCase_component)

	return ..()

/obj/item/gun_modular/module/chamber/revolver_chamber/init_default_components_module()

	var/datum/pipe_system/component/check/chamber_Chambered/check_chambered = new(src)
	var/datum/pipe_system/component/awaiter/wait_chambered = new (src, )
