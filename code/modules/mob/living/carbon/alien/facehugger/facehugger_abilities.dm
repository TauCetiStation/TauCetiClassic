/*----------------------------------------
This is modified grab mechanic for facehugger
----------------------------------------*/

#define UPGRADE_TAIL_TIMER	100

//Grab levels
/*
#define GRAB_PASSIVE	1
#define GRAB_AGGRESSIVE	2
#define GRAB_NECK		3
#define GRAB_UPGRADING	4
#define GRAB_KILL		5*/
#define GRAB_EMBRYO		6
#define GRAB_IMPREGNATE	7
#define GRAB_DONE		8

#define BITE_COOLDOWN 20

/mob/living/carbon/attack_facehugger(mob/living/carbon/alien/facehugger/FH)
	if(FH.can_leap_at_face(src))
		FH.leap_at_face(src)

/mob/living/simple_animal/corgi/attack_facehugger(mob/living/carbon/alien/facehugger/FH)
	if(FH.can_leap_at_face(src))
		FH.leap_at_face(src)

mob/living/carbon/alien/facehugger/attack_hand(mob/living/carbon/human/H)
	if(can_leap_at_face(H))
		src.leap_at_face(H, TRUE)
	else
		..()

mob/living/carbon/alien/facehugger/attack_paw(mob/living/carbon/monkey/M)
	if(can_leap_at_face(M))
		src.leap_at_face(M, TRUE)
	else
		..()

/*----------------------------------------
Helpers for leaping at face.
----------------------------------------*/
/mob/living/proc/get_facehugger_at_face()
	return FALSE

/mob/living/simple_animal/corgi/get_facehugger_at_face()
	if(facehugger && facehugger.current_hugger && facehugger.current_hugger.stat != DEAD) // if its dead - we can simply take it off and jump.
		return facehugger
	return FALSE

