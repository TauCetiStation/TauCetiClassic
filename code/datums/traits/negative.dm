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



/datum/quirk/hypochondria
	name = "Hypochondria"
	desc = "You always feel like you have one kind of disease or another, sometimes it bothers you a little too much."
	value = -1
	gain_text = "<span class='danger'>What is this itch? I think I have asthma!</span>"
	lose_text = "<span class='notice'>You feel like you are cured of all your imagined diseases.</span>"
	human_only = FALSE

	var/datum/disease2/effect/current_effect
	var/next_effect_run = 0
	var/ticks = 0
	var/current_effect_stage = 1

	var/curing_reagent = ""

/datum/quirk/hypochondria/on_spawn()
	var/effect_type = pick(subtypesof(/datum/disease2/effect))
	current_effect = new effect_type
	next_effect_run = world.time + current_effect.cooldown + 60 SECONDS
	curing_reagent = pick(chemical_reagents_list)

/datum/quirk/hypochondria/on_process()
	if(!iscarbon(quirk_holder))
		return

	if(next_effect_run > world.time)
		return

	var/mob/living/carbon/C = quirk_holder
	if(C.reagents)
		if(C.reagents.has_reagent("spaceacillin", 1))
			next_effect_run = world.time + 3 SECONDS
			return
		if(C.reagents.has_reagent(curing_reagent, 1))
			to_chat(C, "<span class='notice'>You feel fantastic, as if your inner craving for at least some sort of medicine faded away!</span>")
			var/effect_type = pick(subtypesof(/datum/disease2/effect))
			current_effect = new effect_type
			next_effect_run = world.time + 300 SECONDS
			ticks = 0
			curing_reagent = pick(chemical_reagents_list)
			return

	if(!prob(rand(current_effect.chance_minm, current_effect.chance_maxm)))
		return

	current_effect.simulate(C, current_effect_stage)
	ticks++
	if(ticks > current_effect_stage * 10 && prob(50))
		if(current_effect_stage < current_effect.max_stage)
			current_effect_stage++
		else if(prob(33))
			var/effect_type = pick(subtypesof(/datum/disease2/effect))
			current_effect = new effect_type
			current_effect_stage = 1
			ticks = 0

	next_effect_run = world.time + current_effect.cooldown
