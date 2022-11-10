/obj/structure/girder
	icon = 'icons/obj/smooth_structures/girder.dmi'
	icon_state = "box"
	anchored = TRUE
	density = TRUE
	layer = 2.9
	var/state = 0

	max_integrity = 200
	resistance_flags = CAN_BE_HIT

	canSmoothWith = list(
		/turf/simulated/wall,
		/turf/simulated/wall/r_wall,
		/obj/structure/falsewall,
		/obj/structure/falsewall/reinforced,
		/obj/structure/girder,
		/obj/structure/girder/reinforced,
		/obj/structure/girder/cult,
	)
	smooth = SMOOTH_TRUE

/obj/structure/girder/attackby(obj/item/W, mob/user)
	if(user.is_busy()) return
	if(istype (W,/obj/item/weapon/changeling_hammer))
		var/obj/item/weapon/changeling_hammer/C = W
		visible_message("<span class='warning'><B>[user]</B> бьет каркас!</span>")
		user.do_attack_animation(src)
		user.SetNextMove(CLICK_CD_MELEE)
		if(C.use_charge(user, 1))
			playsound(src, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
			qdel(src)
	else if(iswrench(W) && state == 0)
		if(anchored && !istype(src,/obj/structure/girder/displaced))
			to_chat(user, "<span class='notice'>Вы разбираете каркас.</span>")
			if(W.use_tool(src, user, 40, volume = 100))
				if(!src) return
				to_chat(user, "<span class='notice'>Вы разобрали каркас!</span>")
				deconstruct(TRUE)
		else if(!anchored)
			to_chat(user, "<span class='notice'>Вы фиксируете каркас.</span>")
			if(W.use_tool(src, user, 40, volume = 100))
				to_chat(user, "<span class='notice'>Вы зафиксировали каркас!</span>")
				new/obj/structure/girder( src.loc )
				qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
		to_chat(user, "<span class='notice'>Вы режете каркас.</span>")
		if(W.use_tool(src, user, 30, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>Вы разрезали каркас!</span>")
			deconstruct(TRUE)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/diamond_drill))
		to_chat(user, "<span class='notice'>Вы просверлили каркас!</span>")
		deconstruct(TRUE)

	else if(isscrewdriver(W) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		to_chat(user, "<span class='notice'>Вы ослабляете кронштейны.</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>Вы ослабили кронштейны!</span>")
			state = 1

	else if(iswirecutter(W) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		to_chat(user, "<span class='notice'>Вы разбираете кронштейны.</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>Вы разобрали кронштейны!</span>")
			new/obj/structure/girder( src.loc )
			qdel(src)

	else if(iscrowbar(W) && state == 0 && anchored )
		to_chat(user, "<span class='notice'>Вы делаете каркас подвижным.</span>")
		if(W.use_tool(src, user, 40, volume = 100))
			if(!src) return
			to_chat(user, "<span class='notice'>Вы сделали каркас подвижным!</span>")
			new/obj/structure/girder/displaced( src.loc )
			qdel(src)

	else if(istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = W
		switch(S.type)

			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(!anchored)
					if(!S.use(2))
						return
					to_chat(user, "<span class='notice'>Вы сделали потайную дверь! Толкните, чтобы открыть или закрыть проход.</span>")
					new /obj/structure/falsewall (src.loc)
					qdel(src)
				else
					if(S.get_amount() < 2)
						return ..()
					to_chat(user, "<span class='notice'>Вы устанавливаете обшивку.</span>")
					if(S.use_tool(src, user, 40, amount = 2, volume = 100))
						to_chat(user, "<span class='notice'>Вы установили обшивку!</span>")
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
					to_chat(user, "<span class='notice'>Вы сделали потайную дверь! Толкните, чтобы открыть или закрыть проход.</span>")
					new /obj/structure/falsewall/reinforced(loc)
					qdel(src)
				else
					if (istype (src, /obj/structure/girder/reinforced))
						if(S.get_amount() < 1)
							return ..()
						to_chat(user, "<span class='notice'>Вы завершаете укрепленную стену.</span>")
						if(S.use_tool(src, user, 50, amount = 1, volume = 100))
							to_chat(user, "<span class='notice'>Укрепленная стена завершена!</span>")
							var/turf/Tsrc = get_turf(src)
							Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
							for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
								X.add_hiddenprint(usr)
							qdel(src)
						return
					else
						if(S.get_amount() < 1)
							return ..()
						to_chat(user, "<span class='notice'>Вы укрепляете каркас.</span>")
						if(S.use_tool(src, user, 60, amount = 1, volume = 100))
							to_chat(user, "<span class='notice'>Каркас укреплен!</span>")
							new/obj/structure/girder/reinforced( src.loc )
							qdel(src)
						return

		if(S.sheettype)
			var/M = S.sheettype
			if (!S.can_be_wall)
				return
			if(!anchored)
				if(!S.use(2))
					return
				to_chat(user, "<span class='notice'>Вы сделали потайную дверь! Толкните, чтобы открыть или закрыть проход.</span>")
				var/F = text2path("/obj/structure/falsewall/[M]")
				new F (src.loc)
				qdel(src)
			else
				if(S.get_amount() < 2)
					return ..()
				to_chat(user, "<span class='notice'>Вы устанавливаете обшивку.</span>")
				if(S.use_tool(src, user, 40, amount = 2, volume = 100))
					to_chat(user, "<span class='notice'>Вы установили обшивку!</span>")
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
			user.drop_from_inventory(P, loc)
			to_chat(user, "<span class='notice'>Вы встроили трубу в каркас!</span>")
	else
		..()

/obj/structure/girder/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE, BURN)
			playsound(loc, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)

/obj/structure/girder/deconstruct(disassembled)
	if(flags & NODECONSTRUCT)
		return ..()
	var/remains
	if(disassembled)
		remains = /obj/item/stack/sheet/metal
	else
		remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/metal)
	new remains(loc)
	..()

/obj/structure/girder/attack_animal(mob/living/simple_animal/attacker)
	. = ..()
	if(.)
		attacker.visible_message("<span class='warning'>[attacker] крушит каркас.</span>", \
			 "<span class='warning'>Вы крушите каркас.</span>", \
			 "Вы слышите скрежет металла.")

/obj/structure/girder/displaced
	icon = 'icons/obj/structures.dmi'
	icon_state = "displaced"
	anchored = FALSE
	max_integrity = 50
	smooth = SMOOTH_FALSE

/obj/structure/girder/reinforced
	icon = 'icons/obj/smooth_structures/girder_reinforced.dmi'
	icon_state = "box"
	state = 2
	max_integrity = 500

/obj/structure/girder/cult
	icon= 'icons/obj/smooth_structures/cult_girder.dmi'
	icon_state= "box"
	anchored = TRUE
	density = TRUE
	layer = 2.9
	max_integrity = 250
	smooth = SMOOTH_TRUE

/obj/structure/girder/cult/Destroy()
	new /obj/effect/decal/remains/human(get_turf(src))
	return ..()
