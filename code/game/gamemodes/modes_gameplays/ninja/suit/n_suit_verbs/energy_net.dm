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

	density = TRUE//Can't pass through.
	opacity = 0//Can see through.
	mouse_opacity = MOUSE_OPACITY_ICON//So you can hit it with stuff.
	anchored = TRUE//Can't drag/grab the trapped mob.

	var/health = 100//How much health it has.
	var/mob/living/affecting = null//Who it is currently affecting, if anyone.

/obj/effect/energy_net/Destroy()
	if(affecting)
		REMOVE_TRAIT(affecting, TRAIT_ANCHORED, src)
		affecting.update_canmove()
		affecting.visible_message("[affecting.name] was recovered from the energy net!", "You hear a grunt.")
	affecting = null
	return ..()

/obj/effect/energy_net/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/effect/energy_net/proc/start_cooldown(mob/living/carbon/M)
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

/obj/effect/energy_net/bullet_act(obj/item/projectile/Proj, def_zone)
	. = ..()
	health -= Proj.damage
	healthcheck()

/obj/effect/energy_net/ex_act(severity)
	if(severity == EXPLODE_LIGHT && prob(50))
		health -= 25
		healthcheck()
		return
	health -= 50
	healthcheck()

/obj/effect/energy_net/blob_act()
	health-=50
	healthcheck()
	return

/obj/effect/energy_net/hitby(atom/movable/AM, datum/thrownthing/throwingdatum)
	..()
	visible_message("<span class='warning'><B>[src] was hit by [AM].</B></span>")
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
