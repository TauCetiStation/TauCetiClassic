/datum/reagent/blood
	data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null, "antibodies" = null)
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#c80000" // rgb: 200, 0, 0
	taste_message = "<span class='warning'>blood</span>"

/datum/reagent/blood/reaction_mob(mob/M, method=TOUCH, volume)
	var/datum/reagent/blood/self = src
	src = null
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			// We don't spread.
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS)
				continue
			if(method == TOUCH)
				M.contract_disease(D)
			else //injected
				M.contract_disease(D, 1, 0)

	if(self.data && self.data["virus2"] && istype(M, /mob/living/carbon))//infecting...
		var/list/vlist = self.data["virus2"]
		if(vlist.len)
			for(var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]
				if(method == TOUCH)
					infect_virus2(M,V.getcopy())
				else
					infect_virus2(M,V.getcopy(),1) //injected, force infection!

	if(self.data && self.data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
		var/mob/living/carbon/C = M
		C.antibodies |= self.data["antibodies"]

/datum/reagent/blood/on_diona_digest(mob/living/M)
	..() // Should be put in these procs, in case a xeno of sorts has a reaction to ALL reagents.
	M.adjustCloneLoss(-REM)
	return FALSE // Returning false would mean that generic digestion proc won't be used.

/datum/reagent/blood/reaction_turf(turf/simulated/T, volume)//splash the blood all over the place
	. = ..()
	if(!istype(T))
		return
	var/datum/reagent/blood/self = src
	if(!(volume >= 3))
		return
	//var/datum/disease/D = self.data["virus"]
	if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

		if(self.data["virus2"])
			blood_prop.virus2 = virus_copylist(self.data["virus2"])


	else if(istype(self.data["donor"], /mob/living/carbon/monkey))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["Non-Human DNA"] = "A+"
		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

	else if(istype(self.data["donor"], /mob/living/carbon/xenomorph))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	reagent_state = LIQUID
	color = "#c81040" // rgb: 200, 16, 64
	taste_message = "health"

/datum/reagent/vaccine/reaction_mob(mob/M, method=TOUCH, volume)
	var/datum/reagent/vaccine/self = src
	src = null
	if(self.data&&method == INGEST)
		for(var/datum/disease/D in M.viruses)
			if(istype(D, /datum/disease/advance))
				var/datum/disease/advance/A = D
				if(A.GetDiseaseID() == self.data)
					D.cure()
			else
				if(D.type == self.data)
					D.cure()

			M.resistances += self.data

/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	color = "#009ca8" // rgb: 0, 156, 168
	overdose = REAGENTS_OVERDOSE
	taste_message = "oil"

	needed_aspects = list(ASPECT_WACKY = 1)

/datum/reagent/lube/reaction_turf(turf/simulated/T, volume)
	. = ..()
	if(!istype(T))
		return
	if(volume >= 1)
		T.make_wet_floor(LUBE_FLOOR)

/datum/reagent/plasticide
	name = "Plasticide"
	id = "plasticide"
	description = "Liquid plastic, do not eat."
	reagent_state = LIQUID
	color = "#cf3600" // rgb: 207, 54, 0
	custom_metabolism = 0.01
	taste_message = "plastic"

/datum/reagent/plasticide/on_general_digest(mob/living/M)
	..()
	// Toxins are really weak, but without being treated, last very long.
	M.adjustToxLoss(0.2)

/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128
	taste_message = "sweetness"
	custom_metabolism = 0.01

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128
	taste_message = "oil" // Wait. Is it really oil though? Or does it here mean oil, as in "?????"?
	custom_metabolism = 0.01

/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

/datum/reagent/thermite/reaction_turf(turf/T, volume)
	. = ..()
	if(volume >= 30)
		if(istype(T, /turf/simulated/wall))
			var/turf/simulated/wall/W = T
			W.thermite = 1
			W.add_overlay(image('icons/effects/effects.dmi',icon_state = "#673910"))

/datum/reagent/thermite/on_general_digest(mob/living/M)
	..()
	M.adjustFireLoss(1)

/datum/reagent/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19

/datum/reagent/virus_food/on_general_digest(mob/living/M)
	..()
	M.nutrition += nutriment_factor * REM

/datum/reagent/virus_vood/on_skrell_digest(mob/living/M)
	..()
	M.adjustToxLoss(2 * REM)
	return FALSE

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for welders. Flamable."
	reagent_state = LIQUID
	color = "#660000" // rgb: 102, 0, 0
	overdose = REAGENTS_OVERDOSE
	taste_message = "motor oil"

/datum/reagent/fuel/reaction_obj(obj/O, volume)
	var/turf/the_turf = get_turf(O)
	if(!the_turf)
		return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
	new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)

