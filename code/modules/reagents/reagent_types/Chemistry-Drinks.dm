/datum/reagent/consumable/drink
	name = "Drink"
	id = "drink"
	description = "Uh, some kind of drink."
	reagent_state = LIQUID
	color = "#e78108" // rgb: 231, 129, 8
	custom_metabolism = DRINK_METABOLISM
	nutriment_factor = 0
	var/adj_dizzy = 0
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/adj_temp = 0

/datum/reagent/consumable/drink/on_general_digest(mob/living/M)
	..()
	if(adj_dizzy)
		M.dizziness = max(0,M.dizziness + adj_dizzy)
	if(adj_drowsy)
		M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if(adj_sleepy)
		M.AdjustSleeping(adj_sleepy)
	if(adj_temp)
		if(M.bodytemperature < BODYTEMP_NORMAL)//310 is the normal bodytemp. 310.055
			M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/drink/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	color = "#e78108" // rgb: 231, 129, 8
	taste_message = "orange"

/datum/reagent/consumable/drink/orangejuice/on_general_digest(mob/living/M)
	..()
	if(M.getOxyLoss() && prob(30))
		M.adjustOxyLoss(-1)

/datum/reagent/consumable/drink/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	color = "#731008" // rgb: 115, 16, 8
	taste_message = "tomato"

/datum/reagent/consumable/drink/tomatojuice/on_general_digest(mob/living/M)
	..()
	if(M.getFireLoss() && prob(20))
		M.heal_bodypart_damage(0, 1)

/datum/reagent/consumable/drink/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	color = "#365e30" // rgb: 54, 94, 48
	taste_message = "lime"

/datum/reagent/consumable/drink/limejuice/on_general_digest(mob/living/M)
	..()
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1 * REM)

/datum/reagent/consumable/drink/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
	description = "It is just like a carrot but without crunching."
	color = "#973800" // rgb: 151, 56, 0
	taste_message = "carrot"

/datum/reagent/consumable/drink/carrotjuice/on_general_digest(mob/living/M)
	..()
	M.eye_blurry = max(M.eye_blurry - 1, 0)
	M.eye_blind = max(M.eye_blind - 1, 0)
	if(!data["ticks"])
		data["ticks"] = 1
	switch(data["ticks"])
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(data["ticks"] - 10))
				M.disabilities &= ~NEARSIGHTED
	data["ticks"]++

/datum/reagent/consumable/drink/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	color = "#990066" // rgb: 153, 0, 102
	taste_message = "berry"

/datum/reagent/consumable/drink/grapejuice
	name = "Grape Juice"
	id = "grapejuice"
	description = "It's grrrrrape!"
	color = "#863333" // rgb: 134, 51, 51
	taste_message = "grape"

/datum/reagent/consumable/drink/grapesoda
	name = "Grape Soda"
	id = "grapesoda"
	description = "Grapes made into a fine drank."
	color = "#421c52" // rgb: 98, 57, 53
	taste_message = "grape"
	adj_drowsy 	= 	-3

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	color = "#863353" // rgb: 134, 51, 83
	taste_message = "bitterness"

/datum/reagent/consumable/drink/poisonberryjuice/on_general_digest(mob/living/M)
	..()
	M.adjustToxLoss(1)

/datum/reagent/consumable/drink/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	color = "#863333" // rgb: 134, 51, 51
	taste_message = "watermelon"

/datum/reagent/consumable/drink/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	color = "#863333" // rgb: 175, 175, 0
	taste_message = "sour"

/datum/reagent/consumable/drink/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana."
	color = "#863333" // rgb: 175, 175, 0
	taste_message = "banana"

/datum/reagent/consumable/drink/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."
	taste_message = "nothing... how?"

/datum/reagent/consumable/drink/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	nutriment_factor = 2
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "puke, you're pretty sure"

/datum/reagent/consumable/drink/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	color = "#dfdfdf" // rgb: 223, 223, 223
	taste_message = "milk"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/drink/milk/on_general_digest(mob/living/M)
	..()
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1, 0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10 * REAGENTS_METABOLISM)

/datum/reagent/consumable/drink/milk/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	color = "#dfdfc7" // rgb: 223, 223, 199
	taste_message = "fake milk"
	diet_flags = DIET_ALL