/mob/living/carbon/get_facehugger_at_face()
	if(istype(wear_mask, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/fh_at_face = wear_mask
		if(fh_at_face.current_hugger && fh_at_face.current_hugger.stat != DEAD)
			return fh_at_face
	return FALSE

/mob/living/carbon/alien/facehugger/proc/can_leap_at_face(mob/living/L, attacked = FALSE)
	if(stat != CONSCIOUS)
		return

	if(L == src)
		return

	if(next_leap > world.time)
		if(!attacked)
			to_chat(src, "<span class='red'>You can't leap at face too often ([round((next_leap - world.time) / 10)] time remaining).</span>")
		return

	if(L.stat == DEAD)
		to_chat(src, "<span class='notice'>Looks dead.</span>")
		return

	if(!iscarbon(L) && !iscorgi(L) || istype(L, /mob/living/carbon/human/machine) || isalien(L))
		to_chat(src, "<span class='red'>You can't impregnate that!</span>")
		return

	if(L.get_facehugger_at_face())
		to_chat(src, "<span class='red'>There is living facehugger on the face!</span>")
		return

	if((locate(/obj/item/alien_embryo) in L.contents) || (locate(/mob/living/carbon/alien/larva) in L.contents))
		to_chat(src, "<span class='red'>[L] already impregnated.</span>")
		return

	return TRUE

/mob/living/carbon/alien/facehugger/proc/leap_at_face(mob/living/L)
	next_leap = world.time + LEAP_AT_FACE_COOLDOWN
	var/obj/item/clothing/mask/facehugger/FH = new(loc)

	src.loc = FH
	FH.current_hugger = src

	if(iscarbon(L))
		var/mob/living/carbon/C = L
		qdel(C.get_equipped_item(slot_wear_mask))
		C.equip_to_slot(FH, slot_wear_mask)
	else if(iscorgi(L))
		var/mob/living/simple_animal/corgi/dog = L
		if(dog.facehugger)
			qdel(dog.facehugger)
			dog.facehugger = null
		FH.loc = dog
		dog.facehugger = FH
		dog.regenerate_icons()

	visible_message("<span class='warning'>[src] leaps at [L] face!</span>")

	if(!FH.sterile)
		L.take_bodypart_damage(FH.strength, 0)

	var/obj/item/weapon/fh_grab/G = new /obj/item/weapon/fh_grab(src, L)

	put_in_active_hand(G)
	L.grabbed_by += G
	G.last_upgrade = world.time
	L.LAssailant = src
	G.state = GRAB_AGGRESSIVE
	G.hud.icon_state = "grab/neck"
	G.hud.name = "grab around neck"


/*----------------------------------------
This is chestburster mechanic for damaging
 victim chest to get out from stomach
----------------------------------------*/
//Moved into /mob/living/carbon/alien/larva/UnarmedAttack proc.

/*----------------------------------------
This is emryo growth procs
----------------------------------------*/

/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob
	var/mob/living/baby
	var/stage = 0

/obj/item/alien_embryo/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		START_PROCESSING(SSobj, src)
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		qdel(src)

/obj/item/alien_embryo/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(baby)
		baby.forceMove(affected_mob)
		baby.reset_view()
		baby.sleeping = 0
		baby = null
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		spawn(0)
			RemoveInfectionImages(affected_mob)
		affected_mob = null
	return ..()

/obj/item/alien_embryo/proc/show_message(message, m_type)
	for(var/mob/living/M in contents)
		M.show_message(message,m_type)

/obj/item/alien_embryo/process()
	if(istype(loc,/turf) || !(contents.len))
		if(baby)
			baby.forceMove(get_turf(affected_mob))
			baby.reset_view()
		qdel(src)
		return

	if(!affected_mob)
		return

	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		STOP_PROCESSING(SSobj, src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return
	if(stage < 5)
		if(affected_mob.stat == DEAD)
			to_chat(baby, "\red Your host died, so and you.")
			baby.death()
			if(baby.key)
				baby.ghostize(can_reenter_corpse = FALSE, bancheck = TRUE)
			qdel(src)
			return
		else if(prob(4))
			stage++
			spawn(0)
				RefreshInfectionImage(affected_mob)
		if(iscarbon(affected_mob))
			affected_mob.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)

	switch(stage)
		if(2, 3)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "\red Your throat feels sore.")
			if(prob(1))
				to_chat(affected_mob, "\red Mucous runs down the back of your throat.")
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "\red Your muscles ache.")
				if(prob(20))
					affected_mob.take_bodypart_damage(1)
			if(prob(2))
				to_chat(affected_mob, "\red Your stomach hurts.")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
					affected_mob.updatehealth()
		if(5)
			affected_mob.updatehealth()
			AttemptGrow()

/obj/item/alien_embryo/proc/AttemptGrow()
	if(baby)
		to_chat(baby, "<span class='userdanger'>You are no longer embryo. Attack your host to get out.</span>")
		qdel(src)

/*----------------------------------------
This is facehugger Attach procs
----------------------------------------*/
/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | MASKINTERNALS
	body_parts_covered = FACE|EYES
	throw_range = 5
	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case
	var/sterile = 0
	var/real = 1 //0 for the toy, 1 for real
	var/strength = 5
	var/mob/living/carbon/alien/facehugger/current_hugger

/obj/item/clothing/mask/facehugger/New()
	START_PROCESSING(SSobj, src)
	..()

/obj/item/clothing/mask/facehugger/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(current_hugger)
		current_hugger.forceMove(get_turf(src))
		current_hugger.reset_view()
		current_hugger = null
	if(iscorgi(loc))
		var/mob/living/simple_animal/corgi/dog = loc
		dog.facehugger = null
		dog.regenerate_icons()
	return ..()

/obj/item/clothing/mask/facehugger/process()
	if(isturf(loc) || !(contents.len))
		qdel(src)

/obj/item/clothing/mask/facehugger/proc/show_message(message, m_type)
	if(current_hugger)
		current_hugger.show_message(message,m_type)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	if(!real)//So that giant red text about probisci doesn't show up.
		return
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			to_chat(user, "<span class='danger'>[src] is not moving.</span>")
		if(CONSCIOUS)
			to_chat(user, "<span class='danger'>[src] seems to be active.</span>")
	if (sterile)
		to_chat(user, "<span class='danger'>It looks like the proboscis has been removed.</span>")

