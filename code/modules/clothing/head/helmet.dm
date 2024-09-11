/obj/item/clothing/head/helmet
	name = "helmet"
	cases = list("шлем", "шлема", "шлему", "шлем", "шлемом", "шлеме")
	desc = "Стандартная экипировка охраны. Защищает голову от пуль, лазеров, осколков и ящиков с инструментами."
	icon_state = "helmet"
	flags = HEADCOVERSEYES
	item_state = "helmet"
	armor = list(melee = 50, bullet = 45, laser = 40,energy = 25, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEEARS|HIDEEYES
	pierce_protection = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	w_class = SIZE_SMALL
	force = 5
	hitsound = list('sound/items/misc/balloon_small-hit.ogg')
	flashbang_protection = TRUE

	var/obj/item/holochip/holochip

/obj/item/clothing/head/helmet/Destroy()
	QDEL_NULL(holochip)
	return ..()

/obj/item/clothing/head/helmet/equipped(mob/user, slot)
	if(holochip && slot == SLOT_HEAD)
		if(user.hud_used) //NPCs don't need a map
			user.hud_used.init_screen(/atom/movable/screen/holomap)
		holochip.add_action(user)
		holochip.update_freq(holochip.frequency)
	..()

/obj/item/clothing/head/helmet/dropped(mob/user)
	if(holochip)
		holochip.remove_action(user)
		holochip.deactivate_holomap()
	..()

/obj/item/clothing/head/helmet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/holochip))
		if(flags & ABSTRACT)
			return    //You can't insert holochip in abstract item.
		if(holochip)
			to_chat(user, "<span class='notice'>В этом [CASE(src, PREPOSITIONAL_CASE)] уже есть [holochip].</span>")
			return
		user.drop_from_inventory(I, src)
		holochip = I
		holochip.holder = src
		var/mob/living/carbon/human/H = user
		if(istype(H) && H.head == src)
			holochip.add_action(user)
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Вы вставляете [CASE(holochip, ACCUSATIVE_CASE)] в [CASE(src, ACCUSATIVE_CASE)].</span>")
	else if(isscrewing(I))
		if(!holochip)
			to_chat(user, "<span class='notice'>В этом [CASE(src, PREPOSITIONAL_CASE)] нет голочипа.</span>")
			return
		holochip.deactivate_holomap()
		holochip.remove_action(user)
		holochip.holder = null
		if(!user.put_in_hands(holochip))
			holochip.forceMove(get_turf(src))
		holochip = null
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Вы вынимаете [CASE(holochip, ACCUSATIVE_CASE)] из [CASE(src, GENITIVE_CASE)].</span>")

	if(!issignaler(I)) //Eh, but we don't want people making secbots out of space helmets.
		return ..()

	var/obj/item/device/assembly/signaler/S = I
	if(!S.secured)
		to_chat(user, "<span class='notice'>Сигналер не готов к использованию.</span>")
		return ..()

	var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>Вы закрепляете [CASE(I, ACCUSATIVE_CASE)] на шлеме.</span>")
	qdel(I)
	qdel(src)

/obj/item/clothing/head/helmet/psyamp
	name = "psychic amplifier"
	cases = list("психический усилитель", "психического усилителя", "психическому усилителю", "психический усилитель", "психическим усилителем", "психическом усилителе")
	desc = "Психический усилитель в виде тернового венца. Выглядит как внебрачный ребёнок тиары и индустриального робота."
	icon_state = "amp"
	item_state = "amp"
	flags_inv = 0
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 30, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/head/helmet/warden
	name = "warden's helmet"
	cases = list("шлем смотрителя", "шлема смотрителя", "шлему смотрителя", "шлем смотрителя", "шлемом смотрителя", "шлеме смотрителя")
	desc = "Особый шлем, выдаваемый смотрителям службы безопасности. Защищает голову от пуль, лазеров, осколков и ящиков с инструментами."
	icon_state = "helmet_warden"

