/obj/item/stack/rods
	name = "metal rod"
	desc = "Some rods. Can be used for building, or something."
	singular_name = "metal rod"
	icon_state = "rods"
	flags = CONDUCT
	w_class = 3.0
	force = 9.0
	throwforce = 15.0
	throw_speed = 5
	throw_range = 20
	m_amt = 1875
	max_amount = 60
	attack_verb = list("hit", "bludgeoned", "whacked")

/obj/item/stack/rods/attackby(obj/item/W, mob/user)
	..()
	if (istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W

		if(amount < 2)
			to_chat(user, "<span class='danger'>You need at least two rods to do this.</span>")
			return

		if(WT.remove_fuel(0,user))
			if(!use(2))
				return
			var/obj/item/stack/sheet/metal/new_item = new(usr.loc)
			new_item.add_to_stacks(usr)
			for (var/mob/M in viewers(src))
				M.show_message("<span class='danger'>[src] is shaped into metal by [user.name] with the weldingtool.</span>", 3, "\red You hear welding.", 2)
		return

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
		if(amount < 2)
			to_chat(user, "<span class='notice'>You need at least two rods to do this.</span>")
			return
		to_chat(usr, "<span class='notice'>Assembling grille...</span>")
		if (!do_after(usr, 10, target = usr))
			return
		if (!use(2))
			return
		var/obj/structure/grille/F = new /obj/structure/grille/ ( usr.loc )
		to_chat(usr, "<span class='notice'>You assemble a grille.</span>")
		F.add_fingerprint(usr)
	return
