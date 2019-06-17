/obj/machinery/power/dynamo
	var/power_produced = 10000
	var/raw_power = 0
	invisibility = 70

/obj/machinery/power/dynamo/process()
	if (raw_power>0)
		if (raw_power>10)
			raw_power -= 3
			add_avail(power_produced * 2)
		else
			raw_power --
			add_avail(power_produced)
	return

/obj/machinery/power/dynamo/proc/Rotated()
	raw_power += 2

/obj/structure/stool/bed/chair/pedalgen
	name = "Pedal Generator"
	desc = "Push it to the limit!"
	icon = 'code/modules/sports/pedalgen.dmi'
	icon_state = "pedalgen"
	anchored = 0
	density = 0
	//copypaste sorry
	var/obj/machinery/power/dynamo/Generator = null
	var/pedaled = 0

/obj/structure/stool/bed/chair/pedalgen/atom_init()
	. = ..()
	handle_rotation()
	Generator = new /obj/machinery/power/dynamo(src)
	if(anchored)
		Generator.loc = loc
		Generator.connect_to_network()

/obj/structure/stool/bed/chair/pedalgen/examine(mob/user)
	..()
	to_chat(user, "This [src] generates power from raw human force!")
	if(Generator.raw_power > 0)
		to_chat(user, "It has [Generator.raw_power] raw power stored and it generates [Generator.raw_power > 10 ? "20k" : "10k" ] energy!")
	else
		to_chat(user, "Generator stands still. Someone need to pedal that thing.")


/obj/structure/stool/bed/chair/pedalgen/attackby(obj/item/W, mob/user)
	if(default_unfasten_wrench(user,W))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(anchored)
			Generator.loc = src.loc
			Generator.connect_to_network()
		else
			Generator.disconnect_from_network()
			Generator.loc = null

/obj/structure/stool/bed/chair/pedalgen/attack_hand(mob/user)
	if(buckled_mob)
		pedal(user)
	return 0

/obj/structure/stool/bed/chair/pedalgen/proc/pedal(mob/user)
	pedaled = 1
	if(buckled_mob.buckled == src)
		if(buckled_mob != user)
			buckled_mob.visible_message(\
				"<span class='notice'>[buckled_mob.name] was unbuckled by [user.name]!</span>",\
				"You were unbuckled from [src] by [user.name].",\
				"You hear metal clanking")
			unbuckle_mob()
			src.add_fingerprint(user)
		else
			user.SetNextMove(CLICK_CD_INTERACT)
			if(buckled_mob.nutrition > 10)
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER, 20)
				Generator.Rotated()
				var/mob/living/carbon/human/pedaler = buckled_mob
				pedaler.nutrition -= 0.5
				pedaler.apply_effect(1,AGONY,0)
				if(pedaler.halloss > 80)
					to_chat(user, "You pushed yourself too hard.")
					pedaler.apply_effect(24,AGONY,0)
					unbuckle_mob()
				sleep(5)
				pedaled = 0
			else
				to_chat(user, "You are too exausted to pedal that thing.")
		return 1

/obj/structure/stool/bed/chair/pedalgen/relaymove(mob/user, direction)
	if(!ishuman(user))
		unbuckle_mob()
	var/mob/living/carbon/human/pedaler = user
	if(!pedaler.handcuffed)
		unbuckle_mob()
	else
		if(!pedaled)
			pedal(user)


/obj/structure/stool/bed/chair/pedalgen/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc
			update_mob(buckled_mob)


/obj/structure/stool/bed/chair/pedalgen/post_buckle_mob(mob/user)
	update_mob(user,1)

/obj/structure/stool/bed/chair/pedalgen/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring
		update_mob(buckled_mob)


/obj/structure/stool/bed/chair/pedalgen/proc/update_mob(mob/M, buckling = 0)
	if(M == buckled_mob)
		M.dir = dir
		var/new_pixel_x = 0
		var/new_pixel_y = 0
		switch(dir)
			if(SOUTH)
				new_pixel_x = 0
				new_pixel_y = 7
			if(WEST)
				new_pixel_x = 13
				new_pixel_y = 7
			if(NORTH)
				new_pixel_x = 0
				new_pixel_y = 4
			if(EAST)
				new_pixel_x = -13
				new_pixel_y = 7
		if(buckling)
			animate(M, pixel_x = new_pixel_x, pixel_y = new_pixel_y, 2, 1, LINEAR_EASING)
		else
			M.pixel_x = new_pixel_x
			M.pixel_y = new_pixel_y
	else
		animate(M, pixel_x = 0, pixel_y = 0, 2, 1, LINEAR_EASING)

/obj/structure/stool/bed/chair/pedalgen/bullet_act(obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message("<span class='warning'>[Proj] ricochets off the [src]!</span>")

/obj/structure/stool/bed/chair/pedalgen/Destroy()
	qdel(Generator)
	return..()

/obj/structure/stool/bed/chair/pedalgen/verb/release()
	set name = "Release Pedalgen"
	set category = "Object"
	set src in view(0)

	if(usr.restrained())
		to_chat(usr, "You can't do it until you restrained")
		return

	unbuckle_mob()
