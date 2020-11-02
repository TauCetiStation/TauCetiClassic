/** 
  * SPACE NINJA NET
  *  It will teleport people to a holding facility after 30 seconds. (Check the process() proc to change where teleport goes)
  *  It is possible to destroy the net by the occupant or someone else.
  */
/obj/effect/energy_net
	name = "energy net"
	desc = "It's a net made of green energy."
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"

	density = 1//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = 1//So you can hit it with stuff.
	anchored = 1//Can't drag/grab the trapped mob.

	var/health = 100//How much health it has.
	var/mob/living/affecting = null//Who it is currently affecting, if anyone.
	var/mob/living/master = null//Who shot web. Will let this person know if the net was successful or failed.

/obj/effect/energy_net/Destroy()
	affecting = null
	master = null
	return ..()

/obj/effect/energy_net/proc/healthcheck()
	if(health <=0)
		density = 0
		if(affecting)
			var/mob/living/carbon/M = affecting
			M.captured = 0 //Important.
			M.anchored = initial(M.anchored) //Changes the mob's anchored status to the original one; this is not handled by the can_move proc.
			M.visible_message("[M.name] was recovered from the energy net!", "You hear a grunt.")
			//if(!isnull(master))//As long as they still exist.
			//	master << "<span class='warning'><b>ERROR</b>:</span> unable to initiate transport protocol. Procedure terminated."
		qdel(src)
	return

/obj/effect/energy_net/process(var/mob/living/carbon/M as mob)
	var/check = 60//30 seconds before teleportation. Could be extended I guess. - Extended to one minute
	//var/mob_name = affecting.name//Since they will report as null if terminated before teleport.
	//The person can still try and attack the net when inside.
	while(!isnull(M)&&!isnull(src)&&check>0)//While M and net exist, and 60 seconds have not passed.
		var/turf/T = get_turf(src)
		if(M in T.contents)
			check--
			sleep(10)
		else
			check = 0
			M.captured = 0 //Important.
			M.anchored = initial(M.anchored) //Changes the mob's anchored status to the original one; this is not handled by the can_move proc.

	if(isnull(M)||M.loc!=loc)//If mob is gone or not at the location.
		//if(!isnull(master))//As long as they still exist.
		//	master << "<span class='warning'><b>ERROR</b>:</span> unable to locate \the [mob_name]. Procedure terminated."
		qdel(src)//Get rid of the net.
		return

	if(!isnull(src))
		M.captured = 0
		M.anchored = initial(M.anchored)
		qdel(src)
	return

/obj/effect/energy_net/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	healthcheck()
	return 0

/obj/effect/energy_net/ex_act(severity)
	switch(severity)
		if(1.0)
			health-=50
		if(2.0)
			health-=50
		if(3.0)
			health-=prob(50)?50:25
	healthcheck()
	return

/obj/effect/energy_net/blob_act()
	health-=50
	healthcheck()
	return

/obj/effect/energy_net/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	..()
	src.visible_message("<span class='warning'><B>[src] was hit by [AM].</B></span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/effect/energy_net/attack_hand(mob/living/carbon/human/user)
	if (HULK in user.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		user.visible_message("<span class='warning'>[user] rips the energy net apart!</span>", "<span class='notice'>You easily destroy the energy net.</span>")
		health-=50
	healthcheck()
	return

/obj/effect/energy_net/attack_paw()
	return attack_hand()

/obj/effect/energy_net/attack_alien(mob/user)
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	if (isxenolarva(user) || isfacehugger(user))
		return
	playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
	health -= rand(10, 20)

	if(health > 0)
		user.visible_message("<span class='warning'>[user] claws at the energy net!</span>", "<span class='notice'>You claw at the net.</span>")
	else
		user.visible_message("<span class='warning'>[user] slices the energy net apart!</span>", "<span class='notice'>You slice the energy net to pieces.</span>")

	healthcheck()
	return

/obj/effect/energy_net/attackby(obj/item/weapon/W, mob/user)
	var/aforce = W.force
	user.SetNextMove(CLICK_CD_MELEE)
	health = max(0, health - aforce)
	healthcheck()
	return ..()
