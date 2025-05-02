// Plant analyzer

/obj/item/device/plant_analyzer
	name = "plant analyzer"
	cases = list("анализатор растений", "анализатора растений", "анализатору растений", "анализатор растений", "анализатором растений", "анализаторе растений")
	desc = "Ручной сканер, который показывает состояние растений."
	icon = 'icons/obj/device.dmi'
	w_class = SIZE_MINUSCULE
	m_amt = 200
	g_amt = 50
	origin_tech = "materials=1;biotech=1"
	icon_state = "hydro"
	item_state = "plantanalyzer"

	var/output_to_chat = TRUE

/obj/item/device/plant_analyzer/attack_self(mob/user)
	return FALSE

/obj/item/device/plant_analyzer/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "Теперь сканер выводит данные в чат.")
	else
		to_chat(usr, "Теперь сканер выводит данные в отдельном окне.")

/obj/item/device/plant_analyzer/attack(mob/living/carbon/human/M, mob/living/user)
	if(istype(M) && M.species.flags[IS_PLANT])
		add_fingerprint(user)
		var/dat = health_analyze(M, user, TRUE, output_to_chat) // TRUE means limb-scanning mode
		if(output_to_chat)
			var/datum/browser/popup = new(user, "window=[M.name]_scan_report", "Scan Report", 400, 400)
			popup.set_content(dat)
			popup.open()
		else
			to_chat(user, dat)

// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************

/obj/item/seeds
	name = "pack of seeds"
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed" // unknown plant seed - these shouldn't exist in-game
	w_class = SIZE_TINY // Makes them pocketable
	var/hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'//this is now path to plant's overlays (in hydropinic tray)
	var/plantname = "Plants"
	var/product_type
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0 // If is -1, the plant/shroom/weed is never meant to be harvested
	var/oneharvest = 0
	var/potency = -1
	var/growthstages = 0
	var/plant_type = 0 // 0 = 'normal plant'; 1 = weed; 2 = shroom
	var/list/mutatelist = list()

/obj/item/seeds/proc/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	return

/obj/item/seeds/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "*** <B>[plantname]</B> ***")
		to_chat(user, "-Plant Endurance: <span class='notice'>[endurance]</span>")
		to_chat(user, "-Plant Lifespan: <span class='notice'>[lifespan]</span>")
		if(yield != -1)
			to_chat(user, "-Plant Yield: <span class='notice'>[yield]</span>")
		to_chat(user, "-Plant Production: <span class='notice'>[production]</span>")
		if(potency != -1)
			to_chat(user, "-Plant Potency: <span class='notice'>[potency]</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		return FALSE
	return ..() // Fallthrough to item/attackby() so that bags can pick seeds up

/obj/item/seeds/peashooter
	name = "pack of peashooter seeds"
	cases = list("семена Горохострела обыкновенного", "семян Горохострела обыкновенного", "семенам Горохострела обыкновенного", "семена Горохострела обыкновенного", "семенами Горохострела обыкновенного", "семенах Горохострела обыкновенного")
	desc = "Эти семена вырастают в Горохострел"
	icon_state = "seed-peashooter"
	species = "peashooter"
	plantname = "Peashooter Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/peashooter
	lifespan = 20
	endurance = 20
	maturation = 10
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'

/obj/item/seeds/peashooter/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/gibbingtons))
		return
	if(prob(holder.stage * 30))
		mutatelist = list(/obj/item/seeds/peashooter/virus)
		tray.mutatespecie()

/obj/item/seeds/peashooter/virus
	name = "pack of virus peashooter seeds"
	cases = list("семена Горохострела Гиббингтонского", "семян Горохострела Гиббингтонского", "семенам Горохострела Гиббингтонского", "семена Горохострела Гиббингтонского", "семенами Горохострела Гиббингтонского", "семенах Горохострела Гиббингтонского")
	desc = "Эти семена вырастают в Горохострел Гиббингтонский"
	icon_state = "seed-peashooter_virus"
	species = "peashooter_virus"
	plantname = "Virus Peashooter Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/peashooter
	lifespan = 20
	endurance = 20
	maturation = 10
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'

/obj/item/seeds/blackpepper
	name = "pack of piper nigrum seeds"
	cases = list("семена черного перца", "семян черного перца", "семенам черного перца", "семена черного перец", "семенами черного перца", "семенах черного перца")
	desc = "Из этих семян вырастает черный перец."
	icon_state = "seed-blackpepper"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "blackpepper"
	plantname = "Black Pepper"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/blackpepper
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 5
	mutatelist = list(/obj/item/seeds/peashooter)

/obj/item/seeds/blackpepper/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/gibbingtons))
		return
	if(prob(holder.stage * 25))
		mutatelist = list(/obj/item/seeds/peashooter/virus)
		tray.mutatespecie()

/obj/item/seeds/chiliseed
	name = "pack of chili seeds"
	cases = list("семена перца чили", "семян перца чили", "семенам перца чили", "семена перца чили", "семенами перца чили", "семенах перца чили")
	desc = "Из этих семян вырастает перец чили. ОСТРО! ЖЖЕТ!"
	icon_state = "seed-chili"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "chili"
	plantname = "Chili Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/chili
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/icepepperseed)

/obj/item/seeds/plastiseed
	name = "pack of plastellium mycelium"
	cases = list("мицелий пластеллия", "мицелия пластеллия", "мицелию пластеллия", "мицелий пластеллия", "мицелием пластеллия", "мицелии пластеллия")
	desc = "Из этого мицелия вырастает пластеллий."
	icon_state = "mycelium-plast"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "plastellium"
	plantname = "Plastellium"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/plastellium
	lifespan = 15
	endurance = 17
	maturation = 5
	production = 6
	yield = 6
	oneharvest = 1
	potency = 20
	plant_type = 2
	growthstages = 3

/obj/item/seeds/grapeseed
	name = "pack of grape seeds"
	cases = list("семена винограда", "семян винограда", "семенам винограда", "семена винограда", "семенами винограда", "семенах винограда")
	desc = "Из этих семян вырастают виноградные лозы."
	icon_state = "seed-grapes"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "grape"
	plantname = "Grape Vine"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2
	mutatelist = list(/obj/item/seeds/greengrapeseed)

/obj/item/seeds/greengrapeseed
	name = "pack of green grape seeds"
	cases = list("семена зеленого винограда", "семян зеленого винограда", "семенам зеленого винограда", "семена зеленого винограда", "семенами зеленого винограда", "семенах зеленого винограда")
	desc = "Из этих семян вырастают лозы зеленого винограда."
	icon_state = "seed-greengrapes"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "greengrape"
	plantname = "Green-Grape Vine"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 2

/obj/item/seeds/cabbageseed
	name = "pack of cabbage seeds"
	cases = list("семена капусты", "семян капусты", "семенам капусты", "семена капусты", "семенами капусты", "семенах капусты")
	desc = "Из этих семян вырастает капуста."
	icon_state = "seed-cabbage"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "cabbage"
	plantname = "Cabbages"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 1

