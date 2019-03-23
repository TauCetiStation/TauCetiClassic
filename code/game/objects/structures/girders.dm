/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = 2.9
	var/state = 0
	var/health = 200


/obj/structure/girder/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam))
		health -= Proj.damage
		..()
		if(health <= 0)
			new /obj/item/stack/sheet/metal(get_turf(src))
			qdel(src)

		return

/obj/structure/girder/attackby(obj/item/W, mob/user)
	if(user.is_busy()) return
	if(istype (W,/obj/item/weapon/changeling_hammer))
		var/obj/item/weapon/changeling_hammer/C = W
		visible_message("\red <B>[user]</B> has punched \the <B>[src]!</B>")
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		if(C.use_charge(user, 1) && prob(40))
			playsound(loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
			qdel(src)
	else if(iswrench(W) && state == 0)
		if(anchored && !istype(src,/obj/structure/girder/displaced))
			to_chat(user, "\blue Now disassembling the girder")
			if(W.use_tool(src, user, 40, volume = 100))
				if(!src) return
				to_chat(user, "\blue You dissasembled the girder!")
				new /obj/item/stack/sheet/metal(get_turf(src))
				qdel(src)
		else if(!anchored)
			to_chat(user, "\blue Now securing the girder")
			if(W.use_tool(src, user, 40, volume = 100))
				to_chat(user, "\blue You secured the girder!")
				new/obj/structure/girder( src.loc )
				qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "\blue Now slicing apart the girder")
		if(W.use_tool(src, user, 30, volume = 100))
			if(!src) return
			to_chat(user, "\blue You slice apart the girder!")
			new /obj/item/stack/sheet/metal(get_turf(src))
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		to_chat(user, "\blue You drill through the girder!")
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)

	else if(isscrewdriver(W) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		to_chat(user, "\blue Now unsecuring support struts")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "\blue You unsecured the support struts!")
			state = 1

	else if(iswirecutter(W) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		to_chat(user, "\blue Now removing support struts")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "\blue You removed the support struts!")
			new/obj/structure/girder( src.loc )
			qdel(src)

	else if(iscrowbar(W) && state == 0 && anchored )
		to_chat(user, "\blue Now dislodging the girder")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "\blue You dislodged the girder!")
			new/obj/structure/girder/displaced( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet))

		var/obj/item/stack/sheet/S = W
		switch(S.type)

			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(!anchored)
					if(!S.use(2))
						return
					to_chat(user, "\blue You create a false wall! Push on it to open or close the passage.")
					new /obj/structure/falsewall (src.loc)
					qdel(src)
				else
					if(S.get_amount() < 2)
						return ..()
					to_chat(user, "\blue Now adding plating...")
					if(S.use_tool(src, user, 40, volume = 100))
						if(QDELETED(src) || QDELETED(S) || !S.use(2))
							return
						to_chat(user, "\blue You added the plating!")
						var/turf/Tsrc = get_turf(src)
						Tsrc.ChangeTurf(/turf/simulated/wall)
						for(var/turf/simulated/wall/X in Tsrc.loc)
							X.add_hiddenprint(usr)
						qdel(src)
					return

			if(/obj/item/stack/sheet/plasteel)
				if(!anchored)
					if(!S.use(2))
						return
					to_chat(user, "\blue You create a false wall! Push on it to open or close the passage.")
					new /obj/structure/falsewall/reinforced(loc)
					qdel(src)
				else
					if (src.icon_state == "reinforced") //I cant believe someone would actually write this line of code...
						if(S.get_amount() < 1)
							return ..()
						to_chat(user, "\blue Now finalising reinforced wall.")
						if(S.use_tool(src, user, 50, volume = 100))
							if(QDELETED(src) || QDELETED(S) || !S.use(1))
								return
							to_chat(user, "\blue Wall fully reinforced!")
							var/turf/Tsrc = get_turf(src)
							Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
							for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
								X.add_hiddenprint(usr)
							qdel(src)
						return
					else
						if(S.get_amount() < 1)
							return ..()
						to_chat(user, "\blue Now reinforcing girders")
						if(S.use_tool(src, user, 60, volume = 100))
							if(QDELETED(src) || QDELETED(S) || !S.use(1))
								return
							to_chat(user, "\blue Girders reinforced!")
							new/obj/structure/girder/reinforced( src.loc )
							qdel(src)
						return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				if(!S.use(2))
					return
				to_chat(user, "\blue You create a false wall! Push on it to open or close the passage.")
				var/F = text2path("/obj/structure/falsewall/[M]")
				new F (src.loc)
				qdel(src)
			else
				if(S.get_amount() < 2)
					return ..()
				to_chat(user, "\blue Now adding plating...")
				if(S.use_tool(src, user, 40, volume = 100))
					if(QDELETED(src) || QDELETED(S) || !S.use(2))
						return
					to_chat(user, "\blue You added the plating!")
					var/turf/Tsrc = get_turf(src)
					Tsrc.ChangeTurf(text2path("/turf/simulated/wall/mineral/[M]"))
					for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
						X.add_hiddenprint(usr)
					qdel(src)
				return

		add_hiddenprint(usr)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if (P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			user.drop_item()
			P.loc = src.loc
			to_chat(user, "\blue You fit the pipe into the [src]!")
	else
		..()


/obj/structure/girder/blob_act()
	if(prob(40))
		qdel(src)


/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)
			return
		if(3.0)
			if (prob(5))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)
			return
		else
	return

/obj/structure/girder/attack_animal(mob/living/simple_animal/M)
	if(M.environment_smash)
		..()
		M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
			 "<span class='warning'>You smash against [src].</span>", \
			 "You hear twisting metal.")
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		health -= M.melee_damage_upper
		if(health <= 0)
			new /obj/item/stack/sheet/metal(get_turf(src))
			qdel(src)

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0
	health = 50

/obj/structure/girder/reinforced
	icon_state = "reinforced"
	state = 2
	health = 500

/obj/structure/cultgirder
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	layer = 2.9
	var/health = 250

/obj/structure/cultgirder/attackby(obj/item/W, mob/user)
	if(user.is_busy(src))
		return
	if(iswrench(W))
		to_chat(user, "\blue Now disassembling the girder")
		if(W.use_tool(src, user, 40, volume = 100))
			to_chat(user, "\blue You dissasembled the girder!")
			new /obj/effect/decal/remains/human(get_turf(src))
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "\blue Now slicing apart the girder")
		if(W.use_tool(src, user, 30, volume = 100))
			to_chat(user, "\blue You slice apart the girder!")
		new /obj/effect/decal/remains/human(get_turf(src))
		qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		to_chat(user, "\blue You drill through the girder!")
		new /obj/effect/decal/remains/human(get_turf(src))
		qdel(src)

/obj/structure/cultgirder/blob_act()
	if(prob(40))
		qdel(src)

/obj/structure/cultgirder/bullet_act(obj/item/projectile/Proj) //No beam check- How else will you destroy the cult girder with silver bullets?????
	health -= Proj.damage
	..()
	if(health <= 0)
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)

	return

/obj/structure/cultgirder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
		if(3.0)
			if (prob(5))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
		else
	return
