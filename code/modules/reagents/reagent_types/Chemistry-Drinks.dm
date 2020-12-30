/datum/reagent/consumable/drink
	name = "Напиток"
	id = "drink"
	description = "Э, какой-то напиток."
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
	name = "Апельсиновый сок"
	id = "orangejuice"
	description = "Вкусный И богатый витамином C. Что тебе ещё нужно?"
	color = "#e78108" // rgb: 231, 129, 8
	taste_message = "апельсин"

/datum/reagent/consumable/drink/orangejuice/on_general_digest(mob/living/M)
	..()
	if(M.getOxyLoss() && prob(30))
		M.adjustOxyLoss(-1)

/datum/reagent/consumable/drink/tomatojuice
	name = "Томатный сок"
	id = "tomatojuice"
	description = "Помидоры превращённые в сок. Какая трата больших сочных помидоров, а?"
	color = "#731008" // rgb: 115, 16, 8
	taste_message = "помидор"

/datum/reagent/consumable/drink/tomatojuice/on_general_digest(mob/living/M)
	..()
	if(M.getFireLoss() && prob(20))
		M.heal_bodypart_damage(0, 1)

/datum/reagent/consumable/drink/limejuice
	name = "Лаймовый сок"
	id = "limejuice"
	description = "Кислосладкий сок лайма."
	color = "#365e30" // rgb: 54, 94, 48
	taste_message = "лайм"

/datum/reagent/consumable/drink/limejuice/on_general_digest(mob/living/M)
	..()
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1 * REM)

/datum/reagent/consumable/drink/carrotjuice
	name = "Морковный сок"
	id = "carrotjuice"
	description = "Это как морковь, только без хруста."
	color = "#973800" // rgb: 151, 56, 0
	taste_message = "морковь"

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
	name = "Ягодный сок"
	id = "berryjuice"
	description = "Вкусная смесь несколькоих видов ягод."
	color = "#990066" // rgb: 153, 0, 102
	taste_message = "ягоды"

/datum/reagent/consumable/drink/grapejuice
	name = "Виноградный сок"
	id = "grapejuice"
	description = "Он виногрррррадный!!"
	color = "#863333" // rgb: 134, 51, 51
	taste_message = "виноград"

/datum/reagent/consumable/drink/grapesoda
	name = "Виноградная газировка"
	id = "grapesoda"
	description = "Виноград превращённый в прекрасный напиток."
	color = "#421c52" // rgb: 98, 57, 53
	taste_message = "виноград"
	adj_drowsy 	= 	-3

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Сок ядовитых ягод"
	id = "poisonberryjuice"
	description = "Вкусный сок, приготовленный из различных видов очень смертоносных и токсичных ягод."
	color = "#863353" // rgb: 134, 51, 83
	taste_message = "горечь"

/datum/reagent/consumable/drink/poisonberryjuice/on_general_digest(mob/living/M)
	..()
	M.adjustToxLoss(1)

/datum/reagent/consumable/drink/watermelonjuice
	name = "Арбузный сок"
	id = "watermelonjuice"
	description = "Вкусный сок приготовленный из арбуза."
	color = "#863333" // rgb: 134, 51, 51
	taste_message = "арбуз"

/datum/reagent/consumable/drink/lemonjuice
	name = "Лимонный сок"
	id = "lemonjuice"
	description = "Этот сок ОЧЕНЬ кислый."
	color = "#863333" // rgb: 175, 175, 0
	taste_message = "кислоту"

/datum/reagent/consumable/drink/banana
	name = "Банановый сок"
	id = "banana"
	description = "Чистая эссенция банана."
	color = "#863333" // rgb: 175, 175, 0
	taste_message = "банан"

/datum/reagent/consumable/drink/nothing
	name = "Ничего"
	id = "nothing"
	description = "Абсолютно ничего."
	taste_message = "ничего... как?"

/datum/reagent/consumable/drink/potato_juice
	name = "Картофельный сок"
	id = "potato"
	description = "Бля, сок из картошки."
	nutriment_factor = 2
	color = "#302000" // rgb: 48, 32, 0
	taste_message = "блевотину, вы вполне уверены"

/datum/reagent/consumable/drink/milk
	name = "Молоко"
	id = "milk"
	description = "Непрозрачная белая жидкость, вырабатываемая молочными железами млекопитающих."
	color = "#dfdfdf" // rgb: 223, 223, 223
	taste_message = "молоко"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/drink/milk/on_general_digest(mob/living/M)
	..()
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1, 0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 10 * REAGENTS_METABOLISM)

