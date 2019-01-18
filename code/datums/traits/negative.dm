//predominantly negative traits

/datum/quirk/blooddeficiency
	name = "Acute Blood Deficiency"
	desc = "Your body can't produce enough blood to sustain itself."
	value = -2
	gain_text = "<span class='danger'>You feel your vigor slowly fading away.</span>"
	lose_text = "<span class='notice'>You feel vigorous again.</span>"

/datum/quirk/blooddeficiency/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.species.flags[NO_BLOOD]) //can't lose blood if your species doesn't have any
		return
	var/blood_volume = H.vessel.get_reagent_amount("blood")
	if(blood_volume)
		var/datum/reagent/blood/B = locate() in H.vessel.reagent_list
		B.volume -= 0.275



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



/datum/quirk/brainproblems
	name = "Brain Tumor"
	desc = "You have a little friend in your brain that is slowly destroying it. Better bring some alkysine!"
	value = -3
	gain_text = "<span class='danger'>You feel smooth.</span>"
	lose_text = "<span class='notice'>You feel wrinkled again.</span>"

/datum/quirk/brainproblems/on_process()
	quirk_holder.adjustBrainLoss(0.2)



/datum/quirk/deafness
	name = "Deaf"
	desc = "You are incurably deaf."
	value = -2
	mob_trait = TRAIT_DEAF
	gain_text = "<span class='danger'>You can't hear anything.</span>"
	lose_text = "<span class='notice'>You're able to hear again!</span>"



/datum/quirk/fatness
	name = "Fatness"
	desc = "You are incurably fat."
	value = -1
	mob_trait = TRAIT_FAT
	gain_text = "<span class='danger'>You feel chubby again.</span>"
	lose_text = "<span class='notice'>You feel fit again!</span>"



/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom. passed down for generations. You have to keep it safe!"
	value = -1
	var/obj/item/heirloom
	var/where_text

	var/heirloom_missing = FALSE
	var/msg_pinged = FALSE

/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/heirloom_type
	switch(quirk_holder.mind.assigned_role)
		// Service jobs
		if("Clown")
			heirloom_type = /obj/item/weapon/bikehorn/golden
		if("Mime")
			heirloom_type = /obj/item/weapon/reagent_containers/food/snacks/baguette
		if("Janitor")
			heirloom_type = pick(/obj/item/weapon/mop, /obj/item/weapon/caution, /obj/item/weapon/reagent_containers/glass/bucket)
		if("Cook")
			heirloom_type = pick(/obj/item/weapon/reagent_containers/food/condiment/saltshaker, /obj/item/weapon/kitchen/rollingpin, /obj/item/clothing/head/chefhat)
		if("Botanist")
			heirloom_type = pick(/obj/item/weapon/reagent_containers/glass/bucket)
		if("Bartender")
			heirloom_type = pick(/obj/item/weapon/reagent_containers/glass/rag, /obj/item/clothing/head/that, /obj/item/weapon/reagent_containers/food/drinks/shaker)
		if("Test Subject")
			switch(quirk_holder.mind.role_alt_title)
				if("Lawyer")
					heirloom_type = pick(/obj/item/weapon/gavelhammer, /obj/item/weapon/book/manual/wiki/security_space_law)
				else
					heirloom_type = /obj/item/weapon/storage/toolbox/heirloom
		// Security / Command
		if("Captain")
			heirloom_type = /obj/item/weapon/reagent_containers/food/drinks/flask
		if("Head of Security")
			heirloom_type = /obj/item/weapon/book/manual/wiki/security_space_law
		if("Warden")
			heirloom_type = /obj/item/weapon/book/manual/wiki/security_space_law
		if("Security Officer")
			heirloom_type = pick(/obj/item/weapon/book/manual/wiki/security_space_law, /obj/item/clothing/head/beret/sec)
		if("Detective")
			heirloom_type = /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey

		// RnD
		if("Research Director")
			heirloom_type = /obj/item/toy/plushie/corgi
		if("Scientist")
			heirloom_type = /obj/item/toy/plushie/corgi
		if("Roboticist")
			heirloom_type = pick(subtypesof(/obj/item/toy/prize)) //look at this nerd
		// Medical
		if("Chief Medical Officer")
			heirloom_type = pick(/obj/item/clothing/accessory/stethoscope, /obj/item/bodybag)
		if("Medical Doctor")
			heirloom_type = pick(/obj/item/clothing/accessory/stethoscope, /obj/item/bodybag)
		if("Chemist")
			heirloom_type = /obj/item/weapon/book/manual/wiki/medical_chemistry
		if("Virologist")
			heirloom_type = /obj/item/weapon/reagent_containers/syringe
		// Engineering
		if("Chief Engineer")
			heirloom_type = pick(/obj/item/clothing/head/hardhat/white, /obj/item/weapon/screwdriver, /obj/item/weapon/wrench, /obj/item/weapon/weldingtool, /obj/item/weapon/crowbar, /obj/item/weapon/wirecutters)
		if("Station Engineer")
			heirloom_type = pick(/obj/item/clothing/head/hardhat, /obj/item/weapon/screwdriver, /obj/item/weapon/wrench, /obj/item/weapon/weldingtool, /obj/item/weapon/crowbar, /obj/item/weapon/wirecutters)
		if("Atmospheric Technician")
			heirloom_type = pick(/obj/item/weapon/lighter, /obj/item/weapon/storage/box/matches)
		// Supply
		if("Quartermaster")
			heirloom_type = pick(/obj/item/weapon/stamp, /obj/item/weapon/stamp/denied)
		if("Cargo Technician")
			heirloom_type = /obj/item/weapon/clipboard
		if("Shaft Miner")
			heirloom_type = pick(/obj/item/weapon/pickaxe, /obj/item/weapon/shovel)

	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards,
		/obj/item/weapon/lighter,
		/obj/item/weapon/dice/d20)
	heirloom = new heirloom_type(get_turf(quirk_holder))
	var/list/slots = list(
		"in your backpack" = slot_in_backpack,
		"in your left pocket" = slot_l_store,
		"in your right pocket" = slot_r_store
	)
	var/where = H.equip_in_one_of_slots(heirloom, slots)
	if(!where)
		where = "at your feet"
	where_text = "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!</span>"

