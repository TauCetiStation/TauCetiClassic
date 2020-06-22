/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = CONDUCT
	w_class = ITEM_SIZE_NORMAL
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_amount = 60
	usesound = 'sound/weapons/Genhit.ogg'
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "rods-[amount]"
	else
		icon_state = "rods"

/obj/item/stack/rods/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
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

	else
		return ..()

/obj/item/stack/rods/attack_self(mob/user)
	src.add_fingerprint(user)

	if(!istype(user.loc,/turf)) return 0

	if (locate(/obj/structure/grille, usr.loc))
		for(var/obj/structure/grille/G in usr.loc)
			if (G.destroyed)
				if(!use(1))
					continue
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
			else
				return 1
	else
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two rods to do this!</span>")
			return
		if(user.is_busy(src))
			return
		to_chat(usr, "<span class='notice'>Assembling grille...</span>")
		if (!use_tool(usr, usr, 10))
			return
		if (!use(2))
			return
		var/obj/structure/grille/F = new /obj/structure/grille( usr.loc )
		to_chat(usr, "<span class='notice'>You assemble a grille.</span>")
		F.add_fingerprint(usr)
	return
