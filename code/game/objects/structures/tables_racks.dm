/* Tables and Racks
 * Contains:
 *		Tables
 *		Wooden tables
 *		Reinforced tables
 *		Racks
 */


/*
 * Tables
 */
/obj/structure/table
	name = "table"
	desc = "A square piece of metal standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "box"
	density = 1
	anchored = 1.0
	layer = CONTAINER_STRUCTURE_LAYER
	throwpass = 1	//You can throw objects over this, despite it's density.")
	climbable = 1
	smooth = SMOOTH_TRUE

	var/parts = /obj/item/weapon/table_parts
	var/flipped = 0
	var/flipable = TRUE
	var/health = 100
	var/canconnect = TRUE

/obj/structure/table/atom_init()
	. = ..()
	for(var/obj/structure/table/T in loc)
		if(T != src)
			warning("Found stacked table at [COORD(src)] while initializing map.")
			QDEL_IN(T, 0)

	if(flipable)
		verbs += /obj/structure/table/proc/do_flip

	if(flipped)
		update_icon()
		update_adjacent()

	AddComponent(/datum/component/clickplace)

/obj/structure/table/Destroy()
	if(flipped)
		update_adjacent()
	return ..()

/obj/structure/table/proc/update_adjacent()
	for(var/direction in alldirs)
		var/obj/structure/table/T = locate() in get_step(src, direction)
		if(T)
			T.update_icon()

/obj/structure/table/proc/destroy()
	new parts(loc)
	density = 0
	qdel(src)

/obj/structure/rack/proc/destroy()
	new parts(loc)
	density = 0
	qdel(src)

/obj/structure/table/update_icon()
	if(flipped)
		smooth = SMOOTH_FALSE

		var/type = 0
		var/tabledirs = 0
		for(var/direction in list(turn(dir, 90), turn(dir, -90)) )
			var/obj/structure/table/T = locate() in get_step(src, direction)
			if (canconnect && !QDELETED(T) && T.flipped && src.type == T.type && T.canconnect && T.dir == dir)
				type++
				tabledirs |= direction

		var/base = "table"
		if (istype(src, /obj/structure/table/woodentable/poker))
			base = "poker"
		else if (istype(src, /obj/structure/table/woodentable))
			base = "wood"

		icon_state = "[base]flip[type]"
		if (type == 1)
			if (tabledirs & turn(dir, 90))
				icon_state = icon_state + "-"
			if (tabledirs & turn(dir, -90))
				icon_state = icon_state + "+"
	else
		smooth = initial(smooth)
		queue_smooth_neighbors(src)
		queue_smooth(src)


/obj/structure/table/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				destroy()
		else
	return


/obj/structure/table/blob_act()
	if(prob(75))
		destroy()

/obj/structure/table/attack_paw(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes the [src] apart!</span>")
		destroy()


/obj/structure/table/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	if(istype(src, /obj/structure/table/reinforced))
		return
	else if(istype(src, /obj/structure/table/woodentable/fancy/black))
		new/obj/item/weapon/table_parts/wood/fancy/black(loc)
	else if(istype(src, /obj/structure/table/woodentable/fancy))
		new/obj/item/weapon/table_parts/wood/fancy(loc)
	else if(istype(src, /obj/structure/table/woodentable))
		new/obj/item/weapon/table_parts/wood(loc)
	else if(istype(src, /obj/structure/table/woodentable/poker))
		new/obj/item/weapon/table_parts/wood(loc)
	else if(istype(src, /obj/structure/table/glass))
		var/obj/structure/table/glass/glasstable = src
		glasstable.shatter()
	else
		new /obj/item/weapon/table_parts(loc)
	density = 0
	qdel(src)

/obj/structure/table/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		..()
		playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()



/obj/structure/table/attack_hand(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()

/obj/structure/table/attack_tk() // no telehulk sorry
	return

/obj/structure/table/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(iscarbon(mover) && mover.checkpass(PASSCRAWL))
		mover.layer = 2.7
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/table/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = flipped ? get_turf(src) : get_step(loc, get_dir(from, loc))
	if (get_dist(P.starting, loc) <= 1) //Tables won't help you if people are THIS close
		return 1
	if (get_turf(P.original) == cover)
		var/chance = 20
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.lying)
				chance += 20				//Lying down lets you catch less bullets
		if(flipped)
			if(get_dir(loc, from) == dir)	//Flipped tables catch mroe bullets
				chance += 20
			else
				return 1					//But only from one side
		if(prob(chance))
			health -= P.damage/2
			if (health > 0)
				visible_message("<span class='warning'>[P] hits \the [src]!</span>")
				return 0
			else
				visible_message("<span class='warning'>[src] breaks down!</span>")
				destroy()
				return 1
	return 1

/obj/structure/table/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if(istype(O) && O.checkpass(PASSCRAWL))
		O.layer = 4.0
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 1

/obj/structure/table/proc/laser_cut(obj/item/I, mob/user)
	user.do_attack_animation(src)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'>You hear [src] coming apart.</span>")
	user.SetNextMove(CLICK_CD_MELEE)
	destroy()

/obj/structure/table/reinforced/laser_cut(obj/item/I, mob/user)
	user.do_attack_animation(src)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)
	spark_system.start()
	playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	to_chat(user, "<span class='notice'>You tried to slice through [src] but [I] is too weak.</span>")
	user.SetNextMove(CLICK_CD_MELEE)

// React to tools attacking src.
/obj/structure/table/proc/attack_tools(obj/item/I, mob/user)
	if(iswrench(I))
		if(user.is_busy(src))
			return FALSE
		to_chat(user, "<span class='notice'>You are now disassembling \the [src].</span>")
		if(I.use_tool(src, user, 50, volume = 50))
			destroy()
		return TRUE
	return FALSE

/obj/structure/table/attackby(obj/item/W, mob/user, params)
	. = TRUE

	if(attack_tools(W, user))
		return

	if(user.a_intent == INTENT_HARM)
		if(istype(W, /obj/item/weapon/melee/energy))
			if(W.force > 3)
				laser_cut(W, user)
				return
		if(istype(W, /obj/item/weapon/pen/edagger) || istype(W,/obj/item/weapon/twohanded/dualsaber))
			if(W.force > 3)
				laser_cut(W, user)
				return

	return ..()

/obj/structure/table/proc/straight_table_check(var/direction)
	var/obj/structure/table/T
	for(var/angle in list(-90,90))
		T = locate() in get_step(src.loc,turn(direction,angle))
		if(T && !T.flipped)
			return 0
	T = locate() in get_step(src.loc,direction)
	if (!T || T.flipped)
		return 1
	if (istype(T,/obj/structure/table/reinforced))
		var/obj/structure/table/reinforced/R = T
		if (R.status == 2)
			return 0
	return T.straight_table_check(direction)

/obj/structure/table/proc/do_flip()
	set name = "Flip table"
	set desc = "Flips a non-reinforced table."
	set category = "Object"
	set src in oview(1)

	if (!can_touch(usr) || ismouse(usr))
		return

	if(!flip(get_cardinal_dir(usr,src)))
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
		return

	usr.visible_message("<span class='warning'>[usr] flips \the [src]!</span>")

	if(climbable)
		structure_shaken()

	return

/obj/structure/table/proc/unflipping_check(direction)
	for(var/mob/M in oview(src,0))
		return 0

	var/list/L = list()
	if(direction)
		L.Add(direction)
	else
		L.Add(turn(src.dir,-90))
		L.Add(turn(src.dir,90))
	for(var/new_dir in L)
		var/obj/structure/table/T = locate() in get_step(src.loc,new_dir)
		if(T)
			if(T.flipped && T.dir == src.dir && !T.unflipping_check(new_dir))
				return 0
	return 1

/obj/structure/table/proc/do_put()
	set name = "Put table back"
	set desc = "Puts flipped table back."
	set category = "Object"
	set src in oview(1)
	if(ismouse(usr))
		return
	if (!can_touch(usr))
		return

	if (!unflipping_check())
		to_chat(usr, "<span class='notice'>It won't budge.</span>")
		return
	unflip()