/datum/reagent/fuel/reaction_turf(turf/T, volume)
	. = ..()
	new /obj/effect/decal/cleanable/liquid_fuel(T, volume)

/datum/reagent/fuel/on_general_digest(mob/living/M)
	..()
	M.adjustToxLoss(1)

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with welding fuel to make them easy to ignite!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 10)

/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#a5f0ee" // rgb: 165, 240, 238
	overdose = REAGENTS_OVERDOSE
	taste_message = "floor cleaner"

/datum/reagent/space_cleaner/reaction_obj(obj/O, volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, volume)
	. = ..()
	if(volume >= 1)
		if(istype(T, /turf/simulated))
			var/turf/simulated/S = T
			S.dirt = 0
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T.contents)
			reaction_obj(C, volume)
			qdel(C)

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/reaction_mob(mob/M, method=TOUCH, volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.lip_style)
				H.lip_style = null
				H.update_body()
		if(C.r_hand)
			C.r_hand.clean_blood()
		if(C.l_hand)
			C.l_hand.clean_blood()
		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask()
		if(ishuman(M))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head()
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit()
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform()
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes()
			var/obj/item/organ/external/l_foot = H.bodyparts_by_name[BP_L_LEG]
			var/obj/item/organ/external/r_foot = H.bodyparts_by_name[BP_R_LEG]
			var/no_legs = FALSE
			if(!l_foot && !r_foot)
				no_legs = TRUE
			if(!no_legs)
				if(H.shoes && H.shoes.clean_blood())
					H.update_inv_shoes()
				else
					H.feet_blood_DNA = null
					H.feet_dirt_color = null
					H.update_inv_shoes()
		M.clean_blood()

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = LIQUID
	color = "#535e66" // rgb: 83, 94, 102
	taste_message = "something alien"

/datum/reagent/xenomicrobes/reaction_mob(mob/M, method=TOUCH, volume)
	src = null
	if((prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/xeno_transformation(0),1)

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = LIQUID
	color = "#9e6b38" // rgb: 158, 107, 56
	taste_message = null

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664b63" // rgb: 102, 75, 99
	taste_message = null

/datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "A highly addictive stimulant extracted from the tobacco plant."
	reagent_state = LIQUID
	color = "#181818" // rgb: 24, 24, 24
	custom_metabolism = 0.005
	restrict_species = list(IPC, DIONA)
	var/alert_time = 0

/datum/reagent/nicotine/on_mob_life(mob/living/M)
	if(!..())
		return
	if(!holder.has_reagent("alkysine"))
		if(volume >= 0.85)
			if(world.time > (alert_time + 90 SECONDS))
				to_chat(M, pick("<span class='danger'>You feel dizzy and weak</span>"))
				alert_time = world.time
			if(prob(60))
				M.adjustOxyLoss(1)
		if(volume < 0.7)
			if(prob(10))
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
		if(volume > 1)
			if(prob(80))
				M.adjustOxyLoss(1)
				M.drowsyness = min(40, (M.drowsyness + 2))
			if(prob(3) & ishuman(M))
				var/mob/living/carbon/human/H = M
				H.invoke_vomit_async()
		if(volume > 5)
			if(prob(70))
				M.adjustOxyLoss(1)
	if(holder.has_reagent("anti_toxin"))
		holder.remove_reagent("nicotine", 0.065)
	return TRUE

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_message = "floor cleaner"

/datum/reagent/ultraglue
	name = "Ultra Glue"
	id = "glue"
	description = "An extremely powerful bonding agent."
	color = "#ffffcc" // rgb: 255, 255, 204
	taste_message = null

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	reagent_state = LIQUID
	color = "#604030" // rgb: 96, 64, 48

/datum/reagent/diethylamine/on_diona_digest(mob/living/M)
	..()
	M.nutrition += 2 * REM
	return FALSE

/datum/reagent/diethylamine/reaction_mob(mob/M, method = TOUCH, volume)
	if(volume >= 1 && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/list/species_hair = list()
		if(!(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS))))
			for(var/i in hair_styles_list)
				var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
				if(i == "Bald")
					continue
				if(H.species.name in tmp_hair.species_allowed)
					species_hair += i
			if(species_hair.len)
				H.h_style = pick(species_hair)
		var/list/species_facial_hair = list()
		if(!((H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)) || (H.head && (H.head.flags & MASKCOVERSMOUTH))))
			for(var/i in facial_hair_styles_list) // In case of a not so far future.
				var/datum/sprite_accessory/hair/tmp_hair = facial_hair_styles_list[i]
				if(i == "Shaved")
					continue
				if(H.species.name in tmp_hair.species_allowed)
					species_facial_hair += i
			if(species_facial_hair.len)
				H.f_style = pick(species_facial_hair)
		H.update_hair()

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Chemlights ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/luminophore_temp //Temporary holder of vars used in mixing colors
	name = "Luminophore"
	id = "luminophore"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	nutriment_factor = 0.2
	color = "#ffffff"
	custom_metabolism = 0.2
	taste_message = "bitterness"