/datum/reagent/consumable/drink/milk/cream
	name = "Cream"
	id = "cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	color = "#dfd7af" // rgb: 223, 215, 175
	taste_message = "cream"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/drink/grenadine
	name = "Grenadine Syrup"
	id = "grenadine"
	description = "Made in the modern day with proper pomegranate substitute. Who uses real fruit, anyways?"
	color = "#ff004f" // rgb: 255, 0, 79
	taste_message = "grenadine"

/datum/reagent/consumable/drink/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	nutriment_factor = 2
	color = "#403010" // rgb: 64, 48, 16
	adj_temp = 5
	taste_message = "chocolate"

/datum/reagent/consumable/drink/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	color = "#482000" // rgb: 72, 32, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -40
	adj_temp = 25
	taste_message = "coffee"

/datum/reagent/consumable/drink/coffee/on_general_digest(mob/living/M)
	..()
	M.make_jittery(5)
	if(adj_temp > 0 && holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 10 * REAGENTS_METABOLISM)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp = -5
	taste_message = "coffee"

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/consumable/drink/coffee/soy_latte/on_general_digest(mob/living/M)
	..()
	M.SetSleeping(0)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1, 0)

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage while you are reading."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/drink/coffee/cafe_latte/on_general_digest(mob/living/M)
	..()
	M.SetSleeping(0)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1, 0)

/datum/reagent/consumable/drink/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	color = "#101000" // rgb: 16, 16, 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -60
	adj_temp = 20
	taste_message = "tea"

/datum/reagent/consumable/drink/tea/on_general_digest(mob/living/M)
	..()
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/consumable/drink/tea/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "No relation to a certain rap artist/ actor."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp = -5

/datum/reagent/consumable/drink/cold
	name = "Cold drink"
	adj_temp = -5
	taste_message = "coolness"

/datum/reagent/consumable/drink/cold/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -40

/datum/reagent/consumable/drink/cold/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	color = "#619494" // rgb: 97, 148, 148
	adj_dizzy = -5
	adj_drowsy = -3

/datum/reagent/consumable/drink/cold/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148

/datum/reagent/consumable/drink/cold/space_cola
	name = "Space Cola"
	id = "cola"
	description = "A refreshing beverage."
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0
	adj_drowsy 	= 	-3
	taste_message = "cola"

/datum/reagent/consumable/drink/cold/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	color = "#100800" // rgb: 16, 8, 0
	adj_sleepy = -40
	taste_message = "cola"

