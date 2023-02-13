/datum/quirk/multitasking
	name = QUIRK_MULTITASKING
	desc = "Вы можете действовать обеими руками одновременно!"
	value = 2
	mob_trait = TRAIT_MULTITASKING
	gain_text = "<span class='notice'>Вы чувствуете уверенность в том, что можете действовать двумя руками одновременно.</span>"
	lose_text = "<span class='danger'>Вы чувствуете, что растеряли талант многозадачности.</span>"



/datum/quirk/child_of_nature
	name = QUIRK_CHILD_OF_NATURE
	desc = "Вы едины с природой. Животные не будут атаковать вас, если вы разденетесь догола."
	value = 2
	mob_trait = TRAIT_NATURECHILD
	gain_text = "<span class='notice'>Вы чуствуете единство с природой.</span>"
	lose_text = "<span class='danger'>Ваша связь с природой нарушена.</span>"

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
	desc = "Вы отличаете истину от лжи своего сознания."
	value = 2
	mob_trait = TRAIT_STRONGMIND
	gain_text = "<span class='notice'>Вы чувствуете уверенность в своём разуме.</span>"
	lose_text = "<span class='danger'>Вы чувствуете ненадёжность своего сознания.</span>"

	req_species_flags = list(
		NO_EMOTION = FALSE,
	)



/datum/quirk/alcohol_tolerance
	name = QUIRK_ALCOHOL_TOLERANCE
	desc = "Вам сложнее опьянеть и легче перенести похмелье."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>Вы чувствуете, что вам и бочка пива будет по силе!</span>"
	lose_text = "<span class='danger'>Вы больше не чувствуете себя стойким к алкоголю. Какая беда.</span>"

	// Those are not affected by alcohol at all.
	incompatible_species = list(SKRELL)

	req_species_flags = list(
		IS_PLANT = FALSE,
		IS_SYNTHETIC = FALSE,
	)



/datum/quirk/freerunning
	name = QUIRK_FREERUNNING
	desc = "Вы проворны как кошка! Вы залазите на различные объекты быстрее."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>Вы ощущаете гибкость своих ног.</span>"
	lose_text = "<span class='danger'>Вы снова чувствуете себя неуклюжим.</span>"

	// They are slow as all hell.
	incompatible_species = list(DIONA)



/datum/quirk/light_step
	name = QUIRK_LIGHT_STEP
	desc = "Вы ходите аккуратно и грациозно, никогда не наступая в лужи крови или грязь."
	value = 2
	mob_trait = TRAIT_LIGHT_STEP
	gain_text = "<span class='notice'>У вас лёгкая поступь.</span>"
	lose_text = "<span class='danger'>Вы начинаете топотать, как грязный варвар.</span>"

/datum/quirk/fast_equip
	name = QUIRK_FAST_EQUIP
	desc = "Вы можете одеваться быстрее."
	value = 2
	mob_trait = TRAIT_FAST_EQUIP
	gain_text = "<span class='notice'Годы жизни на станции научили вас кое-чему.</span>"
	lose_text = "<span class='danger'>Ваша координация стремительно деградировала.</span>"


/datum/quirk/friendly
	name = QUIRK_FRIENDLY
	desc = "Ваши объятия прекрасны! В особенности, если вы в хорошем настроении."
	value = 1
	mob_trait = TRAIT_FRIENDLY
	gain_text = "<span class='notice'>Вы хотите кого-нибудь обнять.</span>"
	lose_text = "<span class='danger'>Ваши объятия теперь мало радуют.</span>"