/datum/reagent/consumable/drink/milk/soymilk
	name = "Соевое молоко"
	id = "soymilk"
	description = "Непрозрачная белая жидкость из соевых бобов."
	color = "#dfdfc7" // rgb: 223, 223, 199
	taste_message = "фальшивое молоко"
	diet_flags = DIET_ALL

/datum/reagent/consumable/drink/milk/cream
	name = "Сливки"
	id = "cream"
	description = "Жирная, тем не менее жидкая часть молока. Почему бы тебе не смешать это со скотчем, а?"
	color = "#dfd7af" // rgb: 223, 215, 175
	taste_message = "сливки"
	diet_flags = DIET_DAIRY

/datum/reagent/consumable/drink/grenadine
	name = "Гренадиновый сироп"
	id = "grenadine"
	description = "Сделано в наши дни из надлежащего заменителя граната. Кто вообще использует настоящие фрукты?"
	color = "#ff004f" // rgb: 255, 0, 79
	taste_message = "гранат"

/datum/reagent/consumable/drink/hot_coco
	name = "Горячий шоколад"
	id = "hot_coco"
	description = "Сделано с любовью! И какао бобами."
	nutriment_factor = 2
	color = "#403010" // rgb: 64, 48, 16
	adj_temp = 5
	taste_message = "шоколад"

/datum/reagent/consumable/drink/coffee
	name = "Кофе"
	id = "coffee"
	description = "Кофе это сваренный напиток, приготовленный из жареных семян кофейного растения, обычно называемых кофейными зернами."
	color = "#482000" // rgb: 72, 32, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -40
	adj_temp = 25
	taste_message = "кофе"

/datum/reagent/consumable/drink/coffee/on_general_digest(mob/living/M)
	..()
	M.make_jittery(5)
	if(adj_temp > 0 && holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 10 * REAGENTS_METABOLISM)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Кофе со льдом"
	id = "icecoffee"
	description = "Кофе и лёд, освежает и прохлаждает."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp = -5

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Соевый латте"
	id = "soy_latte"
	description = "Приятный и вкусный напиток для любителей почитать хиппи книги."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp = 5

/datum/reagent/consumable/drink/coffee/soy_latte/on_general_digest(mob/living/M)
	..()
	M.SetSleeping(0)
	if(M.getBruteLoss() && prob(20))
		M.heal_bodypart_damage(1, 0)

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Латте"
	id = "cafe_latte"
	description = "Приятный, крепкий и вкусный напиток для любителей почитать книги."
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
	name = "Чай"
	id = "tea"
	description = "Вкусный черный чай, в нем есть антиоксиданты, он полезен!"
	color = "#101000" // rgb: 16, 16, 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -60
	adj_temp = 20
	taste_message = "чай"

/datum/reagent/consumable/drink/tea/on_general_digest(mob/living/M)
	..()
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)

/datum/reagent/consumable/drink/tea/icetea
	name = "Чай со льдом"
	id = "icetea"
	description = "Можете привториться что это виски."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp = -5

/datum/reagent/consumable/drink/cold
	name = "Холодный напиток"
	adj_temp = -5
	taste_message = "свежесть"

/datum/reagent/consumable/drink/cold/tonic
	name = "Тоник"
	id = "tonic"
	description = "У него странный вкус, но, по крайней мере, хинин сдерживает космическую малярию."
	color = "#664300" // rgb: 102, 67, 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -40

/datum/reagent/consumable/drink/cold/sodawater
	name = "Содовая"
	id = "sodawater"
	description = "Почему бы не приготовить виски с содовой?"
	color = "#619494" // rgb: 97, 148, 148
	adj_dizzy = -5
	adj_drowsy = -3

/datum/reagent/consumable/drink/cold/ice
	name = "Лёд"
	id = "ice"
	description = "Замерзшая вода, ваш стоматолог не хотел бы, чтобы вы жевали это."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148

/datum/reagent/consumable/drink/cold/space_cola
	name = "Космо-кола"
	id = "cola"
	description = "Освежающий напиток"
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0
	adj_drowsy 	= 	-3
	taste_message = "колу"

/datum/reagent/consumable/drink/cold/nuka_cola
	name = "Ядер-кола"
	id = "nuka_cola"
	description = "Кола, кола никогда не меняется."
	color = "#100800" // rgb: 16, 8, 0
	adj_sleepy = -40
	taste_message = "колу"

