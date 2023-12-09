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
	icon = 'icons/obj/sports/pedalgen.dmi'
	icon_state = "pedalgen"
	anchored = FALSE
	density = FALSE
	//copypaste sorry
	var/obj/machinery/power/dynamo/Generator = null
	var/next_pedal = 0
	var/pedal_left_leg = FALSE

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
	if(buckled_mob && next_pedal < world.time)
		pedal(user)
	return 0

/obj/structure/stool/bed/chair/pedalgen/proc/pedal(mob/user)
	if(buckled_mob.buckled != src)
		return FALSE

	if(buckled_mob != user)
		buckled_mob.visible_message(\
			"<span class='notice'>[buckled_mob.name] was unbuckled by [user.name]!</span>",\
			"You were unbuckled from [src] by [user.name].",\
			"You hear metal clanking")
		unbuckle_mob()
		add_fingerprint(user)
		return FALSE

	if(buckled_mob.nutrition <= 10)
		to_chat(user, "You are too exausted to pedal that thing.")
		return FALSE

	next_pedal = world.time + 4

	playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER, 20)
	Generator.Rotated()

	var/mob/living/carbon/human/pedaler = buckled_mob
	if(ishuman(pedaler))
		var/leg = pedal_left_leg ? BP_L_LEG : BP_R_LEG
		var/obj/item/organ/external/BP = pedaler.get_bodypart(leg)
		if(BP)
			var/pain_amount = BP.adjust_pumped(1)
			pedaler.apply_effect(pain_amount, AGONY, 0)
			SEND_SIGNAL(pedaler, COMSIG_ADD_MOOD_EVENT, "swole", /datum/mood_event/swole, pain_amount)
			pedaler.update_body()

	buckled_mob.nutrition -= 0.5

	pedal_left_leg = !pedal_left_leg
	if(buckled_mob.halloss > 80)
		to_chat(user, "You pushed yourself too hard.")
		buckled_mob.apply_effect(24,AGONY,0)
		unbuckle_mob()

	return TRUE

/obj/structure/stool/bed/chair/pedalgen/relaymove(mob/user, direction)
	if(!ishuman(user))
		unbuckle_mob()
	var/mob/living/carbon/human/pedaler = user
	if(!pedaler.handcuffed)
		unbuckle_mob()
	else if(next_pedal < world.time)
		pedal(user)


/obj/structure/stool/bed/chair/pedalgen/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(buckled_mob && !moving_diagonally)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc
			update_mob(buckled_mob)


/obj/structure/stool/bed/chair/pedalgen/post_buckle_mob(mob/living/user)
	update_mob(user, TRUE)

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


/obj/structure/stool/bed/chair/pedalgen/proc/update_mob(mob/living/M, buckling = 0)
	if(M == buckled_mob)
		M.set_dir(dir)
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
		animate(M, pixel_x = M.default_pixel_x, pixel_y = M.default_pixel_y, 2, 1, LINEAR_EASING)

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
