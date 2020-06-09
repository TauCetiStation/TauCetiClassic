//predominantly negative traits

/datum/quirk/blindness
	name = "Blind"
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
	name = "Coughing"
	desc = "You have incurable coughing fit."
	value = -1
	mob_trait = TRAIT_COUGH
	gain_text = "<span class='danger'>You can't stop coughing!</span>"
	lose_text = "<span class='notice'>You feel relief again, as cough stops bothering you.</span>"



/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	value = -2
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>You can't hear anything.</span>"
	lose_text = "<span class='notice'>You're able to hear again!</span>"



/datum/quirk/epileptic
	name = "Seizures"
	desc = "You have incurable seizures."
	value = -1
	mob_trait = TRAIT_EPILEPSY
	gain_text = "<span class='danger'>You start having a seizures!</span>"
	lose_text = "<span class='notice'>You feel relief again, as seizures stops bothering you.</span>"



/datum/quirk/fatness
	name = "Fatness"
	desc = "You are incurably fat."
	value = -1
	mob_trait = TRAIT_FAT
	gain_text = "<span class='danger'>You feel chubby again.</span>"
	lose_text = "<span class='notice'>You feel fit again!</span>"

/datum/quirk/fatness/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.update_body()
	H.update_mutantrace()
	H.update_mutations()
	H.update_inv_w_uniform()
	H.update_inv_wear_suit()



/datum/quirk/tourette
	name = "Tourette"
	desc = "You have incurable twitching."
	value = -1
	mob_trait = TRAIT_TOURETTE
	gain_text = "<span class='danger'>You start twitch!</span>"
	lose_text = "<span class='notice'>You feel relief again, as twitching stops bothering you.</span>"



/datum/quirk/nearsighted
	name = "Nearsighted"
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
	name = "Nervous"
	desc = "You are always nervous."
	value = -1
	mob_trait = TRAIT_NERVOUS
	gain_text = "<span class='danger'>You feel nervous!</span>"
	lose_text = "<span class='notice'>You feel less yourself less nervous.</span>"



/datum/quirk/stress_eater
	name = "Stress Eater"
	desc = "You eat more when in pain."
	value = -1
	mob_trait = TRAIT_STRESS_EATER
	gain_text = "<span class='danger'>You feel quenchless hunger when hurt.</span>"
	lose_text = "<span class='notice'>You no longer feel the quenchless hunger when hurt.</span>"



/datum/quirk/mute
	name = "Mute"
	desc = "You are completely and incurably mute."
	value = -2
	mob_trait = TRAIT_MUTE
	gain_text = "<span class='danger'>Your voicebox feels wrong somehow.</span>"
	lose_text = "<span class='notice'>Your voicebox appears to work now.</span>"



/datum/quirk/low_pain_threshold
	name = "Low pain threshold"
	desc = "You endure pain more difficult. This quirk only affects sounds"
	mob_trait = TRAIT_LOW_PAIN_THRESHOLD
	gain_text = "<span class='danger'>Just the thought of pain makes you tremble in fear.</span>"
	lose_text = "<span class='notice'>You don't want to show yourself to other people anymore that you're a wimp. Now you're trying to ignore the pain.</span>"



/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='danger'>Just the thought of drinking alcohol makes your head spin.</span>"
	lose_text = "<span class='notice'>You're no longer severely affected by alcohol.</span>"



/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	value = -1

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.species.flags [NO_EMOTION])  //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
		return
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	if(lums <= 0.2)
		if(quirk_holder.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_holder, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")
			quirk_holder.m_intent = MOVE_INTENT_WALK
			quirk_holder.hud_used.move_intent.icon_state = "walking"



/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>You can't taste anything!</span>"
	lose_text = "<span class='notice'>You can taste again!</span>"
