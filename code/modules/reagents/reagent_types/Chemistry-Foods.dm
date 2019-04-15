/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	custom_metabolism = FOOD_METABOLISM
	nutriment_factor = 1
	taste_message = null
	var/last_volume = 0 // Check digestion code below.

/datum/reagent/consumable/on_general_digest(mob/living/M)
	..()
	var/mob_met_factor = 1
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		mob_met_factor = C.get_metabolism_factor()
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
	nutriment_factor = 2 // 1 nutriment reagent is 2.5 nutrition actually, which is confusing, but it works.
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
	taste_message = "crunchy sweetness"

/datum/reagent/consumable/sprinkles/on_general_digest(mob/living/M)
	..()
	if(ishuman(M) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden", "Captain"))
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
	color = "#b31008" // rgb: 179, 16, 8
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
	for(var/mob/living/carbon/slime/M in T)
		M.adjustToxLoss(rand(15,30))

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#ffffff" // rgb: 255,255,255
	overdose = REAGENTS_OVERDOSE
	taste_strength = 2
	taste_message = "salt"

/datum/reagent/consumable/sodiumchloride/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(70))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

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

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	id = "vanilla"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 10
	color = "#FFFACD"
	taste_message = "bitter vanilla"

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
	color = "#365e30" // rgb: 54, 94, 48
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	nutriment_factor = 2
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "dry ramen coated with what might just be your tears"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5
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
	nutriment_factor = 5
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
	nutriment_factor = 2
	color = "#ffffff" // rgb: 0, 0, 0
	taste_message = "rice"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#801e28" // rgb: 128, 30, 40
	taste_message = "cherry jelly"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	id = "bluecherryjelly"
	description = "Blue and tastier kind of cherry jelly."
	reagent_state = LIQUID
	color = "#00F0FF"
	taste_message = "the blues"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/egg
	name = "Egg"
	id = "egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	reagent_state = LIQUID
	color = "#f0c814"
	taste_message = "eggs"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/egg/on_general_digest(mob/living/M)
	..()
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	id = "corn_starch"
	description = "The powdered starch of maize, derived from the kernel's endosperm. Used as a thickener for gravies and puddings."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_message = "flour"

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "A sweet syrup derived from corn starch that has had its starches converted into maltose and other sugars."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_message = "cheap sugar substitute"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/M)
	..()
	M.reagents.add_reagent("sugar", 1.2)

/datum/reagent/consumable/vhfcs
	name = "Very-high-fructose corn syrup"
	id = "vhfcs"
	description = "An incredibly sweet syrup, created from corn syrup treated with enzymes to convert its sugars into fructose."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_message = "diabetes"

/datum/reagent/consumable/vhfcs/on_mob_life(mob/living/M)
	..()
	M.reagents.add_reagent("sugar", 1.2)

/datum/reagent/consumable/honey
	name = "Honey"
	id = "honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	reagent_state = LIQUID
	color = "#ffff00"
	nutriment_factor = 15
	taste_message = "honey sweetness"

/datum/reagent/consumable/honey/on_mob_life(mob/living/M)
	..()
	M.reagents.add_reagent("sugar", 3)
	if(prob(20))
		M.heal_bodypart_damage(1, 1)

/datum/reagent/consumable/onion
	name = "Concentrated Onion Juice"
	id = "onionjuice"
	description = "A strong tasting substance that can induce partial blindness."
	color = "#c0c9a0"
	taste_message = "pungency"

/datum/reagent/consumable/onion/reaction_mob(mob/living/M, method = TOUCH, volume)
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
			if(!mouth_covered && !eyes_covered)
				to_chat(M, "<span class = 'notice'>Your eye sockets feel wet.</span>")
			else
				if(!M.eye_blurry)
					to_chat(M, "<span class = 'warning'>Tears well up in your eyes!</span>")
				victim.eye_blind = max(M.eye_blind, 2)
				victim.eye_blurry = max(M.eye_blurry, 5)
	..()


