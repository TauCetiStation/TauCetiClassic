#define isscp049(A) istype(A, /mob/living/carbon/human/scp049)

/datum/unarmed_attack/scp049_claws
	attack_verb = list("scratch", "claw", "slash")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 40

/datum/species/scp049
	name = "SCP-049"
	icobase = 'code/modules/SCP/SCP_049/SCP-049.dmi'
	deform = 'code/modules/SCP/SCP_049/SCP-049.dmi'
	dietflags = DIET_OMNI
	unarmed_type = /datum/unarmed_attack/scp049_claws
	eyes = "blank_eyes"

	flags = list(
	 NO_BREATHE = TRUE
	,NO_BLOOD = TRUE
	,NO_EMBED = TRUE
	,NO_SCAN = TRUE
	,NO_PAIN = TRUE
	,RAD_IMMUNE = TRUE
	,VIRUS_IMMUNE = TRUE
	)

	brute_mod = 0.2
	burn_mod = 0.2
	oxy_mod = 0
	tox_mod = 0
	brain_mod = 0
	speed_mod = -0.7

	has_gendered_icons = FALSE

/datum/species/scp049/on_gain(mob/living/carbon/human/H)
	H.status_flags &= ~(CANSTUN | CANWEAKEN | CANPARALYSE)
	return ..()

/mob/living/carbon/human/scp049
	real_name = "SCP-049"
	desc = "A mysterious plague doctor."

/mob/living/carbon/human/scp049/atom_init(mapload)
	. = ..(mapload, "SCP-049")
	universal_speak = TRUE
	universal_understand = TRUE
	AddSpell(new /obj/effect/proc_holder/spell/targeted/scp049_surgery)

/mob/living/carbon/human/scp049/examine(mob/user)
	to_chat(user, "<b><span class = 'info'><big>SCP-049</big></span></b> - [desc]")
	return ..(user)

/mob/living/carbon/human/scp049/movement_delay()
	..()
	var/tally = species.speed_mod
	if(crawling)
		tally += 7
	if(buckled) // so, if we buckled we have large debuff
		tally += 5.5
	if(pull_debuff)
		tally += pull_debuff
	return (tally + config.human_delay)

/mob/living/carbon/human/scp049/eyecheck()
	return 2

/mob/living/carbon/human/scp049/IsAdvancedToolUser()
	return FALSE

/obj/effect/proc_holder/spell/targeted/scp049_surgery
	name = "Perform Surgery"
	desc = "Performs surgery on a dead person, making him into a zombie."
	panel = "SCP"
	charge_max = 1
	clothes_req = 0
	range = -1
	include_user = 1
	var/zombies = 0

/obj/effect/proc_holder/spell/targeted/scp049_surgery/cast(list/targets)
	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/user = usr
	var/obj/item/weapon/grab/G = H.get_active_hand()
	if(!istype(G))
		to_chat(user, "<span class='warning'>You must be grabbing a creature in our active hand to do a surgery.</span>")
		return
	if(G.state <= GRAB_NECK)
		to_chat(user, "<span class='warning'>You must have a tighter grip to perform a surgery.</span>")
		return
	if(!ishuman(G.affecting))
		to_chat(usr, "<span class='warning'>You can only do surgery on humans.</span>")
		return
	if(user.is_busy(G.affecting))
		return

	var/mob/living/carbon/human/target = G.affecting
	if(G.affecting.stat != DEAD)
		for(var/stage = 1, stage<=3, stage++)
			switch(stage)
				if(1)
					user.visible_message("<span class='warning'>[user] puts his hand on [target]'s forehead!</span>")
				if(2)
					user.visible_message("<span class='warning'>[target] starts to convulse violently!</span>")
					target.make_jittery(5)

					addtimer(CALLBACK(target, /mob/.proc/emote, "scream",,,1), 10)
					addtimer(CALLBACK(target, /mob/.proc/emote, "scream",,,1), 80)
					addtimer(CALLBACK(target, /mob/.proc/emote, "scream",,,1), 140)
				if(3)
					target.death(0)
					continue

			if(!do_mob(user, target, 150))
				to_chat(user, "<span class='warning'>I was interrupted!</span>")
				return

	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				user.visible_message("<span class='warning'>[user] takes out his surgery bag from nowhere!</span>")
			if(2)
				user.visible_message("<span class='warning'>[user] starts to perform some kind of surgery on a dead body!</span>")
			if(3)
				user.visible_message("<span class='danger'>[user] finishes his surgery!</span>")
				continue

		if(!do_mob(user, target, 150))
			to_chat(user, "<span class='warning'>I was interrupted!</span>")
			return

	if(G)
		qdel(G)

	if(!target.key && target.mind)
		for(var/mob/dead/observer/ghost in player_list)
			if(ghost.mind == target.mind && ghost.can_reenter_corpse)
				var/answer = alert(ghost,"You are about to turn into a zombie. Do you want to return to body?","I'm a zombie!","Yes","No")
				if(answer == "Yes")
					ghost.reenter_corpse()

	spawn (50)
		target.rejuvenate()
		target.losebreath = 0
		target.visible_message("<span class = 'danger'><big>[target] rises up again.</big></span>")
		target.mutations.Add(HUSK)
		target.update_body()
		target.update_mutantrace()
		target.real_name = "SCP-049-[++zombies]"

	return