/obj/item/clothing/mask/facehugger/attackby()
	Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act()
	Die()
	return

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target, mob/living/FH)
	if(!target || !FH || FH.stat == DEAD || target.stat == DEAD) //was taken off or something
		return FALSE

	if(target.get_equipped_item(slot_wear_mask) != src)
		return FALSE

	if(!sterile)
		var/obj/item/alien_embryo/new_embryo = new /obj/item/alien_embryo(target)
		var/mob/living/carbon/alien/larva/new_xeno = new /mob/living/carbon/alien/larva(new_embryo)

		new_xeno.key = FH.key
		new_xeno.chestburster = TRUE
		new_embryo.baby = new_xeno
		qdel(FH)

		STOP_PROCESSING(SSobj, src)

		target.dropItemToGround(src)
		target.status_flags |= XENO_HOST
		target.visible_message("\red \b [src] falls limp after violating [target]'s face!")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"
		return TRUE
	else
		target.visible_message("\red \b [src] violates [target]'s face!")
		return FALSE

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD
	src.visible_message("\red \b[src] curls up into a ball!")
	return

/*----------------------------------------
This is tail grab mechanic. Actually, a heavy modified grab.
We also check here, if there is any facehugger on the victim face.
When we successfully clicked someone, it makes this special grab version to appear
 in player's tail control button hud.
The first step is we leap at victim face. With second step, we reinforce grip.
With third step, we start to reinforce grip to its maximum phase and when that phase is passed,
 we cant remove facehugger from victim face anymore, until facehugger injects embryo inside victim.
With fourth step, we just confirm embryo injection and with firth, we actually start injecting embryo.
When we finish, facehugger's player will be transfered inside embryo.
----------------------------------------*/
/obj/screen/fh_grab
	name = "fh_grab"

/obj/screen/fh_grab/Click()
	var/obj/item/weapon/fh_grab/G = master
	G.s_click(src)
	return 1

/obj/screen/fh_grab/attack_hand()
	return

/obj/screen/fh_grab/attackby()
	return

/obj/item/weapon/fh_grab
	name = "grab"
	flags = NOBLUDGEON | ABSTRACT | DROPDEL
	var/obj/screen/fh_grab/hud = null
	var/mob/living/affecting = null
	var/mob/living/carbon/alien/facehugger/assailant = null
	var/state = GRAB_AGGRESSIVE

	var/last_upgrade = 0

	layer = 21
	abstract = 1
	item_state = "nothing"
	w_class = 5.0

/obj/item/weapon/fh_grab/New(mob/user, mob/victim)
	..()
	loc = user
	assailant = user
	affecting = victim

	hud = new /obj/screen/fh_grab(src)
	hud.icon = 'icons/mob/screen1_xeno.dmi'
	hud.icon_state = "grab/neck"
	hud.screen_loc = ui_rhand
	hud.name = "grab around neck"
	hud.master = src
	START_PROCESSING(SSobj, src)

/obj/item/weapon/fh_grab/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(affecting)
		affecting.grabbed_by -= src
		affecting = null
	if(assailant)
		if(istype(assailant.loc, /obj/item/clothing/mask/facehugger) && !QDELETED(assailant.loc))
			qdel(assailant.loc)
		if(assailant.client)
			assailant.client.screen -= hud
		assailant = null
	qdel(hud)
	hud = null
	return ..()

/obj/item/weapon/fh_grab/attack(mob/M, mob/user)
	if(!affecting)
		return

	if(M == affecting)
		s_click(hud)
		return

/obj/item/weapon/fh_grab/process()
	if(!confirm())
		return

	if(assailant.client)
		assailant.client.screen -= hud
		assailant.client.screen += hud

	affecting.Paralyse(MAX_IMPREGNATION_TIME/6)
	if(iscarbon(affecting))
		affecting.reagents.add_reagent("dexalinp", REAGENTS_METABOLISM)

