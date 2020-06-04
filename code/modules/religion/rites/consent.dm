// This class is used for rites that require conesnt of a mob buckled to altar.
/datum/religion_rites/consent
	var/consent_msg = ""

/datum/religion_rites/consent/New()
	AddComponent(/datum/component/rite/consent, consent_msg)


/*
 * Synthconversion
 * Replace your friendly robotechnicians with this little rite!
 */
/datum/religion_rites/consent/synthconversion
	name = "Synthetic Conversion"
	desc = "Convert a human-esque individual into a (superior) Android."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("By the inner workings of our god...",
						"...We call upon you, in the face of adversity...",
						"...to complete us, removing that which is undesirable...")
	invoke_msg = "...Arise, our champion! Become that which your soul craves, live in the world as your true form!!"
	favor_cost = 700

	consent_msg = "Are you ready to sacrifice your body to turn into a cyborg?"

	needed_aspects = list(
		ASPECT_TECH = 1,
	)

/datum/religion_rites/consent/synthconversion/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only humanoid bodies can be accepted.</span>")
		return FALSE

	if(jobban_isbanned(AOG.buckled_mob, "Cyborg") || role_available_in_minutes(AOG.buckled_mob, ROLE_PAI))
		to_chat(user, "<span class='warning'>[AOG.buckled_mob]'s body is too weak!</span>")
		return FALSE
	return TRUE

/datum/religion_rites/consent/synthconversion/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/human2borg = AOG.buckled_mob
	if(!istype(human2borg))
		return FALSE

	hgibs(AOG.loc, human2borg.viruses, human2borg.dna, human2borg.species.flesh_color, human2borg.species.blood_datum)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [name]!</span>")
	human2borg.Robotize(global.chaplain_religion.bible_info.borg_name, global.chaplain_religion.bible_info.laws_type, FALSE)
	return TRUE

/*
 * Sacrifice
 * Sacrifice a willing being to get a lot of points. Non-sentient beings who can not consent give points, but a lesser amount.
 */
/datum/religion_rites/consent/sacrifice
	name = "Sacrifice"
	desc = "Convert living energy in favor."
	ritual_length = (50 SECONDS)
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
	
	global.chaplain_religion.adjust_favor(sacrifice_favor)

	L.gib()
	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Clownconversion
 * Adds clumsy mutation to mob and changes their clothes
 */
/datum/religion_rites/consent/clownconversion
	name = "Clownconversion"
	desc = "Convert a just person into a clown."
	ritual_length = (1.9 MINUTES)
	ritual_invocations = list("From our mother to our soil we got the gift of bananas...",
						"...From our mother to our ears we got the gift of horns...",
						"...From our mother to our feet we walk on we got the shoes of length...")
	invoke_msg = "...And from our mothers gift to you, we grant you the power of HONK!"
	favor_cost = 500

	consent_msg = "Do you feel the honk, growing, from within your body?"

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_HERD = 1
	)

/datum/religion_rites/consent/clownconversion/required_checks(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Only a human can go through the ritual.</span>")
		return FALSE

	if(jobban_isbanned(AOG.buckled_mob, "Clown"))
		to_chat(user, "<span class='warning'>[pick(global.chaplain_religion.deity_names)] don't accept this person!</span>")
		return FALSE
	
	if(!AOG.buckled_mob.mind)
		to_chat(user, "<span class='warning'>[AOG.buckled_mob]'s body is too weak!</span>")
		return FALSE

	if(AOG.buckled_mob.mind.holy_role >= HOLY_ROLE_PRIEST)
		to_chat(user, "<span class='warning'>[AOG.buckled_mob] are already holy!</span>")
		return FALSE

	return TRUE

/datum/religion_rites/consent/clownconversion/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(!istype(H))
		return FALSE

	H.remove_from_mob(H.wear_mask)
	H.remove_from_mob(H.w_uniform)
	H.remove_from_mob(H.head)
	H.remove_from_mob(H.wear_suit)
	H.remove_from_mob(H.back)
	H.remove_from_mob(H.shoes)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), SLOT_IN_BACKPACK)

	H.mind.holy_role = HOLY_ROLE_PRIEST
	H.mutations.Add(CLUMSY)
	AOG.sect.on_conversion(H)
	return TRUE
