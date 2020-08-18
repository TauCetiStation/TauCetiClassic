/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	layer = CONTAINER_STRUCTURE_LAYER
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/locked = 0
	var/broken = 0
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 100
	var/lastbang
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.

/obj/structure/closet/atom_init(mapload)
	. = ..()
	closet_list += src
	if(mapload && !opened)		// if closed, any item at the crate's loc is put in the contents
		for(var/obj/item/I in src.loc)
			if(I.density || I.anchored || I == src)
				continue
			I.forceMove(src)
	PopulateContents()
	update_icon()

	AddComponent(/datum/component/clickplace)

/obj/structure/closet/Destroy()
	closet_list -= src
	return ..()

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(wall_mounted)
		return TRUE
	return ..()

/obj/structure/closet/proc/can_open()
	if(src.welded)
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src)
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()
	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.forceMove(src.loc)

	for(var/obj/I in src)
		I.forceMove(src.loc)

	for(var/mob/M in src)
		M.forceMove(src.loc)
		M.instant_vision_update(0)

/obj/structure/closet/proc/collect_contents()
	var/itemcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src.loc)
		if(itemcount >= storage_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored)
			I.forceMove(src)
			itemcount++

	for(var/mob/M in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(istype (M, /mob/dead/observer))
			continue
		if(M.buckled)
			continue

		M.forceMove(src)
		M.instant_vision_update(1,src)
		itemcount++

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0

	src.icon_state = src.icon_opened
	src.opened = 1

	src.dump_contents()

	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER, 15, null, -3)
	else
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 15, null, -3)
	density = 0
	SSdemo.mark_dirty(src)
	return 1

/obj/structure/closet/proc/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	collect_contents()

	src.icon_state = src.icon_closed
	src.opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src, 'sound/items/zip.ogg', VOL_EFFECTS_MASTER, 15, null, -3)
	else
		playsound(src, 'sound/machines/click.ogg', VOL_EFFECTS_MASTER, 15, null, -3)
	density = 1
	SSdemo.mark_dirty(src)
	return 1

/obj/structure/closet/proc/toggle(mob/user)
	if(!(src.opened ? src.close() : src.open()))
		to_chat(user, "<span class='notice'>It won't budge!</span>")
	return

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	switch(severity)
		if(1)
			for(var/atom/movable/A as mob|obj in src)//pulls everything out of the locker and hits it with an explosion
				A.ex_act(severity++)
			dump_contents()
			qdel(src)
		if(2)
			if(prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.ex_act(severity++)
				dump_contents()
				qdel(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.ex_act(severity++)
				dump_contents()
				qdel(src)

/obj/structure/closet/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		dump_contents()
		qdel(src)

	return

/obj/structure/closet/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		..()
		playsound(user, 'sound/effects/grillehit.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='warning'>[user] destroys the [src]. </span>")
		open()
		qdel(src)

/obj/structure/closet/blob_act()
	if(prob(75))
		dump_contents()
		qdel(src)

/obj/structure/closet/attackby(obj/item/weapon/W, mob/user)
	if(tools_interact(W, user))
		add_fingerprint(user)
		return

	else if(opened || istype(W, /obj/item/weapon/grab))
		return ..()

	else if(istype(W, /obj/item/weapon/packageWrap) || istype(W, /obj/item/weapon/extraction_pack))
		return

	else
		attack_hand(user)

/obj/structure/closet/proc/tools_interact(obj/item/weapon/W, mob/user)
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!WT.welding)
			return FALSE
		if(!WT.use(0,user))
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return TRUE
		switch(opened)
			if(1)
				new /obj/item/stack/sheet/metal(loc)
				visible_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WT].</span>",
								"<span class='notice'>You hear welding.</span>")
				qdel(src)
				return TRUE
			if(0)
				src.welded = !src.welded
				src.update_icon()
				visible_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>",
								"<span class='warning'>You hear welding.</span>")
				return TRUE

/obj/structure/closet/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.incapacitated() || !isturf(src.loc))
		return

	if(!src.open())
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		if(!lastbang)
			lastbang = 1
			for (var/mob/M in hearers(src, null))
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = 0


/obj/structure/closet/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/closet/attack_hand(mob/user)
	src.add_fingerprint(user)
	user.SetNextMove(CLICK_CD_RAPID)
	src.toggle(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	src.add_fingerprint(user)
	if(!src.toggle())
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(usr.incapacitated())
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	cut_overlays()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			add_overlay("welded")
	else
		icon_state = icon_opened
	SSdemo.mark_dirty(src)

/obj/structure/closet/hear_talk(mob/M, text, verb, datum/language/speaking)
	for (var/atom/A in src)
		if(istype(A,/obj))
			var/obj/O = A
			O.hear_talk(M, text, verb, speaking)

/obj/structure/closet/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2 //2 minutes by default
	//if(istype(user.loc, /obj/structure/closet/critter) && !welded)
	//	breakout_time = 0.75 //45 seconds if it's an unwelded critter crate

	if(opened || (!welded && !locked))
		return  //Door's open, not locked or welded, no point in resisting.

	//okay, so the closet is either welded or locked... resist!!!
	user.SetNextMove(100)
	user.last_special = world.time + 100
	user.visible_message(
		"<span class='warning'>[src] begins to shake violently!</span>",
		"<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>"
	)

	if(do_after(user, (breakout_time MINUTES), target=src))
		if(!user || user.loc != src || opened || (!locked && !welded))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting

		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		to_chat(user, "<span class='notice'>You successfully break out of [src]!</span>")
		open()
