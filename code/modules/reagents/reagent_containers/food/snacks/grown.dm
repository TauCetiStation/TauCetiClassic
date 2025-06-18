// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/grown
	food_type = NATURAL_FOOD
	food_moodlet = /datum/mood_event/natural_food
	var/seed_type
	var/plantname = ""
	var/species = ""
	var/lifespan = 0
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = -1
	var/plant_type = 0
	icon = 'icons/obj/hydroponics/harvest.dmi'

/obj/item/weapon/reagent_containers/food/snacks/grown/atom_init(mapload, newpotency)
	if (!isnull(newpotency))
		potency = newpotency
	. = ..()
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n Это <span class='name'>[CASE(src, NOMINATIVE_CASE)]</span>\n"
		switch(plant_type)
			if(0)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(1)
				msg += "- Plant type: <i>Weed</i>\n"
			if(2)
				msg += "- Plant type: <i>Mushroom</i>\n"
		msg += "- Potency: <i>[potency]</i>\n"
		msg += "- Yield: <i>[yield]</i>\n"
		msg += "- Maturation speed: <i>[maturation]</i>\n"
		msg += "- Production speed: <i>[production]</i>\n"
		msg += "- Endurance: <i>[endurance]</i>\n"
		msg += "- Healing properties: <i>[reagents.get_reagent_amount("nutriment")]</i>\n"
		msg += "*---------*</span>"
		to_chat(usr, msg)
		return
	return ..()

/obj/item/weapon/grown/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		var/msg
		msg = "<span class='info'>*---------*\n Это <span class='name'>[CASE(src, NOMINATIVE_CASE)]</span>\n"
		switch(plant_type)
			if(0)
				msg += "- Plant type: <i>Normal plant</i>\n"
			if(1)
				msg += "- Plant type: <i>Weed</i>\n"
			if(2)
				msg += "- Plant type: <i>Mushroom</i>\n"
		msg += "- Acid strength: <i>[potency]</i>\n"
		msg += "- Yield: <i>[yield]</i>\n"
		msg += "- Maturation speed: <i>[maturation]</i>\n"
		msg += "- Production speed: <i>[production]</i>\n"
		msg += "- Endurance: <i>[endurance]</i>\n"
		msg += "*---------*</span>"
		to_chat(usr, msg)
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	seed_type = /obj/item/seeds/cornseed
	name = "ear of corn"
	cases = list("кукурузный початок", "кукурузного початка", "кукурузному початку", "кукурузный початок", "кукурузным початком", "кукурузном початке")
	desc = "Просто добавь масла!"
	icon_state = "corn"
	potency = 40
	filling_color = "#ffee00"
	trash = /obj/item/weapon/corncob

/obj/item/weapon/reagent_containers/food/snacks/grown/corn/atom_init() // need another solution with those spawns(), maybe new with arguments, so we can set everything on creation.
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	seed_type = /obj/item/seeds/cherryseed
	name = "cherries"
	cases = list("вишня", "вишни", "вишне", "вишню", "вишней", "вишне")
	desc = "Лучшее украшение для торта!" // Адаптация вместо "Хороша для топпингов"
	icon_state = "cherry"
	filling_color = "#ff0000"
	gender = PLURAL