/datum/reagent/consumable/drink/cold/nuka_cola/on_general_digest(mob/living/M)
	..()
	M.make_jittery(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/consumable/drink/cold/spacemountainwind
	name = "Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -7
	adj_sleepy = -20
	taste_message = "lime soda"

/datum/reagent/consumable/drink/cold/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -6
	taste_message = "cherry soda"

/datum/reagent/consumable/drink/cold/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	color = "#202800" // rgb: 32, 40, 0
	adj_temp = -8
	taste_message = "lemon soda"

/datum/reagent/consumable/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	color = "#878f00" // rgb: 135, 40, 0
	adj_temp = -8
	taste_message = "citrus soda"

/datum/reagent/consumable/drink/cold/lemonade
	name = "Lemonade"
	description = "Oh the nostalgia..."
	id = "lemonade"
	color = "#ffff00" // rgb: 255, 255, 0
	taste_message = "lemonade"

/datum/reagent/consumable/drink/cold/kiraspecial
	name = "Kira Special"
	description = "Long live the guy who everyone had mistaken for a girl. Baka!"
	id = "kiraspecial"
	color = "#cccc99" // rgb: 204, 204, 153
	taste_message = "citrus soda"

/datum/reagent/consumable/drink/cold/brownstar
	name = "Brown Star"
	description = "It's not what it sounds like..."
	id = "brownstar"
	color = "#9f3400" // rgb: 159, 052, 000
	adj_temp = - 2
	taste_message = "orange soda"

/datum/reagent/consumable/drink/cold/milkshake
	name = "Milkshake"
	description = "Glorious brainfreezing mixture."
	id = "milkshake"
	color = "#aee5e4" // rgb" 174, 229, 228
	adj_temp = -9
	taste_message = "milkshake"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/drink/cold/milkshake/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	switch(data["ticks"])
		if(1 to 15)
			M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(15,20)
	data["ticks"]++

/datum/reagent/consumable/drink/cold/milkshake/chocolate
	name = "Chocolate Milkshake"
	description = "Glorious brainfreezing mixture. Now with cocoa!"
	id = "milkshake_chocolate"
	color = "#aee5e4" // rgb" 174, 229, 228
	adj_temp = -9
	taste_message = "chocolate milk"

/datum/reagent/consumable/drink/cold/milkshake/strawberry
	name = "Strawberry Milkshake"
	description = "Glorious brainfreezing mixture. So sweet!"
	id = "milkshake_strawberry"
	color = "#aee5e4" // rgb" 174, 229, 228
	adj_temp = -9
	taste_message = "strawberry milk"

/datum/reagent/consumable/drink/cold/rewriter
	name = "Rewriter"
	description = "The secret of the sanctuary of the Libarian..."
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0
	taste_message = "coffee...soda?"

/datum/reagent/consumable/drink/cold/rewriter/on_general_digest(mob/living/M )
	..()
	M.make_jittery(5)

/datum/reagent/consumable/drink/cold/kvass
	name = "kvass"
	id = "kvass"
	description = "A cool refreshing drink with a taste of socialism."
	reagent_state = LIQUID
	color = "#381600" // rgb: 56, 22, 0
	adj_temp = -7
	taste_message = "communism"

/datum/reagent/consumable/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	reagent_state = LIQUID
	color = "#ff8cff" // rgb: 255, 140, 255
	custom_metabolism = FOOD_METABOLISM
	nutriment_factor = 1
	taste_message = "healthy dietary choices"

/datum/reagent/consumable/doctor_delight/on_general_digest(mob/living/M)
	..()
	if(M.getOxyLoss() && prob(50))
		M.adjustOxyLoss(-2)
	if(M.getBruteLoss() && prob(60))
		M.heal_bodypart_damage(2, 0)
	if(M.getFireLoss() && prob(50))
		M.heal_bodypart_damage(0, 2)
	if(M.getToxLoss() && prob(50))
		M.adjustToxLoss(-2)
	if(M.dizziness !=0)
		M.dizziness = max(0, M.dizziness - 15)
	if(M.confused !=0)
		M.confused = max(0, M.confused - 5)

/datum/reagent/consumable/honey
	name = "Honey"
	id = "Honey"
	description = "A golden yellow syrup, loaded with sugary sweetness."
	reagent_state = LIQUID
	color = "#feae00"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	taste_message = "honey"

/datum/reagent/consumable/honey/on_general_digest(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!holder)
			return
		H.nutrition += 15
		if(H.getBruteLoss() && prob(60))
			M.heal_bodypart_damage(2, 0)
		if(H.getFireLoss() && prob(50))
			M.heal_bodypart_damage(0, 2)
		if(H.getToxLoss() && prob(50))
			H.adjustToxLoss(-2)

//////////////////////////////////////////////The ten friggen million reagents that get you drunk//////////////////////////////////////////////

/datum/reagent/consumable/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0
	taste_message = "fruity alcohol"
	restrict_species = list(IPC, DIONA)

/datum/reagent/consumable/atomicbomb/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 50)
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.confused = max(M.confused + 2,0)
		M.make_dizzy(10)
	if(!M.stuttering)
		M.stuttering = 1
	M.stuttering += 3
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(51 to 200)
			M.SetSleeping(20 SECONDS)
		if(201 to INFINITY)
			M.SetSleeping(20 SECONDS)
			M.adjustToxLoss(2)

/datum/reagent/consumable/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	taste_message = "the number fourty two"
	restrict_species = list(IPC, DIONA)

/datum/reagent/consumable/gargle_blaster/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	M.dizziness += 6
	if(data["ticks"] >= 15 && data["ticks"] < 45)
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering += 3
	else if(data["ticks"] >= 45 && prob(50) && data["ticks"] < 55)
		M.confused = max(M.confused + 3,0)
	else if(data["ticks"] >=55)
		M.druggy = max(M.druggy, 55)
	else if(data["ticks"] >=200)
		M.adjustToxLoss(2)