/obj/structure/table/proc/flip(direction)
	if( !straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)) )
		return 0

	verbs -=/obj/structure/table/proc/do_flip
	verbs +=/obj/structure/table/proc/do_put

	var/list/targets = list(get_step(src,dir),get_step(src,turn(dir, 45)),get_step(src,turn(dir, -45)))
	for (var/atom/movable/A in get_turf(src))
		if (!A.anchored)
			A.throw_at(pick(targets),1,1)

	dir = direction
	if(dir != NORTH)
		layer = 5
	flipped = 1
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src, D)
		if(T && !T.flipped && type == T.type)
			T.flip(direction)
	update_icon()
	update_adjacent()

	return 1

/obj/structure/table/proc/unflip()
	verbs -=/obj/structure/table/proc/do_put
	verbs +=/obj/structure/table/proc/do_flip

	layer = initial(layer)
	plane = initial(plane)
	flipped = 0
	flags &= ~ON_BORDER
	for(var/D in list(turn(dir, 90), turn(dir, -90)))
		var/obj/structure/table/T = locate() in get_step(loc, D)
		if(T && T.flipped && type == T.type && T.dir == dir)
			T.unflip()
	update_icon()
	update_adjacent()

	return 1

/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "Looks fragile. You should totally flip it. It is begging for it."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	parts = /obj/item/weapon/table_parts/glass
	health = 10

/obj/structure/table/glass/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace, , CALLBACK(src, .proc/slam))

/obj/structure/table/glass/flip(direction)
	if( !straight_table_check(turn(direction,90)) || !straight_table_check(turn(direction,-90)) )
		return 0

	dir = direction
	if(dir != NORTH)
		layer = 5
	flipped = 1
	flags |= ON_BORDER
	for(var/D in list(turn(direction, 90), turn(direction, -90)))
		var/obj/structure/table/T = locate() in get_step(src,D)
		if(T && !T.flipped)
			T.flip(direction)

	shatter()

	return 1

/obj/structure/table/glass/proc/shatter()
	canconnect = FALSE
	update_adjacent()

	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'>[src] breaks!</span>", "<span class='danger'>You hear breaking glass.</span>")

	var/T = get_turf(src)
	new /obj/item/weapon/shard(T)
	qdel(src)

	var/list/targets = list(get_step(T, dir), get_step(T, turn(dir, 45)), get_step(T, turn(dir, -45)))
	for (var/atom/movable/A in T)
		if (!A.anchored)
			A.throw_at(pick(targets), 1, 1)

/obj/structure/table/glass/on_climb(mob/living/user)
	usr.forceMove(get_turf(src))
	if(check_break(user))
		usr.visible_message("<span class='warning'>[user] tries to climb onto \the [src], but breaks it!</span>")
	else
		..()

/obj/structure/table/glass/Crossed(atom/movable/AM)
	. = ..()
	check_break(AM)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(istype(M) && (M.checkpass(PASSTABLE) || M.checkpass(PASSCRAWL)))
		return FALSE

	if(has_gravity(M) && ishuman(M))
		M.Weaken(5)
		shatter()
		return TRUE
	else
		return FALSE

/obj/structure/table/glass/proc/slam(obj/item/weapon/grab/G)
	var/mob/living/assailant = G.assailant
	var/mob/living/victim = G.affecting

	victim.Weaken(5)
	visible_message("<span class='danger'>[assailant] slams [victim]'s face against \the [src], breaking it!</span>")
	playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)

	victim.log_combat(assailant, "face-slammed against [name]")

	if(prob(30) && ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
		var/obj/item/weapon/shard/S = new
		BP.embed(S)
		H.apply_damage(15, def_zone = BP_HEAD, damage_flags = DAM_SHARP|DAM_EDGE, used_weapon = S)
		H.emote("scream")
	else
		victim.apply_damage(15, def_zone = BP_HEAD)
	shatter()
	qdel(G)
	return TRUE

/*
 * Wooden tables
 */
/obj/structure/table/woodentable
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wooden_table.dmi'
	parts = /obj/item/weapon/table_parts/wood
	health = 50

/obj/structure/table/woodentable/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	parts = /obj/item/weapon/table_parts/wood/poker
	health = 50

/obj/structure/table/woodentable/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/smooth_structures/fancy_table.dmi'
	canSmoothWith = list(/obj/structure/table/woodentable/fancy, /obj/structure/table/woodentable/fancy/black)
	parts = /obj/item/weapon/table_parts/wood/fancy
	flipable = FALSE

/obj/structure/table/woodentable/fancy/black
	icon = 'icons/obj/smooth_structures/fancy_black_table.dmi'
	parts = /obj/item/weapon/table_parts/wood/fancy/black

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A version of the four legged table. It is stronger."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	health = 200
	parts = /obj/item/weapon/table_parts/reinforced
	flipable = FALSE

	var/status = 2

/obj/structure/table/reinforced/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover,/obj/item/projectile))
		return (check_cover(mover,target))
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	if (flipped)
		if (get_dir(loc, target) == dir)
			return !density
		else
			return 1
	return 0