/datum/quirk/family_heirloom/post_add()
	to_chat(quirk_holder, where_text)
	var/list/family_name = splittext(quirk_holder.real_name, " ")
	heirloom.name = "[family_name[family_name.len]] family [heirloom.name]"

/datum/quirk/family_heirloom/on_process() // edited version of this quirk as we don't have moodlets atm and i don't want to remove it.
	if(heirloom in quirk_holder.GetAllContents())
		if(heirloom_missing)
			heirloom_missing = FALSE
			to_chat(quirk_holder, "<span class='notice'>My family heirloom is safe with me.</span>")
	else
		heirloom_missing = TRUE
		if(SSquirks.times_fired % 30 == 1)
			to_chat(quirk_holder, "<span class='warning'>I'm missing my family heirloom...</span>")
		if(quirk_holder.nutrition > 0)
			quirk_holder.adjustNutritionLoss(3)
		else
			quirk_holder.adjustToxLoss(0.3) // 180 in ten minutes excluding anything that reduces toxins like vomit.



/datum/quirk/light_drinker
	name = "Light Drinker"
	desc = "You just can't handle your drinks and get drunk very quickly."
	value = -1
	mob_trait = TRAIT_LIGHT_DRINKER
	gain_text = "<span class='notice'>Just the thought of drinking alcohol makes your head spin.</span>"
	lose_text = "<span class='danger'>You're no longer severely affected by alcohol.</span>"



/datum/quirk/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "You are nearsighted without prescription glasses, but spawn with a pair."
	value = -1
	mob_trait = TRAIT_NEARSIGHT
	gain_text = "<span class='danger'>Things far away from you start looking blurry.</span>"
	lose_text = "<span class='notice'>You start seeing faraway things normally again.</span>"

/datum/quirk/nearsighted/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/clothing/glasses/sunglasses/prescription/G = new
	if(!H.equip_to_slot_if_possible(G, slot_glasses, null, TRUE))
		H.put_in_hands(G)



/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	value = -1

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.species.name in list(SHADOWLING, GOLEM, ZOMBIE, ZOMBIE_TAJARAN, ZOMBIE_SKRELL, ZOMBIE_UNATHI, SKELETON)) // hmm, new species flag?
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	if(lums <= 0.2)
		if(quirk_holder.m_intent == "run")
			to_chat(quirk_holder, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")
			quirk_holder.m_intent = "walk"
			quirk_holder.hud_used.move_intent.icon_state = "walking"



/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -2
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>You think you can defend yourself again.</span>"

/datum/quirk/nonviolent/on_process()
	if(quirk_holder.mind && quirk_holder.mind.special_role)
		to_chat(quirk_holder, "<span class='boldannounce'>Your antagonistic nature has caused you to renounce your pacifism.</span>")
		qdel(src)



/datum/quirk/poor_aim
	name = "Poor Aim"
	desc = "You're terrible with guns and can't line up a straight shot to save your life."
	value = -1
	mob_trait = TRAIT_POOR_AIM



/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a random prosthetic!"
	value = -1
	var/slot_string = "limb"

/datum/quirk/prosthetic_limb/on_spawn()
	var/limb_slot = pick(BP_L_ARM, BP_R_ARM, BP_L_LEG, BP_R_LEG)
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/external/BP = H.get_bodypart(limb_slot)

	slot_string = BP.name

	BP.robotize()
	BP.max_damage = 20
	BP.min_broken_damage = 10

	H.update_body()
	H.updatehealth()
	H.UpdateDamageIcon(BP)

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment.</span>")



/datum/quirk/obstructive
	name = "Physically Obstructive"
	desc = "You somehow manage to always be in the way. You can't swap places with other people."
	value = -1
	mob_trait = TRAIT_NOMOBSWAP
	gain_text = "<span class='danger'>You feel like you're in the way.</span>"
	lose_text = "<span class='notice'>You feel less like you're in the way.</span>"



/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	value = -1
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel easier about talking again.</span>" //if only it were that easy!
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/on_process()
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in view(5, quirk_holder))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = quirk_holder
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(20, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/weapon/reagent_containers/food/snacks/pastatomato(get_turf(H)) //now that's what I call spaghetti code



/datum/quirk/fragile_bones // prosthetic limbs are no excuse.
	name = "Vrolik Syndrome"
	desc = "You are born with rare disease that caused your bones to be very fragile."
	value = -2

/datum/quirk/fragile_bones/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	for(var/obj/item/organ/external/BP in H.bodyparts)
		BP.min_broken_damage *= 0.30
