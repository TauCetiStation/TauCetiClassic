//predominantly positive traits

/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "You become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>You feel like you could drink a whole keg!</span>"
	lose_text = "<span class='danger'>You don't feel as resistant to alcohol anymore. Somehow.</span>"



/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly."
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



/datum/quirk/photographer
	name = "Photographer"
	desc = "You know how to handle a camera, shortening the delay between each shot."
	value = 1
	mob_trait = TRAIT_PHOTOGRAPHER
	gain_text = "<span class='notice'>You know everything about photography.</span>"
	lose_text = "<span class='danger'>You forget how photo cameras work.</span>"

/datum/quirk/photographer/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/device/camera/camera = new(get_turf(H))
	if(!H.equip_to_slot(camera, slot_in_backpack))
		H.put_in_hands(camera)



/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "You know your body well, and can accurately assess the extent of your wounds."
	value = 2
	mob_trait = TRAIT_SELF_AWARE



/datum/quirk/skittish
	name = "Skittish"
	desc = "You can conceal yourself in danger. Ctrl-shift-click a closed locker to jump into it, as long as you have access. Can un*lock closets while being inside."
	value = 2
	mob_trait = TRAIT_SKITTISH



/datum/quirk/spiritual
	name = "Spiritual"
	desc = "You're in tune with the gods, and your prayers may be more likely to be heard. Or not."
	value = 1
	mob_trait = TRAIT_SPIRITUAL
	gain_text = "<span class='notice'>You feel a little more faithful to the gods today.</span>"
	lose_text = "<span class='danger'>You feel less faithful in the gods.</span>"


