/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	custom_metabolism = FOOD_METABOLISM
	nutriment_factor = 1
	taste_message = null
	var/last_volume = 0 // Check digestion code below.

	data = list()

/datum/reagent/consumable/on_general_digest(mob/living/M)
	..()
	var/mob_met_factor = 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		mob_met_factor = C.get_metabolism_factor() * 0.25
	if(volume > last_volume)
		var/to_add = rand(0, volume - last_volume) * nutriment_factor * custom_metabolism * mob_met_factor
		M.reagents.add_reagent("nutriment", ((volume - last_volume) * nutriment_factor * custom_metabolism * mob_met_factor) - to_add)
		if(diet_flags & DIET_ALL)
			M.reagents.add_reagent("nutriment", to_add)
		else if(diet_flags & DIET_MEAT)
			M.reagents.add_reagent("protein", to_add)
		else if(diet_flags & DIET_PLANT)
			M.reagents.add_reagent("plantmatter", to_add)
		else if(diet_flags & DIET_DAIRY)
			M.reagents.add_reagent("dairy", to_add)
		last_volume = volume
	return TRUE

/datum/reagent/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 8 // 1 nutriment reagent is 10 nutrition actually, which is confusing, but it works.
	custom_metabolism = FOOD_METABOLISM * 2 // It's balanced so you gain the nutrition, but slightly faster.
	color = "#664330" // rgb: 102, 67, 48
	taste_message = "bland food"

/datum/reagent/nutriment/on_general_digest(mob/living/M)
	..()
	if(istype(M))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.can_eat(diet_flags))
				C.nutrition += nutriment_factor
				if(prob(50))
					C.adjustBruteLoss(-1)
		else
			M.nutrition += nutriment_factor
	return TRUE

/datum/reagent/nutriment/protein // Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Protein"
	id = "protein"
	description = "Various essential proteins and fats commonly found in animal flesh and blood."
	diet_flags = DIET_MEAT
	taste_message = "meat"

/datum/reagent/nutriment/protein/on_skrell_digest(mob/living/M)
	..()
	M.adjustToxLoss(2 * FOOD_METABOLISM)
	return FALSE

/datum/reagent/nutriment/plantmatter // Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Plant-matter"
	id = "plantmatter"
	description = "Vitamin-rich fibers and natural sugars commonly found in fresh produce."
	diet_flags = DIET_PLANT
	taste_message = "plant matter"

/datum/reagent/nutriment/dairy // Milk-based biomatter.
	name = "dairy"
	id = "dairy"
	description = "A tasty substance that comes out of cows who eat lotsa grass"
	diet_flags = DIET_DAIRY
	taste_message = "dairy"

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = "#ff00ff" // rgb: 255, 0, 255
	taste_message = "sweetness"

/datum/reagent/consumable/sprinkles/on_general_digest(mob/living/M)
	..()
	if(ishuman(M) && (M.job in list("Security Officer", "Head of Security", "Detective", "Warden", "Captain")))
		M.heal_bodypart_damage(1, 1)

/datum/reagent/consumable/syndicream
	name = "Cream filling"
	id = "syndicream"
	description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
	color = "#ab7878" // rgb: 171, 120, 120

/datum/reagent/consumable/syndicream/on_general_digest(mob/living/M)
	..()
	if(ishuman(M) && M.mind && M.mind.special_role)
		M.heal_bodypart_damage(1, 1)

/datum/reagent/nutriment/dairy/on_skrell_digest(mob/living/M) // Is not as poisonous to skrell.
	..()
	M.adjustToxLoss(1 * FOOD_METABOLISM)
	return FALSE

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_message = "salt"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_message = "ketchup"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/flour
	name = "Flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#f5eaea" // rgb: 245, 234, 234
	taste_message = "flour"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 179, 16, 8
	taste_message = "<span class='warning'>HOTNESS</span>"

/datum/reagent/consumable/capsaicin/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	switch(data["ticks"])
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
	data["ticks"]++

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "A chemical agent used for self-defense and in police work."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 179, 16, 8
	taste_message = "<span class='userdanger'>PURE FIRE</span>"

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(!isliving(M))
		return
	var/datum/species/S = all_species[M.get_species()]
	if(S && S.flags[NO_PAIN])
		return
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if(victim.wear_mask)
				if (victim.wear_mask.flags & MASKCOVERSEYES)
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if (victim.wear_mask.flags & MASKCOVERSMOUTH)
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if(victim.head)
				if (victim.head.flags & MASKCOVERSEYES)
					eyes_covered = 1
					safe_thing = victim.head
				if (victim.head.flags & MASKCOVERSMOUTH)
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if (!safe_thing)
					safe_thing = victim.glasses
			if (eyes_covered && mouth_covered)
				to_chat(victim, "<span class='userdanger'>Your [safe_thing] protects you from the pepperspray!</span>")
				return
			else if (mouth_covered)	// Reduced effects if partially protected
				to_chat(victim, "<span class='userdanger'> Your [safe_thing] protect you from most of the pepperspray!</span>")
				victim.eye_blurry = max(M.eye_blurry, 15)
				victim.eye_blind = max(M.eye_blind, 5)
				victim.Stun(5)
				victim.Weaken(5)
				return
			else if (eyes_covered) // Eye cover is better than mouth cover
				to_chat(victim, "<span class='userdanger'> Your [safe_thing] protects your eyes from the pepperspray!</span>")
				victim.emote("scream")
				victim.eye_blurry = max(M.eye_blurry, 5)
				return
			else // Oh dear :D
				victim.emote("scream")
				to_chat(victim, "<span class='userdanger'> You're sprayed directly in the eyes with pepperspray!</span>")
				victim.eye_blurry = max(M.eye_blurry, 25)
				victim.eye_blind = max(M.eye_blind, 10)
				victim.Stun(5)
				victim.Weaken(5)