/obj/item/seeds/cucumberseed
	name = "pack of cucumber seeds"
	cases = list("семена огурцов", "семян огурцов", "семенам огурцов", "семена огурцов", "семенами огурцов", "семенах огурцов")
	desc = "Эти семена вырастают в огурцы."
	icon_state = "seed-cucumber"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "cucumber"
	plantname = "Cucumbers"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/cucumber
	lifespan = 30
	endurance = 20
	maturation = 3
	production = 4
	yield = 4
	potency = 4
	plant_type = 0
	growthstages = 4

/obj/item/seeds/tobacco_space
	name = "pack of space tobacco seeds"
	cases = list("семена космического табака", "семян космического табака", "семенам космического табака", "семена космического табака", "семенами космического табака", "семенах космического табака")
	desc = "Из этих семян вырастает космический табак."
	icon_state = "seed-stobacco"
	species = "stobacco"
	plantname = "Space Tobacco Plant"
	hydroponictray_icon_path = 'icons/obj/hydroponics/hydroponics.dmi'
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space
	plant_type = 0
	growthstages = 3
	yield = 10
	lifespan = 20
	maturation = 3
	production = 5
	endurance = 20

/obj/item/seeds/tobacco
	name = "pack of tobacco seeds"
	cases = list("семена табака", "семян табака", "семенам табака", "семена табака", "семенами табака", "семенах табака")
	desc = "Из этих семян вырастает табак."
	icon_state = "seed-tobacco"
	species = "tobacco"
	plantname = "Tobacco Plant"
	hydroponictray_icon_path = 'icons/obj/hydroponics/hydroponics.dmi'
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/tobacco
	plant_type = 0
	growthstages = 3
	yield = 10
	lifespan = 20
	maturation = 3
	production = 5
	endurance = 20

/obj/item/seeds/tobacco/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/arousal))
		return
	if(prob(holder.stage * 10))
		mutatelist |= /obj/item/seeds/tobacco_space

/obj/item/seeds/shandseed
	name = "pack of s'rendarr's hand seeds"
	cases = list("семена Длани С'рендарра", "семян Длани С'рендарра", "семенам Длани С'рендарра", "семена Длани С'рендарра", "семенами Длани С'рендарра", "семенах Длани С'рендарра")
	desc = "Из этих семян вырастает полезная трава под названием «Длань С'рендара», произрастающая на Адомае."
	icon_state = "seed-shand"
	species = "shand"
	plantname = "S'Rendarr's Hand"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/shand
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/shandseed/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/arousal))
		return
	if(prob(holder.stage * 10))
		mutatelist |= /obj/item/seeds/tobacco

/obj/item/seeds/mtearseed
	name = "pack of messa's tear seeds"
	cases = list("семена Слезы Мессы", "семян Слезы Мессы", "семенам Слезы Мессы", "семена Слезы Мессы", "семенами Слезы Мессы", "семенах Слезы Мессы")
	desc = "Из этих семян вырастает полезная трава под названием «Слеза Мессы», произрастающая на Адомае."
	icon_state = "seed-mtear"
	species = "mtear"
	plantname = "Messa's Tear"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mtear
	lifespan = 50
	endurance = 25
	maturation = 3
	production = 5
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/berryseed
	name = "pack of berry seeds"
	cases = list("семена ягод", "семян ягод", "семенам ягод", "семена ягод", "семенами ягод", "семенах ягод")
	desc = "Из этих семян вырастают кусты ягод."
	icon_state = "seed-berry"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "berry"
	plantname = "Berry Bush"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/berries
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/glowberryseed,/obj/item/seeds/poisonberryseed)

/obj/item/seeds/glowberryseed
	name = "pack of glow-berry seeds"
	cases = list("семена светоягод", "семян светоягод", "семенам светоягод", "семена светоягод", "семенами светоягод", "семенах светоягод")
	desc = "Из этих семян вырастают кусты светящихся ягод."
	icon_state = "seed-glowberry"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "glowberry"
	plantname = "Glow-Berry Bush"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	lifespan = 30
	endurance = 25
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bananaseed
	name = "pack of banana seeds"
	cases = list("семена банана", "семян банана", "семенам банана", "семена банана", "семенами банана", "семенах банана")
	desc = "Из этих семян вырастает банановое дерево."
	icon_state = "seed-banana"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "banana"
	plantname = "Banana Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/honkyseed)

/obj/item/seeds/laughweedseed
	name = "pack of laughweed seeds"
	cases = list("семена смехтравы", "семян смехтравы", "семенам смехтравы", "семена смехтравы", "семенами смехтравы", "семенах смехтравы")
	desc = "Из этих семян вырастает смехтрава. Хи-хи."
	icon_state = "seed-laughweed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'
	species = "laughweed"
	plantname = "Laughweed"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/laughweed
	lifespan = 30
	endurance = 25
	maturation = 6
	production = 6
	yield = 4
	plant_type = 1
	growthstages = 1
	mutatelist = list(/obj/item/seeds/megaweedseed,/obj/item/seeds/blackweedseed)

/obj/item/seeds/megaweedseed
	name = "pack of megaweed seeds"
	cases = list("семена мегатравки", "семян мегатравки", "семенам мегатравки", "семена мегатравки", "семенами мегатравки", "семенах мегатравки")
	desc = "Из этих семян вырастает мегатравка. Хе-хе-хе."
	icon_state = "seed-megaweed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'
	species = "megaweed"
	plantname = "Megaweed"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/megaweed
	lifespan = 30
	endurance = 25
	maturation = 6
	production = 6
	yield = 4
	plant_type = 1
	growthstages = 1

/obj/item/seeds/blackweedseed
	name = "pack of deathweed seeds"
	cases = list("семена смертьтравы", "семян смертьтравы", "семенам смертьтравы", "семена смертьтравы", "семенами смертьтравы", "семенах смертьтравы")
	desc = "Из этих семян вырастает смертьтрава. ХА-ХА-КХ-Х-ХА..."
	icon_state = "seed-blackweed"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing.dmi'
	species = "blackweed"
	plantname = "Deathweed"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/blackweed
	lifespan = 30
	endurance = 25
	maturation = 6
	production = 6
	yield = 4
	plant_type = 1
	growthstages = 1

/obj/item/seeds/honkyseed
	name = "pack of honk-banana seeds"
	cases = list("семена клоунского банана", "семян клоунского банана", "семенам клоунского банана", "семена клоунского банана", "семенами клоунского банана", "семенах клоунского банана")
	desc = "Из этих семян вырастает банановое дерево."
	icon_state = "seed-banana-honk"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "honk"
	plantname = "Honk banana Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk
	lifespan = 50
	endurance = 30
	maturation = 6
	production = 6
	yield = 3
	plant_type = 0
	growthstages = 6

/obj/item/seeds/eggplantseed
	name = "pack of eggplant seeds"
	cases = list("семена баклажана", "семян баклажана", "семенам баклажана", "семена баклажана", "семенами баклажана", "семенах баклажана")
	desc = "Из этих семян вырастают округлые плоды, похожие на большие яйца."
	icon_state = "seed-eggplant"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "eggplant"
	plantname = "Eggplants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 6
	yield = 2
	potency = 20
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/eggyseed)

/obj/item/seeds/eggyseed
	name = "pack of eggplant seeds"
	cases = list("семена баклажана", "семян баклажана", "семенам баклажана", "семена баклажана", "семенами баклажана", "семенах баклажана")
	desc = "Из этих семян вырастают округлые плоды, похожие на большие яйца."
	icon_state = "seed-eggy"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "eggy"
	plantname = "Eggplants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/egg
	lifespan = 75
	endurance = 15
	maturation = 6
	production = 12
	yield = 2
	plant_type = 0
	growthstages = 6