/datum/reagent/consumable/drink/cold/nuka_cola/on_general_digest(mob/living/M)
	..()
	M.make_jittery(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness += 5
	M.drowsyness = 0

/datum/reagent/consumable/drink/cold/spacemountainwind
	name = "Mountain Wind"
	id = "spacemountainwind"
	description = "Дует насквозь, как космический ветер."
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -7
	adj_sleepy = -20
	taste_message = "лаймовую газировку"

/datum/reagent/consumable/drink/cold/dr_gibb
	name = "Д-р Гибб"
	id = "dr_gibb"
	description = "Вкуснейшая смесь различных 42 вкусов!"
	color = "#102000" // rgb: 16, 32, 0
	adj_drowsy = -6
	taste_message = "вишнёвую газировку"

/datum/reagent/consumable/drink/cold/space_up
	name = "Space-Up"
	id = "space_up"
	description = "На вкус как разгерметизация."
	color = "#202800" // rgb: 32, 40, 0
	adj_temp = -8
	taste_message = "лимонную газировку"

/datum/reagent/consumable/drink/cold/lemon_lime
	name = "Lemon Lime"
	description = "Резкая смесь на 0,5% состоящяя из натуральных цитрусовых!"
	id = "lemon_lime"
	color = "#878f00" // rgb: 135, 40, 0
	adj_temp = -8
	taste_message = "цитрусовую газировку"

/datum/reagent/consumable/drink/cold/lemonade
	name = "Лимонад"
	description = "О, были же времена..."
	id = "lemonade"
	color = "#ffff00" // rgb: 255, 255, 0
	taste_message = "лимонад"

/datum/reagent/consumable/drink/cold/kiraspecial
	name = "Кира Спешл"
	description = "Да здравствует парень, которого все приняли за девушку. Бака!"
	id = "kiraspecial"
	color = "#cccc99" // rgb: 204, 204, 153
	taste_message = "цитрусовую газировку"

/datum/reagent/consumable/drink/cold/brownstar
	name = "Коричневая звезда"
	description = "Это не то, о чём вы подумали!"
	id = "brownstar"
	color = "#9f3400" // rgb: 159, 052, 000
	adj_temp = - 2
	taste_message = "апельсиновую газировку"

/datum/reagent/consumable/drink/cold/milkshake
	name = "Милкшейк"
	description = "Великолепная замораживающая мозги смесь."
	id = "milkshake"
	color = "#aee5e4" // rgb" 174, 229, 228
	adj_temp = -9
	taste_message = "милкшейк"
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
	name = "Шоколадный милкшейк"
	description = "Великолепная замораживающая мозги смесь. Теперь с какао!"
	id = "milkshake_chocolate"
	color = "#aee5e4" // rgb" 174, 229, 228
	adj_temp = -9
	taste_message = "шоколадное молоко"

/datum/reagent/consumable/drink/cold/milkshake/strawberry
	name = "Клубничный милкшейк"
	description = "Великолепная замораживающая мозги смесь. Так сладко!"
	id = "milkshake_strawberry"
	color = "#aee5e4" // rgb" 174, 229, 228
	adj_temp = -9
	taste_message = "клубничное молоко"

/datum/reagent/consumable/drink/cold/rewriter
	name = "Переписчик"
	description = "Тайна святилища Библиотекаря..."
	id = "rewriter"
	color = "#485000" // rgb:72, 080, 0
	taste_message = "кофе... с газировкой?"

/datum/reagent/consumable/drink/cold/rewriter/on_general_digest(mob/living/M )
	..()
	M.make_jittery(5)

/datum/reagent/consumable/drink/cold/kvass
	name = "Квас"
	id = "kvass"
	description = "Прохладный освежающий напиток со вкусом социализма."
	reagent_state = LIQUID
	color = "#381600" // rgb: 56, 22, 0
	adj_temp = -7
	taste_message = "коммунизм"

/datum/reagent/consumable/doctor_delight
	name = "Наслаждение Доктора"
	id = "doctorsdelight"
	description = "Кто глоток в день выпивает, у того МедБот не бывает. Это, наверное, к лучшему."
	reagent_state = LIQUID
	color = "#ff8cff" // rgb: 255, 140, 255
	custom_metabolism = FOOD_METABOLISM
	nutriment_factor = 1
	taste_message = "здоровое питание"

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
	name = "Мёд"
	id = "Honey"
	description = "Золотисто-желтый сироп, наполненный сахарной сладостью."
	reagent_state = LIQUID
	color = "#feae00"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	taste_message = "мёд"

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
	name = "Атомная бомба"
	id = "atomicbomb"
	description = "Никогда еще ядерная пролиферация не была такой приятной."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0
	taste_message = "фруктовый алкоголь"
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
	name = "Пангалактический грызлодёр"
	id = "gargleblaster"
	description = "Ого, эта штука выглядит нестабильно!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	taste_message = "номер сорок два"
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
	name = "Нейротоксин"
	id = "neurotoxin"
	description = "Сильный нейротоксин, который вводит субъекта в состояние, подобное смерти."
	reagent_state = LIQUID
	color = "#2e2e61" // rgb: 46, 46, 97
	taste_message = "повреждение мозгааааААааа"
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
	name = "Наслаждение Хиппи"
	id = "hippiesdelight"
	description = "Ты просто не выкупаешь, чувааааак."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	custom_metabolism = FOOD_METABOLISM * 0.5
	taste_message = "примирение"
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
	name = "Этанол" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "Широкоизвестный спирт с множеством применений."
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
	taste_message = "жидкий огонь"
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
		to_chat(usr, "Смесь растворяет чернила на бумаге.")
	if(istype(O,/obj/item/weapon/book))
		if(istype(O,/obj/item/weapon/book/tome))
			to_chat(usr, "Смесь ничего не делает. Что бы это ни было, это не обычные чернила.")
			return
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			to_chat(usr, "Смесь растворяет чернила в книге.")
		else
			to_chat(usr, "Этого не было достаточно...")
	return
/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 15)
		return