/datum/reagent/consumable/chocolate
	name = "Chocolate"
	id = "chocolate"
	description = "Chocolate is a delightful product derived from the seeds of the theobroma cacao tree."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#2E2418"
	taste_message = "chocolate"

/datum/reagent/consumable/chocolate/on_mob_life(mob/living/M)
	..()
	M.reagents.add_reagent("sugar", 1)

/datum/reagent/consumable/porktonium
	name = "Porktonium"
	id = "porktonium"
	description = "A highly-radioactive pork byproduct first discovered in hotdogs."
	reagent_state = LIQUID
	color = "#AB5D5D"
	custom_metabolism = 0.2
	overdose = 90
	taste_message = "bacon"

/datum/reagent/consumable/porktonium/overdose_process(mob/living/M, severity)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("radium", 15)
		M.reagents.add_reagent("cyanide", 10)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/chicken_soup
	name = "Chicken soup"
	id = "chicken_soup"
	description = "An old household remedy for mild illnesses."
	reagent_state = LIQUID
	color = "#B4B400"
	custom_metabolism = 0.2
	nutriment_factor = 5
	taste_message = "broth"

/datum/reagent/consumable/cheese
	name = "Cheese"
	id = "cheese"
	description = "Some cheese. Pour it out to make it solid."
	reagent_state = SOLID
	color = "#ffff00"
	taste_message = "cheese"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/cheese/on_mob_life(mob/living/M)
	..()
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))

/datum/reagent/consumable/fake_cheese
	name = "Cheese substitute"
	id = "fake_cheese"
	description = "A cheese-like substance derived loosely from actual cheese."
	reagent_state = LIQUID
	color = "#B2B139"
	overdose = 50
	taste_message = "cheese?"

/datum/reagent/consumable/fake_cheese/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(8))
		to_chat(M, "<span class='warning'>You feel something squirming in your stomach. Your thoughts turn to cheese and you begin to sweat.</span>")
		update_flags |= M.adjustToxLoss(rand(1,2), FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	description = "Hell, I don't even know if this IS cheese. Whatever it is, it ain't normal. If you want to, pour it out to make it solid."
	reagent_state = SOLID
	color = "#50FF00"
	addiction_chance = 5
	taste_message = "cheeeeeese...?"

/datum/reagent/consumable/weird_cheese/on_mob_life(mob/living/M)
	..()
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))


datum/reagent/consumable/beans
	name = "Refried beans"
	id = "beans"
	description = "A dish made of mashed beans cooked with lard."
	reagent_state = LIQUID
	color = "#684435"
	taste_message = "burritos"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/bread
	name = "Bread"
	id = "bread"
	description = "Bread! Yep, bread."
	reagent_state = SOLID
	color = "#9c5013"
	taste_message = "bread"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/soybeanoil
	name = "Space-soybean oil"
	id = "soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans."
	reagent_state = LIQUID
	color = "#B1B0B0"
	taste_message = "oil"

/datum/reagent/consumable/soybeanoil/on_mob_life(mob/living/M)
	..()
	if(prob(10))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)

/datum/reagent/consumable/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans, with additional hydrogen atoms added to convert it into a saturated form."
	reagent_state = LIQUID
	color = "#B1B0B0"
	custom_metabolism = 0.2
	overdose = 50
	taste_message = "oil"

/datum/reagent/consumable/hydrogenated_soybeanoil/on_mob_life(mob/living/M)
	..()
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	if(volume >= 75)
		custom_metabolism = 0.4
	else
		custom_metabolism = 0.2