/obj/item/seeds/bloodtomatoseed
	name = "pack of blood-tomato seeds"
	cases = list("семена кровавого помидора", "семян кровавого помидора", "семенам кровавого помидора", "семена кровавого помидора", "семенами кровавого помидора", "семенах кровавого помидора")
	desc = "Из этих семян вырастает кровавый помидор."
	icon_state = "seed-bloodtomato"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "bloodtomato"
	plantname = "Blood-Tomato Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	lifespan = 25
	endurance = 20
	maturation = 8
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/tomatoseed
	name = "pack of tomato seeds"
	cases = list("семена помидора", "семян помидора", "семенам помидора", "семена помидора", "семенами помидора", "семенах помидора")
	desc = "Из этих семян вырастает помидор."
	icon_state = "seed-tomato"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "tomato"
	plantname = "Tomato Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluetomatoseed, /obj/item/seeds/bloodtomatoseed, /obj/item/seeds/killertomatoseed)

/obj/item/seeds/killertomatoseed
	name = "pack of killer-tomato seeds"
	cases = list("семена помидора-убийцы", "семян помидора-убийцы", "семенам помидора-убийцы", "семена помидора-убийцы", "семенами помидора-убийцы", "семенах помидора-убийцы")
	desc = "Из этих семян вырастает помидор-убийца."
	icon_state = "seed-killertomato"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "killertomato"
	plantname = "Killer-Tomato Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	oneharvest = 1
	growthstages = 2

/obj/item/seeds/bluetomatoseed
	name = "pack of blue-tomato seeds"
	cases = list("семена голубого помидора", "семян голубого помидора", "семенам голубого помидора", "семена голубого помидора", "семенами голубого помидора", "семенах голубого помидора")
	desc = "Из этих семян вырастает голубой помидор."
	icon_state = "seed-bluetomato"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "bluetomato"
	plantname = "Blue-Tomato Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/bluespacetomatoseed)

/obj/item/seeds/bluespacetomatoseed
	name = "pack of bluespace tomato seeds"
	cases = list("семена блюспейс помидора", "семян блюспейс помидора", "семенам блюспейс помидора", "семена блюспейс помидора", "семенами блюспейс помидора", "семенах блюспейс помидора")
	desc = "Из этих семян вырастает блюспейс помидор."
	icon_state = "seed-bluespacetomato"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "bluespacetomato"
	plantname = "Bluespace Tomato Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/cornseed
	name = "pack of corn seeds"
	cases = list("семена кукурузы", "семян кукурузы", "семенам кукурузы", "семена кукурузы", "семенами кукурузы", "семенах кукурузы")
	desc = "Если есть сырой - может скукурузить!"
	icon_state = "seed-corn"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "corn"
	plantname = "Corn Stalks"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/corn
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 6
	yield = 3
	plant_type = 0
	oneharvest = 1
	potency = 20
	growthstages = 3

/obj/item/seeds/fraxinella
	name = "pack of fraxinella seeds"
	cases = list("семена ясенца", "семян ясенца", "семенам ясенца", "семена ясенца", "семенами ясенца", "семенах ясенца")
	desc = "Из этих семян вырастает ясенец."
	icon_state = "seed-fraxinella"
	species = "fraxinella"
	plantname = "Fraxinella Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_flowers.dmi'
	endurance = 10
	maturation = 8
	production = 6
	yield = 6
	potency = 20
	lifespan = 25
	growthstages = 3

/obj/item/seeds/poppyseed
	name = "pack of poppy seeds"
	cases = list("семена мака", "семян мака", "семенам мака", "семена мака", "семенами мака", "семенах мака")
	desc = "Из этих семян вырастает мак."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	lifespan = 25
	endurance = 10
	potency = 20
	maturation = 8
	production = 6
	yield = 6
	plant_type = 0
	oneharvest = 1
	growthstages = 3

/obj/item/seeds/poppyseed/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/fire))
		return
	if(prob(holder.stage * 10))
		mutatelist |= /obj/item/seeds/fraxinella

/obj/item/seeds/potatoseed
	name = "pack of potato seeds"
	cases = list("семена картофеля", "семян картофеля", "семенам картофеля", "семена картофеля", "семенами картофеля", "семенах картофеля")
	desc = "Вари! Толки! Туши! Но для начала посади в грядку."
	icon_state = "seed-potato"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "potato"
	plantname = "Potato-Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/potato
	lifespan = 30
	endurance = 15
	maturation = 10
	production = 1
	yield = 4
	plant_type = 0
	oneharvest = 1
	potency = 10
	growthstages = 4

/obj/item/seeds/icepepperseed
	name = "pack of ice-pepper seeds"
	cases = list("семена ледяного перца", "семян ледяного перца", "семенам ледяного перца", "семена ледяного перца", "семенами ледяного перца", "семенах ледяного перца")
	desc = "Из этих семян вырастает ледяной перец."
	icon_state = "seed-icepepper"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "chiliice"
	plantname = "Ice-Pepper Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 4
	potency = 20
	plant_type = 0
	growthstages = 6

/obj/item/seeds/soyaseed
	name = "pack of soybean seeds"
	cases = list("семена соевых бобов", "семян соевых бобов", "семенам соевых бобов", "семена соевых бобов", "семенами соевых бобов", "семенах соевых бобов")
	desc = "Из этих семян вырастают соевые бобы."
	icon_state = "seed-soybean"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "soybean"
	plantname = "Soybean Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	lifespan = 25
	endurance = 15
	maturation = 4
	production = 4
	yield = 3
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/meatwheat
	name = "pack of meatwheat seeds"
	cases = list("семена пшеничного мяса", "семян пшеничного мяса", "семенам пшеничного мяса", "семена пшеничного мяса", "семенами пшеничного мяса", "семенах пшеничного мяса")
	desc = "Если вы когда-нибудь хотели свести вегетарианца с ума, то это отличный способ."
	icon_state = "seed-meatwheat"
	species = "meatwheat"
	plantname = "Meatwheat"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/meat/meatwheat
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 15
	oneharvest = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/wheatseed
	name = "pack of wheat seeds"
	cases = list("семена пшеницы", "семян пшеницы", "семенам пшеницы", "семена пшеницы", "семенами пшеницы", "семенах пшеницы")
	desc = "Они могут вырасти в сорняки, а могут и нет."
	icon_state = "seed-wheat"
	species = "wheat"
	plantname = "Wheat Stalks"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	oneharvest = 1
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/durathread)

/obj/item/seeds/wheatseed/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/radian))
		return
	if(prob(holder.stage * 10))
		mutatelist |= /obj/item/seeds/meatwheat

/obj/item/seeds/riceseed
	name = "pack of rice seeds"
	cases = list("семена риса", "семян риса", "семенам риса", "семена риса", "семенами риса", "семенах риса")
	desc = "Из этих семян вырастает рисовый стебель."
	icon_state = "seed-rice"
	species = "rice"
	plantname = "Rice Stalks"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk
	lifespan = 25
	endurance = 15
	maturation = 6
	production = 1
	yield = 4
	potency = 5
	oneharvest = 1
	plant_type = 0
	growthstages = 4