/datum/reagent/luminophore
	name = "Luminophore"
	id = "luminophore"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	color = "#ffffff"
	custom_metabolism = 0.2
	taste_message = "bitterness"

/datum/reagent/luminophore/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.invoke_vomit_async()
		H.apply_effect(1,IRRADIATE,0)

/////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////// Nanobots /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanites"
	description = "Microscopic construction robots."
	reagent_state = LIQUID
	color = "#535e66" // rgb: 83, 94, 102
	taste_message = "nanomachines, son"

/datum/reagent/nanites/reaction_mob(mob/M, method=TOUCH, volume)
	src = null
	if((prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/robotic_transformation(0), 1)

/datum/reagent/nanites2
	name = "Friendly Nanites"
	id = "nanites2"
	description = "Friendly microscopic construction robots."
	reagent_state = LIQUID
	color = "#535e66" //rgb: 83, 94, 102
	taste_message = "nanomachines, son"

/datum/reagent/nanobots
	name = "Nanobots"
	id = "nanobots"
	description = "Microscopic robots intended for use in humans. Must be loaded with further chemicals to be useful."
	reagent_state = LIQUID
	color = "#3e3959" //rgb: 62, 57, 89
	taste_message = "nanomachines, son"

//Great healing powers. Metabolizes extremely slowly, but gets used up when it heals damage.
//Dangerous in amounts over 5 units, healing that occurs while over 5 units adds to a counter. That counter affects gib chance. Guaranteed gib over 20 units.
/datum/reagent/mednanobots
	name = "Medical Nanobots"
	id = "mednanobots"
	description = "Microscopic robots intended for use in humans. Configured for rapid healing upon infiltration into the body."
	reagent_state = LIQUID
	color = "#593948" //rgb: 89, 57, 72
	custom_metabolism = 0.005
	var/spawning_horror = 0
	var/percent_machine = 0
	taste_message = "nanomachines, son"
	restrict_species = list(IPC, DIONA)

	data = list()

/datum/reagent/mednanobots/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		switch(volume)
			if(0 to 5)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_CHEST] // it was H.get_bodypart(????) with nothing as arg, so its always a chest?
				for(var/datum/wound/W in BP.wounds)
					BP.wounds -= W
					H.visible_message("<span class='warning'>[H]'s wounds close up in the blink of an eye!</span>")
				if(H.getOxyLoss() > 0 && prob(90))
					if(holder && holder.has_reagent(id, 0.1))
						H.adjustOxyLoss(-4)
						holder.remove_reagent(id, 0.1)  //The number/40 means that every time it heals, it uses up number/40ths of a unit, meaning each unit heals 40 damage

				if(H.getBruteLoss() > 0 && prob(90))
					if(holder && holder.has_reagent(id, 0.125))
						H.heal_bodypart_damage(5, 0)
						holder.remove_reagent(id, 0.125)

				if(H.getFireLoss() > 0 && prob(90))
					if(holder && holder.has_reagent(id, 0.125))
						H.heal_bodypart_damage(0, 5)
						holder.remove_reagent(id, 0.125)

				if(H.getToxLoss() > 0 && prob(50))
					if(holder && holder.has_reagent(id, 0.05))
						H.adjustToxLoss(-2)
						holder.remove_reagent(id, 0.05)

				if(H.getCloneLoss() > 0 && prob(60))
					if(holder && holder.has_reagent(id, 0.05))
						H.adjustCloneLoss(-2)
						holder.remove_reagent(id, 0.05)

				if(percent_machine > 5)
					if(holder && holder.has_reagent(id))
						percent_machine -= 1
						if(prob(20))
							to_chat(M, pick("You feel more like yourself again."))
				if(H.dizziness != 0)
					H.dizziness = max(0, H.dizziness - 15)
				if(H.confused != 0)
					H.confused = max(0, H.confused - 5)
				if(holder && holder.has_reagent(id))
					for(var/ID in H.virus2)
						var/datum/disease2/disease/D = H.virus2[ID]
						D.spreadtype = "Remissive"
						D.stage--
						if(D.stage < 1 && prob(data["ticks"] / 4))
							D.cure(H)
				data["ticks"]++
			if(5 to 20)		//Danger zone healing. Adds to a human mob's "percent machine" var, which is directly translated into the chance that it will turn horror each tick that the reagent is above 5u.
				var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_CHEST]
				for(var/datum/wound/W in BP.wounds)
					BP.wounds -= W
					H.visible_message("<span class='warning'>[H]'s wounds close up in the blink of an eye!</span>")
				if(H.getOxyLoss() > 0 && prob(90))
					if(holder && holder.has_reagent(id, 0.1))
						H.adjustOxyLoss(-4)
						holder.remove_reagent(id, 0.1)  //The number/40 means that every time it heals, it uses up number/40ths of a unit, meaning each unit heals 40 damage
						percent_machine += 0.5
						if(prob(20))
							to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>", "<span class='warning'>You feel different, somehow...</span>"))

				if(H.getBruteLoss() > 0 && prob(90))
					if(holder && holder.has_reagent(id, 0.125))
						H.heal_bodypart_damage(5, 0)
						holder.remove_reagent(id, 0.125)
						percent_machine += 0.5
						if(prob(20))
							to_chat(M, pick("<span class='warning'> Something shifts inside you...</span>", "<span class='warning'>You feel different, somehow...</span>"))

				if(H.getFireLoss() > 0 && prob(90))
					if(holder && holder.has_reagent(id, 0.125))
						H.heal_bodypart_damage(0, 5)
						holder.remove_reagent(id, 0.125)
						percent_machine += 0.5
						if(prob(20))
							to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>", "<span class='warning'>You feel different, somehow...</span>"))

				if(H.getToxLoss() > 0 && prob(50))
					if(holder && holder.has_reagent(id, 0.05))
						H.adjustToxLoss(-2)
						holder.remove_reagent(id, 0.05)
						percent_machine += 0.5
						if(prob(20))
							to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>", "<span class='warning'>You feel different, somehow...</span>"))

				if(H.getCloneLoss() > 0 && prob(60))
					if(holder && holder.has_reagent(id, 0.05))
						H.adjustCloneLoss(-2)
						holder.remove_reagent(id, 0.05)
						percent_machine += 0.5
						if(prob(20))
							to_chat(M, pick("<span class='warning'>Something shifts inside you...</span>", "<span class='warning'>You feel different, somehow...</span>"))

				if(H.dizziness != 0)
					H.dizziness = max(0, H.dizziness - 15)
				if(H.confused != 0)
					H.confused = max(0, H.confused - 5)
				if(holder && holder.has_reagent(id))
					for(var/ID in H.virus2)
						var/datum/disease2/disease/D = H.virus2[ID]
						D.spreadtype = "Remissive"
						D.stage--
						if(D.stage < 1 && prob(data["ticks"] / 4))
							D.cure(H)
				if(holder && prob(percent_machine))
					holder.add_reagent(id, 20)
					to_chat(M, pick("<b><span class='warning'>Your body lurches!</b></span>"))
				data["ticks"] += 2
			if(20 to INFINITY)
				spawning_horror = 1
				to_chat(M, pick("<b><span class='warning'>Something doesn't feel right...</span></b>", "<b><span class='warning'>Something is growing inside you!</span></b>", "<b><span class='warning'>You feel your insides rearrange!</span></b>"))
				spawn(60)
					if(spawning_horror)
						to_chat(M, pick( "<b><span class='warning'>Something bursts out from inside you!</span></b>"))
						message_admins("[key_name(H)] has gibbed and spawned a new cyber horror due to nanobots. (<A HREF='?_src_=holder;adminmoreinfo=\ref[H]'>?</A>) [ADMIN_JMP(H)]")
						log_game("[key_name(H)] has gibbed and spawned a new cyber horror due to nanobots")
						new /mob/living/simple_animal/hostile/cyber_horror(H.loc)
						spawning_horror = 0
						H.gib()
	else
		holder.del_reagent(id)

