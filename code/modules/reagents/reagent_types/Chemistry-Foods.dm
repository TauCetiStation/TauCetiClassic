/datum/reagent/consumable
	name = "Употребляемое"
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
	name = "Питательное вещество"
	id = "nutriment"
	description = "Все витамины, минералы и углеводы, необходимые организму в чистом виде."
	reagent_state = SOLID
	nutriment_factor = 8 // 1 nutriment reagent is 10 nutrition actually, which is confusing, but it works.
	custom_metabolism = FOOD_METABOLISM * 2 // It's balanced so you gain the nutrition, but slightly faster.
	color = "#664330" // rgb: 102, 67, 48
	taste_message = "мягкой еды"

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
	name = "Протеин"
	id = "protein"
	description = "Различные незаменимые белки и жиры, обычно содержащиеся в мясе и крови животных."
	diet_flags = DIET_MEAT
	taste_message = "мяса"

/datum/reagent/nutriment/protein/on_skrell_digest(mob/living/M)
	..()
	M.adjustToxLoss(2 * FOOD_METABOLISM)
	return FALSE

/datum/reagent/nutriment/plantmatter // Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Растительная масса"
	id = "plantmatter"
	description = "Богатые витаминами волокна и натуральные сахара, которые обычно встречаются в свежих продуктах."
	diet_flags = DIET_PLANT
	taste_message = "растений"

/datum/reagent/nutriment/dairy // Milk-based biomatter.
	name = "Молокопродукт"
	id = "dairy"
	description = "Вкусное вещество, которое получается из коров, которые едят много травы."
	diet_flags = DIET_DAIRY
	taste_message = "молока"

/datum/reagent/consumable/sprinkles
	name = "Присыпка"
	id = "sprinkles"
	description = "Разноцветные кусочки сахара, которые обычно можно найти на пончиках. Любят копы."
	color = "#ff00ff" // rgb: 255, 0, 255
	taste_message = "сладости"

/datum/reagent/consumable/sprinkles/on_general_digest(mob/living/M)
	..()
	if(ishuman(M) && (M.job in list("Security Officer", "Head of Security", "Detective", "Warden", "Captain")))
		M.heal_bodypart_damage(1, 1)

/datum/reagent/consumable/syndicream
	name = "Кремовая начинка"
	id = "syndicream"
	description = "Вкусная кремовая начинка загадочного происхождения. Вкус криминально хороший."
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
	name = "Соевый соус"
	id = "soysauce"
	description = "Соленый соус из соевого растения."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#792300" // rgb: 121, 35, 0
	taste_message = "соли"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/ketchup
	name = "Кетчуп"
	id = "ketchup"
	description = "Кетчуп, кепчук, не важно. Это томатная паста."
	reagent_state = LIQUID
	nutriment_factor = 5
	color = "#731008" // rgb: 115, 16, 8
	taste_message = "кетчупа"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/flour
	name = "Мука"
	id = "flour"
	description = "Это то, чем вы натираете себя, чтобы притвориться призраком."
	reagent_state = LIQUID
	nutriment_factor = 2
	color = "#f5eaea" // rgb: 245, 234, 234
	taste_message = "муки"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/capsaicin
	name = "Капсаициновое масло"
	id = "capsaicin"
	description = "Это то, что делает перец жгучим."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 179, 16, 8
	taste_message = "<span class='warning'>ЖГУЧЕСТИ</span>"

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
	name = "Конденсированный капсаицин"
	id = "condensedcapsaicin"
	description = "Химическое вещество, используемое для самообороны и в полиции."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 179, 16, 8
	taste_message = "<span class='userdanger'>ЧИСТОГО ОГНЯ</span>"

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
				to_chat(victim, "<span class='userdanger'></span>")
				return
			else if (mouth_covered)	// Reduced effects if partially protected
				to_chat(victim, "<span class='userdanger'>Ваш [safe_thing] частично защищает вас от перцового аэрозоля!</span>")
				victim.eye_blurry = max(M.eye_blurry, 15)
				victim.eye_blind = max(M.eye_blind, 5)
				victim.Stun(5)
				victim.Weaken(5)
				return
			else if (eyes_covered) // Eye cover is better than mouth cover
				to_chat(victim, "<span class='userdanger'>Ваш [safe_thing] защищает ваши глаза от перцового аэрозоля!</span>")
				victim.emote("scream")
				victim.eye_blurry = max(M.eye_blurry, 5)
				return
			else // Oh dear :D
				victim.emote("scream")
				to_chat(victim, "<span class='userdanger'>Перцовый аэрозоль попадает вам прямо в глаза!</span>")
				victim.eye_blurry = max(M.eye_blurry, 25)
				victim.eye_blind = max(M.eye_blind, 10)
				victim.Stun(5)
				victim.Weaken(5)

/datum/reagent/consumable/condensedcapsaicin/on_general_digest(mob/living/M)
	..()
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")

