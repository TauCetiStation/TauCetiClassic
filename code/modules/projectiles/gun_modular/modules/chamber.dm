/obj/item/gun_modular/module/chamber
	name = "патронник"
	module_id = CHAMBER_MODULE
	var/recoil_change = 1

/obj/item/gun_modular/module/chamber/activate(datum/process_fire/process)

	return ..()

/obj/item/gun_modular/module/chamber/post_activate(datum/process_fire/process)

	return ..()

/obj/item/gun_modular/module/chamber/init_default_components_module()
	..()

	var/datum/gun_modular/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)