/datum/reagent/paint
	name = "Paint"
	id = "paint_"
	reagent_state = LIQUID
	data = list("r_color"=128,"g_color"=128,"b_color"=128)
	description = "This paint will only adhere to floor tiles."
	color = "#808080"
	color_weight = 20
	taste_message = "strong liquid colour"

/datum/reagent/paint/red
	name = "Red Paint"
	id = "paint_red"
	color = "#fe191a"
	data = list("r_color"=254,"g_color"=25,"b_color"=26)

/datum/reagent/paint/green
	name = "Green Paint"
	color = "#18a31a"
	id = "paint_green"
	data = list("r_color"=24,"g_color"=163,"b_color"=26)

/datum/reagent/paint/blue
	name = "Blue Paint"
	color = "#247cff"
	id = "paint_blue"
	data = list("r_color"=36,"g_color"=124,"b_color"=255)

/datum/reagent/paint/yellow
	name = "Yellow Paint"
	color = "#fdfe7d"
	id = "paint_yellow"
	data = list("r_color"=253,"g_color"=254,"b_color"=125)

/datum/reagent/paint/violet
	name = "Violet Paint"
	color = "#cc0099"
	id = "paint_violet"
	data = list("r_color"=253,"g_color"=254,"b_color"=125)

/datum/reagent/paint/black
	name = "Black Paint"
	color = "#333333"
	id = "paint_black"
	data = list("r_color"=51,"g_color"=51,"b_color"=51)

