#define EGG_INCUBATION_TIME 1200

/obj/effect/proc_holder/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	chemical_cost = 20
	genomecost = 1
	req_human = 1
	req_stat = DEAD
	max_genetic_damage = 10

/obj/effect/proc_holder/changeling/headcrab/sting_action(mob/user)
	var/datum/mind/M = user.mind
	for(var/mob/living/carbon/human/H in range(2,user))
		to_chat(H,"<span class='userdanger'>You are blinded by a shower of blood!</span>")
		H.Stun(1)
		H.apply_effect(20,EYE_BLUR)
		H.confused += 3
	for(var/mob/living/silicon/S in range(2,user))
		to_chat(S,"<span class='userdanger'>Your sensors are disabled by a shower of blood!</span>")
		S.Weaken(3)

	// Prevents having Regenerate verb after rebirth.
	M.changeling.purchasedpowers -= locate(/obj/effect/proc_holder/changeling/revive) in M.changeling.purchasedpowers

	// In case we did it out of stasis
	if (M.changeling.instatis)
		M.changeling.instatis = FALSE
		user.fake_death = FALSE

	var/mob/living/simple_animal/headcrab/crab = new(get_turf(user))
	crab.origin = M
	M.transfer_to(crab)
	for(var/mob/living/parasite/essence/E in user)
		E.exit_host()
		E.loc = crab
		if(E.client)
			E.client.eye = crab
	to_chat(crab,"<span class='warning'>You burst out of the remains of your former body in a shower of gore!</span>")
	feedback_add_details("changeling_powers","LR")
	if(ismob(user))
		playsound(user, 'sound/effects/blobattack.ogg', VOL_EFFECTS_MASTER)
		user.gib()
	else
		qdel(user)
	return 1

/mob/living/simple_animal/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	gender = NEUTER
	pass_flags = PASSTABLE
	health = 50
	maxHealth = 50
	melee_damage = 5
	attacktext = "chomp"
	attack_sound = list('sound/weapons/bite.ogg')
	environment_smash = 0
	speak_emote = list("squeaks")
	ventcrawler = 2
	speed = -2
	small = TRUE
	var/datum/mind/origin
	var/egg_lain = FALSE

/mob/living/simple_animal/headcrab/proc/Infect(mob/living/carbon/victim)
	if(egg_lain)
		return
	if(victim.stat == DEAD)
		to_chat(src,"<span class='userdanger'>With our egg laid, our death approaches rapidly...</span>")
		var/obj/item/changeling_egg/egg = new(victim)
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			var/obj/item/organ/external/chest/BP = H.bodyparts_by_name[BP_CHEST]
			BP.hidden = egg
		if(origin)
			egg.origin = origin
			if(origin.changeling)
				for(var/mob/living/parasite/essence/E in src)
					E.loc = egg
					if(E.client)
						E.client.eye = egg.loc
		else if(mind)
			egg.origin = mind
		visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
		addtimer(CALLBACK(src, .proc/death), 100)
		egg_lain = TRUE

/obj/item/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "eggsac"
	origin_tech = "biotech=7" // You need to be really lucky to obtain it.
	var/datum/mind/origin
	var/respawn_time = 0


/obj/item/changeling_egg/atom_init()
	. = ..()
	respawn_time = world.time + EGG_INCUBATION_TIME
	START_PROCESSING(SSobj, src)

/obj/item/changeling_egg/process()
	// Changeling eggs grow in dead people
	if(!iscarbon(loc))
		STOP_PROCESSING(SSobj, src)
	if(respawn_time <= world.time)
		Pop()
		qdel(src)

/obj/item/changeling_egg/proc/Pop()
	var/mob/living/carbon/monkey/M = new(get_turf(loc))
	if(origin && origin.current && origin.current.stat != DEAD)
		return
	origin.transfer_to(M)
	if(origin.changeling)
		origin.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
		M.changeling_update_languages(origin.changeling.absorbed_languages)
		for(var/mob/living/parasite/essence/E in src)
			E.enter_host(M)
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.gib()
		playsound(C, 'sound/effects/blobattack.ogg', VOL_EFFECTS_MASTER)

#undef EGG_INCUBATION_TIME
