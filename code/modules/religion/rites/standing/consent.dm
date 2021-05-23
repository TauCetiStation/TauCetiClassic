// This class is used for rites that require conesnt of a mob buckled to altar.
/datum/religion_rites/standing/consent
	var/consent_msg = ""
	can_talismaned = FALSE

/datum/religion_rites/standing/consent/New()
	AddComponent(/datum/component/rite/consent, consent_msg)


/*
 * Synthconversion
 * Replace your friendly robotechnicians with this little rite!
 */
/datum/religion_rites/standing/consent/synthconversion
	name = "Синтетическое Возвышение"
	desc = "Превращает <i>homosapiens</i> в (превосходящего) Андройда."
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

/datum/religion_rites/standing/consent/synthconversion/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	var/mob/living/simple_animal/shade/god/god = locate() in get_turf(AOG)
	if(!istype(god))
		if(!ishuman(AOG.buckled_mob))
			to_chat(user, "<span class='warning'>Only humanoid bodies can be accepted.</span>")
			return FALSE

		if(jobban_isbanned(AOG.buckled_mob, "Cyborg") || role_available_in_minutes(AOG.buckled_mob, ROLE_PAI))
			to_chat(user, "<span class='warning'>[AOG.buckled_mob]Тело [AOG.buckled_mob] слишком слабо!</span>")
			return FALSE
	else
		if(jobban_isbanned(god, "Cyborg") || role_available_in_minutes(god, ROLE_PAI))
			to_chat(user, "<span class='warning'>[god] is too weak!</span>")
			return FALSE

	return TRUE

/datum/religion_rites/standing/consent/synthconversion/invoke_effect(mob/living/user, obj/AOG)
	..()

	if(convert_god(AOG))
		return TRUE

	var/mob/living/carbon/human/human2borg = AOG.buckled_mob
	if(!istype(human2borg))
		return FALSE
	hgibs(get_turf(AOG), human2borg.viruses, human2borg.dna, human2borg.species.flesh_color, human2borg.species.blood_datum)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [pick(religion.deity_names)]!</span>")
	var/mob/living/silicon/robot/R = human2borg.Robotize(religion.bible_info.borg_name, religion.bible_info.laws_type, FALSE, religion)
	religion.add_member(R, HOLY_ROLE_PRIEST)
	return TRUE

/datum/religion_rites/standing/consent/synthconversion/proc/convert_god(obj/AOG)
	var/mob/living/simple_animal/shade/god/god = locate() in get_turf(AOG)
	if(!istype(god))
		return FALSE
	god.visible_message("<span class='notice'>[god] has been converted by the rite of [pick(religion.deity_names)]!</span>")
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(AOG), "Son of Heaven", religion.bible_info.laws_type, FALSE)
	god.mind.transfer_to(O)
	O.job = "Cyborg"
	qdel(god)
	religion.add_deity(god, HOLY_ROLE_PRIEST)
	return TRUE

/*
 * Sacrifice
 * Sacrifice a willing being to get a lot of points. Non-sentient beings who can not consent give points, but a lesser amount.
 */
/datum/religion_rites/standing/consent/sacrifice
	name = "Добровольное Жертвоприношение"
	desc = "Превращает энергию живого в favor."
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

/datum/religion_rites/standing/consent/sacrifice/invoke_effect(mob/living/user, obj/AOG)
	..()

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

	religion.adjust_favor(sacrifice_favor * divine_power)

	L.gib()
	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Clownconversion
 * Adds clumsy mutation to mob and changes their clothes
 */
/datum/religion_rites/standing/consent/clownconversion
	name = "Клоунконверсия"
	desc = "Превращает маленького человека в Клоуна." // this is ref to Russian writers
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

/datum/religion_rites/standing/consent/clownconversion/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только люди могут пройти через этот ритуал.</span>")
		return FALSE

	if(jobban_isbanned(AOG.buckled_mob, "Clown"))
		to_chat(user, "<span class='warning'>[pick(religion.deity_names)] don't accept this person!</span>")
		return FALSE

	if(!AOG.buckled_mob.mind)
		to_chat(user, "<span class='warning'>Тело [AOG.buckled_mob] слишком слабо!</span>")
		return FALSE

	if(AOG.buckled_mob.mind.holy_role >= HOLY_ROLE_PRIEST)
		to_chat(user, "<span class='warning'>[AOG.buckled_mob]уже святой!</span>")
		return FALSE

	return TRUE

/datum/religion_rites/standing/consent/clownconversion/invoke_effect(mob/living/user, obj/AOG)
	..()

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

	religion.add_member(H, HOLY_ROLE_PRIEST)
	H.mutations.Add(CLUMSY)
	H.mind.assigned_role = "Clown"
	return TRUE

/*
 * Divine invitation
 * Undresses and baptizes a person
 */
/datum/religion_rites/standing/consent/invite
	name = "Божественное Приглашение"
	desc = "Заставляет человека поверить в Бога."
	ritual_length = (40 SECONDS)
	ritual_invocations = list("Send peace, love, and unquestioning love to...",
						"...all that is good into the hearts of him and our children...",
						"...do not allow any of my family to be separated...",
						"...and to suffer a painful separation...",
						"...to die prematurely and suddenly without repentance....",
						"...Yes, and we will singly and separately, openly and secretly...",
						"...glorify Your Holy Name always, now and ever, and to the ages of ages....",)
	invoke_msg = "...Don't be afraid, little flock! I am with you and no one else on you!"
	favor_cost = 250

	consent_msg = "Do you believe in God?"

	needed_aspects = list(
		ASPECT_HERD = 1
	)

/datum/religion_rites/standing/consent/invite/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только люди могут пройти через этот ритуал.</span>")
		return FALSE

	if(!AOG.buckled_mob.mind)
		to_chat(user, "<span class='warning'>Тело [AOG.buckled_mob] слишком слабо!</span>")
		return FALSE

	if(AOG.buckled_mob.my_religion)
		to_chat(user, "<span class='warning'>[AOG.buckled_mob] уже святой!</span>")
		return FALSE

	return TRUE

/datum/religion_rites/standing/consent/invite/invoke_effect(mob/living/user, obj/AOG)
	..()

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(!istype(H))
		return FALSE

	H.remove_from_mob(H.wear_mask)
	H.remove_from_mob(H.w_uniform)
	H.remove_from_mob(H.head)
	H.remove_from_mob(H.wear_suit)
	H.remove_from_mob(H.back)
	H.remove_from_mob(H.shoes)

	to_chat(H, "<span class='piety'>Теперь вы верите в [pick(religion.deity_names)]</span>")

	religion.add_member(H, HOLY_ROLE_PRIEST)
	return TRUE