/datum/reagent/paint/white
	name = "White Paint"
	color = "#f0f8ff"
	id = "paint_white"
	data = list("r_color"=240,"g_color"=248,"b_color"=255)

/datum/reagent/paint/custom
	name = "Custom Paint"
	id = "paint_custom"

/datum/reagent/paint/reaction_turf(turf/T, volume)
	. = ..()
	if(!istype(T) || istype(T, /turf/space))
		return
	if(color_weight < 15 || volume < 5)
		return
	var/ind = "[initial(T.icon)]|[color]"
	if(!cached_icons[ind])
		var/icon/overlay = new/icon(T.icon)
		overlay.Blend(color, ICON_MULTIPLY)
		overlay.SetIntensity(color_weight * 0.1)
		T.icon = overlay
		cached_icons[ind] = T.icon
	else
		T.icon = cached_icons[ind]

/datum/reagent/paint/reaction_mob(mob/M, method=TOUCH, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/r_tweak = ((data["r_color"] * volume * (color_weight / 10)) / 10) // volume of 10 basically just replaces the color alltogether, a potent hair dye this is.
		var/g_tweak = ((data["g_color"] * volume * (color_weight / 10)) / 10)
		var/b_tweak = ((data["b_color"] * volume * (color_weight / 10)) / 10)
		var/volume_coefficient = max((10-volume)/10, 0)
		var/hair_changes_occured = FALSE
		var/body_changes_occured = FALSE
		if(H.client && volume >= 5 && !H.glasses)
			H.eye_blurry = max(H.eye_blurry, volume)
			H.eye_blind = max(H.eye_blind, 1)
		if(volume >= 10 && H.species.flags[HAS_SKIN_COLOR])
			if(!H.wear_suit && !H.w_uniform && !H.shoes && !H.head && !H.wear_mask) // You either paint the full body, or beard/hair
				H.r_skin = clamp(round(H.r_skin * max((100 - volume)/100, 0) + r_tweak * 0.1), 0, 255) // Full body painting is costly! Hence, *0.1
				H.g_skin = clamp(round(H.g_skin * max((100 - volume)/100, 0) + g_tweak * 0.1), 0, 255)
				H.b_skin = clamp(round(H.b_skin * max((100 - volume)/100, 0) + b_tweak * 0.1), 0, 255)
				H.dyed_r_hair = clamp(round(H.dyed_r_hair * max((100 - volume)/100, 0) + r_tweak * 0.1), 0, 255) // If you're painting full body, all the painting is costly.
				H.dyed_g_hair = clamp(round(H.dyed_g_hair * max((100 - volume)/100, 0) + g_tweak * 0.1), 0, 255)
				H.dyed_b_hair = clamp(round(H.dyed_b_hair * max((100 - volume)/100, 0) + b_tweak * 0.1), 0, 255)
				H.hair_painted = TRUE
				H.dyed_r_facial = clamp(round(H.dyed_r_facial * max((100 - volume)/100, 0) + r_tweak * 0.1), 0, 255)
				H.dyed_g_facial = clamp(round(H.dyed_g_facial * max((100 - volume)/100, 0) + g_tweak * 0.1), 0, 255)
				H.dyed_b_facial = clamp(round(H.dyed_b_facial * max((100 - volume)/100, 0) + b_tweak * 0.1), 0, 255)
				H.facial_painted = TRUE
				hair_changes_occured = TRUE
				body_changes_occured = TRUE
		else if(H.species && (H.species.name in list(HUMAN, UNATHI, TAJARAN)))
			if(!(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS))) && H.h_style != "Bald")
				if(!H.hair_painted)
					H.dyed_r_hair = clamp(round(H.r_hair * volume_coefficient + r_tweak), 0, 255)
					H.dyed_g_hair = clamp(round(H.g_hair * volume_coefficient + g_tweak), 0, 255)
					H.dyed_b_hair = clamp(round(H.b_hair * volume_coefficient + b_tweak), 0, 255)
					H.hair_painted = TRUE
				else
					H.dyed_r_hair = clamp(round(H.dyed_r_hair * volume_coefficient + r_tweak), 0, 255)
					H.dyed_g_hair = clamp(round(H.dyed_g_hair * volume_coefficient + g_tweak), 0, 255)
					H.dyed_b_hair = clamp(round(H.dyed_b_hair * volume_coefficient + b_tweak), 0, 255)
				hair_changes_occured = TRUE
			if(!((H.wear_mask && (H.wear_mask.flags & HEADCOVERSMOUTH)) || (H.head && (H.head.flags & HEADCOVERSMOUTH))) && H.f_style != "Shaved")
				if(!H.facial_painted)
					H.dyed_r_facial = clamp(round(H.r_facial * volume_coefficient + r_tweak), 0, 255)
					H.dyed_g_facial = clamp(round(H.g_facial * volume_coefficient + g_tweak), 0, 255)
					H.dyed_b_facial = clamp(round(H.b_facial * volume_coefficient + b_tweak), 0, 255)
					H.facial_painted = TRUE
				else
					H.dyed_r_facial = clamp(round(H.dyed_r_facial * volume_coefficient + r_tweak), 0, 255)
					H.dyed_g_facial = clamp(round(H.dyed_g_facial * volume_coefficient + g_tweak), 0, 255)
					H.dyed_b_facial = clamp(round(H.dyed_b_facial * volume_coefficient + b_tweak), 0, 255)
				hair_changes_occured = TRUE
		if(!H.head && !H.wear_mask && H.h_style == "Bald" && H.f_style == "Shaved" && volume >= 5)
			H.lip_style = "spray_face"
			H.lip_color = color
			hair_changes_occured = TRUE
			body_changes_occured = TRUE
		if(hair_changes_occured)
			H.update_hair()
		if(body_changes_occured)
			H.update_body()