/datum/reagent/consumable/ethanol/beer
	name = "Пиво"
	id = "beer"
	description = "Алкогольный напиток, приготовленный из солодовых зерен, хмеля, дрожжей и воды."
	color = "#fbbf0d" // rgb: 251, 191, 13
	boozepwr = 1
	nutriment_factor = 1
	taste_message = "пиво"

/datum/reagent/consumable/ethanol/beer/on_general_digest(mob/living/M)
	..()
	M.jitteriness = max(M.jitteriness - 3,0)

/datum/reagent/consumable/ethanol/kahlua
	name = "Калуа"
	id = "kahlua"
	description = "Широко известный мексиканский ликер со вкусом кофе. Выпускается с 1936 года!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	dizzy_adj = -5
	adj_drowsy = -3
	adj_sleepy = -40

/datum/reagent/consumable/ethanol/kahlua/on_general_digest(mob/living/M)
	..()
	M.make_jittery(5)

/datum/reagent/consumable/ethanol/whiskey
	name = "Виски"
	id = "whiskey"
	description = "Превосходный и хорошо выдержанный односолодовый виски. Черт."
	color = "#ee7732" // rgb: 238, 119, 50
	boozepwr = 2
	dizzy_adj = 4

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Виски особого купажа"
	id = "specialwhiskey"
	description = "Как раз тогда, когда вы подумали, что обычный станционный виски это хорошо... Это шелковистое янтарное добро должно прийти и все испортить."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	dizzy_adj = 4
	slur_start = 30		//amount absorbed after which mob starts slurring
	taste_message = "роскошь"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Локо 13"
	id = "thirteenloko"
	description = "Крепкая смесь кофеина и алкоголя."
	color = "#102000" // rgb: 16, 32, 0
	boozepwr = 2
	nutriment_factor = 1
	taste_message = "вечеринку"

/datum/reagent/consumable/ethanol/thirteenloko/on_general_digest(mob/living/M)
	..()
	M.drowsyness = max(0, M.drowsyness - 7)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.bodytemperature = max(BODYTEMP_NORMAL, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.make_jittery(5)

/datum/reagent/consumable/ethanol/vodka
	name = "Водка"
	id = "vodka"
	description = "Напиток AND выбор заправки номер один для русских во всём мире."
	color = "#619494" // rgb: 97, 148, 148
	boozepwr = 2

/datum/reagent/consumable/ethanol/vodka/on_general_digest(mob/living/M)
	..()
	M.radiation = max(M.radiation - 1,0)

/datum/reagent/consumable/ethanol/bilk
	name = "Билк"
	id = "bilk"
	description = "Это похоже на пиво, смешанное с молоком. Отвратительно."
	color = "#895c4c" // rgb: 137, 92, 76
	boozepwr = 1
	nutriment_factor = 2
	taste_message = "молоко с пивом"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Три-Майл-Айленд Айс Ти"
	id = "threemileisland"
	description = "Создан для женщины, достаточно крепкий для мужчины."
	color = "#666340" // rgb: 102, 99, 64
	boozepwr = 5
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/threemileisland/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 50)

