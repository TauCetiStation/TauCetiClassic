/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = CONDUCT
	w_class = SIZE_SMALL
	force = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 20
	m_amt = 1875
	max_amount = 60
	usesound = 'sound/weapons/Genhit.ogg'
	attack_verb = list("hit", "bludgeoned", "whacked")
	qualities = list(
		QUALITY_PRYING = 0.5
	)

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/I, mob/user, params)
	if(iswelding(I))
		var/obj/item/weapon/weldingtool/WT = I

		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this!</span>")
			return

		if(WT.use(0, user))
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc, , TRUE)
			user.visible_message(
				"[user.name] shaped [src] into metal with the welding tool.",
				"<span class='notice'>You shape [src] into metal with the welding tool.</span>",
				"<span class='italics'>You hear welding.</span>")

			var/replace = (user.get_inactive_hand() == src)
			use(2)
			if(!QDELETED(src) && replace)
				user.put_in_hands(new_item)
	if(iscutter(I))
		playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
		user.visible_message(
			"[user.name] cuts the [src], turning it into a crossbow bolt.",
			"<span class='notice'>You cuts the [src], turning it into a crossbow bolt.</span>"
			)
		var/obj/item/weapon/arrow/new_item = new(user.loc)
		use(1)
		var/replace = (user.get_inactive_hand() == src)
		if(!QDELETED(src) && replace)
			user.put_in_hands(new_item)

	else
		return ..()

/obj/item/stack/rods/attack_self(mob/living/user)
	var/atom/build_loc = loc
	if(ismob(build_loc))
		build_loc = build_loc.loc

	if(!isturf(build_loc))
		return FALSE

	add_fingerprint(user)

	if(locate(/obj/structure/grille, build_loc))
		for(var/obj/structure/grille/G in build_loc)
			if(!G.destroyed)
				return TRUE

			if(!use(1))
				continue

			G.update_integrity(G.max_integrity)
			G.density = TRUE
			G.destroyed = FALSE
			update_icon()

		return FALSE

	try_to_build_grille(user, build_loc)

/obj/item/stack/rods/proc/try_to_build_grille(mob/living/user, build_loc, spawn_unanchored = TRUE)
	to_chat(usr, "<span class='notice'>Assembling grille...</span>")
	if (!use_tool(src, usr, 20, 2))
		return

	var/obj/structure/grille/F = new(build_loc, spawn_unanchored)

	to_chat(usr, "<span class='notice'>You assembled \a [F].</span>")
	F.add_fingerprint(usr)
