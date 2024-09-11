// Maybe rework on component
/obj/structure/pedestal
	density = TRUE
	anchored = TRUE
	pass_flags = PASSTABLE

	var/holy_outline
	var/have_outline = FALSE

	var/is_busy = FALSE

	var/datum/religion_rites/pedestals/my_rite

	var/turf/last_turf
	var/list/lying_items = list()
	// illusion = real
	var/list/lying_illusions = list()

	var/static/holo_cash = list()

/obj/structure/pedestal/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace, CALLBACK(src, PROC_REF(put_item)))
	last_turf = get_turf(src)

/obj/structure/pedestal/Destroy()
	last_turf = null
	for(var/obj/I in lying_items)
		UnregisterSignal(I, list(COMSIG_MOVABLE_MOVED))
	qdel(lying_items)
	clear_items()
	if(my_rite)
		my_rite.reset_rite()
	return ..()

/obj/structure/pedestal/examine(mob/user, distance)
	. = ..()
	if(!my_rite || !lying_illusions.len)
		return

	var/can_i_see = FALSE
	if(isobserver(user))
		can_i_see = TRUE
	else if(isliving(user))
		var/mob/living/L = user
		if(L.mind && L.mind.holy_role)
			can_i_see = TRUE

	if(!can_i_see)
		return

	var/obj/effect/overlay/item_illusion/E = pick(lying_illusions) // one pedestal = one type of items
	if(!E.fake_icon)
		E.fake_icon = image(initial(E.my_fake_type.icon), E, initial(E.my_fake_type.icon_state))
	to_chat(user, "<span class='notice'>Вам нужно положить ещё [lying_illusions.len] - [bicon(E.fake_icon)][initial(E.my_fake_type.name)].</span>")

/obj/structure/pedestal/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/storage/bible/tome)) // So that you can destroy the pedestal and not put a tome on it
		return FALSE

	if(iswrenching(W))
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		if(W.use_tool(src, user, 20, volume = 50))
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return FALSE

	return ..()

// Tracking items on a pedestal
/obj/structure/pedestal/proc/put_item(atom/pedestal, obj/item/I, mob/user)
	if(HAS_TRAIT(I, TRAIT_NO_SACRIFICE))
		return
	lying_items += I

	if(lying_illusions.len)
		for(var/obj/effect/overlay/item_illusion/ill in lying_illusions)
			if(!lying_illusions[ill] && istype(I, ill.my_fake_type))
				I.pixel_x = ill.pixel_x
				I.pixel_y = ill.pixel_y
				lying_illusions[ill] = I
				ill.alpha = 0
				break

	RegisterSignal(I, list(COMSIG_MOVABLE_MOVED), PROC_REF(moved_item))

/obj/structure/pedestal/proc/moved_item(atom/movable/I, atom/oldLoc, dir)
	lying_items -= I
	var/obj/effect/overlay/item_illusion/ill = get_key(lying_illusions, I)
	if(ill)
		ill.alpha = 255
		lying_illusions[ill] = null
	UnregisterSignal(I, list(COMSIG_MOVABLE_MOVED))

/obj/structure/pedestal/proc/get_key(list/L, index)
	for(var/key in L)
		if(index == L[key])
			return key
	return null

/obj/structure/pedestal/proc/check_current_items()
	var/list/items = lying_items.Copy()
	var/i = 1
	for(var/obj/effect/overlay/item_illusion/ill in lying_illusions)
		if(lying_items.len < i)
			break

		var/obj/item/I = lying_items[i]
		if(istype(I, ill.my_fake_type))
			lying_illusions[ill] = I
			I.pixel_x = ill.pixel_x
			I.pixel_y = ill.pixel_y
			ill.alpha = 0
			items -= I
		i++

	get_off_useless_items(items)

/obj/structure/pedestal/proc/get_off_useless_items(list/items)
	for(var/obj/item/I in items)
		I.throw_at(get_step(src, pick(alldirs)), rand(1, 6), 2)

/obj/structure/pedestal/proc/get_holo_icon(atom/type)
	if(holo_cash[type])
		return holo_cash[type]

	var/icon/holo_icon = getHologramIcon(icon(initial(type.icon), initial(type.icon_state)))
	holo_cash[type] = holo_icon

	return holo_icon

/obj/structure/pedestal/proc/create_illusions(atom/type, count)
	var/icon/holo_icon = get_holo_icon(type)

	for(var/i in 1 to count)
		create_illusion(type, holo_icon)

	check_current_items()

/obj/structure/pedestal/proc/create_illusion(atom/type, holo_icon)
	var/obj/effect/overlay/item_illusion/I = new(loc)
	I.my_fake_type = type
	I.name = initial(type.name)
	I.pixel_x = rand(-14, 14)
	I.pixel_y = rand(-12, 12)
	var/image/image = image(holo_icon, I, initial(type.icon_state))
	I.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holy_role, "rite_holo_items", image)
	lying_illusions[I] = null
	stoplag()

/obj/structure/pedestal/proc/clear_items()
	for(var/k in lying_illusions)
		qdel(k)
	lying_illusions = list()

/obj/structure/pedestal/proc/create_holy_outline(_color)
	add_filter("pedestal_outline", 2, outline_filter(2, _color))
	have_outline = TRUE

/obj/structure/pedestal/proc/del_holy_outline()
	if(have_outline)
		remove_filter("pedestal_outline")
		have_outline = FALSE

/obj/structure/pedestal/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	return ..()

// CULT! Then move it to the religion module or make it some kind of datum
/obj/structure/pedestal/cult
	name = "pedestal"
	desc = "A monolith of unknown stone with unreadable runes."
	icon = 'icons/obj/cult.dmi'
	icon_state = "pedestal"
