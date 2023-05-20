/**
  * SPACE NINJA NET
  *  It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
  *  It is possible to destroy the net by the occupant or someone else.
  */
/obj/structure/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = TRUE//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = MOUSE_OPACITY_ICON//So you can hit it with stuff.
	anchored = TRUE//Can't drag/grab the trapped mob.

	max_integrity = 100
	var/mob/living/affecting = null//Who it is currently affecting, if anyone.

	resistance_flags = CAN_BE_HIT

/obj/structure/energy_net/Destroy()
	if(affecting)
		REMOVE_TRAIT(affecting, TRAIT_ANCHORED, src)
		affecting.update_canmove()
		affecting.visible_message("[affecting.name] was recovered from the energy net!", "You hear a grunt.")
	affecting = null
	return ..()

/obj/structure/energy_net/proc/start_cooldown(mob/living/carbon/M)
	set waitfor = FALSE

	affecting = M
	layer = M.layer + 1 //To have it appear one layer above the mob.
	ADD_TRAIT(M, TRAIT_ANCHORED, src)
	M.update_canmove()

	var/check = 60

	//The person can still try and attack the net when inside.
	while(!QDELETED(src) && check>0)//While M and net exist, and 60 seconds have not passed.
		var/turf/T = get_turf(src)
		if(M.loc != T)
			qdel(src)
			return

		check--
		sleep(1 SECOND)

	qdel(src)

/obj/structure/energy_net/ex_act(severity)
	if(severity == EXPLODE_LIGHT && prob(50))
		take_damage(25, BRUTE, BOMB)
		return
	take_damage(50, BRUTE, BOMB)

/obj/structure/energy_net/attack_hand(mob/living/carbon/human/user)
	if (HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.visible_message("<span class='warning'>[user] rips the energy net apart!</span>", "<span class='notice'>You easily destroy the energy net.</span>")
		attack_generic(user, 50, BRUTE, MELEE)

/obj/structure/energy_net/attack_paw()
	return attack_hand()

/obj/structure/energy_net/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE, BURN)
			playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER, 80, TRUE)
