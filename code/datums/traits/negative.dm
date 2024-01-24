//predominantly negative traits

/datum/quirk/blindness
	name = QUIRK_BLIND
	desc = "Вы абсолютно слепы. Ничто не в силах это изменить."
	value = -4
	disability = TRUE
	mob_trait = TRAIT_BLIND
	gain_text = "<span class='danger'>Вы ничего не видите.</span>"
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
	desc = "Вы неизлечимо глухи."
	value = -2
	disability = TRUE
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>Вы оглохли.</span>"
	lose_text = "<span class='notice'>Вы снова слышите!</span>"



/datum/quirk/epileptic
	name = QUIRK_SEIZURES
	desc = "Вы испытываете эпилептические припадки."
	value = -1
	mob_trait = TRAIT_EPILEPSY
	gain_text = "<span class='danger'>Вы начинаете испытывать эпилептические припадки!</span>"
	lose_text = "<span class='notice'>Вы чувствуете облегчение, припадки больше вас не побеспокоят.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)

/datum/quirk/epileptic/on_spawn()
	if(!istype(quirk_holder))
		return
	quirk_holder.AddComponent(/datum/component/epilepsy, IS_EPILEPTIC_NOT_IN_PARALYSIS, (EPILEPSY_PARALYSE_EFFECT | EPILEPSY_JITTERY_EFFECT), QUIRK_TYPE_EPILEPSY)

/datum/quirk/fatness
	name = QUIRK_FATNESS
	desc = "Ваше ожирение не лечится."
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
	H.update_mutations()
	H.update_inv_w_uniform()
	H.update_inv_wear_suit()
	H.update_size_class()


/datum/quirk/tourette
	name = QUIRK_TOURETTE
	desc = "У вас неизлечимый нервный тик."
	value = -1
	mob_trait = TRAIT_TOURETTE
	gain_text = "<span class='danger'>Вас начинает трясти!</span>"
	lose_text = "<span class='notice'>Вас перестаёт трясти.</span>"

	incompatible_species = list(SKRELL, DIONA, IPC, ABDUCTOR)

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/nearsighted
	name = QUIRK_NEARSIGHTED
	desc = "У вас близорукость, но вы появляетесь с очками."
	value = -1
	mob_trait = TRAIT_NEARSIGHT
	gain_text = "<span class='danger'>Вещи, находящиеся вдалеке, начинают выглядеть размыто.</span>"
	lose_text = "<span class='notice'>Вы стали нормально видеть!</span>"

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.become_nearsighted(QUIRK_TRAIT)
	var/obj/item/clothing/glasses/regular/G = new
	if(!H.equip_to_slot_if_possible(G, SLOT_GLASSES, null, TRUE))
		H.put_in_hands(G)



/datum/quirk/nervous
	name = QUIRK_NERVOUS
	desc = "Вы постоянно нервничаете."
	value = -1
	mob_trait = TRAIT_NERVOUS
	gain_text = "<span class='danger'>Вы весь на нервах.</span>"
	lose_text = "<span class='notice'>Вы меньше нервничаете.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/stress_eater
	name = QUIRK_STRESS_EATER
	desc = "Вы заедаете боль"
	value = -1
	mob_trait = TRAIT_STRESS_EATER
	gain_text = "<span class='danger'>Боль пробуждает ваш голод.</span>"
	lose_text = "<span class='notice'>Вы перестали заедать боль.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/mute
	name = QUIRK_MUTE
	desc = "Вы полностью и неизлечимо немы."
	disability = TRUE
	value = -1
	mob_trait = TRAIT_MUTE
	gain_text = "<span class='danger'>Вы не можете вымолвить ни слова.</span>"
	lose_text = "<span class='notice'>Вы снова обрели дар речи.</span>"



/datum/quirk/light_drinker
	name = QUIRK_LIGHT_DRINKER
	desc = "Вы очень быстро напиваетесь."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='danger'>У вас кружится голова от одной лишь мысли об алкоголе.</span>"
	lose_text = "<span class='notice'>Вы перестали быть слишком чувствительными к алкоголю.</span>"

	// Those are not affected by alcohol at all.
	incompatible_species = list(SKRELL)

	req_species_flags = list(
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)



/datum/quirk/nyctophobia
	name = QUIRK_NYCTOPHOBIA
	desc = "Всю вашу жизнь вы боялись темноты. Находясь в темноте без света, вы инстинктивно ведете себя осторожно и постоянно испытываете чувство страха."
	value = -1

	gain_text = "<span class='notice'>Даже сама мысль о том, что вы находитесь в темноте, заставляет вас дрожать.</span>"
	lose_text = "<span class='notice'>Вы больше не боитесь темноты!</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)

	var/is_afraid = FALSE

/datum/quirk/nyctophobia/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder

	RegisterSignal(H, list(COMSIG_MOVABLE_MOVED), PROC_REF(on_move))

/datum/quirk/nyctophobia/proc/on_move(datum/source, atom/oldLoc, dir)
	var/mob/living/carbon/human/H = quirk_holder

	check_fear(H, get_turf(H))

/datum/quirk/nyctophobia/proc/become_afraid()
	if(is_afraid)
		return
	is_afraid = TRUE

	var/mob/living/L = quirk_holder

	L.emote("scream")
	to_chat(quirk_holder, "<span class='warning'>Тише, тише, не торопись... Ты в темноте...</span>")

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
	desc = "Неизлечимое генетическое заболевание делает невозможным искусственное восстановление вашего ДНК."
	value = -1

	mob_trait = TRAIT_NO_CLONE

	req_species_flags = list(
		NO_DNA = FALSE,
		NO_SCAN = FALSE,
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)



/datum/quirk/hemophiliac
	name = QUIRK_HEMOPHILIAC
	desc = "Вы с рождения больны гемофилией - пониженной свертываемостью крови. Кровотечения для вас очень опасны!"
	value = -1
	mob_trait = TRAIT_HEMOPHILIAC

	gain_text = "<span class='danger'>Вы чувствуете, насколько жидка кровь в ваших венах.</span>"
	lose_text = "<span class='notice'>Ваша кровь неожиданно густеет!</span>"

	req_species_flags = list(
		NO_BLOOD = FALSE,
	)
