/obj/structure/pit
	name = "pit"
	desc = "Watch your step, partner."
	icon = 'icons/obj/pit.dmi'
	icon_state = "pit1"
	blend_mode = BLEND_MULTIPLY
	density = 0
	anchored = 1
	var/open = 1

/obj/structure/pit/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/weapon/shovel))
		if(user.is_busy(src))
			return
		visible_message("<span class='notice'>\The [user] starts [open ? "filling" : "digging open"] \the [src]</span>")
		if(W.use_tool(src, user, 50, volume = 100))
			visible_message("<span class='notice'>\The [user] [open ? "fills" : "digs open"] \the [src]!</span>")
			if(open)
				close(user)
			else
				open()
		else
			to_chat(user, "<span class='notice'>You stop shoveling.</span>")
		return
	if(!open && istype(W,/obj/item/stack/sheet/wood))
		if(locate(/obj/structure/gravemarker) in src.loc)
			to_chat(user, "<span class='notice'>There's already a grave marker here.</span>")
		else
			var/obj/item/stack/sheet/wood/plank = W
			if(plank.get_amount() < 1)
				return
			if(user.is_busy()) return
			visible_message("<span class='notice'>\The [user] starts making a grave marker on top of \the [src]</span>")
			if(plank.use_tool(src, user, 50, volume = 100))
				if(!plank.use(1))
					return
				visible_message("<span class='notice'>\The [user] finishes the grave marker</span>")
				new/obj/structure/gravemarker(src.loc)
			else
				to_chat(user, "<span class='notice'>You stop making a grave marker.</span>")
		return
	..()

/obj/structure/pit/update_icon()
	icon_state = "pit[open]"


/obj/structure/pit/proc/open()
	name = "pit"
	desc = "Watch your step, partner."
	open = 1
	for(var/atom/movable/A in src)
		A.forceMove(src.loc)
	update_icon()

/obj/structure/pit/proc/close(user)
	name = "mound"
	desc = "Some things are better left buried."
	open = 0
	for(var/atom/movable/A in src.loc)
		if(!A.anchored && A != user)
			A.forceMove(src)
	update_icon()

/obj/structure/pit/return_air()
	return open

/obj/structure/pit/proc/digout(mob/escapee)
	var/breakout_time = 1 //2 minutes by default

	if(open)
		return

	if(escapee.incapacitated())
		return

	to_chat(escapee, "<span class='warning'>You start digging your way out of \the [src] (this will take about [breakout_time] minute\s)</span>")
	visible_message("<span class='danger'>Something is scratching its way out of \the [src]!</span>")

	for(var/i in 1 to (6*breakout_time * 2)) //minutes * 6 * 5seconds * 2
		playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)

		if(!do_after(escapee, 50, target = src))
			to_chat(escapee, "<span class='warning'>You have stopped digging.</span>")
			return
		if(!escapee || escapee.incapacitated() || escapee.loc != src)
			return
		if(open)
			return

		if(i == 6*breakout_time)
			to_chat(escapee, "<span class='warning'>Halfway there...</span>")

	to_chat(escapee, "<span class='warning'>You successfuly dig yourself out!</span>")
	visible_message("<span class='danger'>\the [escapee] emerges from \the [src]!</span>")
	playsound(src, 'sound/effects/squelch1.ogg', VOL_EFFECTS_MASTER)
	open()

/obj/structure/pit/closed
	name = "mound"
	desc = "Some things are better left buried."
	open = 0

/obj/structure/pit/closed/atom_init()
	. = ..()
	close()

//invisible until unearthed first
/obj/structure/pit/closed/hidden
	invisibility = INVISIBILITY_OBSERVER

/obj/structure/pit/closed/hidden/open()
	..()
	invisibility = INVISIBILITY_LEVEL_ONE

//spoooky
/obj/structure/pit/closed/grave
	name = "grave"
	icon_state = "pit0"