/obj/item/weapon/fh_grab/proc/confirm()
	if(QDELETED(src))
		return FALSE

	if(!assailant || !affecting)
		qdel(src)
		return FALSE

	if(affecting.stat == DEAD)
		qdel(src)
		return FALSE

	if(isturf(assailant.loc))
		qdel(src)
		return FALSE

	if(!isliving(assailant.loc.loc))
		qdel(src)
		return FALSE

	return TRUE

/obj/item/weapon/fh_grab/proc/s_click(obj/screen/S)
	if(state == GRAB_UPGRADING)
		return
	if(world.time < (last_upgrade + UPGRADE_COOLDOWN))
		to_chat(assailant, "Not ready, please wait couple of seconds.")
		return
	if(!confirm())
		return

	if(!in_range(assailant, affecting))
		to_chat(assailant, "Too far.")
		qdel(src)
		return

	last_upgrade = world.time

	switch(state)
		if(GRAB_AGGRESSIVE)
			state = GRAB_UPGRADING
			if(do_after(assailant, UPGRADE_COOLDOWN, target = affecting))
				affecting.visible_message("<span class='warning'>[assailant] has reinforced \his grip on [affecting] neck!</span>")
				state = GRAB_NECK
				hud.icon_state = "grab/neck+"
				hud.name = "reinforce grab"
			else
				state = GRAB_AGGRESSIVE
				hud.icon_state = "grab/neck"
				hud.name = "grab around neck"
		if(GRAB_NECK)
			state = GRAB_UPGRADING
			affecting.visible_message("<span class='danger'>[assailant] starts to tighten \his tail on [affecting]'s neck!</span>")
			hud.icon_state = "grab/neck++"
			if(do_after(assailant, UPGRADE_TAIL_TIMER, target = affecting))
				if(state == GRAB_EMBRYO)
					return
				if(!affecting)
					qdel(src)
					return
				if(!assailant.canmove || assailant.lying)
					qdel(src)
					return
				state = GRAB_EMBRYO
				hud.icon_state = "grab/neck+++"
				hud.name = "prepare to impregnate"
				if(istype(assailant.loc, /obj/item/clothing/mask/facehugger))
					var/obj/item/clothing/mask/facehugger/FH_mask = assailant.loc
					FH_mask.canremove = 0
				affecting.visible_message("<span class='danger'>[assailant] has tightened \his tail on [affecting]'s neck!</span>")
				assailant.next_move = world.time + 10
			else
				affecting.visible_message("<span class='warning'>[assailant] was unable to tighten \his grip on [affecting]'s neck!</span>")
				hud.icon_state = "grab/neck"
				state = GRAB_AGGRESSIVE
				hud.icon_state = "grab/neck"
				hud.name = "grab around neck"
		if(GRAB_EMBRYO)
			state = GRAB_UPGRADING
			if(do_after(assailant, UPGRADE_COOLDOWN, target = affecting))
				state = GRAB_IMPREGNATE
				hud.icon_state = "grab/impreg"
				hud.name = "ready to impregnate"
				to_chat(assailant, "You are now ready to inject embryo inside your victim")
			else
				state = GRAB_AGGRESSIVE
				hud.icon_state = "grab/neck"
				hud.name = "grab around neck"
		if(GRAB_IMPREGNATE)
			state = GRAB_UPGRADING
			if(do_after(assailant, UPGRADE_TAIL_TIMER, target = affecting))
				state = GRAB_DONE
				hud.icon_state = "grab/do_impreg"
				hud.name = "impregnating"
				affecting.visible_message("<span class='danger'>[assailant] extends its proboscis deep inside [affecting]'s mouth!</span>")
				spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
					if(istype(assailant.loc, /obj/item/clothing/mask/facehugger))
						assailant.visible_message("\red \b [assailant] falls limp after violating [affecting]'s face!")
						var/obj/item/clothing/mask/facehugger/FH_mask = assailant.loc
						FH_mask.canremove = 1
						if(!FH_mask.Impregnate(affecting, assailant))
							qdel(src)
			else
				state = GRAB_AGGRESSIVE
				hud.icon_state = "grab/neck"
				hud.name = "grab around neck"
