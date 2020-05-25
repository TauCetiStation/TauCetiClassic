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



/datum/quirk/high_pain_threshold
	name = "High pain threshold"
	desc = "You can take pain more easily. This quirk only affects sounds."
	mob_trait = TRAIT_HIGH_PAIN_THRESHOLD
	gain_text = "<span class='danger'>You want to show how strong you are. You will try to ignore any pain.</span>"
	lose_text = "<span class='notice'>You no longer want to endure pain, it scares you.</span>"



/datum/quirk/strong_mind
	name = "Strong mind"
	desc = "You can distinguish between lies and truth of your consciousness."
	value = 2
	mob_trait = TRAIT_STRONGMIND
	gain_text = "<span class='notice'>You feel confident in your sense.</span>"
	lose_text = "<span class='danger'>You feel insecure about your consciousness.</span>"



/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"
    
  
  
 /datum/quirk/photographer
	name = "Photographer"
	desc = "You know how to handle a camera, shortening the delay between each shot."
	value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = "<span class='notice'>You know everything about photography.</span>"
	lose_text = "<span class='danger'>You forget how photo cameras work.</span>"



/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb objects more quickly."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"



/datum/quirk/light_step
	name = "Light Step"
	desc = "You walk with a gentle step, never stepping on sharp objects or blood."
	value = 2
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>You walk with a litheness.</span>"
	lose_text = "<span class='danger'>You start tromping around like a barbarian.</span>"
