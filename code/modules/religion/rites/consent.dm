// This class is used for rites that require conesnt of a mob buckled to altar.
/datum/religion_rites/consent
	var/consent_msg = ""

/datum/religion_rites/consent/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE
	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE

	var/mob/M = AOG.buckled_mob
	// Basically: "Are you sentient and willing?"
	if(M.IsAdvancedToolUser() && alert(M, consent_msg, "Rite", "Yes", "No") == "No")
		to_chat(user, "<span class='warning'>[M] does not want to give themselves into this ritual!.</span>")
		return FALSE
	return ..()

/datum/religion_rites/consent/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!AOG)
		to_chat(user, "<span class='warning'>This rite requires an altar to be performed.</span>")
		return FALSE
	if(!AOG.buckled_mob)
		to_chat(user, "<span class='warning'>This rite requires an individual to be buckled to [AOG].</span>")
		return FALSE
	return TRUE



/*
 * Synthconversion
 * Replace your friendly robotechnicians with this little rite!
 */
/datum/religion_rites/consent/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 700

	consent_msg = "Are you ready to sacrifice your body to turn into a cyborg?"

	needed_aspects = list(
		ASPECT_TECH = 1,
	)

/datum/religion_rites/consent/synthconversion/perform_rite(mob/living/user, obj/structure/altar_of_gods/AOG)
	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only humanoid bodies can be accepted.</span>")
		return FALSE

	if(jobban_isbanned(AOG.buckled_mob, "Cyborg") || !role_available_in_minutes(AOG.buckled_mob, ROLE_PAI))
		to_chat(usr, "<span class='warning'>[AOG.buckled_mob]'s body is too weak!.</span>")
		return FALSE
	return ..()

/datum/religion_rites/consent/synthconversion/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/human2borg = AOG.buckled_mob
	if(!istype(human2borg))
		return FALSE

	hgibs(AOG.loc, human2borg.viruses, human2borg.dna, human2borg.species.flesh_color, human2borg.species.blood_datum)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	human2borg.Robotize(global.chaplain_religion.bible_info.borg_name, global.chaplain_religion.bible_info.laws_type)
	return TRUE

/*
 * Sacrifice
 * Sacrifice a willing being to get a lot of points. Non-sentient beings who can not consent give points, but a lesser amount.
 */
/datum/religion_rites/consent/sacrifice
	name = "Sacrifice"
	desc = "Convert living energy in favor."
	ritual_length = (1 MINUTES)
	ritual_invocations = list("Hallowed be thy name...",
							  "...Thy kingdom come...",
							  "...Thy will be done in earth as it is in heaven...",
							  "...Give us this day our daily bread...",
							  "...and forgive us our trespasses...",
							  "...as we forgive them who trespass against us...",
							  "...and lead us not into temptation...")
	invoke_msg = "...but deliver us from the evil one!!"
	favor_cost = 0

	consent_msg = "Are you ready to sacrifice your body to give strength to a deity?"

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/consent/sacrifice/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/L = AOG.buckled_mob
	if(!istype(L))
		return FALSE

	var/sacrifice_favor = 0
	if(isanimal(L))
		sacrifice_favor += 100
	else if(ismonkey(L))
		sacrifice_favor += 150
	else if(ishuman(L) && L.mind && L.ckey)
		sacrifice_favor += 350
	else
		sacrifice_favor += 200

	if(L.stat == DEAD)
		sacrifice_favor *= 0.5
	if(!L.ckey)
		sacrifice_favor  *= 0.5

	L.gib()
	usr.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE
