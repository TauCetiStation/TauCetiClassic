/obj/item/gun_modular/module/magazine_holder
	name = "держатель магазина"
	module_id = MAGAZINE_HOLDER
	var/obj/item/ammo_box/magazine/internal/cylinder/ammo_box = null

/obj/item/gun_modular/module/magazine_holder/atom_init(mapload, ...)
	. = ..()

	ammo_box = new(src)

/obj/item/gun_modular/module/magazine_holder/main_action(datum/process_fire/process)

	var/datum/gun_modular/component/data/gun_ammo_box/ammo_box_component = new (src, ammo_box)
	process.AddComponentGun(ammo_box_component)

	return ..()

/obj/item/gun_modular/module/magazine_holder/init_default_components_module()

	var/datum/gun_modular/component/check/get_ammo/get_ammo_check = new(src, null, null)
	var/datum/gun_modular/component/proc_gun/ammo_box_get_round/ammo_box_get_round_proc = new(src)

	var/datum/gun_modular/component/awaiter/await_get_ammo = new (src, ammo_box_get_round_proc, get_ammo_check, list(COMSIG_GUN_CHECK_SUCCESS), null)
	await_get_ammo.id_component = "await request ammo"
	add_default_component(await_get_ammo)