/datum/reagent/consumable/ethanol/gin
	name = "Джин"
	id = "gin"
	description = "Это джин. В космосе."
	color = "#cdd1da" // rgb: 205, 209, 218
	boozepwr = 1
	dizzy_adj = 3
	taste_message = "джин"

/datum/reagent/consumable/ethanol/rum
	name = "Ром"
	id = "rum"
	description = "Йо-хо-хо и всё такое."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	taste_message = "ром"

/datum/reagent/consumable/ethanol/champagne
	name = "Игристое вино"
	id = "champagne"
	description = "Же не манж па си жюр."
	color = "#fcfcee" // rgb: 252, 252, 238
	boozepwr = 1
	taste_message = "игристое вино"

/datum/reagent/consumable/ethanol/tequilla
	name = "Текила"
	id = "tequilla"
	description = "Крепкий алкогольный напиток с умеренным вкусом, произведенный в Мексике. Чувствуете жажду, сеньор?"
	color = "#ffff91" // rgb: 255, 255, 145
	boozepwr = 2
	taste_message = "текилу"

/datum/reagent/consumable/ethanol/vermouth
	name = "Вермут"
	id = "vermouth"
	description = "Вдруг вы чувствуете тягу к мартини..."
	color = "#91ff91" // rgb: 145, 255, 145
	boozepwr = 1.5
	taste_message = "вермут"

/datum/reagent/consumable/ethanol/wine
	name = "Вино"
	id = "wine"
	description = "Алкогольный напиток премиум-класса из дистиллированного виноградного сока."
	color = "#7e4043" // rgb: 126, 64, 67
	boozepwr = 1.5
	dizzy_adj = 2
	slur_start = 65			//amount absorbed after which mob starts slurring
	confused_start = 145	//amount absorbed after which mob starts confusing directions
	taste_message = "вино"

	needed_aspects = list(ASPECT_FOOD = 1, ASPECT_RESCUE = 1)

/datum/reagent/consumable/ethanol/cognac
	name = "Коньяк"
	id = "cognac"
	description = "Сладкий и крепкий алкогольный напиток, полученный после многочисленных перегонок и многолетней выдержки. Классно, как блуд."
	color = "#ab3c05" // rgb: 171, 60, 5
	boozepwr = 1.5
	dizzy_adj = 4
	confused_start = 115	//amount absorbed after which mob starts confusing directions
	taste_message = "коньяк"

/datum/reagent/consumable/ethanol/hooch
	name = "Сивуха"
	id = "hooch"
	description = "Либо чья-то неудача в приготовлении коктейлей, либо попытка изготовления алкоголя. В любом случае, вы действительно хотите это выпить?"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	dizzy_adj = 6
	slurr_adj = 5
	slur_start = 35			//amount absorbed after which mob starts slurring
	confused_start = 90	//amount absorbed after which mob starts confusing directions
	taste_message = "рвоту"

/datum/reagent/consumable/ethanol/ale
	name = "Эль"
	id = "ale"
	description = "Темный алкогольный напиток из ячменного солода и дрожжей."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1
	taste_message = "эль"

/datum/reagent/consumable/ethanol/absinthe
	name = "Абсент"
	id = "absinthe"
	description = "Смотри чтобы зелёная фея не пришла за тобой!"
	color = "#33ee00" // rgb: 51, 238, 0
	boozepwr = 4
	dizzy_adj = 5
	slur_start = 15
	confused_start = 30
	taste_message = "абсент"


/datum/reagent/consumable/ethanol/pwine
	name = "Ядовитое вино"
	id = "pwine"
	description = "Это вообще вино? Токсично! Галлюциноген! Вероятно, ваше начальство потребляет его ведрами!"
	color = "#000000" // rgb: 0, 0, 0 SHOCKER
	boozepwr = 1
	dizzy_adj = 1
	slur_start = 1
	confused_start = 1
	taste_message = "горькое вино"

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

/datum/reagent/consumable/ethanol/sake
	name = "Сакэ"
	id = "sake"
	description = "Любимый напиток анимешников."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "сакэ"


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////


/datum/reagent/consumable/ethanol/goldschlager
	name = "Златовласка"
	id = "goldschlager"
	description = "Стоградусный шнапс с корицей, сделанный для девочек-алкоголиков на весенних каникулах."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "шнапс"