/obj/item/seeds/carrotseed
	name = "pack of carrot seeds"
	cases = list("семена моркови", "семян моркови", "семенам моркови", "семена моркови", "семенами моркови", "семенах моркови")
	desc = "Из этих семян вырастает морковь."
	icon_state = "seed-carrot"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "carrot"
	plantname = "Carrots"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	lifespan = 25
	endurance = 15
	maturation = 10
	production = 1
	yield = 5
	potency = 10
	oneharvest = 1
	plant_type = 0
	growthstages = 3

/obj/item/seeds/reishimycelium
	name = "pack of reishi mycelium"
	cases = list("мицелий рейши", "мицелия рейши", "мицелию рейши", "мицелий рейши", "мицелием рейши", "мицелие рейши")
	desc = "Из этого мицелия вырастает что-то расслабляющее."
	icon_state = "mycelium-reishi"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "reishi"
	plantname = "Reishi"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	lifespan = 35
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 15 // Sleeping based on potency?
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/amanitamycelium
	name = "pack of fly amanita mycelium"
	cases = list("мицелий мухомора", "мицелия мухомора", "мицелию мухомора", "мицелий мухомора", "мицелием мухомора", "мицелие мухомора")
	desc = "Из этого мицелия вырастает нечто ужасное."
	icon_state = "mycelium-amanita"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "amanita"
	plantname = "Fly Amanitas"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	lifespan = 50
	endurance = 35
	maturation = 10
	production = 5
	yield = 4
	potency = 10 // Damage based on potency?
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/angelmycelium)

/obj/item/seeds/angelmycelium
	name = "pack of destroying angel mycelium"
	cases = list("мицелий бледной поганки", "мицелия бледной поганки", "мицелию бледной поганки", "мицелий бледной поганки", "мицелием бледной поганки", "мицелии бледной поганки")
	desc = "Из этого мицелия вырастает что-то разрушительное."
	icon_state = "mycelium-angel"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "angel"
	plantname = "Destroying Angels"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	lifespan = 50
	endurance = 35
	maturation = 12
	production = 5
	yield = 2
	potency = 35
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/libertymycelium
	name = "pack of liberty-cap mycelium"
	cases = list("мицелий грибов псилоцибе", "мицелия грибов псилоцибе", "мицелию грибов псилоцибе", "мицелий грибов псилоцибе", "мицелием грибов псилоцибе", "мицелии грибов псилоцибе")
	desc = "Из этого мицелия вырастают грозди грибов псилоцибе."
	icon_state = "mycelium-liberty"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "liberty"
	plantname = "Liberty-Caps"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	lifespan = 25
	endurance = 15
	maturation = 7
	production = 1
	yield = 5
	potency = 15 // Lowish potency at start
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/jupitercup
	name = "pack of jupiter cup mycelium"
	cases = list("мицелий юпитерской чашечки", "мицелия юпитерской чашечки", "мицелию юпитерской чашечки", "мицелий юпитерской чашечки", "мицелием юпитерской чашечки", "мицелии юпитерской чашечки")
	desc = "Из этого мицелия вырастают юпитерские чашечки. Зевс бы позавидовал силе, которая у тебя под рукой."
	icon_state = "mycelium-jupitercup"
	species = "jupitercup"
	plantname = "Jupiter Cups"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/jupitercup
	lifespan = 40
	production = 4
	endurance = 8
	yield = 4
	potency = 15
	growthstages = 2
	oneharvest = TRUE
	plant_type = 2

/obj/item/seeds/chantermycelium
	name = "pack of chanterelle mycelium"
	cases = list("мицелий лисичек", "мицелия лисичек", "мицелию лисичек", "мицелий лисичек", "мицелием лисичек", "мицелие лисичек")
	desc = "Из этого мицелия вырастают грибы-лисички."
	icon_state = "mycelium-chanter"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "chanter"
	plantname = "Chanterelle Mushrooms"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	lifespan = 35
	endurance = 20
	maturation = 7
	production = 1
	yield = 5
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/chantermycelium/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/conductivity))
		return
	if(prob(holder.stage * 10))
		mutatelist = list(/obj/item/seeds/jupitercup)
		tray.mutatespecie()

/obj/item/seeds/towermycelium
	name = "pack of tower-cap mycelium"
	cases = list("мицелий башенного гриба", "мицелия башенного гриба", "мицелию башенного гриба", "мицелий башенного гриба", "мицелием башенного гриба", "мицелие башенного гриба")
	desc = "Из этого мицелия вырастают башенные грибы."
	icon_state = "mycelium-tower"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "towercap"
	plantname = "Tower Caps"
	product_type = /obj/item/weapon/grown/log
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 5
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/glowshroom
	name = "pack of glowshroom mycelium"
	cases = list("мицелий светогрибов", "мицелия светогрибов", "мицелию светогрибов", "мицелий светогрибов", "мицелием светогрибов", "мицелие светогрибов")
	desc = "Из этого мицелия -просветают- особые грибы!"
	icon_state = "mycelium-glowshroom"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "glowshroom"
	plantname = "Glowshrooms"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3 //-> spread
	potency = 30 //-> brightness
	oneharvest = 1
	growthstages = 4
	plant_type = 2

/obj/item/seeds/plumpmycelium
	name = "pack of plump-helmet mycelium"
	cases = list("мицелий толстошлемника", "мицелия толстошлемника", "мицелию толстошлемника", "мицелий толстошлемника", "мицелием толстошлемника", "мицелие толстошлемника")
	desc = "Из этого мицелия вырастают шлемы... вроде бы."
	icon_state = "mycelium-plump"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "plump"
	plantname = "Plump-Helmet Mushrooms"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	lifespan = 25
	endurance = 15
	maturation = 8
	production = 1
	yield = 4
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2
	mutatelist = list(/obj/item/seeds/walkingmushroommycelium)

/obj/item/seeds/walkingmushroommycelium
	name = "pack of walking mushroom mycelium"
	cases = list("мицелий ходячего гриба", "мицелия ходячего гриба", "мицелию ходячего гриба", "мицелий ходячего гриба", "мицелием ходячего гриба", "мицелие ходячего гриба")
	desc = "Этот мицелий вырастает таким большим, словно хорошо кушал кашку!"
	icon_state = "mycelium-walkingmushroom"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_mushrooms.dmi'
	species = "walkingmushroom"
	plantname = "Walking Mushrooms"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	lifespan = 30
	endurance = 30
	maturation = 5
	production = 1
	yield = 1
	potency = 0
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/nettleseed
	name = "pack of nettle seeds"
	cases = list("семена крапивы", "семян крапивы", "семенам крапивы", "семена крапивы", "семенами крапивы", "семенах крапивы")
	desc = "Из этих семян вырастает крапива."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product_type = /obj/item/weapon/grown/nettle
	lifespan = 30
	endurance = 40 // tuff like a toiger
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1
	mutatelist = list(/obj/item/seeds/deathnettleseed)

