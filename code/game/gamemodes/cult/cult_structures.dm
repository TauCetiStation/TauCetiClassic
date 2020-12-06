/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "Altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	light_color = "#2f0e0e"
	light_power = 2
	light_range = 3


/obj/structure/cult/forge
	name = "Daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"
	light_color = "#cc9338"
	light_power = 2
	light_range = 3

/obj/structure/cult/pylon
	name = "Pylon"
	desc = "A floating crystal that hums with an unearthly energy."
	icon_state = "pylon"
	light_color = "#ff9595"
	light_power = 2
	light_range = 6
	pass_flags = PASSTABLE

	var/holy_outline
	var/have_outline = FALSE

	var/turf/last_turf
	var/list/lying_items = list()
	// illusion = real
	var/list/lying_illusions = list()

/obj/structure/cult/pylon/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace, CALLBACK(src, .proc/put_item))
	last_turf = get_turf(src)

/obj/structure/cult/pylon/Destroy()
	last_turf = null
	for(var/obj/I in lying_items)
		UnregisterSignal(I, list(COMSIG_MOVABLE_MOVED))
	qdel(lying_items)
	clear_items()
	return ..()

// Tracking items on a pedestal
/obj/structure/cult/pylon/proc/put_item(atom/pedestal, obj/item/I, mob/user)
	lying_items += I

	if(lying_illusions.len)
		for(var/obj/effect/overlay/item_illusion/ill in lying_illusions)
			if(!lying_illusions[ill] && I.type == ill.my_fake_type)
				I.pixel_x = ill.pixel_x
				I.pixel_y = ill.pixel_y
				lying_illusions[ill] = I
				ill.alpha = 0
				break

	RegisterSignal(I, list(COMSIG_MOVABLE_MOVED), .proc/moved_item)

/obj/structure/cult/pylon/proc/moved_item(atom/movable/I, atom/oldLoc, dir)
	lying_items -= I
	var/obj/effect/overlay/item_illusion/ill = get_key(lying_illusions, I)
	if(ill)
		ill.alpha = 255
		lying_illusions[ill] = null
	UnregisterSignal(I, list(COMSIG_MOVABLE_MOVED))

/obj/structure/cult/pylon/proc/get_key(list/L, index)
	for(var/key in L)
		if(index == L[key])
			return key

/obj/structure/cult/pylon/proc/check_current_items()
	for(var/obj/effect/overlay/item_illusion/ill in lying_illusions)
		if(lying_illusions[ill])
			continue
		for(var/obj/item/I in lying_items)
			if(I.type == ill.my_fake_type)
				lying_illusions[ill] = I
				I.pixel_x = ill.pixel_x
				I.pixel_y = ill.pixel_y
				ill.alpha = 0

/obj/structure/cult/pylon/proc/get_off_useless_items()
	for(var/obj/item/I in lying_items)
		if(!get_key(lying_illusions, I))
			I.throw_at(get_step(src, pick(alldirs)), rand(1, 3), 3)

/obj/structure/cult/pylon/proc/create_illusions(atom/type, count)
	var/icon/holo_icon = getHologramIcon(icon(initial(type.icon), initial(type.icon_state)))

	for(var/i in 1 to count)
		create_illusion(type, holo_icon)

	check_current_items()
	get_off_useless_items()

/obj/structure/cult/pylon/proc/create_illusion(atom/type, holo_icon)
	var/obj/effect/overlay/item_illusion/I = new(loc)
	I.my_fake_type = type
	I.name = initial(type.name)
	I.pixel_x = rand(-14, 14)
	I.pixel_y = rand(-12, 12)
	var/image/image = image(holo_icon, I, initial(type.icon_state))
	I.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holy_role, "rite_holo_items", image)
	lying_illusions[I] = null
	stoplag()

/obj/structure/cult/pylon/proc/clear_items()
	for(var/k in lying_illusions)
		qdel(k)
	lying_illusions = list()

/obj/structure/cult/pylon/proc/create_holy_outline(_color)
	holy_outline = filter(type = "outline", size = 2, color = _color)
	filters += holy_outline
	have_outline = TRUE

/obj/structure/cult/pylon/proc/del_holy_outline()
	if(have_outline)
		filters -= holy_outline
		have_outline = FALSE

/obj/structure/cult/pylon/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	return ..()

/obj/structure/cult/pylon/CheckExit(atom/movable/AM, target)
	if(istype(AM) && AM.checkpass(PASSTABLE))
		return TRUE
	return ..()

/obj/structure/cult/tome
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_color = "#cc9338"
	light_power = 2
	light_range = 3

/obj/structure/cult/shell
	name = "cursed shell"
	desc = "It looks at you."
	icon_state = "shuttlecurse"
	light_color = "#6d1616"
	light_power = 2
	light_range = 2

/obj/structure/cult/spacewhole
	name = "abyss in space"
	desc = "You're pretty sure that abyss is staring back."
	icon_state = "space"

/obj/effect/timewhole
	name = "abyss in time"
	desc = "You feel a billion different looks when you gaze into emptiness."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0
	light_color = "#550314"
	light_power = 30
	light_range = 3

/obj/effect/orb
	name = "orb"
	desc = "Strange circle."
	icon = 'icons/obj/cult.dmi'
	icon_state = "summoning_orb"