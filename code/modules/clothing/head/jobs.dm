
//Cook
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	cases = list("поварской колпак", "поварского колпака", "поварскому колпаку", "поварской колпак", "поварским колпаком", "поварском колпаке")
	desc = "Защищает еду от поварских волос. Задачу свою выполняет не очень."
	gender = MALE
	icon_state = "chefhat"
	item_state = "chefhat"
	siemens_coefficient = 0.9

//Cook-alt
/obj/item/clothing/head/sushi_band
	name = "sushi master headband"
	cases = list("повязка суши-мастера", "повязки суши-мастера", "повязке суши-мастера", "повязку суши-мастера", "повязкой суши-мастера", "повязке суши-мастера")
	desc = "Прекрасная минималистичная повязка."
	gender = FEMALE
	icon_state = "sushiband"
	item_state = "sushiband"

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/caphat
	name = "captain's hat"
	cases = list("шляпа капитана", "шляпы капитана", "шляпе капитана", "шляпу капитана", "шляпой капитана", "шляпе капитана")
	icon_state = "captain"
	gender = FEMALE
	desc = "Хорошо быть королём."
	item_state = "caphat"
	siemens_coefficient = 0.9

//Captain: This probably shouldn't be space-worthy
/obj/item/clothing/head/helmet/cap
	name = "captain's cap"
	cases = list("фуражка капитана", "фуражки капитана", "фуражке капитана", "фуражку капитана", "фуражкой капитана", "фуражке капитана")
	desc = "Так и манит посамодурствовать."
	gender = FEMALE
	icon_state = "capcap"
	flags_inv = 0
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.9
	force = 0
	hitsound = list()

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	cases = list("капюшон священника", "капюшона священника", "капюшону священника", "капюшон священника", "капюшоном священника", "капюшоне священника")
	desc = "Капюшон, покрывающий голову. В таком не замерзнешь в космическую зиму."
	gender = MALE
	icon_state = "chaplain_hood"
	flags = HEADCOVERSEYES|BLOCKHAIR
	siemens_coefficient = 0.9
	body_parts_covered = HEAD|EYES

/obj/item/clothing/head/skhima_hood
	name = "skhima hood"
	cases = list("куколь", "куколя", "куколю", "куколь", "куколем", "куколю")
	desc = "Монашеский головной покров, украшенный белыми письменами. Такой обычно носят священнослужители, принявшие схиму."
	gender = MALE
	icon_state = "skhima_hood"
	item_state = "skhima_hood"
	flags = HEADCOVERSEYES
	siemens_coefficient = 0.9

/obj/item/clothing/head/nun_hood
	name = "nun hood"
	cases = list("капюшон монахини", "капюшона монахини", "капюшону монахини", "капюшон монахини", "капюшоном монахини", "капюшоне монахини")
	gender = MALE
	desc = "Религиозный капюшон, носимый монастырскими сестрами."
	icon_state = "nun_hood"
	flags = BLOCKHAIR
	siemens_coefficient = 0.9

//HoS
/obj/item/clothing/head/hos_peakedcap
	name = "head of security's peaked cap"
	cases = list("фуражка главы охраны", "фуражки главы охраны", "фуражке главы охраны", "фуражку главы охраны", "фуражкой главы охраны", "фуражке главы охраны")
	desc = "Фуражка главы службы безопасности. Я тебя выслушал, криминальный ублюдок. А теперь - прямиком в ГУЛАГ. В подкладке есть место под особую бронеплиту."
	gender = FEMALE
	icon_state = "hos_peakedcap"
	item_state = "hos_peakedcap"
	w_class = SIZE_TINY
	siemens_coefficient = 0.9
	body_parts_covered = 0
	valid_accessory_slots = list("dermal")
	restricted_accessory_slots = list("dermal")

/obj/item/clothing/head/hos_hat
	name = "head of security's hat"
	cases = list("шляпа главы охраны", "шляпы главы охраны", "шляпе главы охраны", "шляпу главы охраны", "шляпой главы охраны", "шляпе главы охраны")
	desc = "Шляпа главы службы безопасности. Показывает офицерам, кто тут главный. В подкладке есть место под особую бронеплиту."
	gender = FEMALE
	icon_state = "hoshat"
	item_state = "hoshat"
	w_class = SIZE_TINY
	siemens_coefficient = 0.9
	body_parts_covered = 0
	valid_accessory_slots = list("dermal")
	restricted_accessory_slots = list("dermal")

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	cases = list("хирургический чепчик", "хирургического чепчика", "хирургическому чепчику", "хирургический чепчик", "хирургическим чепчиком", "хирургическому чепчику")
	desc = "Головной убор для проведения хирургических операций. Предотвращает попадание волос в ваши привередливые внутренние органы."
	gender = MALE
	icon_state = "surgcap_blue"
	flags = BLOCKHEADHAIR

/obj/item/clothing/head/surgery/purple
	desc = "Головной убор для проведения хирургических операций. Предотвращает попадание волос в ваши привередливые внутренние органы. Этот выполнен в глубоком фиолетовом цвете"
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/blue
	desc = "Головной убор для проведения хирургических операций. Предотвращает попадание волос в ваши привередливые внутренние органы. Этот выполнен в нежно-голубом цвете"
	icon_state = "surgcap_blue"

/obj/item/clothing/head/surgery/green
	desc = "Головной убор для проведения хирургических операций. Предотвращает попадание волос в ваши привередливые внутренние органы. Этот выполнен в тёмно-зелёном цвете"
	icon_state = "surgcap_green"

//Detective

/obj/item/clothing/head/det_hat
	name = "detective's brown hat"
	cases = list("коричневая шляпа детектива", "коричневой шляпы детектива", "коричневой шляпе детектива", "коричневую шляпу детектива", "коричневой шляпой детектива", "коричневой шляпе детектива")
	desc = "В этой шляпе вы будете выглядеть как настоящий заумный сыщик."
	gender = FEMALE
	icon_state = "detective_hat_brown"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	body_parts_covered = HEAD

/obj/item/clothing/head/det_hat/gray
	name = "detective's gray hat"
	cases = list("серая шляпа детектива", "серой шляпы детектива", "серой шляпе детектива", "серую шляпу детектива", "серой шляпой детектива", "серой шляпе детектива")
	icon_state = "detective_hat_gray"