/datum/reagent/paint/reaction_obj(obj/O, volume)
	if(istype(O, /obj/machinery/camera))
		var/obj/machinery/camera/C = O
		if(!C.painted)
			if(!C.isXRay())
				var/paint_time = min(volume * 1 SECOND, 10 SECONDS)
				addtimer(CALLBACK(C, /obj/machinery/camera/proc/remove_paint_state, C.network), paint_time) // EMP turns it off for 90 SECONDS, 10 seems fair.
				C.disconnect_viewers()
				C.painted = TRUE
				C.toggle_cam(FALSE) // Do not show deactivation message, it's just paint.
				C.triggerCameraAlarm()
			C.color = color

/datum/reagent/paint_remover
	name = "Paint Remover"
	id = "paint_remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = 2
	color = "#808080"

/datum/reagent/paint_remover/reaction_mob(mob/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/changes_occured = FALSE
			if(H.hair_painted && !(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS))) && H.h_style != "Bald")
				H.dyed_r_hair = H.r_hair
				H.dyed_g_hair = H.g_hair
				H.dyed_b_hair = H.b_hair
				H.hair_painted = FALSE
				changes_occured = TRUE
			if(H.facial_painted && !((H.wear_mask && (H.wear_mask.flags & HEADCOVERSMOUTH)) || (H.head && (H.head.flags & HEADCOVERSMOUTH))) && H.f_style != "Shaved")
				H.dyed_r_facial = H.r_facial
				H.dyed_g_facial = H.g_facial
				H.dyed_b_facial = H.b_facial
				H.facial_painted = FALSE
				changes_occured = TRUE
			if(changes_occured)
				H.update_hair()

