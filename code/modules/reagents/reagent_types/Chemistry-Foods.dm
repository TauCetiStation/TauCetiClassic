/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	taste_message = null

/datum/reagent/consumable/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.can_eat(diet_flags))	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
			H.nutrition += nutriment_factor	// For hunger and fatness
	return TRUE

/datum/reagent/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	taste_message = "bland food"

/datum/reagent/nutriment/on_general_digest(mob/living/M)
	..()
	if(istype(M))
		M.nutrition += nutriment_factor
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.can_eat(diet_flags))
				if(prob(50))
					M.adjustBruteLoss(-1)

/*
				// If overeaten - vomit and fall down
				// Makes you feel bad but removes reagents and some effect
				// from your body
				if (M.nutrition > 650)
					M.nutrition = rand (250, 400)
					M.weakened += rand(2, 10)
					M.jitteriness += rand(0, 5)
					M.dizziness = max (0, (M.dizziness - rand(0, 15)))
					M.druggy = max (0, (M.druggy - rand(0, 15)))
					M.adjustToxLoss(rand(-15, -5)))
					M.updatehealth()
*/

/datum/reagent/nutriment/protein // Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Protein"
	id = "protein"
	description = "Various essential proteins and fats commonly found in animal flesh and blood."
	diet_flags = DIET_CARN | DIET_OMNI
	taste_message = "meat"

/datum/reagent/nutriment/protein/on_skrell_digest(mob/living/M, alien)
	..()
	M.adjustToxLoss(2 * REM)
	return FALSE

/datum/reagent/consumable/nutriment/plantmatter // Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Plant-matter"
	id = "plantmatter"
	description = "Vitamin-rich fibers and natural sugars commonly found in fresh produce."
	diet_flags = DIET_HERB | DIET_OMNI
	taste_message = "plant matter"

/datum/reagent/consumable/vitamin //Helps to regen blood and hunger
	name = "Vitamin"
	id = "vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	color = "#664330" // rgb: 102, 67, 48
	taste_message = null

/datum/reagent/consumable/vitamin/on_general_digest(mob/living/M)
	..()
	if(prob(50))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	/*if(M.nutrition < NUTRITION_LEVEL_WELL_FED) //we are making him WELL FED
		M.nutrition += 30*/  //will remain commented until we can deal with fat
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/blood_volume = H.vessel.get_reagent_amount("blood")
		if(!(NO_BLOOD in H.species.flags))//do not restore blood on things with no blood by nature.
			if(blood_volume < BLOOD_VOLUME_NORMAL && blood_volume)
				var/datum/reagent/blood/B = locate() in H.vessel.reagent_list
				B.volume += 0.5

/datum/reagent/consumable/lipozine
	name = "Lipozine" // The anti-nutriment.
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#BBEDA4" // rgb: 187, 237, 164
	overdose = REAGENTS_OVERDOSE

/datum/reagent/consumable/lipozine/on_general_digest(mob/living/M)
	..()
	M.nutrition = max(M.nutrition - nutriment_factor, 0)
	M.overeatduration = 0

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0
	taste_message = "salt"

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8
	taste_message = "ketchup"

/datum/reagent/consumable/flour
	name = "Flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#F5EAEA" // rgb: 245, 234, 234
	taste_message = "flour"

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	custom_metabolism = FOOD_METABOLISM
	taste_message = "<span class='warning'>HOTNESS</span>"

/datum/reagent/consumable/capsaicin/on_general_digest(mob/living/M)
	..()
	if(!data)
		data = 1
	switch(data)
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
	data++

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "A chemical agent used for self-defense and in police work."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_message = "<span class='userdanger'>PURE FIRE</span>"

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(!isliving(M))
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
				victim.emote("scream",,, 1)
				victim.eye_blurry = max(M.eye_blurry, 5)
				return
			else // Oh dear :D
				victim.emote("scream",,, 1)
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
	color = "#B31008" // rgb: 139, 166, 233
	custom_metabolism = FOOD_METABOLISM
	taste_message = "<font color='lightblue'>cold</span>"

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
	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15,30))

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	overdose = REAGENTS_OVERDOSE
	taste_message = "salt"

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)
	taste_message = "pepper"

/datum/reagent/consumable/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "cocoa"

/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	taste_message = "chocolate"

/datum/reagent/consumable/hot_coco/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < BODYTEMP_NORMAL)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	overdose = REAGENTS_OVERDOSE
	custom_metabolism = FOOD_METABOLISM * 0.5
	restrict_species = list(IPC, DIONA)

/datum/reagent/consumable/psilocybin/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 30)
	if(!data)
		data = 1
	switch(data)
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
	data++

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_message = "sweetness"

/*/datum/reagent/consumable/sprinkles/on_general_digest(mob/living/M)
	..()
	if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden")) //if we want some FUN and FEATURES we should uncomment it
		if(!M) M = holder.my_atom
		M.heal_bodypart_damage(1, 1)
		M.nutrition += nutriment_factor
		..()
		return
	*/

/*//removed because of meta bullshit. this is why we can't have nice things.
/datum/reagent/consumable/syndicream
	name = "Cream filling"
	id = "syndicream"
	description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#AB7878" // rgb: 171, 120, 120

	on_general_digest(var/mob/living/M as mob)
		M.nutrition += nutriment_factor
		if(istype(M, /mob/living/carbon/human) && M.mind)
		if(M.mind.special_role)
			if(!M) M = holder.my_atom
				M.heal_bodypart_damage(1, 1)
				M.nutrition += nutriment_factor
				..()
				return
		..()
*/
/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 40 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "oil"

/datum/reagent/consumable/cornoil/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
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
	color = "#365E30" // rgb: 54, 94, 48
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "dry ramen coated with what might just be your tears"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "ramen"

/datum/reagent/consumable/hot_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "SPICY ramen"

/datum/reagent/consumable/hell_ramen/on_general_digest(mob/living/M)
	..()
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT

/datum/reagent/consumable/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	reagent_state = SOLID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_message = "rice"

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#801E28" // rgb: 128, 30, 40
	taste_message = "cherry jelly"

/datum/reagent/consumable/egg
	name = "Egg"
	id = "egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	reagent_state = LIQUID
	color = "#F0C814"
	taste_message = "eggs"

/datum/reagent/consumable/egg/on_skrell_digest(mob/living/M)
	..()
	M.adjustToxLoss(2 * REM)
	return FALSE

/datum/reagent/consumable/cheese
	name = "Cheese"
	id = "cheese"
	description = "Some cheese. Pour it out to make it solid."
	reagent_state = SOLID
	color = "#FFFF00"
	taste_message = "cheese"

/datum/reagent/consumable/beans
	name = "Refried beans"
	id = "beans"
	description = "A dish made of mashed beans cooked with lard."
	reagent_state = LIQUID
	color = "#684435"
	taste_message = "burritos"

/datum/reagent/consumable/bread
	name = "Bread"
	id = "bread"
	description = "Bread! Yep, bread."
	reagent_state = SOLID
	color = "#9C5013"
	taste_message = "bread"