/datum/reagent/consumable/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = LIQUID
	color = "#2e2e61" // rgb: 46, 46, 97
	taste_message = "brain damageeeEEeee"
	restrict_species = list(IPC, DIONA)

/datum/reagent/consumable/neurotoxin/on_general_digest(mob/living/M)
	..()
	M.weakened = max(M.weakened, 3)
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	M.dizziness += 6
	if(data["ticks"] >= 15 && data["ticks"] < 45)
		if (!M.stuttering)
			M.stuttering = 1
		M.stuttering += 3
	else if(data["ticks"] >= 45 && prob(50) && data["ticks"] <55)
		M.confused = max(M.confused + 3,0)
	else if(data["ticks"] >=55)
		M.druggy = max(M.druggy, 55)
	else if(data["ticks"] >=200)
		M.adjustToxLoss(2)

/datum/reagent/consumable/hippies_delight
	name = "Hippies' Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	custom_metabolism = FOOD_METABOLISM * 0.5
	taste_message = "peeeeeeace"
	restrict_species = list(IPC, DIONA)

/datum/reagent/consumable/hippies_delight/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 50)
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 5)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_dizzy(10)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_jittery(20)
			M.make_dizzy(20)
			M.druggy = max(M.druggy, 45)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to 200)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_jittery(40)
			M.make_dizzy(40)
			M.druggy = max(M.druggy, 60)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
		if(200 to INFINITY)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_jittery(60)
			M.make_dizzy(60)
			M.druggy = max(M.druggy, 75)
			if(prob(40))
				M.emote(pick("twitch","giggle"))
			if(prob(30))
				M.adjustToxLoss(2)

/*boozepwr chart
1-2 = non-toxic alcohol
3 = medium-toxic
4 = the hard stuff
5 = potent mixes
<6 = deadly toxic
*/

/datum/reagent/consumable/ethanol
	name = "Ethanol" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	custom_metabolism = DRINK_METABOLISM * 0.4
	var/boozepwr = 5 //higher numbers mean the booze will have an effect faster.
	var/dizzy_adj = 3
	var/adj_drowsy = 0
	var/adj_sleepy = 0
	var/slurr_adj = 3
	var/confused_adj = 2
	var/slur_start = 90			//amount absorbed after which mob starts slurring
	var/confused_start = 150	//amount absorbed after which mob starts confusing directions
	var/blur_start = 300	//amount absorbed after which mob starts getting blurred vision
	var/pass_out = 400	//amount absorbed after which mob starts passing out
	taste_message = "liquid fire"
	restrict_species = list(IPC, DIONA)
	flags = list(IS_ORGANIC)

/datum/reagent/consumable/ethanol/on_general_digest(mob/living/M)
	if(!..())
		return

	if(adj_drowsy)
		M.drowsyness = max(0,M.drowsyness + adj_drowsy)
	if(adj_sleepy)
		M.SetSleeping(adj_sleepy)

	if(!data["ticks"])
		data["ticks"] = 1   //if it doesn't exist we set it.
	data["ticks"] += boozepwr						//avoid a runtime error associated with drinking blood mixed in drinks (demon's blood).

	var/d = 0

	// make all the beverages work together
	for(var/datum/reagent/consumable/ethanol/A in holder.reagent_list)
		if(A.data["ticks"])
			d += A.data["ticks"]

	if(HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE)) //we're an accomplished drinker
		d *= 0.7

	if(HAS_TRAIT(M, TRAIT_LIGHT_DRINKER))
		d *= 2

	M.dizziness += dizzy_adj
	if(d >= slur_start && d < pass_out)
		if(!M.slurring)
			M.slurring = 1
		M.slurring += slurr_adj
	if(d >= confused_start && prob(33))
		if(!M.confused)
			M.confused = 1
		M.confused = max(M.confused + confused_adj, 0)
	if(d >= blur_start)
		M.eye_blurry = max(M.eye_blurry, 10)
		M.drowsyness = max(M.drowsyness, 0)
	if(d >= pass_out)
		M.paralysis = max(M.paralysis, 20)
		M.drowsyness = max(M.drowsyness, 30)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/liver/IO = H.organs_by_name[O_LIVER]
			if(istype(IO))
				IO.take_damage(0.1, 1)
			H.adjustToxLoss(0.1)
	return TRUE

