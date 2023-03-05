/obj/item/gun_modular/module/barrel
	name = "ствол"
	module_id = MAGAZINE_HOLDER
	var/obj/item/ammo_box/magazine/internal/cylinder/ammo_box = null
	var/recoil_change = 1;

/obj/item/gun_modular/module/barrel/atom_init(mapload, ...)
	. = ..()

/obj/item/gun_modular/module/barrel/main_action(datum/process_fire/process)

	return ..()

/obj/item/gun_modular/module/barrel/init_default_components_module()

	var/datum/gun_modular/component/data/gun_recoil/recoil_component = new (src, recoil_change)
	add_default_component(recoil_component)