/obj/structure/table/reinforced/flip(direction)
	if (status == 2)
		return 0
	else
		return ..()

/obj/structure/table/reinforced/attack_tools(obj/item/I, mob/user)
	if(iswelder(I))
		if(user.is_busy())
			return FALSE
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.use(0, user))
			if(status == 2)
				to_chat(user, "<span class='notice'>You are now strengthening \the [src].</span>")
				if(WT.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You have weakened \the [src].</span>")
					src.status = 1
			else
				to_chat(user, "<span class='notice'>You are now strengthening \the [src].</span>")
				if(WT.use_tool(src, user, 50, volume = 50))
					to_chat(user, "<span class='notice'>You have strengthened \the [src].</span>")
					src.status = 2
			return TRUE
		return FALSE

	else if(status != 2 && iswrench(I))
		if(user.is_busy(src))
			return FALSE
		to_chat(user, "<span class='notice'>You are now disassembling \the [src].</span>")
		if(I.use_tool(src, user, 50, volume = 50))
			destroy()
		return TRUE

	return FALSE

/obj/structure/table/reinforced/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/door_control_frame))
		var/obj/item/door_control_frame/frame = W
		frame.try_build(src)
		return

	return ..()

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	anchored = 1.0
	layer = CONTAINER_STRUCTURE_LAYER
	throwpass = 1	//You can throw objects over this, despite it's density.
	var/parts = /obj/item/weapon/rack_parts

/obj/structure/rack/atom_init()
	. = ..()
	AddComponent(/datum/component/clickplace)

/obj/structure/rack/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			qdel(src)
			if(prob(50))
				new /obj/item/weapon/rack_parts(src.loc)
		if(3.0)
			if(prob(25))
				qdel(src)
				new /obj/item/weapon/rack_parts(src.loc)

/obj/structure/rack/blob_act()
	if(prob(75))
		qdel(src)
		return
	else if(prob(50))
		new /obj/item/weapon/rack_parts(src.loc)
		qdel(src)
		return

/obj/structure/rack/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(src.density == 0) //Because broken racks -Agouri |TODO: SPRITE!|
		return 1
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0

/obj/structure/rack/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		new /obj/item/weapon/rack_parts( src.loc )
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		qdel(src)
		return

	if(user.a_intent != INTENT_HARM)
		return ..()

	var/can_cut = FALSE
	if(istype(W, /obj/item/weapon/melee/energy))
		var/obj/item/weapon/melee/energy/E = W
		can_cut = E.active
	else if(istype(W, /obj/item/weapon/twohanded/dualsaber))
		var/obj/item/weapon/twohanded/dualsaber/D = W
		can_cut = D.wielded

	if(!can_cut)
		return ..()

	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)

	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, loc)
	spark_system.start()

	playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
	playsound(src, "sparks", VOL_EFFECTS_MASTER)
	visible_message("<span class='notice'>[src] was sliced apart by [user]!</span>", "<span class='notice'> You hear [src] coming apart.</span>")
	destroy()

/obj/structure/table/attack_hand(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		destroy()

/obj/structure/rack/attack_paw(mob/user)
	if(HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='danger'>[user] slices [src] apart!</span>")
	destroy()

/obj/structure/rack/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		..()
		playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] smashes [src] apart!</span>")
		destroy()

/obj/structure/rack/attack_tk() // no telehulk sorry
	return