/obj/item/seeds/deathnettleseed
	name = "pack of death-nettle seeds"
	cases = list("семена смерто-крапивы", "семян смерто-крапивы", "семенам смерто-крапивы", "семена смерто-крапивы", "семенами смерто-крапивы", "семенах смерто-крапивы")
	desc = "Из этих семян вырастает смерто-крапива."
	icon_state = "seed-deathnettle"
	species = "deathnettle"
	plantname = "Death Nettles"
	product_type = /obj/item/weapon/grown/deathnettle
	lifespan = 30
	endurance = 25
	maturation = 8
	production = 6
	yield = 2
	potency = 10
	oneharvest = 0
	growthstages = 5
	plant_type = 1

/obj/item/seeds/weeds
	name = "pack of weed seeds"
	cases = list("семена травки", "семян травки", "семенам травки", "семена травки", "семенами травки", "семенах травки")
	desc = "Эй, ма бой, хочешь дунуть?"
	icon_state = "seed"
	species = "weeds"
	plantname = "Starthistle"
	product_type = null
	lifespan = 100
	endurance = 50 // damm pesky weeds
	maturation = 5
	production = 1
	yield = -1
	potency = -1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/harebell
	name = "pack of harebell seeds"
	cases = list("семена колокольчика", "семян колокольчика", "семенам колокольчика", "семена колокольчика", "семенами колокольчика", "семенах колокольчика")
	desc = "Из этих семян вырастают милые маленькие цветочки."
	icon_state = "seed-harebell"
	species = "harebell"
	plantname = "Harebells"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 1
	oneharvest = 1
	growthstages = 4
	plant_type = 1

/obj/item/seeds/sunflowerseed
	name = "pack of sunflower seeds"
	cases = list("семена подсолнуха", "семян подсолнуха", "семенам подсолнуха", "семена подсолнуха", "семенами подсолнуха", "семенах подсолнуха")
	desc = "Из этих семян вырастают подсолнухи."
	icon_state = "seed-sunflower"
	species = "sunflower"
	plantname = "Sunflowers"
	product_type = /obj/item/weapon/grown/sunflower
	lifespan = 25
	endurance = 20
	maturation = 6
	production = 1
	yield = 2
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 1

/obj/item/seeds/brownmold
	name = "pack of brown mold"
	cases = list("упаковка коричневой плесени", "упаковки коричневой плесени", "упаковке коричневой плесени", "упаковку коричневой плесени", "упаковкой коричневой плесени", "упаковке коричневой плесени")
	desc = "Оу... заплесневело."
	icon_state = "seed"
	species = "mold"
	plantname = "Brown Mold"
	product_type = null
	lifespan = 50
	endurance = 30
	maturation = 10
	production = 1
	yield = -1
	potency = 1
	oneharvest = 1
	growthstages = 3
	plant_type = 2

/obj/item/seeds/appleseed
	name = "pack of apple seeds"
	cases = list("семена яблок", "семян яблок", "семенам яблок", "семена яблок", "семенами яблок", "семенах яблок")
	desc = "Из этих семян вырастает яблоня."
	icon_state = "seed-apple"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "apple"
	plantname = "Apple Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/apple
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/goldappleseed, /obj/item/seeds/poisonedappleseed)

/obj/item/seeds/poisonedappleseed
	name = "pack of apple seeds"
	cases = list("семена яблок", "семян яблок", "семенам яблок", "семена яблок", "семенами яблок", "семенах яблок")
	desc = "Из этих семян вырастает яблоня."
	icon_state = "seed-apple"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "apple"
	plantname = "Apple Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	lifespan = 55
	endurance = 35
	maturation = 6
	production = 6
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/goldappleseed
	name = "pack of golden apple seeds"
	cases = list("семена золотых яблок", "семян золотых яблок", "семенам золотых яблок", "семена золотых яблок", "семенами золотых яблок", "семенах золотых яблок")
	desc = "Из этих семян вырастает золотая яблоня. Хорошо, что в космосе не водятся жар-птицы."
	icon_state = "seed-goldapple"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "goldapple"
	plantname = "Golden Apple Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/goldapple
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/chureech_nut
	name = "pack of Chur'eech seeds"
	cases = list("пачка семян ореха Чур'их", "пачки семян ореха Чур'их", "пачке семян ореха Чур'их", "пачку семян ореха Чур'их", "пачкой семян ореха Чур'их", "пачке семян ореха Чур'их")
	desc = "Эти семена вырастут в дерево, известное среди народа таяран своими обильными плодами орехов и съестными листьями."
	icon_state = "seed-chureech"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "chureech"
	plantname = "Chur'eech tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/chureech_nut
	lifespan = 55
	endurance = 35
	maturation = 10
	production = 10
	yield = 5
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/tea_astra
	name = "pack of tea astra seeds"
	cases = list("семена чайной астры", "семян чайной астры", "семенам чайной астры", "семена чайной астры", "семенами чайной астры", "семенах чайной астры")
	desc = "Из этих семян вырастает чайная астра."
	icon_state = "seed-teaastra"
	species = "teaastra"
	plantname = "Tea Astra Plant"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	lifespan = 20
	maturation = 5
	production = 5
	yield = 5
	growthstages = 5
	endurance = 20

/obj/item/seeds/tea
	name = "pack of tea aspera seeds"
	cases = list("семена чая", "семян чая", "семенам чая", "семена чая", "семенами чая", "семенах чая")
	desc = "Из этих семян вырастает чай."
	icon_state = "seed-teaaspera"
	species = "teaaspera"
	plantname = "Tea Aspera Plant"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/tea
	lifespan = 20
	maturation = 5
	production = 5
	yield = 5
	growthstages = 5
	endurance = 20
	mutatelist = list(/obj/item/seeds/tea_astra)

/obj/item/seeds/ambrosiavulgarisseed
	name = "pack of ambrosia vulgaris seeds"
	cases = list("семена амброзии обыкновенной", "семян амброзии обыкновенной", "семенам амброзии обыкновенной", "семена амброзии обыкновенной", "семенами амброзии обыкновенной", "семенах амброзии обыкновенной")
	desc = "Из этих семян вырастает амброзия обыкновенная — растение, выращиваемое исключительно в медицинских целях."
	icon_state = "seed-ambrosiavulgaris"
	species = "ambrosiavulgaris"
	plantname = "Ambrosia Vulgaris"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/ambrosiadeusseed)

/obj/item/seeds/ambrosiavulgarisseed/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(!istype(E, /datum/disease2/effect/bactericidal_tannins))
		return
	if(prob(holder.stage * 10))
		mutatelist |= /obj/item/seeds/tea

/obj/item/seeds/ambrosiadeusseed
	name = "pack of ambrosia deus seeds"
	cases = list("семена амброзии божественной", "семян амброзии божественной", "семенам амброзии божественной", "семена амброзии божественной", "семенами амброзии божественной", "семенах амброзии божественной")
	desc = "Из этих семян вырастает амброзия божественная. Может ли это быть пищей богов...?"
	icon_state = "seed-ambrosiadeus"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus
	lifespan = 60
	endurance = 25
	maturation = 6
	production = 6
	yield = 6
	potency = 5
	plant_type = 0
	growthstages = 6