/datum/reagent/consumable/ethanol/on_skrell_digest(mob/living/M)
	..()
	return !flags[IS_ORGANIC]

/datum/reagent/consumable/ethanol/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		to_chat(usr, "The solution dissolves the ink on the paper.")
	if(istype(O,/obj/item/weapon/book))
		if(istype(O,/obj/item/weapon/book/tome))
			to_chat(usr, "The solution does nothing. Whatever this is, it isn't normal ink.")
			return
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			to_chat(usr, "The solution dissolves the ink on the book.")
		else
			to_chat(usr, "It wasn't enough...")
	return
/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 15)
		return


/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#fbbf0d" // rgb: 251, 191, 13
	boozepwr = 1
	nutriment_factor = 1
	taste_message = "beer"

/datum/reagent/consumable/ethanol/beer/on_general_digest(mob/living/M)
	..()
	M.jitteriness = max(M.jitteriness - 3,0)

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	dizzy_adj = -5
	adj_drowsy = -3
	adj_sleepy = -40

/datum/reagent/consumable/ethanol/kahlua/on_general_digest(mob/living/M)
	..()
	M.make_jittery(5)

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#ee7732" // rgb: 238, 119, 50
	boozepwr = 2
	dizzy_adj = 4

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Special Blend Whiskey"
	id = "specialwhiskey"
	description = "Just when you thought regular station whiskey was good... This silky, amber goodness has to come along and ruin everything."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	dizzy_adj = 4
	slur_start = 30		//amount absorbed after which mob starts slurring
	taste_message = "class"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	boozepwr = 2
	nutriment_factor = 1
	taste_message = "party"

/datum/reagent/consumable/ethanol/thirteenloko/on_general_digest(mob/living/M)
	..()
	M.drowsyness = max(0, M.drowsyness - 7)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.bodytemperature = max(BODYTEMP_NORMAL, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.make_jittery(5)

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#619494" // rgb: 97, 148, 148
	boozepwr = 2

/datum/reagent/consumable/ethanol/vodka/on_general_digest(mob/living/M)
	..()
	M.radiation = max(M.radiation - 1,0)

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895c4c" // rgb: 137, 92, 76
	boozepwr = 1
	nutriment_factor = 2
	taste_message = "bilk"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	boozepwr = 5
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/threemileisland/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 50)

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#cdd1da" // rgb: 205, 209, 218
	boozepwr = 1
	dizzy_adj = 3
	taste_message = "gin"

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Yohoho and all that."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	taste_message = "rum"

/datum/reagent/consumable/ethanol/champagne
	name = "Champagne"
	id = "champagne"
	description = "Une delicieuse boisson."
	color = "#fcfcee" // rgb: 252, 252, 238
	boozepwr = 1
	taste_message = "champagne"

/datum/reagent/consumable/ethanol/tequilla
	name = "Tequila"
	id = "tequilla"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#ffff91" // rgb: 255, 255, 145
	boozepwr = 2
	taste_message = "tequilla"

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91ff91" // rgb: 145, 255, 145
	boozepwr = 1.5
	taste_message = "vermouth"

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7e4043" // rgb: 126, 64, 67
	boozepwr = 1.5
	dizzy_adj = 2
	slur_start = 65			//amount absorbed after which mob starts slurring
	confused_start = 145	//amount absorbed after which mob starts confusing directions
	taste_message = "wine"

	needed_aspects = list(ASPECT_FOOD = 1, ASPECT_RESCUE = 1)

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#ab3c05" // rgb: 171, 60, 5
	boozepwr = 1.5
	dizzy_adj = 4
	confused_start = 115	//amount absorbed after which mob starts confusing directions
	taste_message = "cognac"

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35			//amount absorbed after which mob starts slurring
	confused_start = 90	//amount absorbed after which mob starts confusing directions
	taste_message = "puke"

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1
	taste_message = "ale"

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	id = "absinthe"
	description = "Watch out that the Green Fairy doesn't come for you!"
	color = "#33ee00" // rgb: 51, 238, 0
	boozepwr = 4
	dizzy_adj = 5
	slur_start = 15
	confused_start = 30
	taste_message = "absinthe"