/obj/item/weapon/reagent_containers/food/snacks/grown/cherries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 15), 1))
	reagents.add_reagent("sugar", 1+round((potency / 15), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	seed_type = /obj/item/seeds/poppyseed
	name = "poppy"
	cases = list("мак", "мака", "маку", "мак", "маком", "маке")
	desc = "Издавна использовался как символ покоя, мира и смерти."
	icon_state = "poppy"
	potency = 30
	filling_color = "#cc6464"

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	reagents.add_reagent("bicaridine", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 3, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cable_piece = I
		if(cable_piece.use(3))
			new /obj/item/clothing/head/poppy_crown(get_turf(loc))
			qdel(src)
			return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	seed_type = /obj/item/seeds/harebell
	name = "harebell"
	cases = list("колокольчик", "колокольчика", "колокольчику", "колокольчик", "колокольчиком", "колокольчике")
	desc = "\"Коль буду жив, Фиделе, я все лето печальную твою могилу стану цветами украшать. Увидишь ты подснежник белый, как твое лицо, и колокольчик, голубее жилок твоих; и розы, аромат которых не сладостней дыханья твоего. Их будут реполовы приносить тебе, к стыду наследников богатых, не ставящих надгробия отцам. Когда ж цветов не будет, я укрою могилу мхом от стужи.\""
	icon_state = "harebell"
	potency = 1
	filling_color = "#d4b2c9"
	slot_flags = SLOT_FLAGS_HEAD

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	bitesize = 1+round(reagents.total_volume / 3, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	seed_type = /obj/item/seeds/potatoseed
	name = "potato"
	cases = list("картофель", "картофеля", "картофелю", "картофель", "картофелем", "картофеле")
	desc = "Вари! Толки! Туши!"
	icon_state = "potato"
	potency = 25
	filling_color = "#e6e8da"

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		var/obj/item/stack/cable_coil/C = I
		if(C.use(5))
			to_chat(user, "<span class='notice'>Вы добавляете провода к картофелине и получаете самодельную батарею.</span>")
			var/obj/item/weapon/stock_parts/cell/potato/pocell = new(get_turf(user))
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			qdel(src)
			return

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/blackpepper
	seed_type = /obj/item/seeds/blackpepper
	name = "black pepper"
	cases = list("черный перец", "черного перца", "черному перцу", "черный перец", "черным перцем", "черном перце")
	desc = "Остренький!"
	icon_state = "blackpepper"
	potency = 25
	filling_color = "#020108"

/obj/item/weapon/reagent_containers/food/snacks/grown/blackpepper/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("blackpepper", 4+round((potency / 5), 1))
	bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	seed_type = /obj/item/seeds/grapeseed
	name = "bunch of grapes"
	cases = list("виноград", "винограда", "винограду", "виноград", "виноградом", "винограде")
	desc = "Сладкий и крайне питательный. Из него традиционно делают красные вина Шардоне, Совиньон-блан и другие."
	icon_state = "grapes"
	filling_color = "#a332ad"

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("sugar", 1+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
	seed_type = /obj/item/seeds/greengrapeseed
	name = "bunch of green grapes"
	cases = list("зеленый виноград", "зеленого винограда", "зеленому винограду", "зеленый виноград", "зеленым виноградом", "зеленом винограде")
	desc = "Сладкий и крайне питательный. Из этого сорта винограда традиционно делают белые вина Винью-верде и другие."
	icon_state = "greengrapes"
	potency = 25
	filling_color = "#a6ffa3"

/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("kelotane", 3+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	seed_type = /obj/item/seeds/cabbageseed
	name = "cabbage"
	cases = list("кочан капусты", "кочана капусты", "кочану капусты", "кочан капусты", "кочаном капусты", "кочане капусты")
	desc = "Бывает, в ней находят детей."
	icon_state = "cabbage"
	potency = 25
	filling_color = "#a2b5a1"

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/cucumber
	seed_type = /obj/item/seeds/cucumberseed
	name = "cucumber"
	cases = list("огурец", "огурца", "огурцу", "огурец", "огурцом", "огурце")
	desc = "Выглядит как слащавый огурчик."
	icon_state = "cucumber"
	item_state_world = "cucumber_world"
	potency = 15
	filling_color = "#598157"

/obj/item/weapon/reagent_containers/food/snacks/grown/cucumber/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("ethylredoxrazine", 1+round((potency / 10), 1))
	bitesize = reagents.total_volume

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	seed_type = /obj/item/seeds/berryseed
	name = "bunch of berries"
	cases = list("гроздь ягод", "грозди ягод", "грозди ягод", "гроздь ягод", "гроздью ягод", "грозди ягод")
	desc = "Гроздь кисленьких ягод."
	icon_state = "berrypile"
	filling_color = "#c2c9ff"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium
	seed_type = /obj/item/seeds/plastiseed
	name = "clump of plastellium"
	cases = list("пластеллий", "пластеллия", "пластеллию", "пластеллий", "пластеллием", "пластеллие")
	desc = "Хм, кажется, он нуждается в переработке."
	icon_state = "plastellium"
	filling_color = "#c4c4c4"

/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium/atom_init()
	. = ..()
	reagents.add_reagent("plasticide", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/shand
	seed_type = /obj/item/seeds/shandseed
	name = "S'rendarr's Hand leaf"
	cases = list("лист Длани С'рендарра", "листа Длани С'рендарра", "листу Длани С'рендарра", "лист Длани С'рендарра", "листом Длани С'рендарра", "листе Длани С'рендарра")
	desc = "Образец листа кустарника из низменных зарослей, в котором часто прячутся хищники и их добыча, чтобы заживить раны и скрыть запах. Это позволяет растению распространяться далеко по его родному Адомаю. Сильно пахнет воском."
	icon_state = "shand"
	filling_color = "#70c470"

/obj/item/weapon/reagent_containers/food/snacks/grown/shand/atom_init()
	. = ..()
	reagents.add_reagent("bicaridine", round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mtear
	seed_type = /obj/item/seeds/mtearseed
	name = "sprig of Messa's Tear"
	cases = list("ветвь Слезы Мессы", "ветви Слезы Мессы", "ветви Слезы Мессы", "ветвь Слезы Мессы", "ветвью Слезы Мессы", "ветви Слезы Мессы")
	desc = "Растение, произрастающее в горном климате, с мягкими, холодными синими цветками. Известное тем, что в его цветках содержится большое количество химических веществ, полезных для лечения ожогов. Вредно для людей, страдающих аллергией на пыльцу."
	icon_state = "mtear"
	filling_color = "#70c470"
	slot_flags = SLOT_FLAGS_HEAD

/obj/item/weapon/reagent_containers/food/snacks/grown/mtear/atom_init()
	. = ..()
	reagents.add_reagent("honey", 1+round((potency / 10), 1))
	reagents.add_reagent("kelotane", 3+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mtear/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	var/obj/item/stack/medical/ointment/tajaran/poultice = new /obj/item/stack/medical/ointment/tajaran(user.loc)

	poultice.heal_burn = potency
	qdel(src)

	to_chat(user, "<span class='notice'>You mash the petals into a poultice.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/shand/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	var/obj/item/stack/medical/bruise_pack/tajaran/poultice = new /obj/item/stack/medical/bruise_pack/tajaran(user.loc)

	poultice.heal_brute = potency
	qdel(src)

	to_chat(user, "<span class='notice'>You mash the leaves into a poultice.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	seed_type = /obj/item/seeds/glowberryseed
	name = "bunch of glow-berries"
	cases = list("гроздь светоягод", "грозди светоягод", "грозди светоягод", "гроздь светоягод", "гроздью светоягод", "грозди светоягод")
	desc = "Гроздь питательных ягод. Слабо светится в темноте."
	var/light_on = 1
	var/brightness_on = 2 //luminosity when on
	filling_color = "#d3ff9e"
	icon_state = "glowberrypile"

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", round((potency / 10), 1))
	reagents.add_reagent("uranium", 3+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/Destroy()
	if(istype(loc,/mob))
		loc.set_light(0)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/pickup(mob/living/user)
	. = ..()
	set_light(0)
	user.set_light(2,1)

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries/dropped(mob/user)
	..()
	user.set_light(0)
	set_light(2,1)

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	seed_type = /obj/item/seeds/cocoapodseed
	name = "cocoa pod"
	cases = list("стручок какао-бобов", "стручка какао-бобов", "стручку какао-бобов", "стручок какао-бобов", "стручком какао-бобов", "стручке какао-бобов")
	desc = "От этого толстеют? Шок, но ладно." // "Chucklate" - непереводимая игра слов от chocolate/chucklate, адаптировал как шоколадно/шок, но ладно
	icon_state = "cocoapod"
	potency = 50
	filling_color = "#9c8e54"

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("coco", 4+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	seed_type = /obj/item/seeds/sugarcaneseed
	name = "sugarcane"
	cases = list("сахарный тростник", "сахарного тростника", "сахарному тростнику", "сахарный тростник", "сахарным тростником", "сахарном тростнике")
	desc = "Приторно-сладкий."
	icon_state = "sugarcane"
	potency = 50
	filling_color = "#c0c9ad"

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane/atom_init()
	. = ..()
	reagents.add_reagent("sugar", 4+round((potency / 5), 1))

/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	seed_type = /obj/item/seeds/poisonberryseed
	name = "bunch of poison-berries"
	cases = list("гроздь ядовитых ягод", "грозди ядовитых ягод", "грозди ядовитых ягод", "гроздь ядовитых ягод", "гроздью ядовитых ягод", "грозди ядовитых ягод")
	desc = "Смертельно вкусные ягоды."
	icon_state = "poisonberrypile"
	gender = PLURAL
	potency = 15
	filling_color = "#b422c7"

/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("toxin", 3+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
	seed_type = /obj/item/seeds/deathberryseed
	name = "bunch of death-berries"
	cases = list("гроздь смертоягод", "грозди смертоягод", "грозди смертоягод", "гроздь смертоягод", "гроздью смертоягод", "грозди смертоягод")
	desc = "После такой сладости хоть в могилу!"
	icon_state = "deathberrypile"
	gender = PLURAL
	potency = 50
	filling_color = "#4e0957"

/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("toxin", 3+round(potency / 3, 1))
	reagents.add_reagent("lexorin", 1+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
	seed_type = /obj/item/seeds/ambrosiavulgarisseed
	name = "ambrosia vulgaris branch"
	cases = list("ветвь амброзии обыкновенной", "ветви амброзии обыкновенной", "ветви амброзии обыкновенной", "ветвь амброзии обыкновенной", "ветвью амброзии обыкновенной", "ветви амброзии обыкновенной")
	desc = "Это растение содержит различные лечебные вещества."
	icon_state = "ambrosiavulgaris"
	potency = 10
	filling_color = "#125709"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("ambrosium", 1+round(potency / 8, 1))
	reagents.add_reagent("kelotane", 1+round(potency / 8, 1))
	reagents.add_reagent("bicaridine", 1+round(potency / 10, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/laughweed
	seed_type = /obj/item/seeds/laughweedseed
	name = "laughweed"
	cases = list("смехтрава", "смехтравы", "смехтраве", "смехтраву", "смехтравой", "смехтраве")
	desc = "У нас было 2 пакетика травы..."
	icon_state = "laughweed"
	item_state_world = "laughweed_world"
	potency = 10
	filling_color = "#39962d"

/obj/item/weapon/reagent_containers/food/snacks/grown/laughweed/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1 + round(potency / 10, 1))
	reagents.add_reagent("dexalin", 1 + round(potency / 8, 1))
	reagents.add_reagent("laughbidiol", 3 + round(potency / 5, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/megaweed
	seed_type = /obj/item/seeds/megaweedseed
	name = "megaweed"
	cases = list("мегатравка", "мегатравки", "мегатравке", "мегатравку", "мегатравкой", "мегатравке")
	desc = "У нас было 2 пакетика мегатравы..."
	icon_state = "megaweed"
	item_state_world = "megaweed_world"
	potency = 10
	filling_color = "#39962d"

/obj/item/weapon/reagent_containers/food/snacks/grown/megaweed/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1 + round(potency / 10, 1))
	reagents.add_reagent("dexalinp", 1 + round(potency / 5, 1))
	reagents.add_reagent("space_drugs", 1 + round(potency / 8, 1))
	reagents.add_reagent("laughbidiol", 3 + round(potency / 5, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/blackweed
	seed_type = /obj/item/seeds/blackweedseed
	name = "deathweed"
	cases = list("смертьтрава", "смертьтравы", "смертьтраве", "смертьтраву", "смертьтравой", "смертьтраве")
	desc = "Смешит до болезненных колик в животике."
	icon_state = "blackweed"
	item_state_world = "blackweed_world"
	potency = 10
	filling_color = "#39962d"

/obj/item/weapon/reagent_containers/food/snacks/grown/blackweed/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1 + round(potency / 10, 1))
	reagents.add_reagent("cyanide", 1 + round((potency / 5), 1))
	reagents.add_reagent("laughbidiol", 3 + round(potency / 5, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus
	seed_type = /obj/item/seeds/ambrosiadeusseed
	name = "ambrosia deus branch"
	cases = list("ветвь амброзии божественной", "ветви амброзии божественной", "ветви амброзии божественной", "ветвь амброзии божественной", "ветвью амброзии божественной", "ветви амброзии божественной")
	desc = "Поедание этого приводит к бессмертию!"
	icon_state = "ambrosiadeus"
	potency = 10
	filling_color = "#229e11"
	food_moodlet = /datum/mood_event/tasty_food
	food_type = TASTY_FOOD

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2)
	reagents.add_reagent("bicaridine", 1+round(potency / 6, 1))
	reagents.add_reagent("synaptizine", 1+round(potency / 6, 1))
	reagents.add_reagent("space_drugs", 1+round(potency / 9, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	seed_type = /obj/item/seeds/appleseed
	name = "apple"
	cases = list("яблоко", "яблока", "яблоку", "яблоко", "яблоком", "яблоке")
	desc = "Запретный плод Эдема."
	icon_state = "apple"
	potency = 15
	filling_color = "#dfe88b"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/atom_init()
	. = ..()
	reagents.maximum_volume = 20
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = reagents.maximum_volume // Always eat the apple in one

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	seed_type = /obj/item/seeds/poisonedappleseed
	name = "apple"
	cases = list("яблоко", "яблока", "яблоку", "яблоко", "яблоком", "яблоке")
	desc = "Запретный плод Эдема."
	icon_state = "apple"
	potency = 15
	filling_color = "#b3bd5e"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned/atom_init()
	. = ..()
	reagents.maximum_volume = 20
	reagents.add_reagent("cyanide", 1+round((potency / 5), 1))
	bitesize = reagents.maximum_volume // Always eat the apple in one

/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple
	seed_type = /obj/item/seeds/goldappleseed
	name = "golden apple"
	cases = list("золотое яблоко", "золотого яблока", "золотому яблоку", "золотое яблоко", "золотым яблоком", "золотом яблоке")
	desc = "На яблоке красуется слово 'Kallisti'."
	icon_state = "goldapple"
	potency = 15
	food_type = VERY_TASTY_FOOD
	food_moodlet = /datum/mood_event/very_tasty_food
	filling_color = "#f5cb42"

/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("gold", 1+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Mineral Content: <i>[reagents.get_reagent_amount("gold")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	seed_type = /obj/item/seeds/watermelonseed
	name = "watermelon"
	cases = list("арбуз", "арбуза", "арбузу", "арбуз", "арбузом", "арбузе")
	desc = "И поел, и попил."
	icon_state = "watermelon"
	potency = 10
	filling_color = "#fa2863"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	slices_num = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 6), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	seed_type = /obj/item/seeds/pumpkinseed
	name = "pumpkin"
	cases = list("тыква", "тыквы", "тыкве", "тыкву", "тыквой", "тыкве")
	desc = "Большая и страшная."
	icon_state = "pumpkin"
	potency = 10
	filling_color = "#fab728"

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 6), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)


/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/circular_saw) || istype(I, /obj/item/weapon/hatchet) || istype(I, /obj/item/weapon/fireaxe) || istype(I, /obj/item/weapon/kitchenknife) || istype(I, /obj/item/weapon/melee/energy))
		to_chat(user, "<span class='notice'>Вы вырезаете лицо в [CASE(src, PREPOSITIONAL_CASE)]!</span>")
		if (tgui_alert(usr, "Шлем или Декор?", "Что вырезать?", list("Шлем", "Декор")) == "Шлем")
			new /obj/item/clothing/head/hardhat/pumpkinhead (user.loc)
			qdel(src)
			return
		else
			new /obj/item/weapon/carved_pumpkin (user.loc)
			qdel(src)
			return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/lime
	seed_type = /obj/item/seeds/limeseed
	name = "lime"
	cases = list("лайм", "лайма", "лайму", "лайм", "лаймом", "лайме")
	desc = "Настолько кислый, что скукожит твое лицо."
	icon_state = "lime"
	potency = 20
	filling_color = "#28fa59"

/obj/item/weapon/reagent_containers/food/snacks/grown/lime/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	seed_type = /obj/item/seeds/lemonseed
	name = "lemon"
	cases = list("лимон", "лимона", "лимону", "лимон", "лимоном", "лимоне")
	desc = "Если жизнь дает тебе лимоны — не делай лимонад. Заставь жизнь забрать их обратно! Разозлись! «Мне не нужны твои проклятые лимоны! Что мне с ними делать?»."
	icon_state = "lemon"
	potency = 20
	filling_color = "#faf328"

/obj/item/weapon/reagent_containers/food/snacks/grown/lemon/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/orange
	seed_type = /obj/item/seeds/orangeseed
	name = "orange"
	cases = list("апельсин", "апельсина", "апельсину", "апельсин", "апельсином", "апельсине")
	desc = "Терпкий оранжевый фрукт."
	icon_state = "orange"
	potency = 20
	filling_color = "#faad28"

/obj/item/weapon/reagent_containers/food/snacks/grown/orange/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mandarin
	seed_type = /obj/item/seeds/mandarinseed
	name = "mandarin"
	cases = list("мандарин", "мандарина", "мандарину", "мандарин", "мандарином", "мандарине")
	desc = "Сладкий оранжевый фрукт."
	icon_state = "mandarin"
	item_state_world = "mandarin_world"
	potency = 20
	filling_color = "#faad28"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/mandarinslice
	slices_num = 13

/obj/item/weapon/reagent_containers/food/snacks/grown/mandarin/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	seed_type = /obj/item/seeds/whitebeetseed
	name = "white-beet"
	cases = list("сахарная свекла", "сахарной свеклы", "сахарной свекле", "сахарную свеклу", "сахарной свеклой", "сахарной свекле")
	desc = "Не то чтобы сильно сладкая."
	icon_state = "whitebeet"
	potency = 15
	filling_color = "#fffccc"

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", round((potency / 20), 1))
	reagents.add_reagent("sugar", 1+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	seed_type = /obj/item/seeds/bananaseed
	name = "banana"
	cases = list("банан", "банана", "банану", "банан", "бананом", "банане")
	desc = "Хороший реквизит для искрометных шуток."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	filling_color = "#fcf695"
	can_be_holstered = TRUE
	trash = /obj/item/weapon/bananapeel
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/atom_init()
	. = ..()
	reagents.add_reagent("banana", 1+round((potency / 10), 1))
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk
	seed_type = /obj/item/seeds/honkyseed
	name = "Clowny banana"
	cases = list("клоунский банан", "клоунского банана", "клоунскому банану", "клоунский банан", "клоунским бананом", "клоунском банане")
	desc = "Выглядит очень ярким и вкусным, клоун убьет за этот банан!"
	icon = 'icons/obj/items.dmi'
	icon_state = "h-banana"
	item_state = "h-banana"
	filling_color = "#fcf695"
	can_be_holstered = TRUE
	trash = /obj/item/weapon/bananapeel/honk
	bitesize = 5

/obj/item/weapon/reagent_containers/food/snacks/grown/banana/honk/atom_init()
	. = ..()
	reagents.add_reagent("banana", 1+round((potency / 10), 1))
	pixel_x = rand(-5.0, 5)
	pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed_type = /obj/item/seeds/chiliseed
	name = "chili"
	cases = list("перец чили", "перца чили", "перцу чили", "перец чили", "перцем чили", "перце чили")
	desc = "Безумно острый! Лучше запастись молоком!"
	icon_state = "chilipepper"
	filling_color = "#ff0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/chili/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
	reagents.add_reagent("capsaicin", 3+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/chili/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Capsaicin: <i>[reagents.get_reagent_amount("capsaicin")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	seed_type = /obj/item/seeds/eggplantseed
	name = "eggplant"
	cases = list("баклажан", "баклажана", "баклажану", "баклажан", "баклажаном", "баклажане")
	desc = "Приложи к фотографии лучшего друга."
	icon_state = "eggplant"
	filling_color = "#550f5c"

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	seed_type = /obj/item/seeds/soyaseed
	name = "soybeans"
	cases = list("соевые бобы", "соевых бобов", "соевым бобам", "соевые бобы", "соевыми бобами", "соевых бобах")
	desc = "Довольно пресные, но сколько открывают возможностей..."
	gender = PLURAL
	filling_color = "#e6e8b7"
	icon_state = "soybeans"

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	seed_type = /obj/item/seeds/tomatoseed
	name = "tomato"
	cases = list("помидор", "помидора", "помидору", "помидор", "помидором", "помидоре")
	desc = "Я говорю по-ми-до-ры, а ты говоришь то-ма-ты."
	icon_state = "tomato"
	filling_color = "#ff0000"
	potency = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	new/obj/effect/decal/cleanable/tomato_smudge(loc)
	visible_message("<span class='notice'>[CASE(src, NOMINATIVE_CASE)] расплющился.</span>","<span class='notice'>Вы слышите шлепок.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
	seed_type = /obj/item/seeds/killertomatoseed
	name = "killer-tomato"
	cases = list("помидор-убийца", "помидора-убийцы", "помидору-убийце", "помидор-убийца", "помидором-убийцей", "помидоре-убийце")
	desc = "Я говорю по-ми-до-ры, а ты говоришь то-ма... ГОСПОДИ, ОНО ЕСТ МОИ НОГИ!!"
	icon_state = "killertomato"
	potency = 10
	filling_color = "#ff0000"
	lifespan = 120
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	new /mob/living/simple_animal/hostile/tomato(user.loc, potency)
	qdel(src)
	to_chat(user, "<span class='notice'>Вы посадили помидор-убийцу.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/attack_hand(mob/living/carbon/human/user)
	if(!user.gloves)
		to_chat(user, "<span class='warning'>Вы разбудили помидор-убийцу!</span>")
		new /mob/living/simple_animal/hostile/tomato(user.loc, potency)
		qdel(src)
	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	seed_type = /obj/item/seeds/bloodtomatoseed
	name = "blood-tomato"
	cases = list("кровавый помидор", "кровавого помидора", "кровавому помидору", "кровавый помидор", "кровавым помидором", "кровавом помидоре")
	desc = "Очень кровавый...очень...ОЧЕЕНЬ...кровавый....АААААРГХ!!!!"
	icon_state = "bloodtomato"
	potency = 10
	filling_color = "#ff0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 10), 1))
	reagents.add_reagent("blood", 1+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	new/obj/effect/decal/cleanable/blood/splatter(loc)
	visible_message("<span class='notice'>[CASE(src, NOMINATIVE_CASE)] расплющился.</span>","<span class='notice'>Вы слышите шлепок.</span>")
	reagents.reaction(get_turf(hit_atom))
	for(var/atom/A in get_turf(hit_atom))
		reagents.reaction(A)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	seed_type = /obj/item/seeds/bluetomatoseed
	name = "blue-tomato"
	cases = list("голубой помидор", "голубого помидора", "голубому помидору", "голубой помидор", "голубым помидором", "голубом помидоре")
	desc = "Я говорю по-ми-дор, ты говоришь го-лу-бой."
	icon_state = "bluetomato"
	potency = 10
	filling_color = "#586cfc"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	reagents.add_reagent("lube", 1+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)
	AddComponent(/datum/component/slippery, 8, NONE, CALLBACK(src, PROC_REF(AfterSlip)))

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato/proc/AfterSlip(mob/living/carbon/human/M)
	M.Stun(5)

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	new/obj/effect/decal/cleanable/blood/oil(loc)
	visible_message("<span class='notice'>[CASE(src, NOMINATIVE_CASE)] расплющился.</span>","<span class='notice'>Вы слышите шлепок.</span>")
	reagents.reaction(get_turf(hit_atom))
	for(var/atom/A in get_turf(hit_atom))
		reagents.reaction(A)
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	seed_type = /obj/item/seeds/wheatseed
	name = "wheat"
	cases = list("пшеница", "пшеницы", "пшенице", "пшеницу", "пшеницей", "пшенице")
	desc = "Курочка будет благодарна."
	gender = PLURAL
	icon_state = "wheat"
	filling_color = "#f7e186"

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk
	seed_type = /obj/item/seeds/riceseed
	name = "rice stalk"
	cases = list("стебель риса", "стебля риса", "стеблю риса", "стебель риса", "стеблем риса", "стебле риса")
	desc = "Добро пожаловать на рисовые поля!"
	gender = PLURAL
	icon_state = "ricestalk"
	filling_color = "#fff8db"

/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 25), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	seed_type = /obj/item/seeds/kudzuseed
	name = "kudzu pod"
	cases = list("стручок кудзу", "стручка кудзу", "стручку кудзу", "стручок кудзу", "стручком кудзу", "стручке кудзу")
	desc = "<I>Пуэрария Вирусная</I>: Инвазивный вид лозы с лианами, которые быстро ползут и обвивают все, с чем соприкасаются."
	icon_state = "kudzupod"
	filling_color = "#59691b"

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod/atom_init()
	. = ..()
	reagents.add_reagent("nutriment",1+round((potency / 50), 1))
	reagents.add_reagent("anti_toxin",1+round((potency / 25), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed_type = /obj/item/seeds/icepepperseed
	name = "ice-pepper"
	cases = list("ледяной перец", "ледяного перца", "ледяному перцу", "ледяной перец", "ледяным перцем", "ледяном перце")
	desc = "Особая мутация перца чили."
	icon_state = "icepepper"
	potency = 20
	filling_color = "#66ceed"

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
	reagents.add_reagent("frostoil", 3+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Frostoil: <i>[reagents.get_reagent_amount("frostoil")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	seed_type = /obj/item/seeds/carrotseed
	name = "carrot"
	cases = list("морковь", "моркови", "моркови", "морковь", "морковью", "моркови")
	desc = "Полезно для зрения!"
	icon_state = "carrot"
	potency = 10
	filling_color = "#ffc400"

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	reagents.add_reagent("imidazoline", 3+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	seed_type = /obj/item/seeds/reishimycelium
	name = "reishi"
	cases = list("рейши", "рейши", "рейши", "рейши", "рейши", "рейши")
	desc = "<I>Ганодерма люцидум</I>: Особый гриб, который, как полагают, помогает снять стресс»."
	icon_state = "reishi"
	potency = 10
	filling_color = "#ff4800"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("stoxin", 3+round(potency / 3, 1))
	reagents.add_reagent("space_drugs", 1+round(potency / 25, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Sleep Toxin: <i>[reagents.get_reagent_amount("stoxin")]%</i></span>")
		to_chat(user, "<span class='info'>- Space Drugs: <i>[reagents.get_reagent_amount("space_drugs")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	seed_type = /obj/item/seeds/amanitamycelium
	name = "fly amanita"
	cases = list("мухомор", "мухомора", "мухомору", "мухомор", "мухомором", "мухоморе")
	desc = "<I>Мухомор красный</I>: Выучите ядовитые грибы наизусть. Собирайте только те грибы, которые знаете."
	icon_state = "amanita"
	potency = 10
	filling_color = "#ff0000"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1)
	reagents.add_reagent("amatoxin", 3+round(potency / 3, 1))
	reagents.add_reagent("psilocybin", 1+round(potency / 25, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Amatoxins: <i>[reagents.get_reagent_amount("amatoxin")]%</i></span>")
		to_chat(user, "<span class='info'>- Psilocybin: <i>[reagents.get_reagent_amount("psilocybin")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	seed_type = /obj/item/seeds/angelmycelium
	name = "destroying angel"
	cases = list("бледная поганка", "бледной поганки", "бледной поганке", "бледную поганку", "бледной поганкой", "бледной поганке")
	desc = "<I>Бледная поганка</I>: Смертельно ядовитый гриб-базидиомицет, содержащий альфа-аматоксины."
	icon_state = "angel"
	potency = 35
	filling_color = "#ffdede"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
	reagents.add_reagent("amatoxin", 13+round(potency / 3, 1))
	reagents.add_reagent("psilocybin", 1+round(potency / 25, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Amatoxins: <i>[reagents.get_reagent_amount("amatoxin")]%</i></span>")
		to_chat(user, "<span class='info'>- Psilocybin: <i>[reagents.get_reagent_amount("psilocybin")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	seed_type = /obj/item/seeds/libertymycelium
	name = "liberty-cap"
	cases = list("грибы псилоцибе", "грибов псилоцибе", "грибам псилоцибе", "грибы псилоцибе", "грибами псилоцибе", "грибах псилоцибе")
	desc = "<I>Псилоцибе полуланцетовидная</I>: Почувствуй вкус свободы!"
	icon_state = "libertycap"
	potency = 15
	filling_color = "#f714be"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 50), 1))
	reagents.add_reagent("psilocybin", 3+round(potency / 5, 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/plant_analyzer))
		to_chat(user, "<span class='info'>- Psilocybin: <i>[reagents.get_reagent_amount("psilocybin")]%</i></span>")

	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	seed_type = /obj/item/seeds/plumpmycelium
	name = "plump-helmet"
	cases = list("гриб толстошлемник", "гриба толстошлемника", "грибу толстошлемнику", "гриб толстошлемник", "грибом толстошлемником", "грибе толстошлемнике")
	desc = "<I>Плюмус Хельмус</I>: Пухленькая, мягкая и такая привлекательная~"
	icon_state = "plumphelmet"
	filling_color = "#f714be"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	seed_type = /obj/item/seeds/walkingmushroommycelium
	name = "walking mushroom"
	cases = list("ходячий гриб", "ходячего гриба", "ходячему грибу", "ходячий гриб", "ходячим грибом", "ходячем грибе")
	desc = "<I>Плюмус Локомотус</I>: Пойдет семимильными шагами."
	icon_state = "walkingmushroom"
	filling_color = "#ffbfef"
	lifespan = 120
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 2+round((potency / 10), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	new /mob/living/simple_animal/mushroom(user.loc)
	qdel(src)

	to_chat(user, "<span class='notice'>Вы посадили ходячий гриб.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	seed_type = /obj/item/seeds/chantermycelium
	name = "chanterelle cluster"
	cases = list("гроздь лисичек", "грозди лисичек", "грозди лисичек", "гроздь лисичек", "гроздью лисичек", "грозди лисичек")
	desc = "<I>Лисичка обыкновенная</I>: Эти веселые желтые грибочки выглядят очень вкусно!"
	icon_state = "chanterelle"
	filling_color = "#ffe991"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle/atom_init()
	. = ..()
	reagents.add_reagent("nutriment",1+round((potency / 25), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	seed_type = /obj/item/seeds/glowshroom
	name = "glowshroom cluster"
	cases = list("гроздь светогрибов", "грозди светогрибов", "грозди светогрибов", "гроздь светогрибов", "гроздью светогрибов", "грозди светогрибов")
	desc = "<I>Мицена Брегпрокс</I>: Этот вид грибов светится в темноте. Или нет?"
	icon_state = "glowshroom"
	filling_color = "#daff91"
	lifespan = 120 //ten times that is the delay
	endurance = 30
	maturation = 15
	production = 1
	yield = 3
	potency = 30
	plant_type = 2

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/atom_init()
	. = ..()
	reagents.add_reagent("radium", 1+round((potency / 5), 1))
	set_light(round(potency/10,1))

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	var/obj/structure/glowshroom/planted = new /obj/structure/glowshroom(user.loc)

	planted.delay = lifespan * 50
	planted.modify_max_integrity(endurance)
	planted.yield = yield
	planted.potency = potency
	qdel(src)

	to_chat(user, "<span class='notice'>Вы посадили гроздь светящихся грибов.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/Destroy()
	if(istype(loc,/mob))
		loc.set_light(round(loc.luminosity - potency/10,1))
	return ..()

// *************************************
// Complex Grown Object Defines -
// Putting these at the bottom so they don't clutter the list up. -Cheridan
// *************************************

/*
//This object is just a transition object. All it does is make a grass tile and delete itself.
/obj/item/weapon/reagent_containers/food/snacks/grown/grass
	seed_type = /obj/item/seeds/grassseed
	name = "grass"
	cases = list("газон", "газона", "газону", "газон", "газоном", "газоне")
	desc = "Зеленый и пышный."
	icon_state = "spawner"
	potency = 20

/obj/item/weapon/reagent_containers/food/snacks/grown/grass/atom_init()
	. = ..()
	new/obj/item/stack/tile/grass(src.loc)
	spawn(5) //Workaround to keep harvesting from working weirdly.
		qdel(src)
*/

//This object is just a transition object. All it does is make dosh and delete itself. -Cheridan
/obj/item/weapon/reagent_containers/food/snacks/grown/money
	seed_type = /obj/item/seeds/cashseed
	name = "dosh"
	desc = "Green and lush."
	icon_state = "spawner"
	potency = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/money/atom_init()
	. = ..()
	switch(rand(1,100))//(potency) //It wants to use the default potency instead of the new, so it was always 10. Will try to come back to this later - Cheridan
		if(0 to 10)
			new/obj/item/weapon/spacecash(loc)
		if(11 to 20)
			new/obj/item/weapon/spacecash/c10(loc)
		if(21 to 30)
			new/obj/item/weapon/spacecash/c20(loc)
		if(31 to 40)
			new/obj/item/weapon/spacecash/c50(loc)
		if(41 to 50)
			new/obj/item/weapon/spacecash/c100(loc)
		if(51 to 60)
			new/obj/item/weapon/spacecash/c200(loc)
		if(61 to 80)
			new/obj/item/weapon/spacecash/c500(loc)
		else
			new/obj/item/weapon/spacecash/c1000(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
	seed_type = /obj/item/seeds/bluespacetomatoseed
	name = "bluespace tomato"
	cases = list("блюспейс помидор", "блюспейс помидора", "блюспейс помидору", "блюспейс помидор", "блюспейс помидором", "блюспейс помидоре")
	desc = "Настолько маслянистый, что ты можешь проскользнуть сквозь пространство-время."
	icon_state = "bluespacetomato"
	potency = 20
	origin_tech = "bluespace=3"
	filling_color = "#91f8ff"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1+round((potency / 20), 1))
	reagents.add_reagent("singulo", 1+round((potency / 5), 1))
	bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())
		return
	var/mob/M = usr
	var/outer_teleport_radius = potency / 10 //Plant potency determines radius of teleport.
	var/inner_teleport_radius = potency / 15
	var/list/turfs = list()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	if(inner_teleport_radius < 1) //Wasn't potent enough, it just splats.
		new/obj/effect/decal/cleanable/blood/oil(loc)
		visible_message("<span class='notice'>[CASE(src, NOMINATIVE_CASE)] расплющился.</span>","<span class='notice'>Вы слышите шлепок.</span>")
		qdel(src)
		return
	for(var/turf/T in orange(M,outer_teleport_radius))
		if(T in orange(M,inner_teleport_radius))
			continue
		if(isenvironmentturf(T))
			continue
		if(T.density)
			continue
		if(T.x > world.maxx - outer_teleport_radius || T.x < outer_teleport_radius)
			continue
		if(T.y > world.maxy - outer_teleport_radius || T.y < outer_teleport_radius)
			continue
		turfs += T
	if(!turfs.len)
		var/list/turfs_to_pick_from = list()
		for(var/turf/T in orange(M,outer_teleport_radius))
			if(!(T in orange(M,inner_teleport_radius)))
				turfs_to_pick_from += T
		turfs += pick(/turf in turfs_to_pick_from)
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	switch(rand(1,2))//Decides randomly to teleport the thrower or the throwee.
		if(1) // Teleports the person who threw the tomato.
			s.set_up(3, 1, M)
			s.start()
			new/obj/effect/decal/cleanable/molten_item(M.loc) //Leaves a pile of goo behind for dramatic effect.
			M.loc = picked //
			sleep(1)
			s.set_up(3, 1, M)
			s.start() //Two set of sparks, one before the teleport and one after.
		if(2) //Teleports mob the tomato hit instead.
			for(var/mob/A in get_turf(hit_atom))//For the mobs in the tile that was hit...
				s.set_up(3, 1, A)
				s.start()
				new/obj/effect/decal/cleanable/molten_item(A.loc) //Leave a pile of goo behind for dramatic effect...
				A.loc = picked//And teleport them to the chosen location.
				sleep(1)
				s.set_up(3, 1, A)
				s.start()
	new/obj/effect/decal/cleanable/blood/oil(loc)
	visible_message("<span class='notice'>[CASE(src, NOMINATIVE_CASE)] расплющился, вызвав искажение пространства-времени.</span>","<span class='notice'>Вы слышите хлопок и треск.</span>")
	qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/chureech_nut
	name = "Сhur'eech nut"
	cases = list("орех Чур'их", "ореха Чур'их", "ореху Чур'их", "орех Чур'их", "орехом Чур'их", "орехе Чур'их")
	icon_state = "chureechnut"
	desc = "Огромный орех небесного цвета, который славится поистине сладким вкусом."
	potency = 10
	seed_type = /obj/item/seeds/chureech_nut
	filling_color = "#91ebff"

/obj/item/weapon/reagent_containers/food/snacks/grown/chureech_nut/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1 + round(potency / 5))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter
	seed_type = /obj/item/seeds/peashooter
	name = "peashooter"
	cases = list("горохострел", "горохострела", "горохострелу", "горохострел", "горохострелом", "горохостреле")
	desc = "Нераскрывшийся плод горохострела, подозрительно напоминающий пистолет"
	icon_state = "peashooter"
	item_state_world = "peashooter_world"
	potency = 25
	filling_color = "#020108"
	trash = /obj/item/weapon/gun/projectile/automatic/pistol/peashooter

/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter/atom_init()
	. = ..()
	reagents.add_reagent("potassium", 1 + round(potency / 25, 1))
	reagents.add_reagent("carbon", 1 + round(potency / 10, 1))
	reagents.add_reagent("nitrogen", 1 + round(potency / 10, 1))
	reagents.add_reagent("sulfur", 1 + round(potency / 10, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter/virus
	seed_type = /obj/item/seeds/peashooter/virus
	name = "virus peashooter"
	cases = list("горохострел Гиббингтонский", "горохострела Гиббингтонского", "горохострелу Гиббингтонскому", "горохострел Гиббингтонский", "горохострелом Гиббингтонским", "горохостреле  Гиббингтонском")
	desc = "Нераскрывшийся плод горохострела Гиббингтонского, подозрительно напоминающий пистолет"
	icon_state = "peashooter_virus"
	item_state_world = "peashooter_virus_world"
	potency = 25
	filling_color = "#020108"
	trash = /obj/item/weapon/gun/projectile/automatic/pistol/peashooter/virus

/obj/item/weapon/reagent_containers/food/snacks/grown/peashooter/virus/atom_init()
	. = ..()
	reagents.add_reagent("potassium", 1 + round(potency / 25, 1))
	reagents.add_reagent("carbon", 1 + round(potency / 10, 1))
	reagents.add_reagent("iron", 1 + round(potency / 10, 1))
	reagents.add_reagent("chlorine", 1 + round(potency / 10, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space
	seed_type = /obj/item/seeds/tobacco
	name = "tobacco leaves"
	cases = list("листья космического табака", "листьев космического табака", "листьям космического табака", "листья космического табака", "листьями космического табака", "листьях космического табака")
	desc = "Высушите их, чтобы скрутить немного сигарет."
	icon_state = "stobacco_leaves"
	potency = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco_space/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1 + round(potency / 10, 1))
	reagents.add_reagent("vitamin", 1 + round(potency / 10, 1))
	reagents.add_reagent("nicotine", 1 + round(potency / 10, 1))
	reagents.add_reagent("dexalinp", 1 + round(potency / 10, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco
	seed_type = /obj/item/seeds/tobacco
	name = "tobacco leaves"
	cases = list("листья табака", "листьев табака", "листьям табака", "листья табака", "листьями табака", "листьях табака")
	desc = "Высушите их, чтобы скрутить немного сигарет."
	icon_state = "tobacco_leaves"
	potency = 10

/obj/item/weapon/reagent_containers/food/snacks/grown/tobacco/atom_init()
	. = ..()
	reagents.add_reagent("nicotine", 1 + round(potency / 10, 1))
	reagents.add_reagent("dexalin", 1 + round(potency / 10, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella
	seed_type = /obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella
	name = "fraxinella"
	cases = list("ясенец", "ясенца", "ясенцу", "ясенец", "ясенцом", "ясенце")
	desc = "Красивый светло-розовый цветок."
	icon_state = "fraxinella"
	potency = 30
	filling_color = "#cc6464"

/obj/item/weapon/reagent_containers/food/snacks/grown/fraxinella/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 1 + round((potency / 10), 1))
	reagents.add_reagent("thermite", 1 + round((potency / 10), 1))
	bitesize = 1 + round(reagents.total_volume / 3, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/jupitercup
	seed_type = /obj/item/seeds/jupitercup
	name = "Jupiter Cups"
	cases = list("юпитерская чашечка", "юпитерской чашечки", "юпитерской чашечке", "юпитерская чашечка", "юпитерской чашечкой", "юпитерской чашечке")
	desc = "Странный красный гриб, его поверхность влажная и скользкая. Интересно, сколько маленьких червячков встретили свою судьбу внутри?"
	icon_state = "jupitercup"
	filling_color = "#97ee63"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/jupitercup/atom_init()
	. = ..()
	reagents.add_reagent("liquidelectricity", 1 + round((potency / 25), 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra
	seed_type = /obj/item/seeds/tea_astra
	name = "Tea Astra tips"
	cases = list("чайная астра", "чайной астры", "чайной астре", "чайную астру", "чайной астрой", "чайной астре")
	desc = "Как насчет травяного чая по уникальному бабушкиному рецепту?"
	icon_state = "tea_astra_leaves"

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/astra/atom_init()
	. = ..()
	reagents.add_reagent("sodiumchloride", 1)
	reagents.add_reagent("sugar", 1)
	reagents.add_reagent("vitamin", 1 + round(potency / 10, 1))
	reagents.add_reagent("tea", 1 + round(potency / 10, 1))
	reagents.add_reagent("synaptizine", 1 + round(potency / 10, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/tea
	seed_type = /obj/item/seeds/tea
	name = "Tea Aspera tips"
	cases = list("чайные листья", "чайных листьев", "чайным листьям", "чайные листья", "чайными листьями", "чайных листьях")
	desc = "Эти ароматные побеги чайного растения можно высушить, чтобы заварить чай."
	icon_state = "tea_aspera_leaves"
	potency = 10
	filling_color = "#125709"

/obj/item/weapon/reagent_containers/food/snacks/grown/tea/atom_init()
	. = ..()
	reagents.add_reagent("tea", 1 + round(potency / 10, 1))
	bitesize = 1 + round(reagents.total_volume / 2, 1)