/datum/reagent/paint_remover/reaction_turf(turf/T, volume)
	. = ..()
	if(istype(T) && T.icon != initial(T.icon))
		T.icon = initial(T.icon)

/datum/reagent/paint_remover/reaction_obj(obj/O, volume)
	if(istype(O, /obj/machinery/camera))
		var/obj/machinery/camera/C = O
		if(C.painted)
			C.remove_paint_state()
			C.color = null

////////////////////////////////////
///// All the barber's bullshit/////
////////////////////////////////////
/datum/reagent/paint/hair_dye
	name = "Hair Dye"
	id = "whitehairdye"
	description = "A compound used to dye hair. Any hair."
	data = list("r_color"=255,"g_color"=255,"b_color"=255)
	reagent_state = LIQUID
	color = "#ffffff" // to see rgb just look into data!
	color_weight = 10
	taste_message = "liquid colour"

/*
TODO: Convert everything to custom hair dye. ~ Luduk.
*/

/datum/reagent/paint/hair_dye/red
	name = "Red Hair Dye"
	id = "redhairdye"
	data = list("r_color"=255,"g_color"=0,"b_color"=0)
	color = "#ff0000"

/datum/reagent/paint/hair_dye/green
	name = "Green Hair Dye"
	id = "greenhairdye"
	data = list("r_color"=0,"g_color"=255,"b_color"=0)
	color = "#00ff00"

/datum/reagent/paint/hair_dye/blue
	name = "Blue Hair Dye"
	id = "bluehairdye"
	data = list("r_color"=0,"g_color"=0,"b_color"=255)
	color = "#0000ff"

/datum/reagent/paint/hair_dye/black
	name = "Black Hair Dye"
	id = "blackhairdye"
	data = list("r_color"=0,"g_color"=0,"b_color"=0)
	color = "#000000"

/datum/reagent/paint/hair_dye/brown
	name = "Brown Hair Dye"
	id = "brownhairdye"
	data = list("r_color"=50,"g_color"=0,"b_color"=0)
	color = "#500000"

/datum/reagent/paint/hair_dye/blond
	name = "Blond Hair Dye"
	id = "blondhairdye"
	data = list("r_color"=255,"g_color"=225,"b_color"=135)
	color = "#ffe187"

/datum/reagent/paint/hair_dye/custom
	name = "Custom Hair Dye"
	id = "customhairdye"

/datum/reagent/hair_growth_accelerator
	name = "Hair Growth Accelerator"
	id = "hair_growth_accelerator"
	data = list("bald_head_list"=list("Bald", "Balding Hair", "Skinhead", "Unathi Horns", "Tajaran Ears"),"shaved_face_list"=list("Shaved"),"allowed_races"=list(HUMAN, UNATHI, TAJARAN))
	description = "A substance for the bald. Renews hair. Apply to head or groin."
	reagent_state = LIQUID
	color = "#efc769" // rgb: 239, 199, 105
	taste_message = "hairs inside me"

