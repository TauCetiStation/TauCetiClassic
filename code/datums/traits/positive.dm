/datum/quirk/multitasking
	name = "Multitasking"
	desc = "You can do stuff with both of your hands simultaneously!"
	value = 2
	mob_trait = TRAIT_MULTITASKING
	gain_text = "<span class='notice'>You feel confident in using both of your hands simultaneously.</span>"
	lose_text = "<span class='danger'>You feel as if you lose the ability to multitask.</span>"



/datum/quirk/child_of_nature
	name = "Child of Nature"
	desc = "You feel as if you're one with nature. If you're nude animals do not attack you."
	value = 2
	mob_trait = TRAIT_NATURECHILD
	gain_text = "<span class='notice'>You feel like you are one with nature.</span>"
	lose_text = "<span class='danger'>You no more feel as if you're part of nature's plan.</span>"

/datum/quirk/child_of_nature/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/head/bearpelt/B = new(H.loc)
	if(!H.equip_to_slot_if_possible(B, SLOT_HEAD, null, TRUE))
		H.put_in_hands(B)
