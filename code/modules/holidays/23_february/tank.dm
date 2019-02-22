/obj/effect/decal/mecha_wreckage/t_34
	name = "Tank wreckage"
	icon = 'code/modules/holidays/23_february/tank.dmi'
	icon_state = "tank-broken"
	salvage = list(
		"welder" = list(
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			),
		"wirecutter" = list(
			/obj/item/stack/cable_coil,
			/obj/item/weapon/stock_parts/scanning_module/adv,
			/obj/item/weapon/stock_parts/capacitor/adv,
			/obj/item/stack/rods
			),
		"crowbar" = list(
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/plasteel
			)
		)

/obj/mecha/combat/t_34
	desc = "Wow, T-34 changed alot since WW2."
	name = "\improper T-34"
	icon = 'code/modules/holidays/23_february/tank.dmi'
	icon_state = "tank"
	initial_icon = "tank"
	step_in = 6
	dir_in = 1 // Facing North.
	health = 300
	deflect_chance = 15
	damage_absorption = list("brute"=0.75,"fire"=1,"bullet"=0.8,"laser"=0.7,"energy"=0.85,"bomb"=1)
	max_temperature = 35000
	infra_luminosity = 0
	wreckage = /obj/effect/decal/mecha_wreckage/t_34
	internal_damage_threshold = 35
	max_equip = 4
	step_energy_drain = 5

/obj/mecha/combat/t_34/eject()
	. = ..()
	if(!opened)
		return

/obj/mecha/combat/t_34/atom_init()
	. = ..()

	pixel_x = -10
	pixel_y = -15
	icon_state = "tank"

	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/generator(src)
	ME.attach(src)

/obj/mecha/combat/t_34/add_cell(obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 40000
	cell.maxcharge = 40000