/datum/reagent/consumable/frostoil
	name = "Морозное масло"
	id = "frostoil"
	description = "Специальное масло, которое заметно охлаждает тело. Добывается из ледяного перца."
	reagent_state = LIQUID
	color = "#b31008" // rgb: 139, 166, 233
	taste_message = "<font color='lightblue'>холода</font>"
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
	name = "Кухонная соль"
	id = "sodiumchloride"
	description = "Соль из хлорида натрия. Обычно используется для приправки еды."
	reagent_state = SOLID
	color = "#ffffff" // rgb: 255,255,255
	overdose = REAGENTS_OVERDOSE
	taste_message = "соли"

/datum/reagent/consumable/blackpepper
	name = "Чёрный перец"
	id = "blackpepper"
	description = "Перемолотые горошины перца. *АААПЧХИИИ*"
	reagent_state = SOLID
	// no color (ie, black)
	taste_message = "перца"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/coco
	name = "Какао-порошок"
	id = "coco"
	description = "Жирная горькая паста из какао-бобов."
	reagent_state = SOLID
	nutriment_factor = 10
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "какао"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/psilocybin
	name = "Псилоцибин"
	id = "psilocybin"
	description = "Сильный психотроп, полученный из определенных видов грибов."
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
	name = "Кукурузное масло"
	id = "cornoil"
	description = "Масло, полученное из различных видов кукурузы."
	reagent_state = LIQUID
	nutriment_factor = 40
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "масла"
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
	name = "Универсальный фермент"
	id = "enzyme"
	description = "Универсальный фермент, используемый при приготовлении некоторых химикатов и продуктов питания."
	reagent_state = LIQUID
	color = "#365e30" // rgb: 54, 94, 48
	overdose = REAGENTS_OVERDOSE
	taste_message = null

/datum/reagent/consumable/dry_ramen
	name = "Сухая лапша"
	id = "dry_ramen"
	description = "Пища космической эры, с 25 августа 1958 года. Содержит сушеную лапшу, пару крошечных овощей и химические вещества со вкусом курицы, выделяет тепло при контакте с водой."
	reagent_state = SOLID
	nutriment_factor = 2
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "сухой лапши покрытой чем-то вроде ваших слез"

/datum/reagent/consumable/hot_ramen
	name = "Горячая лапша"
	id = "hot_ramen"
	description = "Лапша отварная, ароматизаторы искусственные, как в школьные времена."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "лапши"

/datum/reagent/consumable/hot_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(BODYTEMP_NORMAL, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/hell_ramen
	name = "Острая лапша"
	id = "hell_ramen"
	description = "Пища космической эры, с 25 августа 1958 года. Содержит сушеную лапшу, пару крошечных овощей и острые химические вещества, выделяет тепло при контакте с водой."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "сухой лапши покрытой чем-то ОСТРЫМ"

/datum/reagent/consumable/hell_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL + 40) // Not Tajaran friendly food (by the time of writing this, Tajaran has 330 heat limit, while this is 350 and human 360.
		M.bodytemperature = min(BODYTEMP_NORMAL + 40, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/hot_hell_ramen
	name = "Горячая острая лапша"
	id = "hot_hell_ramen"
	description = "Лапша отварная, ароматизаторы ЖГУЧИЕ, как в школьные времена."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "ЖГУЧЕЙ лапши"

/datum/reagent/consumable/hot_hell_ramen/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature < BODYTEMP_NORMAL + 40)
		M.bodytemperature = min(BODYTEMP_NORMAL + 40, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT))

/datum/reagent/consumable/rice
	name = "Рис"
	id = "rice"
	description = "Наслаждайтесь прекрасным вкусом ничего."
	reagent_state = SOLID
	nutriment_factor = 8
	color = "#ffffff" // rgb: 0, 0, 0
	taste_message = "риса"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/cherryjelly
	name = "Вишнёвый джем"
	id = "cherryjelly"
	description = "Абсолютно лучший. Только для намазывания на продукты с превосходной боковой симметрией."
	reagent_state = LIQUID
	nutriment_factor = 8
	color = "#801e28" // rgb: 128, 30, 40
	taste_message = "вишнёвого джема"
	diet_flags = DIET_PLANT

/datum/reagent/consumable/egg
	name = "Яйцо"
	id = "egg"
	description = "Жидкая и вязкая смесь прозрачных и желтых жидкостей."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#f0c814"
	taste_message = "яиц"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/cheese
	name = "Сыр"
	id = "cheese"
	description = "Некоторый сыр."
	reagent_state = SOLID
	nutriment_factor = 4
	color = "#ffff00"
	taste_message = "сыра"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/beans
	name = "Пережареные бобы"
	id = "beans"
	description = "Блюдо из протертой фасоли, приготовленной на сале."
	reagent_state = LIQUID
	nutriment_factor = 4
	color = "#684435"
	taste_message = "буррито"
	diet_flags = DIET_MEAT

/datum/reagent/consumable/bread
	name = "Хлеб"
	id = "bread"
	description = "Хлеб! Ага, хлеб."
	reagent_state = SOLID
	nutriment_factor = 4
	color = "#9c5013"
	taste_message = "хлеба"
	diet_flags = DIET_PLANT