/datum/reagent/consumable/hydrogenated_soybeanoil/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		to_chat(M, "<span class='warning'>You feel horribly weak.</span>")
	if(prob(10))
		to_chat(M, "<span class='warning'>You cannot breathe!</span>")
		update_flags |= M.adjustOxyLoss(5, FALSE)
	if(prob(5))
		to_chat(M, "<span class='warning'>You feel a sharp pain in your chest!</span>")
		update_flags |= M.adjustOxyLoss(25, FALSE)
		update_flags |= M.Stun(5, FALSE)
		update_flags |= M.Paralyse(10, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	description = "A paste comprised of highly-processed organic material. Uncomfortably similar to deviled ham spread."
	reagent_state = LIQUID
	color = "#EBD7D7"
	taste_message = "meat?"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/meatslurry/on_mob_life(mob/living/M)
	..()
	if(prob(4))
		M.reagents.add_reagent("cholesterol", rand(1,3))

/datum/reagent/consumable/mashedpotatoes
	name = "Mashed potatoes"
	id = "mashedpotatoes"
	description = "A starchy food paste made from boiled potatoes."
	reagent_state = SOLID
	color = "#D6D9C1"
	taste_message = "potatoes"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/gravy
	name = "Gravy"
	id = "gravy"
	description = "A savory sauce made from a simple meat-dripping roux and milk."
	reagent_state = LIQUID
	color = "#B4641B"
	taste_message = "gravy"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/beff
	name = "Beff"
	id = "beff"
	description = "An advanced blend of mechanically-recovered meat and textured synthesized protein product notable for its unusual crystalline grain when sliced."
	reagent_state = SOLID
	color = "#AC7E67"
	taste_message = "meat"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/beff/on_mob_life(mob/living/M)
	..()
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent(pick("blood", "corn_syrup", "synthflesh", "hydrogenated_soybeanoil", "porktonium", "toxic_slurry"), 0.8)
	else if(prob(6))
		to_chat(M, "<span class='warning'>[pick("You feel ill.","Your stomach churns.","You feel queasy.","You feel sick.")]</span>")
		M.emote(pick("groan","moan"))


/datum/reagent/consumable/pepperoni
	name = "Pepperoni"
	id = "pepperoni"
	description = "An Italian-American variety of salami usually made from beef and pork"
	reagent_state = SOLID
	color = "#AC7E67"
	taste_message = "pepperoni"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/pepperoni/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				to_chat(H, "<span class='warning'>The pepperoni bounces off your mask!</span>")
				return

			if(H.head)
				to_chat(H, "<span class='warning'>Your mask protects you from the errant pepperoni!</span>")
				return

			if(prob(50))
				M.adjustBruteLoss(1)
				playsound(M, 'sound/effects/woodhit.ogg', 50, 1)
				to_chat(M, "<span class='warning'>A slice of pepperoni slaps you!</span>")
			else
				M.emote("burp")
				to_chat(M, "<span class='warning'>My goodness, that was tasty!</span>")

///Food Related, but non-nutritious

/datum/reagent/questionmark // food poisoning
	name = "????"
	id = "????"
	description = "A gross and unidentifiable substance."
	reagent_state = LIQUID
	color = "#63DE63"
	taste_message = "burned food"

/datum/reagent/questionmark/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		M.Stun(2, FALSE)
		M.Weaken(2, FALSE)
		M.update_canmove()
		to_chat(M, "<span class='danger'>Ugh! Eating that was a terrible idea!</span>")

/datum/reagent/msg
	name = "Monosodium glutamate"
	id = "msg"
	description = "Monosodium Glutamate is a sodium salt known chiefly for its use as a controversial flavor enhancer."
	reagent_state = LIQUID
	color = "#F5F5F5"
	custom_metabolism = 0.2
	taste_message = "excellent cuisine"
	taste_strength = 4

/datum/reagent/msg/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		if(prob(10))
			update_flags |= M.adjustToxLoss(rand(2.4), FALSE)
		if(prob(7))
			to_chat(M, "<span class='warning'>A horrible migraine overpowers you.</span>")
			update_flags |= M.Stun(rand(2,5), FALSE)
	return ..() | update_flags

/datum/reagent/cholesterol
	name = "cholesterol"
	id = "cholesterol"
	description = "Pure cholesterol. Probably not very good for you."
	reagent_state = LIQUID
	color = "#FFFAC8"
	taste_message = "heart attack"

/datum/reagent/cholesterol/on_mob_life(mob/living/M)
	..()
	if(volume >= 25 && prob(volume*0.15))
		to_chat(M, "<span class='warning'>Your chest feels [pick("weird","uncomfortable","nasty","gross","odd","unusual","warm")]!</span>")
		M.adjustToxLoss(rand(1,2), FALSE)
	else if(volume >= 45 && prob(volume*0.08))
		to_chat(M, "<span class='warning'>Your chest [pick("hurts","stings","aches","burns")]!</span>")
		M.adjustToxLoss(rand(2,4), FALSE)
		M.Stun(1, FALSE)
	else if(volume >= 150 && prob(volume*0.01))
		to_chat(M, "<span class='warning'>Your chest is burning with pain!</span>")
		M.Stun(1, FALSE)
		M.Weaken(1, FALSE)
		//M.ForceContractDisease(new /datum/disease/critical/heart_failure(0))


/datum/reagent/fungus
	name = "Space fungus"
	id = "fungus"
	description = "Scrapings of some unknown fungus found growing on the station walls."
	reagent_state = LIQUID
	color = "#C87D28"
	taste_message = "mold"

/datum/reagent/fungus/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		var/ranchance = rand(1,10)
		if(ranchance == 1)
			to_chat(M, "<span class='warning'>You feel very sick.</span>")
			M.reagents.add_reagent("toxin", rand(1,5))
		else if(ranchance <= 5)
			to_chat(M, "<span class='warning'>That tasted absolutely FOUL.</span>")
			//M.ForceContractDisease(new /datum/disease/food_poisoning(0))
		else
			to_chat(M, "<span class='warning'>Yuck!</span>")

/*datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = "ectoplasm"
	description = "A bizarre gelatinous substance supposedly derived from ghosts."
	reagent_state = LIQUID
	color = "#8EAE7B"
	process_flags = ORGANIC | SYNTHETIC		//Because apparently ghosts in the shell
	taste_message = "spooks"

/datum/reagent/ectoplasm/on_mob_life(mob/living/M)
	var/spooky_message = pick("You notice something moving out of the corner of your eye, but nothing is there...", "Your eyes twitch, you feel like something you can't see is here...", "You've got the heebie-jeebies.", "You feel uneasy.", "You shudder as if cold...", "You feel something gliding across your back...")
	if(prob(8))
		to_chat(M, "<span class='warning'>[spooky_message]</span>")
	return ..()

/datum/reagent/ectoplasm/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		var/spooky_eat = pick("Ugh, why did you eat that? Your mouth feels haunted. Haunted with bad flavors.", "Ugh, why did you eat that? It has the texture of ham aspic.  From the 1950s.  Left out in the sun.", "Ugh, why did you eat that? It tastes like a ghost fart.", "Ugh, why did you eat that? It tastes like flavor died.")
		to_chat(M, "<span class='warning'>[spooky_eat]</span>")

/datum/reagent/ectoplasm/reaction_turf(turf/T, volume)
	if(volume >= 10 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/ectoplasm(T)

/datum/reagent/consumable/bread/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/breadslice(T)*/

		///Vomit///

/datum/reagent/vomit
	name = "Vomit"
	id = "vomit"
	description = "Looks like someone lost their lunch. And then collected it. Yuck."
	reagent_state = LIQUID
	color = "#FFFF00"
	taste_message = "puke"

/datum/reagent/vomit/reaction_turf(turf/simulated/T, volume)
	if(volume >= 5 )
		new /obj/effect/decal/cleanable/vomit(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/greenvomit
	name = "Green vomit"
	id = "green_vomit"
	description = "Whoa, that can't be natural. That's horrible."
	reagent_state = LIQUID
	color = "#78FF74"
	taste_message = "puke"

/datum/reagent/greenvomit/reaction_turf(turf/simulated/T, volume)
	if(volume >= 5)
		new /obj/effect/decal/cleanable/vomit/green(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

