/obj/structure/scp151
	name = "SCP-151"
	desc = "A painting depicting a rising wave."
	icon = 'code/modules/SCP/SCP_151/SCP.dmi'
	icon_state = "scp151"
	anchored = TRUE
	density = TRUE
	var/last_regen = 0
	var/gen_time = 100 //how long we wait between hurting victims
	var/list/victims = list()
	var/list/activevictims = list()

/obj/structure/scp151/proc/hurt_victims() //simulate drowning
	for(var/mob/living/user in activevictims)
		user.apply_damage(30, OXY)
		user.emote("gasp")

/obj/structure/scp151/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time

/obj/structure/scp151/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/scp151/process()
	if(world.time > last_regen + gen_time) //hurt victims after time
		hurt_victims()
		last_regen = world.time

	for(var/mob/living/user in activevictims)
		if(user.stat == DEAD)
			victims -= user
			activevictims -= user

/obj/structure/scp151/examine(mob/living/user)
	. = ..()
	if(ishuman(user))
		user.visible_message("<span class='notice'>[user] looks at a picture.</span>")
		if(!(user in victims) && istype(user))
			victims += user //on examine, adds user into victims list
			spawn(20 SECONDS)
				activevictims += user
				to_chat(user, "<span class='warning'>Your lungs begin to feel tight, and the briny taste of seawater permeates your mouth.</span>")