/obj/item/seeds/whitebeetseed
	name = "pack of white-beet seeds"
	cases = list("семена сахарной свеклы", "семян сахарной свеклы", "семенам сахарной свеклы", "семена сахарной свеклы", "семенами сахарной свеклы", "семенах сахарной свеклы")
	desc = "Из этих семян вырастает сахарная свекла."
	icon_state = "seed-whitebeet"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_vegetables.dmi'
	species = "whitebeet"
	plantname = "White-Beet Plants"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 6
	oneharvest = 1
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/sugarcaneseed
	name = "pack of sugarcane seeds"
	cases = list("семена сахарного тростника", "семян сахарного тростника", "семенам сахарного тростника", "семена сахарного тростника", "семенами сахарного тростника", "семенах сахарного тростника")
	desc = "Из этих семян вырастает сахарный тростник."
	icon_state = "seed-sugarcane"
	species = "sugarcane"
	plantname = "Sugarcane"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	lifespan = 60
	endurance = 50
	maturation = 3
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 3

/obj/item/seeds/watermelonseed
	name = "pack of watermelon seeds"
	cases = list("семена арбуза", "семян арбуза", "семенам арбуза", "семена арбуза", "семенами арбуза", "семенах арбуза")
	desc = "Из этих семян вырастает арбуз."
	icon_state = "seed-watermelon"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "watermelon"
	plantname = "Watermelon Vines"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 1
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/gourdseed)

/obj/item/seeds/pumpkinseed
	name = "pack of pumpkin seeds"
	cases = list("семена тыквы", "семян тыквы", "семенам тыквы", "семена тыквы", "семенами тыквы", "семенах тыквы")
	desc = "Из этих семян вырастают лозы тыквы."
	icon_state = "seed-pumpkin"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "pumpkin"
	plantname = "Pumpkin Vines"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	lifespan = 50
	endurance = 40
	maturation = 6
	production = 6
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 3
	mutatelist = list(/obj/item/seeds/gourdseed)

/obj/item/seeds/gourdseed
	name = "pack of gourd seeds"
	cases = list("семена тыквяка", "семян тыквяка", "семенам тыквяка", "семена тыквяка", "семенами тыквяка", "семенах тыквяка")
	desc = "Вырастают в отборный декоративный тыквяк. В еду не потреблять!"
	icon_state = "seed-gourd"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "gourd"
	plantname = "Gourd"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/gourd
	lifespan = 70
	endurance = 50
	maturation = 6
	production = 6
	yield = 1
	potency = 10
	plant_type = 0
	growthstages = 3
	mutatelist = list(/obj/item/seeds/pumpkinseed, /obj/item/seeds/watermelonseed, /obj/item/seeds/magicgourdseed)

/obj/item/seeds/gourdseed/atom_init()
	. = ..()
	name = "pack of [get_gourd_name()] seeds"

/obj/item/seeds/magicgourdseed
	name = "pack of gourd seeds"
	cases = list("семена тыквяка", "семян тыквяка", "семенам тыквяка", "семена тыквяка", "семенами тыквяка", "семенах тыквяка")
	desc = "Вырастают в отборный декоративный тыквяк. В еду не потреблять!"
	icon_state = "seed-gourd_magic"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "magic_gourd"
	plantname = "Refreshing Gourd"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/gourd/magic
	lifespan = 70
	endurance = 50
	maturation = 6
	production = 6
	yield = 1
	potency = 20
	plant_type = 0
	growthstages = 3
	mutatelist = list(/obj/item/seeds/gourdseed, /obj/item/seeds/pumpkinseed, /obj/item/seeds/watermelonseed)

/obj/item/seeds/magicgourdseed/atom_init()
	. = ..()
	name = "pack of refreshing [get_gourd_name()] seeds"

/obj/item/seeds/limeseed
	name = "pack of lime seeds"
	cases = list("семена лайма", "семян лайма", "семенам лайма", "семена лайма", "семенами лайма", "семенах лайма")
	desc = "Эти семена очень кислые."
	icon_state = "seed-lime"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "lime"
	plantname = "Lime Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/lime
	lifespan = 55
	endurance = 50
	maturation = 6
	production = 6
	yield = 4
	potency = 15
	plant_type = 0
	growthstages = 6

/obj/item/seeds/lemonseed
	name = "pack of lemon seeds"
	cases = list("семена лимона", "семян лимона", "семенам лимона", "семена лимона", "семенами лимона", "семенах лимона")
	desc = "Эти семена кислые."
	icon_state = "seed-lemon"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "lemon"
	plantname = "Lemon Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/cashseed)

/obj/item/seeds/cashseed
	name = "pack of money seeds"
	cases = list("семена денежного дерева", "семян денежного дерева", "семенам денежного дерева", "семена денежного дерева", "семенами денежного дерева", "семенах денежного дерева")
	desc = "Когда жизнь дает тебе лимоны, мутируй их в наличку."
	icon_state = "seed-cash"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "cashtree"
	plantname = "Money Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/money
	lifespan = 55
	endurance = 45
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	plant_type = 0
	growthstages = 6

/obj/item/seeds/orangeseed
	name = "pack of orange seed"
	cases = list("семена апельсина", "семян апельсина", "семенам апельсина", "семена апельсина", "семенами апельсина", "семенах апельсина")
	desc = "Эти семена кислые."
	icon_state = "seed-orange"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "orange"
	plantname = "Orange Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/orange
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 5
	potency = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/mandarinseed
	name = "pack of mandarin seed"
	cases = list("семена мандарина", "семян мандарина", "семенам мандарина", "семена мандарина", "семенами мандарина", "семенах мандарина")
	desc = "Эти семена кислые."
	icon_state = "seed-orange"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "orange"
	plantname = "Mandarin Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/mandarin
	lifespan = 60
	endurance = 50
	maturation = 6
	production = 6
	yield = 5
	potency = 1
	plant_type = 0
	growthstages = 6

/obj/item/seeds/poisonberryseed
	name = "pack of poison-berry seeds"
	cases = list("семена ядовитых ягод", "семян ядовитых ягод", "семенам ядовитых ягод", "семена ядовитых ягод", "семенами ядовитых ягод", "семенах ядовитых ягод")
	desc = "Из этих семян вырастают кусты ядовитых ягод."
	icon_state = "seed-poisonberry"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "poisonberry"
	plantname = "Poison-Berry Bush"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 6
	mutatelist = list(/obj/item/seeds/deathberryseed)

/obj/item/seeds/deathberryseed
	name = "pack of death-berry seeds"
	cases = list("семена смертоягод", "семян смертоягод", "семенам смертоягод", "семена смертоягод", "семенами смертоягод", "семенах смертоягод")
	desc = "Из этих семян вырастают смертоягоды."
	icon_state = "seed-deathberry"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "deathberry"
	plantname = "Death Berry Bush"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
	lifespan = 30
	endurance = 20
	maturation = 5
	production = 5
	yield = 3
	potency = 50
	plant_type = 0
	growthstages = 6

/obj/item/seeds/fairy_grass
	name = "pack of fairygrass seeds"
	cases = list("семена волшебной травы", "семян волшебной травы", "семенам волшебной травы", "семена волшебной травы", "семенами волшебной травы", "семенах волшебной травы")
	desc = "Из этих семян вырастает мистическая трава."
	icon_state = "seed-fairygrass"
	species = "fairygrass"
	plantname = "Fairygrass"
	lifespan = 40
	endurance = 40
	maturation = 2
	production = 5
	yield = 5
	growthstages = 2