/datum/reagent/consumable/ethanol/patron
	name = "Патрон"
	id = "patron"
	description = "Текила с добавлением серебра, любима клубными алкоголичками."
	color = "#585840" // rgb: 88, 88, 64
	boozepwr = 1.5
	taste_message = "лёгкую текилу"

/datum/reagent/consumable/ethanol/gintonic
	name = "Джин Тоник"
	id = "gintonic"
	description = "Классика всех времён, слабый коктейль."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1
	taste_message = "джин тоник"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Куба Либре"
	id = "cubalibre"
	description = "Ром, смешанный с колой. Viva la revolucion."
	color = "#3e1b00" // rgb: 62, 27, 0
	boozepwr = 1.5
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Виски Кола"
	id = "whiskeycola"
	description = "Виски, смешанный с колой. Удивительно освежающе."
	color = "#3e1b00" // rgb: 62, 27, 0
	boozepwr = 2
	taste_message = "виски с колой"

/datum/reagent/consumable/ethanol/martini
	name = "Классический Мартини"
	id = "martini"
	description = "Вермут с Джином. Не совсем такой, каким наслаждался 007, но все равно вкусно."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "мартини"

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Водка Мартини"
	id = "vodkamartini"
	description = "Водка с Джином. Не совсем такой, каким наслаждался 007, но все равно вкусно."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "горький мартини"

/datum/reagent/consumable/ethanol/white_russian
	name = "Белый Русский"
	id = "whiterussian"
	description = "Это просто твое мнение, чувак..."
	color = "#a68340" // rgb: 166, 131, 64
	boozepwr = 3
	taste_message = "сливочный алкоголь"

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Отвёртка"
	id = "screwdrivercocktail"
	description = "Водка, смешанная с апельсиновым соком. Результат на удивление вкусный."
	color = "#a68310" // rgb: 166, 131, 16
	boozepwr = 3
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/booger
	name = "Козявка"
	id = "booger"
	description = "Фу-у..."
	color = "#8cff8c" // rgb: 140, 255, 140
	boozepwr = 1.5
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Кровавая Мэри"
	id = "bloodymary"
	description = "Странная, но приятная смесь из водки, томатного сока и сока лайма. Или, по крайней мере, вы ДУМАЕТЕ, что красный цвет это томатный сок."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "помидор с бухлом"

/datum/reagent/consumable/ethanol/brave_bull
	name = "Храбрый Бык"
	id = "bravebull"
	description = "Почти такой же эффективный как Женевер."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/tequilla_sunrise
	name = "Текила Санрайз"
	id = "tequillasunrise"
	description = "Текила с апельсиновым соком. Примерно такой же, как и отвёртка, только мексиканский."
	color = "#ffe48c" // rgb: 255, 228, 140
	boozepwr = 2
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Особо Токсичный"
	id = "toxins_special"
	description = "Эта штука ГОРИТ! ВЫЗОВИТЕ ЧЕРТОВ ШАТТЛ!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 5
	taste_message = "ОГОНЬ"

/datum/reagent/consumable/ethanol/toxins_special/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Бипски Смэш"
	id = "beepskysmash"
	description = "Прекращайте пить это и приготовтесь к ЗАКОНУ."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "ЗАКОН"

/datum/reagent/consumable/ethanol/beepsky_smash/on_general_digest(mob/living/M)
	..()
	if(!HAS_TRAIT(M, TRAIT_ALCOHOL_TOLERANCE))
		M.Stun(10)

/datum/reagent/consumable/ethanol/irish_cream
	name = "Ирландские сливки"
	id = "irishcream"
	description = "Сливки, пропитанные виски, чего еще можно ожидать от ирландцев."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "сливочный алкоголь"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "Мэнли Дорф"
	id = "manlydorf"
	description = "Пиво и Эль встречаются друг с другом в этом замечательном коктейле. Только для настоящий мужчин."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "мужественность"

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Лонг Айленд Айс Ти"
	id = "longislandicedtea"
	description = "Всё содержимое винного шкафа, собранное в этом восхитительном коктейле. Предназначено только для алкоголичек среднего возраста."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/moonshine
	name = "Самогон"
	id = "moonshine"
	description = "Вы действительно достигли дна... Ваша печень собрала чемоданы и ушла прошлой ночью."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "метанол и сивушные масла"

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Кофе, ирландские сливки и коньяк. Вы будете разбомблены."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "сливочный алкоголь"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Ирландский кофе"
	id = "irishcoffee"
	description = "Кофе и алкоголь. Пить по утрам это веселее, чем мимозу."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "кофе с бухлом"

