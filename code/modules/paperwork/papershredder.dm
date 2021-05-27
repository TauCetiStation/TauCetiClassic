//
// Paper Shredder Machine
//

/obj/item/weapon/circuitboard/papershredder
	name = "papershredder"
	build_path = /obj/machinery/papershredder
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/weapon/stock_parts/micro_laser = 2,
							/obj/item/weapon/stock_parts/manipulator = 3)

/obj/machinery/papershredder
	name = "paper shredder"
	desc = "For those documents you don't want seen."
	icon = 'icons/obj/papershredder.dmi'
	icon_state = "shredder-off"
	var/shred_anim = "shredder-shredding"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 200
	power_channel = STATIC_ENVIRON
	var/max_paper = 10
	var/paperamount = 0
	var/list/shred_amounts = list(
		/obj/item/weapon/photo = 1,
		/obj/item/weapon/shreddedp = 1,
		/obj/item/weapon/paper = 1,
		/obj/item/weapon/newspaper = 3,
		/obj/item/weapon/card/id = 3,
		/obj/item/weapon/paper_bundle = 3,
		)

/obj/machinery/papershredder/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/papershredder(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()
	update_icon()

/obj/machinery/papershredder/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/weapon/storage))
		empty_bin(user, W)
		return
	else if(default_unfasten_wrench(user, W))
		return
	else if(exchange_parts(user, W))
		return
	else if(default_deconstruction_screwdriver(user, W))
		return
	else if(default_deconstruction_crowbar(user, W))
		return
	else
		var/paper_result
		for(var/shred_type in shred_amounts)
			if(istype(W, shred_type))
				paper_result = shred_amounts[shred_type]
				break
		if(paper_result)
			if(!is_operational())
				return // Need powah!
			if(paperamount == max_paper)
				to_chat(user, "<span class='warning'>\The [src] is full; please empty it before you continue.</span>")
				return
			paperamount += paper_result
			user.drop_from_inventory(W)
			qdel(W)
			playsound(src, 'sound/items/pshred.ogg', VOL_EFFECTS_MASTER)
			flick(shred_anim, src)
			if(paperamount > max_paper)
				to_chat(user,"<span class='danger'>\The [src] was too full, and shredded paper goes everywhere!</span>")
				for(var/i=(paperamount-max_paper);i>0;i--)
					var/obj/item/weapon/shreddedp/SP = get_shredded_paper()
					SP.forceMove(loc)
					SP.throw_at(get_edge_target_turf(src, pick(alldirs)), 1, 5)
				paperamount = max_paper
			update_icon()
			return
	return ..()

/obj/machinery/papershredder/verb/empty_contents()
	set name = "Empty bin"
	set category = "Object"
	set src in range(1)

	if(usr.incapacitated())
		return

	if(!paperamount)
		to_chat(usr, "<span class='notice'>\The [src] is empty.</span>")
		return

	empty_bin(usr)

/obj/machinery/papershredder/proc/empty_bin(var/mob/living/user, var/obj/item/weapon/storage/empty_into)

	// Sanity.
	if(empty_into && !istype(empty_into))
		empty_into = null

	if(empty_into?.contents.len>0)
		to_chat(user, "<span class='notice'>\The [empty_into] is full.</span>")
		return

	while(paperamount)
		var/obj/item/weapon/shreddedp/SP = get_shredded_paper()
		if(!SP) break
		if(empty_into)
			empty_into.handle_item_insertion(SP)
			if(empty_into.contents.len >= empty_into.storage_slots)
				break
	if(empty_into)
		if(paperamount)
			to_chat(user, "<span class='notice'>You fill \the [empty_into] with as much shredded paper as it will carry.</span>")
		else
			to_chat(user, "<span class='notice'>You empty \the [src] into \the [empty_into].</span>")

	else
		to_chat(user, "<span class='notice'>You empty \the [src].</span>")
	update_icon()

/obj/machinery/papershredder/proc/get_shredded_paper()
	if(!paperamount)
		return
	paperamount--
	return new /obj/item/weapon/shreddedp(get_turf(src))

/obj/machinery/papershredder/power_change()
	..()
	spawn(rand(0,15))
		update_icon()

/obj/machinery/papershredder/update_icon()
	overlays.Cut()
	if(is_operational())
		icon_state = "shredder-on"
	else
		icon_state = "shredder-off"
	// Fullness overlay
	overlays += "shredder-[clamp(0, 5, FLOOR(paperamount/max_paper*5, 1))]"
	if (panel_open)
		overlays += "panel_open"

//
// Shredded Paper Item
//

/obj/item/weapon/shreddedp
	name = "shredded paper"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "shredp"
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 3
	throw_speed = 1

/obj/item/weapon/shreddedp/New()
	..()
	pixel_x = rand(-5,5)
	pixel_y = rand(-5,5)
	if(prob(65))
		color = pick("#BABABA", "#7F7F7F")

/obj/item/weapon/shreddedp/attackby(var/obj/item/P as obj, var/mob/user)
	if(istype(P, /obj/item/weapon/lighter))
		burnpaper(P, user)
	else
		..()

/obj/item/weapon/shreddedp/burnpaper(var/obj/item/weapon/lighter/P, var/mob/user)
	if(user.restrained())
		return
	if(!P.lit)
		to_chat(user, "<span class='warning'>\The [P] is not lit.</span>")
		return
	user.visible_message("<span class='warning'>\The [user] holds \the [P] up to \the [src]. It looks like try to burn it!</span>", \
		"<span class='warning'>You hold \the [P] up to \the [src], burning it slowly.</span>")
	if(!do_after(user,20))
		to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")
		return
	user.visible_message("<span class='danger'>\The [user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
		"<span class='danger'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")
	FireBurn()

/obj/item/weapon/shreddedp/proc/FireBurn()
	var/mob/living/M = loc
	if(istype(M))
		M.drop_from_inventory(src)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