/obj/structure/pit/closed/grave/atom_init()
	var/obj/structure/closet/coffin/C = new(src.loc)

	var/obj/effect/decal/remains/human/bones = new(C)
	bones.layer = MOB_LAYER

	var/loot
	var/list/suits = list(
		/obj/item/clothing/suit/wintercoat/captain,
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/storage/det_suit,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/postal_dude_coat,
		/obj/item/clothing/suit/jacket,
		/obj/item/clothing/suit/poncho
		)
	loot = pick(suits)
	new loot(C)

	var/list/uniforms = list(
		/obj/item/clothing/under/soviet,
		/obj/item/clothing/under/redcoat,
		/obj/item/clothing/under/pants/khaki,
		/obj/item/clothing/under/pants/jeans,
		/obj/item/clothing/under/pants/camo,
		/obj/item/clothing/under/det,
		/obj/item/clothing/under/brown,
		/obj/item/clothing/under/jetsons,
		/obj/item/clothing/under/jetsons/j2
		)
	loot = pick(uniforms)
	new loot(C)

	if(prob(30))
		var/list/misc = list(
			/obj/item/clothing/accessory/fluff/altair_locket,
			/obj/item/clothing/accessory/holobadge,
			/obj/item/clothing/accessory/tie/horrible,
			/obj/item/clothing/accessory/medal,
			/obj/item/clothing/accessory/medal/silver,
			/obj/item/clothing/accessory/medal/silver/valor,
			/obj/item/clothing/accessory/medal/gold,
			/obj/item/clothing/accessory/medal/gold/heroism,
			/obj/item/weapon/gun/energy/laser/retro/jetsons
			)
		loot = pick(misc)
		new loot(C)

	var/obj/structure/gravemarker/random/R = new(src.loc)
	R.generate()
	. = ..()

/obj/structure/gravemarker
	name = "grave marker"
	desc = "You're not the first."
	icon = 'icons/obj/gravestone.dmi'
	icon_state = "wood"
	pixel_x = 15
	pixel_y = 8
	anchored = 1
	var/message = "Unknown."

/obj/structure/gravemarker/cross
	icon_state = "cross"

/obj/structure/gravemarker/examine(mob/user)
	..()
	to_chat(user, message)

/obj/structure/gravemarker/random/atom_init()
	generate()
	. = ..()

/obj/structure/gravemarker/random/proc/generate()
	icon_state = pick("wood","cross")

	var/nam = random_name(pick(MALE,FEMALE))
	var/cur_year = text2num(time2text(world.timeofday, "YYYY"))+544
	var/born = cur_year - rand(5,150)
	var/died = max(cur_year - rand(0,70),born)

	message = "Here lies [nam], [born] - [died]."

/obj/structure/gravemarker/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/hatchet))
		if(user.is_busy(src))
			return
		visible_message("<span class = 'warning'>\The [user] starts hacking away at \the [src] with \the [W].</span>")
		if(W.use_tool(src, user, 30, volume = 100))
			visible_message("<span class = 'warning'>\The [user] hacks \the [src] apart.</span>")
			new /obj/item/stack/sheet/wood(src)
			qdel(src)
			return
	if(istype(W,/obj/item/weapon/pen))
		var/msg = sanitize(input(user, "What should it say?", "Grave marker", input_default(message)) as text|null)
		add_fingerprint(user)
		if(msg)
			message = msg


//Grave jetsons items


/obj/item/weapon/gun/energy/laser/retro/jetsons
	name ="unwanted laser"
	icon_state = "jetsons"
	item_state = "jetsons"
	desc = "Very unusual version of laser gun, oldschool style"
	origin_tech = "combat=2;magnets=1"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice/jetsons)


/obj/item/weapon/gun/energy/laser/retro/jetsons/update_icon()
	return 0

/obj/item/ammo_casing/energy/laser/practice/jetsons
	projectile_type = /obj/item/projectile/beam/practice/jetsons
	select_name = "practice_jetsons"
	fire_sound = 'sound/weapons/guns/gunpulse_laser2.ogg'

/obj/item/projectile/beam/practice/jetsons
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 7 //lucky shot
	damage_type = BURN
	flag = "laser"
	eyeblur = 2

/obj/item/clothing/under/jetsons
	name = "old overall"
	desc = "Mr. Spacely's favorite overalls"
	icon_state = "jetsons_s"
	item_color = "jetsons_s"

/obj/item/clothing/under/jetsons/j2
	name = "old dress"
	desc = "Jetson is coming appart"
	icon_state = "jetsons_f"
	item_color = "jetsons_f"

