/obj/structure/girder
	icon = 'icons/obj/smooth_structures/girder.dmi'
	icon_state = "box"
	anchored = 1
	density = 1
	layer = 2.9
	var/state = 0
	var/health = 200
	canSmoothWith = list(
		/turf/simulated/wall,
		/turf/simulated/wall/r_wall,
		/obj/structure/falsewall,
		/obj/structure/falsewall/reinforced,
		/obj/structure/girder,
		/obj/structure/girder/reinforced
	)
	smooth = SMOOTH_TRUE

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
		visible_message("<span class='warning'><B>[user]</B> has punched \the <B>[src]!</B></span>")
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		if(C.use_charge(user, 1) && prob(40))
			playsound(src, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
			qdel(src)
	else if(iswrench(W) && state == 0)
		if(anchored && !istype(src,/obj/structure/girder/displaced))
			to_chat(user, "<span class='notice'>Now disassembling the girder</span>")
			if(W.use_tool(src, user, 40, volume = 100))
				if(!src) return
				to_chat(user, "<span class='notice'>You dissasembled the girder!</span>")
				new /obj/item/stack/sheet/metal(get_turf(src))
				qdel(src)
		else if(!anchored)
			to_chat(user, "<span class='notice'>Now securing the girder</span>")
			if(W.use_tool(src, user, 40, volume = 100))
				to_chat(user, "<span class='notice'>You secured the girder!</span>")
				new/obj/structure/girder( src.loc )
				qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>Now slicing apart the girder</span>")
		if(W.use_tool(src, user, 30, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>You slice apart the girder!</span>")
			new /obj/item/stack/sheet/metal(get_turf(src))
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		to_chat(user, "<span class='notice'>You drill through the girder!</span>")
		new /obj/item/stack/sheet/metal(get_turf(src))
		qdel(src)

	else if(isscrewdriver(W) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		to_chat(user, "<span class='notice'>Now unsecuring support struts</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>You unsecured the support struts!</span>")
			state = 1

	else if(iswirecutter(W) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		to_chat(user, "<span class='notice'>Now removing support struts</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>You removed the support struts!</span>")
			new/obj/structure/girder( src.loc )
			qdel(src)

	else if(iscrowbar(W) && state == 0 && anchored )
		to_chat(user, "<span class='notice'>Now dislodging the girder</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>You dislodged the girder!</span>")
			new/obj/structure/girder/displaced( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet))

		var/obj/item/stack/sheet/S = W
		switch(S.type)

			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(!anchored)
					if(!S.use(2))
						return
					to_chat(user, "<span class='notice'>You create a false wall! Push on it to open or close the passage.</span>")
					new /obj/structure/falsewall (src.loc)
					qdel(src)
				else
					if(S.get_amount() < 2)
						return ..()
					to_chat(user, "<span class='notice'>Now adding plating...</span>")
					if(S.use_tool(src, user, 40, amount = 2, volume = 100))
						to_chat(user, "<span class='notice'>You added the plating!</span>")
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
					to_chat(user, "<span class='notice'>You create a false wall! Push on it to open or close the passage.</span>")
					new /obj/structure/falsewall/reinforced(loc)
					qdel(src)
				else
					if (istype (src, /obj/structure/girder/reinforced))
						if(S.get_amount() < 1)
							return ..()
						to_chat(user, "<span class='notice'>Now finalising reinforced wall.</span>")
						if(S.use_tool(src, user, 50, amount = 1, volume = 100))
							to_chat(user, "<span class='notice'>Wall fully reinforced!</span>")
							var/turf/Tsrc = get_turf(src)
							Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
							for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
								X.add_hiddenprint(usr)
							qdel(src)
						return
					else
						if(S.get_amount() < 1)
							return ..()
						to_chat(user, "<span class='notice'>Now reinforcing girders</span>")
						if(S.use_tool(src, user, 60, amount = 1, volume = 100))
							to_chat(user, "<span class='notice'>Girders reinforced!</span>")
							new/obj/structure/girder/reinforced( src.loc )
							qdel(src)
						return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				if(!S.use(2))
					return
				to_chat(user, "<span class='notice'>You create a false wall! Push on it to open or close the passage.</span>")
				var/F = text2path("/obj/structure/falsewall/[M]")
				new F (src.loc)
				qdel(src)
			else
				if(S.get_amount() < 2)
					return ..()
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(S.use_tool(src, user, 40, amount = 2, volume = 100))
					to_chat(user, "<span class='notice'>You added the plating!</span>")
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
			to_chat(user, "<span class='notice'>You fit the pipe into the [src]!</span>")
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

/obj/structure/girder/attack_animal(mob/living/simple_animal/attacker)
	if(attacker.environment_smash)
		..()
		attacker.visible_message("<span class='warning'>[attacker] smashes against [src].</span>", \
			 "<span class='warning'>You smash against [src].</span>", \
			 "You hear twisting metal.")
		playsound(src, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		health -= attacker.melee_damage
		if(health <= 0)
			new /obj/item/stack/sheet/metal(get_turf(src))
			qdel(src)

/obj/structure/girder/displaced
	icon = 'icons/obj/structures.dmi'
	icon_state = "displaced"
	anchored = 0
	health = 50
	smooth = SMOOTH_FALSE

/obj/structure/girder/reinforced
	icon = 'icons/obj/smooth_structures/girder_reinforced.dmi'
	icon_state = "box"
	state = 2
	health = 500

/obj/structure/cultgirder
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	layer = 2.9
	var/health = 250
	smooth = SMOOTH_FALSE

/obj/structure/cultgirder/attackby(obj/item/W, mob/user)
	if(user.is_busy(src))
		return
	if(iswrench(W))
		to_chat(user, "<span class='notice'>Now disassembling the girder</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			to_chat(user, "<span class='notice'>You dissasembled the girder!</span>")
			new /obj/effect/decal/remains/human(get_turf(src))
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>Now slicing apart the girder</span>")
		if(W.use_tool(src, user, 30, volume = 100))
			to_chat(user, "<span class='notice'>You slice apart the girder!</span>")
		new /obj/effect/decal/remains/human(get_turf(src))
		qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		to_chat(user, "<span class='notice'>You drill through the girder!</span>")
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
