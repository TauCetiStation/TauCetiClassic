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
	icon = 'tauceti/items/sports/pedalgen.dmi'
	icon_state = "pedalgen"
	anchored = 0
	density = 0
	flags = OPENCONTAINER
	//copypaste sorry
	var/obj/machinery/power/dynamo/MyGenerator	= null
	var/callme = "Pedal Generator"	//how do people refer to it?
	var/pedaled = 0



/obj/structure/stool/bed/chair/pedalgen/New()
	handle_rotation()
	MyGenerator = new /obj/machinery/power/dynamo(src)

/obj/structure/stool/bed/chair/pedalgen/examine()
	set src in usr
	usr << "\icon[src] This [callme] generates power from raw human force!"
	if (MyGenerator.raw_power>0)
		usr << "It has [MyGenerator.raw_power] raw power stored and it generates [(MyGenerator.raw_power>10)?"20k":"10k"] energy!"
	else
		usr << "Generator stands still. Someone need to pedal that thing."


/obj/structure/stool/bed/chair/pedalgen/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
		src.anchored = !src.anchored
		user.visible_message("[user.name] [anchored? "secures":"unsecures"] the [src.name].", \
			"You [anchored? "secure":"undo"] the external bolts.", \
			"You hear a ratchet")
		MyGenerator.loc = src.loc //this is really needed
		if(anchored)
			MyGenerator.connect_to_network()
		else
			MyGenerator.disconnect_from_network()
			MyGenerator.loc = src

/obj/structure/stool/bed/chair/pedalgen/attack_hand(mob/user)
	pedal(user)

/obj/structure/stool/bed/chair/pedalgen/proc/pedal(mob/user)
	pedaled = 1
	if(buckled_mob == user)
		if(buckled_mob.nutrition > 10)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 20, 1)
			MyGenerator.Rotated()
			var/mob/living/carbon/human/pedaler = buckled_mob
			pedaler.nutrition -= 0.5
			pedaler.apply_effect(1,AGONY,0)
			if(pedaler.halloss > 80)
				user << "You pushed yourself too hard."
				pedaler.apply_effect(24,AGONY,0)
				unbuckle()
			sleep(5)
			pedaled = 0
		else
			user << "You are too exausted to pedal that thing."
	else
		..()


/obj/structure/stool/bed/chair/pedalgen/relaymove(mob/user, direction)
	if(!ishuman(user)) unbuckle()
	var/mob/living/carbon/human/pedaler = user
	if (!pedaler.handcuffed)
		unbuckle()
	else
		if(!pedaled)
			pedal(user)


/obj/structure/stool/bed/chair/pedalgen/Move()
	..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc


/obj/structure/stool/bed/chair/pedalgen/buckle_mob(mob/M, mob/user)
	if(!ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon))
		return

	unbuckle()

	M.visible_message(\
		"<span class='notice'>[M] climbs onto the [callme]!</span>",\
		"<span class='notice'>You climb onto the [callme]!</span>")
	M.buckled = src
	M.loc = loc
	M.dir = dir
	M.update_canmove()
	buckled_mob = M
	update_mob()
	add_fingerprint(user)


/obj/structure/stool/bed/chair/pedalgen/unbuckle()
	if(buckled_mob)
		buckled_mob.pixel_x = 0
		buckled_mob.pixel_y = 0
	..()


/obj/structure/stool/bed/chair/pedalgen/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

	if(buckled_mob)
		if(buckled_mob.loc != loc)
			buckled_mob.buckled = null //Temporary, so Move() succeeds.
			buckled_mob.buckled = src //Restoring

	update_mob()


/obj/structure/stool/bed/chair/pedalgen/proc/update_mob()
	if(buckled_mob)
		buckled_mob.dir = dir
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7


/obj/structure/stool/bed/chair/pedalgen/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		if(prob(85))
			return buckled_mob.bullet_act(Proj)
	visible_message("<span class='warning'>[Proj] ricochets off the [callme]!</span>")

/obj/structure/stool/bed/chair/pedalgen/Del()
	del(MyGenerator)
	..()