/datum/reagent/consumable/condensedcapsaicin/on_general_digest(mob/living/M)
	..()
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extracted from Ice Peppers."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 139, 166, 233
	taste_message = "<font color='lightblue'>cold</font>"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/frostoil/on_general_digest(mob/living/M)
	..()
	M.bodytemperature = max(M.bodytemperature - 10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0)
	if(prob(1))
		M.emote("shiver")
	if(isslime(M))
		M.bodytemperature = max(M.bodytemperature - rand(10,20), 0)
	holder.remove_reagent("capsaicin", 5)
	holder.remove_reagent(src.id, FOOD_METABOLISM)

/datum/reagent/consumable/frostoil/reaction_turf(turf/simulated/T, volume)
	. = ..()
	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15,30))

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#ffffff" // rgb: 255,255,255
	overdose = REAGENTS_OVERDOSE
	taste_message = "salt"

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)
	taste_message = "pepper"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 10
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "cocoa"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#403010" // rgb: 64, 48, 16
	taste_message = "chocolate"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/hot_coco/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < BODYTEMP_NORMAL)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#e700e7" // rgb: 231, 0, 231
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = FOOD_METABOLISM * 0.5
	restrict_species = list(IPC, DIONA)

/datum/reagent/consumable/psilocybin/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 30)
	if(!data["ticks"])
		data["ticks"] = 1
	switch(data["ticks"])
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_dizzy(5)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_jittery(10)
			M.make_dizzy(10)
			M.druggy = max(M.druggy, 35)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_jittery(20)
			M.make_dizzy(20)
			M.druggy = max(M.druggy, 40)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	data["ticks"]++

/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 40
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "oil"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/cornoil/reaction_turf(var/turf/simulated/T, var/volume)
	. = ..()
	if (!istype(T))
		return
	if(volume >= 3)
		T.make_wet_floor(WATER_FLOOR)
	var/hotspot = (locate(/obj/fire) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T:air:total_moles)
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = LIQUID
	color = "#365e30" // rgb: 54, 94, 48
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, couple tiny vegetables, and chicken flavored chemicals that boil in contact with water."
	reagent_state = SOLID
	nutriment_factor = 2
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "dry ramen coated with what might just be your tears"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "ramen"

/datum/reagent/consumable/hot_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/hell_ramen
	name = "Spicy Ramen"
	id = "hell_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, couple tiny vegetables, and spicy flavored chemicals that boil in contact with water."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "dry ramen with SPICY flavor"

/datum/reagent/consumable/hell_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL + 40) // Not Tajaran friendly food (by the time of writing this, Tajaran has 330 heat limit, while this is 350 and human 360.
		M.bodytemperature = min(BODYTEMP_NORMAL + 40, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/hot_hell_ramen
	name = "Hot Spicy Ramen"
	id = "hot_hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "SPICY ramen"

/datum/reagent/consumable/hot_hell_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL + 40)
		M.bodytemperature = min(BODYTEMP_NORMAL + 40, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	reagent_state = SOLID
	nutriment_factor = 8
	color = "#ffffff" // rgb: 0, 0, 0
	taste_message = "rice"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 8
	color = "#801e28" // rgb: 128, 30, 40
	taste_message = "cherry jelly"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/egg
	name = "Egg"
	id = "egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#f0c814"
	taste_message = "eggs"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/cheese
	name = "Cheese"
	id = "cheese"
	description = "Some cheese. Pour it out to make it solid."
	reagent_state = SOLID
	nutriment_factor = 4
	color = "#ffff00"
	taste_message = "cheese"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/beans
	name = "Refried beans"
	id = "beans"
	description = "A dish made of mashed beans cooked with lard."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#684435"
	taste_message = "burritos"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/bread
	name = "Bread"
	id = "bread"
	description = "Bread! Yep, bread."
	reagent_state = SOLID
	nutriment_factor = 4
	color = "#9c5013"
	taste_message = "bread"
	diet_flags = DIET_PLANT
