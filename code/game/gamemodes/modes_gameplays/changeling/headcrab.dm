#define EGG_INCUBATION_TIME 1200

/obj/effect/proc_holder/changeling/headcrab
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	chemical_cost = 20
	genomecost = 1
	req_human = 1
	req_stat = DEAD
	max_genetic_damage = 10
	can_be_used_in_abom_form = FALSE

/obj/effect/proc_holder/changeling/headcrab/can_sting(mob/user, mob/target)
	. = ..()
	if(tgui_alert(user, "Are we sure we wish to sacrifice our current body?","Last Resort", list("Yes","No")) != "Yes")
		return FALSE

/obj/effect/proc_holder/changeling/headcrab/sting_action(mob/user)
	var/datum/mind/M = user.mind
	for(var/mob/living/carbon/human/H in range(2,user))
		to_chat(H,"<span class='userdanger'>You are blinded by a shower of blood!</span>")
		H.Stun(1)
		H.apply_effect(20,EYE_BLUR)
		H.AdjustConfused(3)
	for(var/mob/living/silicon/S in range(2,user))
		to_chat(S,"<span class='userdanger'>Your sensors are disabled by a shower of blood!</span>")
		S.Stun(3)

	// In case we did it out of stasis
	if(role.instatis)
		role.instatis = FALSE
		user.fake_death = FALSE
	for(var/obj/effect/proc_holder/changeling/fakedeath/A in role.purchasedpowers)
		A.action.button_icon_state = "fake_death"
		A.action.button.UpdateIcon()
		A.ready2revive = FALSE

	var/mob/living/simple_animal/headcrab/crab = new(get_turf(user))
	crab.origin = M
	M.transfer_to(crab)
	for(var/mob/living/parasite/essence/E in user)
		E.transfer(crab)
	to_chat(crab,"<span class='warning'>You burst out of the remains of your former body in a shower of gore!</span>")
	feedback_add_details("changeling_powers","LR")
	if(ismob(user))
		playsound(user, 'sound/effects/blobattack.ogg', VOL_EFFECTS_MASTER)
		user.gib()
	else
		qdel(user)
	return TRUE

/mob/living/simple_animal/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	gender = NEUTER
	pass_flags = PASSTABLE|PASSMOB
	health = 50
	maxHealth = 50
	melee_damage = 5
	attacktext = "chomp"
	attack_sound = list('sound/weapons/bite.ogg')
	environment_smash = 0
	speak_emote = list("squeaks")
	ventcrawler = 2
	speed = -2
	w_class = SIZE_MINUSCULE
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
			var/datum/role/changeling/C = origin.GetRoleByType(/datum/role/changeling)
			if(C)
				for(var/mob/living/parasite/essence/E in src)
					E.loc = egg
					if(E.client)
						E.client.eye = egg.loc
		else if(mind)
			egg.origin = mind
		visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
		addtimer(CALLBACK(src, PROC_REF(death)), 100)
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
	var/datum/role/changeling/C = origin.GetRoleByType(/datum/role/changeling)
	if(C)
		var/obj/effect/proc_holder/changeling/lesserform/A = locate(/obj/effect/proc_holder/changeling/lesserform) in C.purchasedpowers
		if(!A) //If ling doesnt have lesserfrom, give them one-use
			A = new (null)
			A.last_resort = TRUE
			C.purchasedpowers += A
			A.on_purchase(M)
		A.action.button_icon_state = "human_form"
		A.action.button.name = "Human form"
		A.action.button.UpdateIcon()
		M.changeling_update_languages(C.absorbed_languages)
		for(var/mob/living/parasite/essence/E in src)
			E.transfer(M)
	if(iscarbon(loc))
		var/mob/living/carbon/carbon = loc
		carbon.gib()
		playsound(carbon, 'sound/effects/blobattack.ogg', VOL_EFFECTS_MASTER)

#undef EGG_INCUBATION_TIME