/datum/reagent/consumable/ethanol/pwine
	name = "Poison Wine"
	id = "pwine"
	description = "Is this even wine? Toxic! Hallucinogenic! Probably consumed in boatloads by your superiors!"
	color = "#000000" // rgb: 0, 0, 0 SHOCKER
	boozepwr = 1
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1
	taste_message = "bitter wine"

	needed_aspects = list(ASPECT_FOOD = 1, ASPECT_OBSCURE = 1)

/datum/reagent/consumable/ethanol/pwine/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 50)
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	switch(data["ticks"])
		if(1 to 25)
			if(!M.stuttering)
				M.stuttering = 1
			M.make_dizzy(1)
			M.hallucination = max(M.hallucination, 3)
			if(prob(1))
				M.emote(pick("twitch","giggle"))
		if(25 to 75)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 10)
			M.make_jittery(2)
			M.make_dizzy(2)
			M.druggy = max(M.druggy, 45)
			if(prob(5))
				M.emote(pick("twitch","giggle"))
		if(75 to 150)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.make_jittery(4)
			M.make_dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
		if(150 to 300)
			if(!M.stuttering)
				M.stuttering = 1
			M.hallucination = max(M.hallucination, 60)
			M.make_jittery(4)
			M.make_dizzy(4)
			M.druggy = max(M.druggy, 60)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
			if(prob(30))
				M.adjustToxLoss(2)
			if(prob(5) && ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
				if(istype(IO))
					IO.take_damage(5, 0)
		if(300 to INFINITY)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/internal/heart/IO = H.organs_by_name[O_HEART]
				if(istype(IO))
					IO.take_damage(100, 0)

/datum/reagent/consumable/ethanol/deadrum
	name = "Deadrum"
	id = "rum"
	description = "Popular with the sailors. Not very popular with everyone else."
	color = "#f09f42" // rgb: 240, 159, 66
	boozepwr = 1
	taste_message = "rum"

/datum/reagent/consumable/ethanol/deadrum/on_general_digest(mob/living/M)
	..()
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.dizziness += 5

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	id = "sake"
	description = "Anime's favorite drink."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "sake"


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////


/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "schnapps"

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	boozepwr = 1.5
	taste_message = "light tequila"

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1
	taste_message = "gin tonic"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolucion."
	color = "#3e1b00" // rgb: 62, 27, 0
	boozepwr = 1.5
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3e1b00" // rgb: 62, 27, 0
	boozepwr = 2
	taste_message = "whiskey and coke"

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "martini"

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "bitter martini"

/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	color = "#a68340" // rgb: 166, 131, 64
	boozepwr = 3
	taste_message = "creamy alcohol"

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#a68310" // rgb: 166, 131, 16
	boozepwr = 3
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	color = "#8cff8c" // rgb: 140, 255, 140
	boozepwr = 1.5
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "tomatoes with booze"

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "It's just as effective as Dutch-Courage!."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/tequilla_sunrise
	name = "Tequila Sunrise"
	id = "tequillasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	color = "#ffe48c" // rgb: 255, 228, 140
	boozepwr = 2
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxins_special"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 5
	taste_message = "FIRE"

/datum/reagent/consumable/ethanol/toxins_special/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "THE LAW"

/datum/reagent/consumable/ethanol/beepsky_smash/on_general_digest(mob/living/M)
	..()
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.Stun(10)

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "creamy alcohol"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "manliness"

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "prohibition"

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "creamy alcohol"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "coffee and booze"

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8cff8c" // rgb: 140, 255, 140
	boozepwr = 3
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	boozepwr = 3
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "bitter alcohol"

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 5
	taste_message = "bitter alcohol"

/datum/reagent/consumable/ethanol/manhattan_proj/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 30)

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "For the more refined griffon."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "mediocrity"

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "poor life choices"