/datum/reagent/consumable/ethanol/margarita
	name = "Маргарита"
	id = "margarita"
	description = "На камнях с солью на ободке. Арриба~!"
	color = "#8cff8c" // rgb: 140, 255, 140
	boozepwr = 3
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/black_russian
	name = "Чёрный Русский"
	id = "blackrussian"
	description = "Для людей с непереносимостью лактозы. Все еще такой же классный, как белый русский."
	color = "#360000" // rgb: 54, 0, 0
	boozepwr = 3
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/manhattan
	name = "Манхэттэн"
	id = "manhattan"
	description = "Любимый напиток детектива под прикрытием. Он никогда не мог переварить джин..."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "горький алкоголь"

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Манхэттэнский проект"
	id = "manhattan_proj"
	description = "Любимый напиток ученых для обдумывания способов взорвать станцию."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 5
	taste_message = "горький алкоголь"

/datum/reagent/consumable/ethanol/manhattan_proj/on_general_digest(mob/living/M)
	..()
	M.druggy = max(M.druggy, 30)

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Виски с содовой"
	id = "whiskeysoda"
	description = "Для более изысканного графона."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "заурядность"

/datum/reagent/consumable/ethanol/antifreeze
	name = "Антифриз"
	id = "antifreeze"
	description = "Абсолютное освежение."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "плохой жизненный выбор"

/datum/reagent/consumable/ethanol/antifreeze/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/barefoot
	name = "Босяк"
	id = "barefoot"
	description = "Босый и беременный"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/snowwhite
	name = "Белоснежка"
	id = "snowwhite"
	description = "Прохладный освежающий напиток."
	color = "#ffffff" // rgb: 255, 255, 255
	boozepwr = 1.5
	taste_message = "освежающеий алкоголь"

/datum/reagent/consumable/ethanol/melonliquor
	name = "Дынный ликёр"
	id = "melonliquor"
	description = "Относительно сладкий фруктовый сорокашестиградусный ликёр."
	color = "#138808" // rgb: 19, 136, 8
	boozepwr = 1
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Блю Кюрасао"
	id = "bluecuracao"
	description = "Экзотического синего цвета фруктовый напиток полученный путём перегонки апельсинов."
	color = "#0000cd" // rgb: 0, 0, 205
	boozepwr = 1.5
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/suidream
	name = "Мечта Сьюи"
	id = "suidream"
	description = "Состоит из: белой газировки, блю кюрасао, дынного ликера."
	color = "#00a86b" // rgb: 0, 168, 107
	boozepwr = 0.5
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/demonsblood
	name = "Кровь Демона"
	id = "demonsblood"
	description = "A-А-А-А!!!!"
	color = "#820000" // rgb: 130, 0, 0
	boozepwr = 3
	taste_message = "<span class='warning'>зло</span>"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Водка Тоник"
	id = "vodkatonic"
	description = "На тот случай, когда джин с тоником это недостаточно по-русски."
	color = "#0064c8" // rgb: 0, 100, 200
	boozepwr = 3
	dizzy_adj = 4
	slurr_adj = 3
	taste_message = "шипучий алкоголь"

/datum/reagent/consumable/ethanol/ginfizz
	name = "Джин-физ"
	id = "ginfizz"
	description = "Освежающий лимонный, восхитительно сухой."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	dizzy_adj = 4
	slurr_adj = 3
	taste_message = "шипучий алкоголь"

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Багама-мама"
	id = "bahama_mama"
	description = "Тропический коктейль."
	color = "#ff7f3b" // rgb: 255, 127, 59
	boozepwr = 2
	taste_message = "фруктовый алкоголь"

/datum/reagent/consumable/ethanol/singulo
	name = "Сингуло"
	id = "singulo"
	description = "Блюспейс напиток!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 5
	dizzy_adj = 15
	slurr_adj = 15
	taste_message = "бесконечность"

/datum/reagent/consumable/ethanol/sbiten
	name = "Перцовка"
	id = "sbiten"
	description = "Острая водка! Может быть немного слишком острая для маленьких ребят!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "жгучий алкоголь"

