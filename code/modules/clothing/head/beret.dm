/obj/item/clothing/head/beret
	name = "beret"
	cases = list("берет", "берета", "берету", "берет", "беретом", "берете")
	icon_state = "" // so we can spot it as a broken item if we see it ingame
	desc = "Берет - любимый головной убор любого уважающего себя художника."
	gender = MALE
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/beret/red
	name = "red beret"
	cases = list("красный берет", "красного берета", "красному берету", "красный берет", "красным беретом", "красном берете")
	desc = "Бонжур! Красный берет, пахнущий багетом, простите за мой французский."
	icon_state = "beret_red"

/obj/item/clothing/head/beret/blue
	name = "blue beret"
	cases = list("синий берет", "синего берета", "синему берету", "синий берет", "синим беретом", "синем берете")
	desc = "Бонжур! Синий берет, пахнущий багетом, простите за мой французский."
	icon_state = "beret_blue"

/obj/item/clothing/head/beret/black
	name = "black beret"
	cases = list("чёрный берет", "чёрного берета", "чёрному берету", "чёрный берет", "чёрным беретом", "чёрном берете")
	desc = "Бонжур! Чёрный берет, пахнущий багетом, простите за мой французский."
	icon_state = "beret_black"

/obj/item/clothing/head/beret/purple
	name = "purple beret"
	cases = list("фиолетовый берет", "фиолетового берета", "фиолетовому берету", "фиолетовый берет", "фиолетовым беретом", "фиолетовом берете")
	desc = "Бонжур! Фиолетовый берет, пахнущий багетом, простите за мой французский."
	icon_state = "beret_purple"

/obj/item/clothing/head/beret/centcomofficer
	name = "officers beret"
	cases = list("офицерский берет", "офицерского берета", "офицерскому берету", "офицерский берет", "офицерским беретом", "офицерском берете")
	desc = "Черный берет, украшенный серебряной эмблемой меча службы безопасности Нанотрейзен, означающей, что носитель берета – настоящий защитник Корпорации."
	icon_state = "centcomofficerberet"

/obj/item/clothing/head/beret/centcomcaptain
	name = "captains beret"
	cases = list("капитанский берет", "капитанского берета", "капитанскому берету", "капитанский берет", "капитанским беретом", "капитанском берете")
	desc = "Черный берет, украшенный кобальтовой эмблемой меча службы безопасности Нанотрейзен, означающей, что носитель берета – капитан корабля Флота Нанотрейзен."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/beret/rosa
	name = "white beret"
	cases = list("белый берет", "белого берета", "белому берету", "белый берет", "белым беретом", "белом берете")
	icon_state = "rosas_hat"
	item_state = "helmet"

// Security

/obj/item/clothing/head/beret/sec
	name = "officer's beret"
	cases = list("офицерский берет", "офицерского берета", "офицерскому берету", "офицерский берет", "офицерским беретом", "офицерском берете")
	desc = "Берет с эмблемой охраны. Для офицеров, отдающих предпочтение стилю, а не безопасности."
	icon_state = "beret_badge"

/obj/item/clothing/head/sec_peakedcap
	name = "офицерская фуражка"
	cases = list("офицерская фуражка", "офицерской фуражки", "офицерской фуражке", "офицерскую фуражку", "офицерской фуражкой", "офицерской фуражке")
	desc = "Фуражка с эмблемой охраны. Для офицеров, скучающих по армии."
	icon_state = "sec_peakedcap"
	item_state = "sec_peakedcap"
	gender = FEMALE
	w_class = SIZE_TINY
	siemens_coefficient = 0.9
	body_parts_covered = 0

/obj/item/clothing/head/beret/sec/warden
	name = "берет смотрителя"
	cases = list("берет смотрителя", "берета смотрителя", "берету смотрителя", "берет смотрителя", "беретом смотрителя", "берете смотрителя")
	desc = "Берет с бронзовой эмблемой охраны. Для смотрителей, отдающих предпочтение стилю, а не безопасности."
	icon_state = "beret_warden"

/obj/item/clothing/head/beret/sec/hos
	name = "head of security's beret"
	cases = list("берет главы охраны", "берета главы охраны", "берету главы охраны", "берет главы охраны", "беретом главы охраны", "берете главы охраны")
	desc = "Берет с золотой эмблемой охраны. Показывает, у кого на станции самая длинная дубинка. В подкладке есть место под особую бронеплиту."
	icon_state = "beret_hos"
	valid_accessory_slots = list("dermal")
	restricted_accessory_slots = list("dermal")

// Engineering

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	cases = list("инженерный берет", "инженерного берета", "инженерному берету", "инженерный берет", "инженерным беретом", "инженерном берете")
	desc = "Берет с эмблемой инженерного отдела. Для инженеров, отдающих предпочтение стилю, а не безопасности."
	icon_state = "e_beret_badge"

//Medical


/obj/item/clothing/head/beret/paramed
	name = "first responder beret"
	cases = list("берет первой помощи", "берета первой помощи", "берету первой помощи", "берет первой помощи", "беретом первой помощи", "берете первой помощи")
	desc = "Берет с эмблемой медицинского отдела. Выделяющийся берет для парамедиков, показывающий, кто тут спасает жизни."
	icon_state = "beret_fr"

/obj/item/clothing/head/beret/blueshield
	name = "blueshield officer's beret"
	cases = list("берет синего щита", "берета синего щита", "берету синего щита", "берет синего щита", "беретом синего щита", "берете синего щита")
	desc = "Берет с эмблемой синего щита. Офицерам синего щита рекомендуется НЕ НОСИТЬ декоративные головные уборы во время работы."
	icon_state = "beret_blueshield"
