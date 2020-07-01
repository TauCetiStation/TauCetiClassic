/datum/quirk/multitasking
	name = "Multitasking"
	desc = "You can do stuff with both of your hands simultaneously!"
	value = 2
	mob_trait = TRAIT_MULTITASKING
	gain_text = "<span class='notice'>You feel confident in using both of your hands simultaneously.</span>"
	lose_text = "<span class='danger'>You feel as if you lose the ability to multitask.</span>"



/datum/quirk/child_of_nature
	name = QUIRK_CHILD_OF_NATURE
	desc = "You feel as if you're one with nature. If you're nude animals do not attack you."
	value = 2
	mob_trait = TRAIT_NATURECHILD
	gain_text = "<span class='notice'>You feel like you are one with nature.</span>"
	lose_text = "<span class='danger'>You no more feel as if you're part of nature's plan.</span>"

	req_species_flags = list(
		IS_PLANT = TRUE,
	)

/datum/quirk/child_of_nature/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/head/bearpelt/B = new(H.loc)
	if(!H.equip_to_slot_if_possible(B, SLOT_HEAD, null, TRUE))
		H.put_in_hands(B)



/datum/quirk/strong_mind
	name = QUIRK_STRONG_MIND
	desc = "You can distinguish between lies and truth of your consciousness."
	value = 2
	mob_trait = TRAIT_STRONGMIND
	gain_text = "<span class='notice'>You feel confident in your sense.</span>"
	lose_text = "<span class='danger'>You feel insecure about your consciousness.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/alcohol_tolerance
	name = QUIRK_ALCOHOL_TOLERANCE
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"

	// Those are not affected by alcohol at all.
	incompatible_species = list(SKRELL)

	req_species_flags = list(
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)



/datum/quirk/freerunning
	name = QUIRK_FREERUNNING
	desc = "You're great at quick moves! You can climb objects more quickly."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"

	// They are slow as all hell.
	incompatible_species = list(DIONA)



/datum/quirk/light_step
	name = QUIRK_LIGHT_STEP
	desc = "You walk with a gentle step, never stepping on sharp objects or blood."
	value = 2
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>You walk with a litheness.</span>"
	lose_text = "<span class='danger'>You start tromping around like a barbarian.</span>"