/obj/item/seeds/fairy_grass/harvest(mob/user = usr)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_yield = round(yield * parent.yieldmod)

	if(t_yield > 0)
		new /obj/item/stack/tile/fairygrass(user.loc, t_yield)

	parent.update_tray()

/obj/item/seeds/grassseed
	name = "pack of grass seeds"
	cases = list("семена газона", "семян газона", "семенам газона", "семена газона", "семенами газона", "семенах газона")
	desc = "Из этих семян вырастает газон. Не топтаться!"
	icon_state = "seed-grass"
	species = "grass"
	plantname = "Grass"
	lifespan = 60
	endurance = 50
	maturation = 2
	production = 5
	yield = 5
	plant_type = 0
	growthstages = 2

/obj/item/seeds/grassseed/react_to_disease_effect(obj/machinery/hydroponics/tray, datum/disease2/effect/E, datum/disease2/effectholder/holder)
	if(istype(E, /datum/disease2/effect/hallucinations))
		if(prob(holder.stage * 10))
			mutatelist |= /obj/item/seeds/fairy_grass
		return
	if(istype(E, /datum/disease2/effect/anti_toxins))
		if(holder.stage < 5)
			return
		if(prob(holder.stage * 10))
			mutatelist |= /obj/item/seeds/kudzuseed

/obj/item/seeds/cocoapodseed
	name = "pack of cocoa pod seeds"
	cases = list("семена какао-бобов", "семян какао-бобов", "семенам какао-бобов", "семена какао-бобов", "семенами какао-бобов", "семенах какао-бобов")
	desc = "Из этих семян вырастает дерево какао. Выглядит сладко."
	icon_state = "seed-cocoapod"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "cocoapod"
	plantname = "Cocoa Tree" //SIC: see above
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	lifespan = 20
	endurance = 15
	maturation = 5
	production = 5
	yield = 2
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/cherryseed
	name = "pack of cherry pits"
	cases = list("семена вишни", "семян вишни", "семенам вишни", "семена вишни", "семенами вишни", "семенах вишни")
	desc = "Осторожно, не сломайте зуб... А, это и так косточки."
	icon_state = "seed-cherry"
	hydroponictray_icon_path = 'icons/obj/hydroponics/growing_fruits.dmi'
	species = "cherry"
	plantname = "Cherry Tree"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	lifespan = 35
	endurance = 35
	maturation = 5
	production = 5
	yield = 3
	potency = 10
	plant_type = 0
	growthstages = 5

/obj/item/seeds/kudzuseed
	name = "pack of kudzu seeds"
	cases = list("семена кудзу", "семян кудзу", "семенам кудзу", "семена кудзу", "семенами кудзу", "семенах кудзу")
	desc = "Из этих семян вырастает сорняк, который невероятно быстро разрастается."
	icon_state = "seed-kudzu"
	species = "kudzu"
	plantname = "Kudzu"
	product_type = /obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	lifespan = 20
	endurance = 10
	maturation = 6
	production = 6
	yield = 4
	potency = 10
	growthstages = 4
	plant_type = 1

/obj/item/seeds/kudzuseed/attack_self(mob/user)
	if(isspaceturf(user.loc) || istype(user.loc, /turf/simulated/shuttle))
		to_chat(user, "<span class='notice'>You cannot plant kudzu on a moving shuttle or space.</span>")
		return
	to_chat(user, "<span class='notice'>You plant the kudzu. You monster.</span>")
	new /obj/effect/spacevine_controller(user.loc)
	qdel(src)

/obj/item/seeds/durathread
	name = "pack of durathread seeds"
	cases = list("семена дюранити", "семян дюранити", "семенам дюранити", "семена дюранити", "семенами дюранити", "семенах дюранити")
	desc = "Из этих семян вырастает чрезвычайно прочная нить, которая при правильном плетении может легко соперничать с пласталью."
	icon_state = "seed-durathread"
	species = "durathread"
	plantname = "Durathread"
	product_type = /obj/item/weapon/grown/durathread
	lifespan = 80
	endurance = 50
	maturation = 15
	production = 1
	yield = 2
	potency = 5
	growthstages = 3


// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/weapon/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/weapons.dmi'
	var/seed_type
	var/plantname = ""
	var/species = ""
	var/lifespan = 20
	var/endurance = 15
	var/maturation = 7
	var/production = 7
	var/yield = 2
	var/potency = 1
	var/plant_type = 0

/obj/item/weapon/grown/atom_init()
	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src
	. = ..()

/obj/item/weapon/grown/proc/changePotency(newValue)
	potency = newValue

/obj/item/weapon/grown/log
	name = "tower-cap log"
	cases = list("бревно", "бревна", "бревну", "бревно", "бревном", "бревне")
	desc = "Скорее хорошо, чем плохо!"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "logs"
	force = 5
	throwforce = 5
	w_class = SIZE_SMALL
	throw_speed = 3
	throw_range = 3
	plant_type = 2
	origin_tech = "materials=1"
	seed_type = /obj/item/seeds/towermycelium
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

/obj/item/weapon/grown/log/attackby(obj/item/I, mob/user, params)
	if(I.sharp && I.edge && I.force > 10)
		user.SetNextMove(CLICK_CD_INTERACT)
		to_chat(user, "<span class='notice'>You make planks out of \the [src]!</span>")
		for(var/i in 1 to 2)
			new/obj/item/stack/sheet/wood(user.loc)
		qdel(src)
		return FALSE
	return ..()


/obj/item/weapon/grown/sunflower
	name = "sunflower"
	cases = list("подсолнух", "подсолнуха", "подсолнуху", "подсолнух", "подсолнухом", "подсолнухе")
	desc = "Очень красивый! Кое-кто может забить тебя до смерти, если ты их растопчешь."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	damtype = BURN
	force = 0
	throwforce = 1
	w_class = SIZE_MINUSCULE
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed_type = /obj/item/seeds/sunflowerseed

/obj/item/weapon/grown/
	cases = list("крапива", "крапивы", "крапиве", "крапиву", "крапивой", "крапиве")
	desc = "Вероятно <B>НЕ</B> разумно трогать это голыми руками..."
	icon = 'icons/obj/weapons.dmi'
	name = "nettle"
	icon_state = "nettle"
	damtype = BURN
	force = 15
	throwforce = 1
	w_class = SIZE_TINY
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	origin_tech = "combat=1"
	seed_type = /obj/item/seeds/nettleseed

/obj/item/weapon/grown/nettle/atom_init()
	. = ..()
	spawn(5)
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("sacid", round(potency, 1))
		force = round((5 + potency / 5), 1)

/obj/item/weapon/grown/deathnettle
	cases = list("смерто-крапива", "смерто-крапивы", "смерто-крапиве", "смерто-крапиву", "смерто-крапивой", "смерто-крапиве")
	desc = "Эта <span class='warning'>светящаяся</span> крапива пробуждает в вас <span class='warning'><B>ярость</B></span> от одного лишь взгляда!"
	icon = 'icons/obj/weapons.dmi'
	name = "deathnettle"
	icon_state = "deathnettle"
	damtype = BURN
	force = 30
	throwforce = 1
	w_class = SIZE_TINY
	throw_speed = 1
	throw_range = 3
	plant_type = 1
	seed_type = /obj/item/seeds/deathnettleseed
	origin_tech = "combat=3"
	attack_verb = list("stung")

