/obj/effect/decal/mecha_wreckage/t_34
	name = "Tank wreckage"
	icon = 'code\modules\holidays\23_february\tank.dmi'
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

/obj/item/weapon/key/t_34
	name = "key"
	desc = "A keyring with a small steel key."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "key"
	w_class = ITEM_SIZE_TINY
	var/id = 0

/obj/item/weapon/key/t_34/examine(mob/user)
	..()
	to_chat(user, "There is a small tag reading [id].")

/obj/mecha/combat/t_34
	desc = "Wow, T-34 changed alot since WW2."
	name = "\improper T-34"
	icon = 'code\modules\holidays\23_february\tank.dmi'
	icon_state = "basis"
	initial_icon = "basis"
	step_in = 3
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

	var/opened = FALSE // you need a key to open it
	var/key_id = 0

/obj/mecha/combat/t_34/atom_init()
	. = ..()

	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/generator(src)
	ME.attach(src)

	key_id = rand(1, 1000)
	var/obj/item/weapon/key/t_34/key = new /obj/item/weapon/key/t_34(get_turf(src))
	key.id = key_id

/obj/mecha/attackby(obj/item/weapon/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/weapon/key/t_34))
		if(user.is_busy())
			return
		if(do_after(user, 5, target = src))
			playsound(src, 'sound/weapons/handcuffs.ogg', 40, 1)
			opened = !opened
			user.visible_message("<b>[user] inserts the key into \the [src.name] and turn it [opened ? "on" : "off"].</b>", "<b>You insert the key into \the [src.name] and turn it [opened ? "on" : "off"]</b>")
			return

/obj/mecha/combat/t_34/add_cell(obj/item/weapon/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new(src)
	cell.charge = 40000
	cell.maxcharge = 40000
