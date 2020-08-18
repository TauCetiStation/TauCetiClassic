//predominantly negative traits

/datum/quirk/blindness
	name = QUIRK_BLIND
	desc = "You are completely blind, nothing can counteract this."
	value = -4
	mob_trait = TRAIT_BLIND
	gain_text = "<span class='danger'>You can't see anything.</span>"
	lose_text = "<span class='notice'>You miraculously gain back your vision.</span>"

/datum/quirk/blindness/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/sunglasses/blindfold/white/B = new
	if(!H.equip_to_slot_if_possible(B, SLOT_GLASSES, null, TRUE)) //if you can't put it on the user's eyes, put it in their hands.
		H.put_in_hands(B)



/datum/quirk/cough
	name = QUIRK_COUGHING
	desc = "You have incurable coughing fit."
	value = -1
	mob_trait = TRAIT_COUGH
	gain_text = "<span class='danger'>You can't stop coughing!</span>"
	lose_text = "<span class='notice'>You feel relief again, as cough stops bothering you.</span>"

	req_species_flags = list(
		NO_BREATHE = FALSE,
	)



/datum/quirk/deafness
	name = QUIRK_DEAF
	desc = "You are incurably deaf."
	value = -2
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>You can't hear anything.</span>"
	lose_text = "<span class='notice'>You're able to hear again!</span>"



/datum/quirk/epileptic
	name = QUIRK_SEIZURES
	desc = "You have incurable seizures."
	value = -1
	mob_trait = TRAIT_EPILEPSY
	gain_text = "<span class='danger'>You start having a seizures!</span>"
	lose_text = "<span class='notice'>You feel relief again, as seizures stops bothering you.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/fatness
	name = QUIRK_FATNESS
	desc = "You are incurably fat."
	value = -1
	mob_trait = TRAIT_FAT
	gain_text = "<span class='danger'>You feel chubby again.</span>"
	lose_text = "<span class='notice'>You feel fit again!</span>"

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



/datum/quirk/tourette
	name = QUIRK_TOURETTE
	desc = "You have incurable twitching."
	value = -1
	mob_trait = TRAIT_TOURETTE
	gain_text = "<span class='danger'>You start twitch!</span>"
	lose_text = "<span class='notice'>You feel relief again, as twitching stops bothering you.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/nearsighted
	name = QUIRK_NEARSIGHTED
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	value = -1
	mob_trait = TRAIT_NEARSIGHT
	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/regular/G = new
	if(!H.equip_to_slot_if_possible(G, SLOT_GLASSES, null, TRUE))
		H.put_in_hands(G)



/datum/quirk/nervous
	name = QUIRK_NERVOUS
	desc = "You are always nervous."
	value = -1
	mob_trait = TRAIT_NERVOUS
	gain_text = "<span class='danger'>You feel nervous!</span>"
	lose_text = "<span class='notice'>You feel less yourself less nervous.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/stress_eater
	name = QUIRK_STRESS_EATER
	desc = "You eat more when in pain."
	value = -1
	mob_trait = TRAIT_STRESS_EATER
	gain_text = "<span class='danger'>You feel quenchless hunger when hurt.</span>"
	lose_text = "<span class='notice'>You no longer feel the quenchless hunger when hurt.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/mute
	name = QUIRK_MUTE
	desc = "You are completely and incurably mute."
	value = -1
	mob_trait = TRAIT_MUTE
	gain_text = "<span class='danger'>Your voicebox feels wrong somehow.</span>"
	lose_text = "<span class='notice'>Your voicebox appears to work now.</span>"



/datum/quirk/light_drinker
	name = QUIRK_LIGHT_DRINKER
	desc = "You just can't handle your drinks and get drunk very quickly."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='danger'>Just the thought of drinking alcohol makes your head spin.</span>"
	lose_text = "<span class='notice'>You're no longer severely affected by alcohol.</span>"

	// Those are not affected by alcohol at all.
	incompatible_species = list(SKRELL)

	req_species_flags = list(
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)



/datum/quirk/nyctophobia
	name = QUIRK_NYCTOPHOBIA
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	value = -1

	gain_text = "<span class='notice'>Just thinking about being in the dark makes you shiver.</span>"
	lose_text = "<span class='notice'>You are not afraid of darkness anymore!</span>"

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
	to_chat(quirk_holder, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")

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
