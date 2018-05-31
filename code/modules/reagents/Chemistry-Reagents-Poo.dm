///SHIT STUFF GOES HERE
/datum/reagent/poo
	name = "Liquid Shit"
	id = "poo"
	description = "It's a poo"
	reagent_state = LIQUID
	color = "#402000" //rgb: 64, 32, 0
	taste_message = "devastating foul taste of shit"
	restrict_species = list(IPC,DIONA,SHADOWLING,SKELETON,GOLEM)
	var/datum/dirt_cover/decal_datum = new/datum/dirt_cover/poo

/datum/reagent/poo/on_mob_life(mob/living/M)
	if(!..())
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(prob(5))
			H.vomit()
		H.adjustToxLoss(0.1)

/datum/reagent/poo/reaction_turf(var/turf/T, var/volume)
	if(!istype(T, /turf/simulated)) return
	if(!(volume < 3)) return
	var/obj/effect/decal/cleanable/blood/poo/shit = locate() in T
	if(!shit)
		shit = new(T)

/datum/reagent/poo/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(method == TOUCH)
			if(H.wear_suit)
				H.wear_suit.add_blood(H,decal_datum)
				H.update_inv_wear_suit()
			if(H.w_uniform)
				H.w_uniform.add_blood(H,decal_datum)
				H.update_inv_w_uniform()
			if(H.shoes)
				H.shoes.add_blood(H,decal_datum)
				H.update_inv_shoes()
			if(H.gloves)
				H.gloves.add_blood(H,decal_datum)
				H.update_inv_gloves()
			if(H.head)
				H.head.add_blood(H,decal_datum)
				H.update_inv_head()
			if(H.glasses)
				H.glasses.add_blood(H,decal_datum)
				H.update_inv_glasses()
			if(H.wear_mask)
				H.wear_mask.add_blood(H,decal_datum)
				H.update_inv_wear_mask()
			if(H.back)
				H.back.add_blood(H,decal_datum)
				H.update_inv_back()
			if(H.belt)
				H.belt.add_blood(H,decal_datum)
				H.update_inv_belt()