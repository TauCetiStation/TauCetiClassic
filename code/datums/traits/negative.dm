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
	if(!H.equip_to_slot_if_possible(B, slot_glasses, null, TRUE)) //if you can't put it on the user's eyes, put it in their hands.
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



/datum/quirk/epileptic
	name = "Twitching"
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
	if(!H.equip_to_slot_if_possible(G, slot_glasses, null, TRUE))
		H.put_in_hands(G)



/datum/quirk/nervous
	name = "Nervous"
	desc = "You are always nervous."
	value = -1
	mob_trait = TRAIT_NERVOUS
	gain_text = "<span class='danger'>You feel nervous!</span>"
	lose_text = "<span class='notice'>You feel less yourself less nervous.</span>"
