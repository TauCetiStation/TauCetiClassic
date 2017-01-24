/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
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

/obj/structure/closet/initialize()
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		for(var/obj/item/I in src.loc)
			if(I.density || I.anchored || I == src) continue
			I.forceMove(src)

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0 || wall_mounted)) return 1
	return (!density)

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

/obj/structure/closet/proc/open()
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0

	src.dump_contents()

	src.icon_state = src.icon_opened
	src.opened = 1
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src.loc, 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 0
	return 1

/obj/structure/closet/proc/close()
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

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

	src.icon_state = src.icon_closed
	src.opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(src.loc, 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(src.loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 1
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
				A.forceMove(src.loc)
				A.ex_act(severity++)
			qdel(src)
		if(2)
			if(prob(50))
				for (var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity++)
				qdel(src)
		if(3)
			if(prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity++)
				qdel(src)

/obj/structure/closet/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	if(health <= 0)
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.loc)
		qdel(src)

	return

/obj/structure/closet/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		playsound(user.loc, 'sound/effects/grillehit.ogg', 50, 1)
		user.do_attack_animation(src)
		visible_message("\red [user] destroys the [src]. ")
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.loc)
		qdel(src)

// this should probably use dump_contents()
/obj/structure/closet/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.forceMove(src.loc)
		qdel(src)

/obj/structure/closet/meteorhit(obj/O)
	if(O.icon_state == "flaming")
		for(var/mob/M in src)
			M.meteorhit(O)
		src.dump_contents()
		qdel(src)

/obj/structure/closet/attackby(obj/item/weapon/W, mob/user)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		if(istype(W,/obj/item/tk_grab))
			return 0
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.remove_fuel(0,user))
				to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
				return
			new /obj/item/stack/sheet/metal(src.loc)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WT].</span>", 3, "You hear welding.", 2)
			qdel(src)
			return
		if(isrobot(user))
			return
		if(!W.canremove)
			return
		usr.drop_item()
		if(W)
			W.forceMove(src.loc)
	else if(istype(W, /obj/item/weapon/packageWrap) || istype(W, /obj/item/weapon/extraction_pack))
		return
	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
		src.welded = !src.welded
		src.update_icon()
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>", 3, "You hear welding.", 2)
	else
		src.attack_hand(user)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/user)
	if(istype(O, /obj/screen))	//fix for HUD elements making their way into the world	-Pete
		return
	if(O.loc == user)
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis)
		return
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!src.opened)
		return
	if(istype(O, /obj/structure/closet))
		return
	step_towards(O, src.loc)
	if(user != O)
		user.show_viewers("<span class='danger'>[user] stuffs [O] into [src]!</span>")
	src.add_fingerprint(user)
	return

/obj/structure/closet/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(src.loc))
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

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(ishuman(usr))
		src.add_fingerprint(usr)
		src.toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += "welded"
	else
		icon_state = icon_opened

/obj/structure/closet/hear_talk(mob/M, text, verb, datum/language/speaking)
	for (var/atom/A in src)
		if(istype(A,/obj/))
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
	user.next_move = world.time + 100
	user.last_special = world.time + 100
	to_chat(user, "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>")
	for(var/mob/O in viewers(src))
		to_chat(O, "<span class='warning'>[src] begins to shake violently!</span>")

	if(do_after(user,(breakout_time*60*10),target=src)) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded))
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting

		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>")
		to_chat(user, "<span class='notice'>You successfully break out of [src]!</span>")
		open()