/datum/reagent/consumable/ethanol/antifreeze/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	color = "#ffffff" // rgb: 255, 255, 255
	boozepwr = 1.5
	taste_message = "refreshing alcohol"

/datum/reagent/consumable/ethanol/melonliquor
	name = "Melon Liquor"
	id = "melonliquor"
	description = "A relatively sweet and fruity 46 proof liquor."
	color = "#138808" // rgb: 19, 136, 8
	boozepwr = 1
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "Exotically blue, fruity drink, distilled from oranges."
	color = "#0000cd" // rgb: 0, 0, 205
	boozepwr = 1.5
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/suidream
	name = "Sui Dream"
	id = "suidream"
	description = "Comprised of: White soda, blue curacao, melon liquor."
	color = "#00a86b" // rgb: 0, 168, 107
	boozepwr = 0.5
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	boozepwr = 3
	taste_message = "<span class='warning'>evil</span>"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	color = "#0064c8" // rgb: 0, 100, 200
	boozepwr = 3
	dizzy_adj = 4
	slurr_adj = 3
	taste_message = "fizzy alcohol"

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	dizzy_adj = 4
	slurr_adj = 3
	taste_message = "fizzy alcohol"

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropical cocktail."
	color = "#ff7f3b" // rgb: 255, 127, 59
	boozepwr = 2
	taste_message = "fruity alcohol"

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 5
	dizzy_adj = 15
	slurr_adj = 15
	taste_message = "infinity"

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "spicy alcohol"

/datum/reagent/consumable/ethanol/sbiten/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
		M.bodytemperature = min(BODYTEMP_HEAT_DAMAGE_LIMIT, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	color = "#a68310" // rgb: 166, 131, 16
	boozepwr = 3
	taste_message = "blood"

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking's drink! Even though it has a strange red color."
	color = "#c73c00" // rgb: 199, 60, 0
	boozepwr = 1.5
	taste_message = "blood"

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Viking's drink, though a cheap one."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	nutriment_factor = 1
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1
	taste_message = "refreshing alcohol"

/datum/reagent/consumable/ethanol/iced_beer/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature > 270)
		M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, NanoTrasen approves!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 0.5
	taste_message = "rum"

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strangely named drink."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "sweet alcohol"


/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies, not as sweet as when made from your enemies."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "bitter alcohol"

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0
	boozepwr = 1.5
	taste_message = "PAIN"

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the NanoTrasen Gun-Club!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "a stunbaton"

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 5
	taste_message = "a tiny prick"

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 3
	dizzy_adj = 5
	taste_message = "creamy alcohol"

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "Tastes like terrorism!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 5
	taste_message = "a job offer"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is it's green!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 3
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 4
	taste_message = "bitter alcohol"

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1
	color = "#ffff91" // rgb: 255, 255, 140
	boozepwr = 4
	taste_message = "honks"

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "mphhhh"

/datum/reagent/consumable/ethanol/silencer/on_general_digest(mob/living/M)
	..()
	if(!data["ticks"])
		data["ticks"] = 1
	data["ticks"]++
	M.dizziness += 10
	if(data["ticks"] >= 55 && data["ticks"] < 115)
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering += 10
	else if(data["ticks"] >= 115 && prob(33))
		M.confused = max(M.confused + 15, 15)

/datum/reagent/consumable/ethanol/bacardi
	name = "Bacardi"
	id = "bacardi"
	description = "A soft light drink made of rum."
	reagent_state = LIQUID
	color = "#ffc0cb" // rgb: 255, 192, 203
	boozepwr = 3
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/bacardialoha
	name = "Bacardi Aloha"
	id = "bacardialoha"
	description = "Sweet mixture of rum, martini and lime soda."
	reagent_state = LIQUID
	color = "#c5f415" // rgb: 197, 244, 21
	boozepwr = 4
	taste_message = "sweet alcohol"

/datum/reagent/consumable/ethanol/bacardilemonade
	name = "Bacardi Lemonade"
	id = "bacardilemonade"
	description = "Mixture of refreshing lemonade and sweet rum."
	reagent_state = LIQUID
	color = "#c5f415" // rgb: 197, 244, 21
	boozepwr = 3
	taste_message = "sweet alcohol"
