//predominantly negative traits

/datum/quirk/blindness
	name = QUIRK_BLIND
	desc = "Вы абсолютно слепы."
	value = -4
	disability = TRUE
	mob_trait = TRAIT_BLIND
	gain_text = "<span class='danger'>Эй, кто выключил свет?</span>"
	lose_text = "<span class='notice'>К вам чудесным образом вернулось зрение!</span>"

/datum/quirk/blindness/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/sunglasses/blindfold/white/B = new
	if(!H.equip_to_slot_if_possible(B, SLOT_GLASSES, null, TRUE)) //if you can't put it on the user's eyes, put it in their hands.
		H.put_in_hands(B)



/datum/quirk/cough
	name = QUIRK_COUGHING
	desc = "У вас неизлечимый хронический кашель."
	value = -1
	mob_trait = TRAIT_COUGH
	gain_text = "<span class='danger'>Вы не можете перестать кашлять!</span>"
	lose_text = "<span class='notice'>Вы чувствуете облегчение, кашель больше вас не побеспокоит.</span>"

	req_species_flags = list(
		NO_BREATHE = FALSE,
	)



/datum/quirk/deafness
	name = QUIRK_DEAF
	desc = "Вы полностью и неизлечимо глухи."
	value = -2
	disability = TRUE
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>Тут подозрительно тихо.</span>"
	lose_text = "<span class='notice'>Вы снова слышите!</span>"



/datum/quirk/epileptic
	name = QUIRK_SEIZURES
	desc = "Вы испытываете припадки."
	value = -1
	mob_trait = TRAIT_EPILEPSY
	gain_text = "<span class='danger'>Вы начинаете испытывать эпилептические припадки!</span>"
	lose_text = "<span class='notice'>Вы чувствуете облегчение, припадки больше вас не побеспокоят.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/fatness
	name = QUIRK_FATNESS
	desc = "Вы, мягко скажем, полноваты."
	value = -1
	mob_trait = TRAIT_FAT
	gain_text = "<span class='danger'>Вы чувствуете, что набрали несколько лишних килограмм.</span>"
	lose_text = "<span class='notice'>Вы снова в форме!</span>"

	req_species_flags = list(
		NO_FAT = FALSE,
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)

/datum/quirk/fatness/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.update_body()
	H.update_mutantrace()
	H.update_mutations()
	H.update_inv_w_uniform()
	H.update_inv_wear_suit()
	H.update_size_class()


/datum/quirk/tourette
	name = QUIRK_TOURETTE
	desc = "У вас неизлечимые нервные тики."
	value = -1
	mob_trait = TRAIT_TOURETTE
	gain_text = "<span class='danger'>Вас начинает трясти!</span>"
	lose_text = "<span class='notice'>Вас перестаёт трясти.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/nearsighted
	name = QUIRK_NEARSIGHTED
	desc = "Вы плохо видите без очков, однако появляетесь с парой таковых."
	value = -1
	mob_trait = TRAIT_NEARSIGHT
	gain_text = "<span class='danger'>Всё на расстоянии от вас выглядит размыто.</span>"
	lose_text = "<span class='notice'>Вы стали нормально видеть!</span>"

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/G = new
	if(!H.equip_to_slot_if_possible(G, SLOT_GLASSES, null, TRUE))
		H.put_in_hands(G)



/datum/quirk/nervous
	name = QUIRK_NERVOUS
	desc = "Вы постоянно на взводе."
	value = -1
	mob_trait = TRAIT_NERVOUS
	gain_text = "<span class='danger'>Вы весь на нервах.</span>"
	lose_text = "<span class='notice'>Вы чувствуете себя более расслабленно.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/stress_eater
	name = QUIRK_STRESS_EATER
	desc = "Когда вы испытываете боль, ваш голод усиливается."
	value = -1
	mob_trait = TRAIT_STRESS_EATER
	gain_text = "<span class='danger'>Когда вам больно, вы чувствуете неутолимый голод.</span>"
	lose_text = "<span class='notice'>Вы перестали чувствовать голод, испытывая боль.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/mute
	name = QUIRK_MUTE
	desc = "Вы полностью и неизлечимо немы."
	disability = TRUE
	value = -1
	mob_trait = TRAIT_MUTE
	gain_text = "<span class='danger'>Голосовой аппарат ощущается странновато.</span>"
	lose_text = "<span class='notice'>Ваш голосовой аппарат, похоже, снова исправен.</span>"



/datum/quirk/light_drinker
	name = QUIRK_LIGHT_DRINKER
	desc = "Вы очень быстро напиваетесь."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='danger'>От одной лишь мысли об алкоголе у вас кружится голова.</span>"
	lose_text = "<span class='notice'>Вас больше не коробит от алкоголя.</span>"

	// Those are not affected by alcohol at all.
	incompatible_species = list(SKRELL)

	req_species_flags = list(
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)



/datum/quirk/nyctophobia
	name = QUIRK_NYCTOPHOBIA
	desc = "Всю вашу жизнь вас преследовал страх темноты. Ныряя во тьму вы инстинктивно настораживаетесь и действуете с осторожностью, познавая настоящий страх. Лишь источник света способен помочь вам."
	value = -1

	gain_text = "<span class='notice'>Даже от мимолётной мысли о пребывании в темноте вас бросает в холодный пот.</span>"
	lose_text = "<span class='notice'>Темнота больше не пугает вас!</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)

	var/is_afraid = FALSE

/datum/quirk/nyctophobia/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder

	RegisterSignal(H, list(COMSIG_MOVABLE_MOVED), .proc/on_move)

/datum/quirk/nyctophobia/proc/on_move(datum/source, atom/oldLoc, dir)
	var/mob/living/carbon/human/H = quirk_holder

	if(isturf(oldLoc))
		UnregisterSignal(H, list(COMSIG_LIGHT_UPDATE_OBJECT))

	check_fear(H, get_turf(H))

	if(isturf(H.loc))
		RegisterSignal(H, list(COMSIG_LIGHT_UPDATE_OBJECT), .proc/check_fear)

/datum/quirk/nyctophobia/proc/become_afraid()
	if(is_afraid)
		return
	is_afraid = TRUE

	var/mob/living/L = quirk_holder

	L.emote("scream")
	to_chat(quirk_holder, "<span class='warning'>Тише, тише, успокойся, дружище... Это всего-лишь темнота...</span>")

	L.set_m_intent(MOVE_INTENT_WALK)
	ADD_TRAIT(quirk_holder, TRAIT_NO_RUN, FEAR_TRAIT)

/datum/quirk/nyctophobia/proc/chill()
	if(!is_afraid)
		return
	is_afraid = FALSE

	REMOVE_TRAIT(quirk_holder, TRAIT_NO_RUN, FEAR_TRAIT)

/datum/quirk/nyctophobia/proc/check_fear(datum/source, turf/myturf)
	var/lums = myturf.get_lumcount()

	if(lums <= 0.4)
		become_afraid()
	else
		chill()

/datum/quirk/genetic_degradation
	name = QUIRK_GENETIC_DEGRADATION
	desc = "Ужасная генетическая болезнь делает невозможной искусственную реконструкцию вашего ДНК."
	value = -1

	mob_trait = TRAIT_NO_CLONE
	
	req_species_flags = list(
		NO_DNA = FALSE,
		NO_SCAN = FALSE,
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)