/datum/reagent/hair_growth_accelerator/reaction_mob(mob/M, method = TOUCH, volume)
	if(volume >= 1 && ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name in data["allowed_races"])
			if(!(H.head && ((H.head.flags & BLOCKHAIR) || (H.head.flags & HIDEEARS))))
				var/list/species_hair = list()
				if(H.species)
					for(var/i in hair_styles_list)
						var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
						if(i in data["bald_hair_styles_list"])
							continue
						if(H.species.name in tmp_hair.species_allowed)
							species_hair += i
				else
					species_hair = hair_styles_list

				if(species_hair.len)
					H.h_style = pick(species_hair)

			if(!((H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)) || (H.head && (H.head.flags & MASKCOVERSMOUTH))))
				var/list/species_facial_hair = list()
				if(H.species)
					for(var/i in facial_hair_styles_list)
						var/datum/sprite_accessory/hair/tmp_hair = facial_hair_styles_list[i]
						if(i in data["shaved_facial_hair_styles_list"])
							continue
						if(H.species.name in tmp_hair.species_allowed)
							species_facial_hair += i
				else
					species_facial_hair = facial_hair_styles_list

				if(species_facial_hair.len)
					H.f_style = pick(species_facial_hair)
			H.update_hair()

/datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = "ectoplasm"
	description = "A spooky scary substance to explain ghosts and stuff."
	reagent_state = LIQUID
	taste_message = "spooky ghosts"
	color = "#ffa8e4" // rgb: 255, 168, 228

	data = list()

	needed_aspects = list(ASPECT_MYSTIC = 1)

/datum/reagent/ectoplasm/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	M.hallucination += 1
	M.make_jittery(2)
	switch(data["ticks"])
		if(1 to 15)
			M.make_jittery(2)
			M.hallucination = max(M.hallucination, 3)
			if(prob(1))
				to_chat(src, "<span class='warning'>You see... [pick(nightmares)] ...</span>")
				M.Sleeping(10) // Seeing ghosts ain't an easy thing for your mind.
		if(15 to 45)
			M.make_jittery(4)
			M.druggy = max(M.druggy, 15)
			M.hallucination = max(M.hallucination, 10)
			if(prob(5))
				to_chat(src, "<span class='warning'>You see... [pick(nightmares)] ...</span>")
				M.Sleeping(10)
		if(45 to 90)
			M.make_jittery(8)
			M.druggy = max(M.druggy, 30)
			M.hallucination = max(M.hallucination, 60)
			if(prob(10))
				to_chat(src, "<span class='warning'>You see... [pick(nightmares)] ...</span>")
				M.Sleeping(10)
		if(90 to 180)
			M.make_jittery(8)
			M.druggy = max(M.druggy, 35)
			M.hallucination = max(M.hallucination, 60)
			if(prob(10))
				to_chat(src, "<span class='warning'>You see... [pick(nightmares)] ...</span>")
				M.Sleeping(10)
			if(prob(5))
				M.adjustBrainLoss(5)
		if(180 to INFINITY)
			M.adjustBrainLoss(100)
	data["ticks"]++

/datum/reagent/aqueous_foam
	name = "Aqueous Film Forming Foam"
	id = "aqueous_foam"
	description = "Smothers the fire and seals in the flammable vapours."
	reagent_state = LIQUID
	taste_message = "fire repellant"
	color = "#c2eaed" // rgb: 194, 234, 237

/datum/reagent/aqueous_foam/reaction_turf(turf/T, method=TOUCH, volume)
	. = ..()
	var/obj/effect/effect/aqueous_foam/F = locate(/obj/effect/effect/aqueous_foam) in T
	if(F)
		INVOKE_ASYNC(F, /obj/effect/effect/aqueous_foam.proc/performAction) // So we don't instantinate a new object, but still make the room slightly colder.
	else if(!T.density)
		new /obj/effect/effect/aqueous_foam(T)

/datum/reagent/aqueous_foam/on_slime_digest(mob/living/M)
	..()
	M.adjustToxLoss(REM)
	return FALSE