/obj/item/clothing/head/helmet/riot
	name = "riot helmet"
	cases = list("противоударный шлем", "противоударного шлема", "противоударному шлему", "противоударный шлем", "противоударным шлемом", "противоударном шлеме")
	desc = "Шлем, специально разработанный для защиты от атак в ближнем бою."
	icon_state = "riot"
	item_state = "helmet"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list(melee = 82, bullet = 15, laser = 5,energy = 5, bomb = 5, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.3
	var/up = 0
	item_action_types = list(/datum/action/item_action/hands_free/adjust_helmet_visor)

/datum/action/item_action/hands_free/adjust_helmet_visor
	name = "Использовать визор"

/obj/item/clothing/head/helmet/riot/attack_self()
	toggle()

/obj/item/clothing/head/helmet/riot/verb/toggle()
	set category = "Object"
	set name = "Использовать визор"
	set src in usr

	if(!usr.incapacitated())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			icon_state = initial(icon_state)
			to_chat(usr, "Вы опускаете визор.")
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			icon_state = "[initial(icon_state)]up"
			to_chat(usr, "Вы поднимаете визор.")
		update_inv_mob() //so our mob-overlays update
		update_item_actions()

/obj/item/clothing/head/helmet/bulletproof
	name = "bulletproof helmet"
	cases = list("пуленепробиваемый шлем", "пуленепробиваемого шлема", "пуленепробиваемому шлему", "пуленепробиваемый шлем", "пуленепробиваемым шлемом", "пуленепробиваемом шлеме")
	desc = "Пуленепробиваемый шлем, отлично защищающий носителя от выстрелов из огнестрельного оружия."
	icon_state = "bulletproof"
	armor = list(melee = 10, bullet = 80, laser = 20,energy = 20, bomb = 35, bio = 0, rad = 0)
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH	// cause sprite has a drawn mask

/obj/item/clothing/head/helmet/laserproof
	name = "ablative helmet"
	cases = list("абляционный шлем", "абляционного шлема", "абляционному шлему", "абляционный шлем", "абляционным шлемом", "абляционном шлеме")
	desc = "Абляционный шлем, отлично защищающий носителя от лазерный и энергетических снарядов."
	icon_state = "laserproof"
	armor = list(melee = 10, bullet = 10, laser = 65,energy = 75, bomb = 0, bio = 0, rad = 0)
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH	// cause sprite has a drawn mask
	siemens_coefficient = 0
	var/hit_reflect_chance = 40

/obj/item/clothing/head/helmet/laserproof/IsReflect(def_zone)
	if(prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/head/helmet/swat
	name = "SWAT helmet"
	cases = list("шлем спецназа", "шлема спецназа", "шлему спецназа", "шлем спецназа", "шлемом спецназа", "шлеме спецназа")
	desc = "Такие шлемы часто используют подразделения специального назначения."
	icon_state = "swat"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state = "swat"
	armor = list(melee = 80, bullet = 75, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.3
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_HEAD)

/obj/item/clothing/head/helmet/thunderdome
	name = "thunderdome helmet"
	cases = list("шлем 'Thunderdome'", "шлема 'Thunderdome'", "шлему 'Thunderdome'", "шлем 'Thunderdome'", "шлемом 'Thunderdome'", "шлеме 'Thunderdome'")
	desc = "<i>'Да начнётся битва!'</i>"
	icon_state = "thunderdome"
	flags = HEADCOVERSEYES
	item_state = "thunderdome"
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 10, bomb = 25, bio = 10, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/gladiator
	name = "gladiator helmet"
	cases = list("шлем гладиатора", "шлема гладиатора", "шлему гладиатора", "шлем гладиатора", "шлемом гладиатора", "шлеме гладиатора")
	desc = "Ave, Imperator, morituri te salutant."
	icon_state = "gladiator"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	item_state = "gladiator"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	siemens_coefficient = 1

/obj/item/clothing/head/helmet/tactical
	name = "tactical helmet"
	cases = list("тактический шлем", "тактического шлема", "тактическому шлему", "тактический шлем", "тактическим шлемом", "тактическом шлеме")
	desc = "Бронированный шлем, на который можно установить широкий спектр тактических обвесов. Только где их взять-то?"
	icon_state = "swathelm"
	item_state = "helmet"
	flags = HEADCOVERSEYES
	armor = list(melee = 62, bullet = 60, laser = 50,energy = 35, bomb = 10, bio = 2, rad = 0)
	flags_inv = HIDEEARS
	siemens_coefficient = 0.7

/obj/item/clothing/head/helmet/tactical/marinad
	name = "marine helmet"
	cases = list("шлем морпеха", "шлема морпеха", "шлему морпеха", "шлем морпеха", "шлемом морпеха", "шлеме морпеха")
	desc = "Лёгкий и прочный шлем из особого защитного сплава. К бою готов!"
	icon_state = "marinad"
	item_state = "marinad_helmet"

/obj/item/clothing/head/helmet/tactical/marinad/leader
	name = "marine beret"
	cases = list("берет морпеха", "берета морпеха", "берету морпеха", "берет морпеха", "беретом морпеха", "берете морпеха")
	desc = "Прочный кевларовый берет в защитных цветах, носимый офицерами низшего звена КМП НТ."
	icon_state = "beret_marinad"

/obj/item/clothing/head/helmet/helmet_of_justice
	name = "helmet of justice"
	cases = list("шлем правосудия", "шлема правосудия", "шлему правосудия", "шлем правосудия", "шлемом правосудия", "шлеме правосудия")
	desc = "Приготовься к правосудию!"
	icon_state = "shitcuritron_0"
	item_state = "helmet"
	var/on = 0
	item_action_types = list(/datum/action/item_action/hands_free/toggle_helmet)

/datum/action/item_action/hands_free/toggle_helmet
	name = "Включить шлем"

/obj/item/clothing/head/helmet/helmet_of_justice/attack_self(mob/user)
	on = !on
	icon_state = "shitcuritron_[on]"
	update_inv_mob()
	update_item_actions()

/obj/item/clothing/head/helmet/warden/blue
	name = "warden's hat"
	cases = list("шляпа смотрителя", "шляпы смотрителя", "шляпе смотрителя", "шляпу смотрителя", "шляпой смотрителя", "шляпе смотрителя")
	desc = "Особая кевларовая шляпа, которую раньше носили смотрители службы безопасности."
	icon_state = "policehelm"
	item_state = "helmet"
	force = 0
	hitsound = list()

/obj/item/clothing/head/helmet/roman
	name = "roman helmet"
	cases = list("римский шлем", "римского шлема", "римскому шлему", "римский шлем", "римским шлемом", "римском шлеме")
	desc = "Древний шлем, сделанный из бронзы и железа."
	armor = list(melee = 25, bullet = 0, laser = 25, energy = 10, bomb = 10, bio = 0, rad = 0)
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/head/helmet/roman/legionaire
	name = "roman legionaire helmet"
	cases = list("римский шлем легионера", "римского шлем легионера", "римскому шлем легионера", "римский шлем легионера", "римским шлем легионера", "римском шлем легионера")
	desc = "Древний шлем, сделанный из бронзы и железа с красным гребнем."
	icon_state = "roman_c"
	item_state = "roman_c"

/obj/item/clothing/head/helmet/M89_Helmet
	name = "M89 Helmet"
	cases = list("шлем М39", "шлема М39", "шлему М39", "шлем М39", "шлемом М39", "шлеме М39")
	desc = "Боевой шлем, используемый частной охранной организацией."
	icon_state = "m89_helmet"
	item_state = "helmet"

/obj/item/clothing/head/helmet/M35_Helmet
	name = "M35 Helmet"
	cases = list("шлем M35", "шлема M35", "шлему M35", "шлем M35", "шлемом M35", "шлеме M35")
	desc = "Стандартный шлем Вермахта."
	icon_state = "M35_Helmet"
	item_state = "helmet"

/obj/item/clothing/head/helmet/syndilight
	name = "light helmet"
	cases = list("лёгкий шлем", "лёгкого шлема", "лёгкому шлему", "лёгкий шлем", "лёгким шлемом", "лёгком шлеме")
	desc = "Более лёгкий и менее бронированный, чем штурмовой аналог, этот шлем предпочитают носить скрытные оперативники."
	icon_state = "lighthelmet"
	item_state = "lighthelmet"
	armor = list(melee = 50, bullet = 60, laser = 45,energy = 50, bomb = 35, bio = 0, rad = 50)
	siemens_coefficient = 0.2

/obj/item/clothing/head/helmet/syndiassault
	name = "assault helmet"
	cases = list("штурмовой шлем", "штурмового шлема", "штурмовому шлему", "штурмовой шлем", "штурмовым шлемом", "штурмовом шлеме")
	desc = "Стильный чёрно-красный шлем с бронированным забралом."
	icon_state = "assaulthelmet_b"
	item_state = "assaulthelmet_b"
	armor = list(melee = 80, bullet = 70, laser = 55, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_HEAD)

/obj/item/clothing/head/helmet/syndiassault/atom_init()
	. = ..()
	holochip = new /obj/item/holochip/nuclear(src)
	holochip.holder = src

/obj/item/clothing/head/helmet/syndiassault/alternate
	icon_state = "assaulthelmet"
	item_state = "assaulthelmet"

/obj/item/clothing/head/helmet/crusader
	name = "crusader topfhelm"
	cases = list("топфхельм крестоносца", "топфхельма крестоносца", "топфхельму крестоносца", "топфхельм крестоносца", "топфхельмом крестоносца", "топфхельме крестоносца")
	desc = "Пусть Вас и зовут ведроголовым, но мы ещё посмотрим, кто будет смеяться последним, когда начнётся крестовый поход."
	icon_state = "crusader"
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 20, bomb = 20, bio = 0, rad = 10)
	siemens_coefficient = 1.2
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/head/helmet/police
	name = "police helmet"
	cases = list("полицейский шлем", "полицейского шлема", "полицейскому шлему", "полицейский шлем", "полицейским шлемом", "полицейском шлеме")
	desc = "Последний писк моды правоохранительных организаций. А ещё этот шлем большой. Реально большой."
	icon_state = "police_helmet"
	flags = HEADCOVERSEYES|HEADCOVERSMOUTH|BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/head/helmet/police/heavy
	name = "heavy police helmet"
	cases = list("тяжелый полицейский шлем", "тяжелого полицейского шлема", "тяжелому полицейскому шлему", "тяжелый полицейский шлем", "тяжелым полицейским шлемом", "тяжелом полицейском шлеме")
	desc = "Последний писк моды правоохранительных организаций. А ещё этот шлем большой. Реально большой. Золотые знаки на этом шлеме обозначают высокое звание его владельца."
	icon_state = "police_helmet_heavy"
	armor = list(melee = 55, bullet = 50, laser = 45,energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/laserproof/police
	name = "inspector helmet"
	cases = list("шлем инспектора", "шлема инспектора", "шлему инспектора", "шлем инспектора", "шлемом инспектора", "шлеме инспектора")
	desc = "Экспериментальный шлем, способный отражать лазерные выстрелы с помощью псионических манипуляций. А ещё он немного больше своих аналогов, чтобы вместить развитый мозг своего владельца."
	icon_state = "police_helmet_inspector"
	armor = list(melee = 35, bullet = 35, laser = 65,energy = 75, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0

/obj/item/clothing/head/helmet/police/elite
	name = "elite police helmet"
	cases = list("элитный полицейский шлем", "элитного полицейского шлема", "элитному полицейскому шлему", "элитный полицейский шлем", "элитным полицейским шлемом", "элитном полицейском шлеме")
	desc = "Tяжелобронированный полицейский шлем. Больше похож на голубой кирпич, чем на шлем."
	icon_state = "police_helmet_elite"
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/surplus
	name = "surplus helmet"
	cases = list("потёртый шлем", "потёртого шлема", "потёртому шлему", "потёртый шлем", "потёртым шлемом", "потёртом шлеме")
	desc = "Простой стальной шлем, копирующий дизайн шлемов двадцатого века."
	icon_state = "surplus_helmet"
	armor = list(melee = 45, bullet = 40, laser = 40,energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/blueshield
	name = "blueshield helmet"
	cases = list("шлем синего щита", "шлема синего щита", "шлему синего щита", "шлем синего щита", "шлемом синего щита", "шлеме синего щита")
	desc = "Шлем из продвинутых материалов, носимый офицерами синего щита."
	icon_state = "blueshield_helmet"
	armor = list(melee = 60, bullet = 55, laser = 50,energy = 35, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/durathread
	name = "durathread helmet"
	cases = list("дюратканевый шлем", "дюратканевого шлема", "дюратканевому шлему", "дюратканевый шлем", "дюратканевым шлемом", "дюратканевом шлеме")
	desc = "Шлем, собранный на коленке из пары листов металла и дюраткани."
	icon_state = "Durahelmet"
	item_state = "Durahelmet"
	armor = list(melee = 45, bullet = 15, laser = 50, energy = 35, bomb = 0, bio = 0, rad = 0)

	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