/obj/item/weapon/grown/deathnettle/atom_init()
	. = ..()
	spawn(5)
		reagents.add_reagent("nutriment", 1 + round((potency / 50), 1))
		reagents.add_reagent("pacid", round(potency, 1))
		reagents.add_reagent("sanguisacid", round(potency, 1))
		force = round((5 + potency / 2.5), 1)

/obj/item/weapon/grown/deathnettle/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] поедает [CASE(src, ACCUSATIVE_CASE)]! Похоже, что [THEY_RU(user)] пытается покончить с собой.</b></span>")
	return (BRUTELOSS | TOXLOSS)

/obj/item/weapon/grown/durathread
	seed_type = /obj/item/seeds/durathread
	icon = 'icons/obj/hydroponics/harvest.dmi'
	name = "durathread bundle"
	cases = list("клубок дюраткани", "клубка дюраткани", "клубку дюраткани", "клубок дюраткани", "клубком дюраткани", "клубке дюраткани")
	desc = "Крепкий клубок дюранити, удачи в его распутывании."
	icon_state = "durathread"

// *************************************
// Pestkiller defines for hydroponics
// *************************************

/obj/item/pestkiller
	name = "bottle of pestkiller"
	cases = list("бутылка пестицида", "бутылки пестицида", "бутылке пестицида", "бутылка пестицида", "бутылкой пестицида", "бутылке пестицида")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/PestKillStr = 0

/obj/item/pestkiller/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/pestkiller/carbaryl
	name = "bottle of carbaryl"
	cases = list("бутылка карбарила", "бутылки карбарила", "бутылке карбарила", "бутылка карбарила", "бутылкой карбарила", "бутылке карбарила")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	toxicity = 4
	PestKillStr = 2

/obj/item/pestkiller/lindane
	name = "bottle of lindane"
	cases = list("бутылка линдана", "бутылки линдана", "бутылке линдана", "бутылка линдана", "бутылкой линдана", "бутылке линдана")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	toxicity = 6
	PestKillStr = 4

/obj/item/pestkiller/phosmet
	name = "bottle of phosmet"
	cases = list("бутылка фосмета", "бутылки фосмета", "бутылке фосмета", "бутылка фосмета", "бутылкой фосмета", "бутылке фосмета")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	toxicity = 8
	PestKillStr = 7

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/weapon/weedspray
	cases = list("спрей от сорняков", "спрея от сорняков", "спрею от сорняков", "спрей от сорняков", "спреем от сорняков", "спрее от сорняков")
	desc = "Токсичная смесь в виде спрея для уничтожения мелких сорняков."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "weed-spray"
	icon_state = "weedspray"
	item_state = "spray"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 4
	w_class = SIZE_TINY
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/WeedKillStr = 2

/obj/item/weapon/weedspray/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</b></span>")
	return (TOXLOSS)

/obj/item/weapon/pestspray // -- Skie
	cases = list("спрей от вредителей", "спрея от вредителей", "спрею от вредителей", "спрей от вредителей", "спреем от вредителей", "спрее от вредителей")
	desc = "Спрей для уничтожения вредителей! <I>Не вдыхать!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "pest-spray"
	icon_state = "pestspray"
	item_state = "spraycan"
	flags = OPENCONTAINER | NOBLUDGEON
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 4
	w_class = SIZE_TINY
	throw_speed = 2
	throw_range = 10
	var/toxicity = 4
	var/PestKillStr = 2

/obj/item/weapon/pestspray/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='warning'><b>[user] вдыхает [CASE(src, ACCUSATIVE_CASE)]! Похоже, что [THEY_RU(user)] пытается покончить с собой.</b></span>")
	return (TOXLOSS)

/obj/item/weapon/minihoe // -- Numbers
	name = "mini hoe"
	cases = list("мини мотыга", "мини мотыги", "мини мотыге", "мини мотыга", "мини мотыгой", "мини мотыге")
	desc = "Используется, чтобы пропалывать сорняки или чесать спинку."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hoe"
	item_state = "hoe"
	flags = CONDUCT | NOBLUDGEON
	force = 5.0
	throwforce = 7.0
	w_class = SIZE_TINY
	m_amt = 2550
	origin_tech = "materials=1;biotech=1"
	attack_verb = list("slashed", "sliced", "cut", "clawed")

// *************************************
// Weedkiller defines for hydroponics
// *************************************

/obj/item/weedkiller
	name = "bottle of weedkiller"
	cases = list("бутылка средства от сорняков", "бутылки средства от сорняков", "бутылке средства от сорняков", "бутылку средства от сорняков", "бутылкой средства от сорняков", "бутылке средства от сорняков")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	var/toxicity = 0
	var/WeedKillStr = 0

/obj/item/weedkiller/triclopyr
	name = "bottle of glyphosate"
	cases = list("бутылка глифосата", "бутылки глифосата", "бутылке глифосата", "бутылку глифосата", "бутылкой глифосата", "бутылке глифосата")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	toxicity = 4
	WeedKillStr = 2

/obj/item/weedkiller/lindane
	cases = list("бутылка линдана", "бутылки линдана", "бутылке линдана", "бутылку линдана", "бутылкой линдана", "бутылке линдана")
	name = "bottle of triclopyr"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	toxicity = 6
	WeedKillStr = 4

/obj/item/weedkiller/D24
	cases = list("бутылка 2,4-D", "бутылки 2,4-D", "бутылке 2,4-D", "бутылку 2,4-D", "бутылкой 2,4-D", "бутылке 2,4-D")
	name = "bottle of 2,4-D"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	toxicity = 8
	WeedKillStr = 7

// *************************************
// Nutrient defines for hydroponics
// *************************************

/obj/item/nutrient
	name = "bottle of nutrient"
	cases = list("бутылка удобрений", "бутылки удобрений", "бутылке удобрений", "бутылку удобрений", "бутылкой удобрений", "бутылке удобрений")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	w_class = SIZE_TINY
	var/mutmod = 0
	var/yieldmod = 0

/obj/item/nutrient/atom_init()
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	cases = list("бутылка E-Z удобрений", "бутылки E-Z удобрений", "бутылке E-Z удобрений", "бутылку E-Z удобрений", "бутылкой E-Z удобрений", "бутылке E-Z удобрений")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	mutmod = 1
	yieldmod = 1

/obj/item/nutrient/l4z
	name = "bottle of Left 4 Zed"
	cases = list("бутылка удобрений Left 4 Zed", "бутылки удобрений Left 4 Zed", "бутылке удобрений Left 4 Zed", "бутылку удобрений Left 4 Zed", "бутылкой удобрений Left 4 Zed", "бутылке удобрений Left 4 Zed")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"
	mutmod = 2
	yieldmod = 0

/obj/item/nutrient/rh
	name = "bottle of Robust Harvest"
	cases = list("бутылка удобрений Robust Harvest", "бутылки удобрений Robust Harvest", "бутылке удобрений Robust Harvest", "бутылку удобрений Robust Harvest", "бутылкой удобрений Robust Harvest", "бутылке удобрений Robust Harvest")
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	mutmod = 0
	yieldmod = 2