/datum/reagent/consumable/ethanol/sbiten/on_general_digest(mob/living/M)
	..()
	if (M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
		M.bodytemperature = min(BODYTEMP_HEAT_DAMAGE_LIMIT, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/devilskiss
	name = "Поцелуй Дьявола"
	id = "devilskiss"
	description = "Жуткие времена!"
	color = "#a68310" // rgb: 166, 131, 16
	boozepwr = 3
	taste_message = "кровь"

/datum/reagent/consumable/ethanol/red_mead
	name = "Красная медовуха"
	id = "red_mead"
	description = "Напиток истинного Викинга! Не смотря на то что он странного красного цвета..."
	color = "#c73c00" // rgb: 199, 60, 0
	boozepwr = 1.5
	taste_message = "кровь"

/datum/reagent/consumable/ethanol/mead
	name = "Медовуха"
	id = "mead"
	description = "Напиток Викингов, однако, дешёвый."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1.5
	nutriment_factor = 1
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/iced_beer
	name = "Пиво со льдом"
	id = "iced_beer"
	description = "Пиво настолько холодное, что воздух вокруг него замерзает."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 1
	taste_message = "освежающий алкоголь"

/datum/reagent/consumable/ethanol/iced_beer/on_general_digest(mob/living/M)
	..()
	if(M.bodytemperature > 270)
		M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055

/datum/reagent/consumable/ethanol/grog
	name = "Грог"
	id = "grog"
	description = "Разбавленный водой ром. НаноТрейзен одобряет."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 0.5
	taste_message = "ром"

/datum/reagent/consumable/ethanol/aloe
	name = "Алоэ"
	id = "aloe"
	description = "Очень-очень-очень хорошо."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/andalusia
	name = "Андалусия"
	id = "andalusia"
	description = "Хороший напиток со странным названием."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 3
	taste_message = "сладкий алкоголь"


/datum/reagent/consumable/ethanol/alliescocktail
	name = "Коктейль Союзнический"
	id = "alliescocktail"
	description = "Напиток из ваших союзников, не такой сладкий, как из ваших врагов."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "горький алкоголь"

/datum/reagent/consumable/ethanol/acid_spit
	name = "Кислотный плевок"
	id = "acidspit"
	description = "Напиток для смелых, если его неправильно приготовить, может оказаться смертельным!"
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0
	boozepwr = 1.5
	taste_message = "БОЛЬ"

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Официальный напиток оружейного клуба NanoTrasen!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 2
	taste_message = "шоковую дубинку"

/datum/reagent/consumable/ethanol/changelingsting
	name = "Жало Подменыша"
	id = "changelingsting"
	description = "Вы делаете крошечный глоток и чувствуете жжение..."
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 5
	taste_message = "крошечный укол"

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Ирландская Автомобильная Бомба"
	id = "irishcarbomb"
	description = "Ммм, на вкус как шоколадный торт!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 3
	dizzy_adj = 5
	taste_message = "сливочный алкоголь"

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Бомба Синдиката"
	id = "syndicatebomb"
	description = "На вкус как терроризм!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 5
	taste_message = "предложение о работе"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Сюрприз Эрики"
	id = "erikasurprise"
	description = "Сюрприз в том, что он зелёный!"
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 3
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Самый сухой Мартини"
	id = "driestmartini"
	description = "Только для опытных. Вы думаете, что видите песок в бокале."
	nutriment_factor = 1
	color = "#2e6671" // rgb: 46, 102, 113
	boozepwr = 4
	taste_message = "горький алкоголь"

/datum/reagent/consumable/ethanol/bananahonk
	name = "Банана-мама"
	id = "bananahonk"
	description = "Напиток из Рая Клоунов."
	nutriment_factor = 1
	color = "#ffff91" // rgb: 255, 255, 140
	boozepwr = 4
	taste_message = "гудок"

/datum/reagent/consumable/ethanol/silencer
	name = "Глушитель"
	id = "silencer"
	description = "Напиток из Рая Мимов."
	nutriment_factor = 1
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 4
	taste_message = "ммпфф"

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
	name = "Бакарди"
	id = "bacardi"
	description = "Мягкий лёгкий напиток из рома."
	reagent_state = LIQUID
	color = "#ffc0cb" // rgb: 255, 192, 203
	boozepwr = 3
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/bacardialoha
	name = "Бакарди Алоха"
	id = "bacardialoha"
	description = "Сладкая смесь рома, мартини и лаймовой газировки."
	reagent_state = LIQUID
	color = "#c5f415" // rgb: 197, 244, 21
	boozepwr = 4
	taste_message = "сладкий алкоголь"

/datum/reagent/consumable/ethanol/bacardilemonade
	name = "Бакарди Лимонад"
	id = "bacardilemonade"
	description = "Смесь освежающего лимонада и сладкого рома."
	reagent_state = LIQUID
	color = "#c5f415" // rgb: 197, 244, 21
	boozepwr = 3
	taste_message = "сладкий алкоголь"
