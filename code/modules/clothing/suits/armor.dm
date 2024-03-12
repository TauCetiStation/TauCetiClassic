/obj/item/clothing/suit/armor
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/plasma,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/clothing/head/helmet)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4

/obj/item/clothing/suit/armor/vest
	name = "armor"
	cases = list("бронежилет", "бронежилета", "бронежилету", "бронежилет", "бронежилетом", "бронежилете")
	desc = "Бронежилет, защищающий от незначительных повреждений."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/security
	name = "security armor"
	cases = list("бронежилет охраны", "бронежилета охраны", "бронежилету охраны", "бронежилет охраны", "бронежилетом охраны", "бронежилете охраны")
	desc = "Бронежилет, защищающий от незначительных повреждений. На нём есть корпоративная нашивка НаноТрейзен."
	icon_state = "armorsec"
	item_state = "armor"

/obj/item/clothing/suit/armor/vest/fullbody
	name = "fullbody armor"
	cases = list("броня", "брони", "броне", "броню", "бронёй", "броне")
	desc = "Комплект брони, покрывающий всё тело. Преимущественно используется различными правоохранительными органами по всей галактике."
	icon_state = "armor_fullbody"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/armor/vest/fullbody/psy_robe
	name = "purple robes"
	cases = list("пурпурная роба", "пурпурной робы", "пурпурной робе", "пурпурную робу", "пурпурной робой", "пурпурной робе")
	desc = "Тяжелые королевские пурпурные одеяния, инкрустированные психическими усилителями и странными выпуклыми линзами. Не подлежит машинной стирке."
	icon_state = "psyamp"
	item_state = "psyamp"
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 0, bio = 100, rad = 100)

/obj/item/clothing/suit/storage/flak
	name = "security armor"
	cases = list("броня охраны", "брони охраны", "броне охраны", "броню охраны", "бронёй охраны", "броне охраны")
	desc = "Броня, защищающая от незначительных повреждений. На ней прикреплена разгрузка, позволяющая хранить до четырёх предметов."
	icon_state = "armorsec"
	item_state = "armor"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/plasma,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/clothing/head/helmet)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = UPPER_TORSO|LOWER_TORSO
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	siemens_coefficient = 0.4
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)
	flags = ONESIZEFITSALL|HEAR_TALK

/obj/item/clothing/suit/storage/flak/atom_init()
	. = ..()
	pockets = new/obj/item/weapon/storage/internal(src)
	pockets.set_slots(slots = 4, slot_size = SIZE_TINY)

/obj/item/clothing/suit/storage/flak/police
	name = "police armor"
	cases = list("полицейский бронежилет", "полицейского бронежилета", "полицейскому бронежилету", "полицейский бронежилет", "полицейским бронежилетом", "полицейском бронежилете")
	desc = "Бронежилет, защищающий от незначительных повреждений в цветовой палитре \'ОБОП\'. На нём прикреплена разгрузка, позволяющая хранить до четырёх предметов."
	icon_state = "police_armor"
	flags = HEAR_TALK

/obj/item/clothing/suit/storage/flak/police/fullbody
	name = "police fullbody armor"
	cases = list("полицейская броня", "полицейской брони", "полицейской броне", "полицейскую броню", "полицейской бронёй", "полицейской броне")
	desc = "Комплект брони, покрывающий всё тело. Этот экземпляр используется \'ОБОП\' и окрашен в соответствующие цвета."
	icon_state = "police_armor_fullbody"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/storage/flak/police/fullbody/heavy
	name = "heavy fullbody armor"
	cases = list("тяжелая броня", "тяжёлой брони", "тяжёлой броне", "яжёлую броню", "тяжёлой бронёй", "тяжёлой броне")
	desc = "Комплект брони, используемый подразделениями специального назначения \'ОБОП\'. Справедливость восторжествует."
	icon_state = "police_armor_heavy"
	slowdown = 0.2
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/suit/marinad
	name = "marine armor"
	cases = list("броня морпеха", "брони морпеха", "броне морпеха", "броню морпеха", "бронёй морпеха", "броне морпеха")
	desc = "Это однозначно защитит вас от враждебно настроенной флоры и фауны."
	icon_state = "marinad"
	item_state = "marinad_armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 0.5
	armor = list(melee = 60, bullet = 65, laser = 55, energy = 60, bomb = 40, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/plasma,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/clothing/head/helmet)

/obj/item/clothing/suit/armor/vest/warden
	name = "Warden's jacket"
	cases = list("куртка смотрителя", "куртки смотрителя", "куртке смотрителя", "куртку смотрителя", "курткой смотрителя", "куртке смотрителя")
	desc = "Бронированная куртка с золотыми нашивками и ливреями."
	icon_state = "warden_jacket"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/storage/flak/warden
	name = "Warden's jacket"
	cases = list("куртка смотрителя", "куртки смотрителя", "куртке смотрителя", "куртку смотрителя", "курткой смотрителя", "куртке смотрителя")
	desc = "Бронированная куртка с золотыми нашивками и ливреями."
	icon_state = "warden_jacket"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags = null

/obj/item/clothing/suit/armor/vest/leather
	name = "security overcoat"
	cases = list("армированный плащ", "армированного плаща", "армированному плащу", "армированный плащ", "армированным плащем", "армированном плаще")
	desc = "Легкий кожаный бронированный плащ, предназначенный для повседневного ношения высокопоставленными офицерами. Украшен гербом безопасности НаноТрейзен."
	icon_state = "leather_overcoat-sec"
	item_state = "hostrench"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/suit/armor/hos
	name = "armored coat"
	cases = list("армированная шинель", "армированной шинели", "армированной шинели", "армированную шинель", "армированной шинелью", "армированной шинели")
	desc = "Великолепная шинель, усиленная специальным сплавом для дополнительной защиты и стиля."
	icon_state = "hos"
	item_state = "hos"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 80, bullet = 60, laser = 55, energy = 35, bomb = 50, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.6

/obj/item/clothing/suit/armor/riot
	name = "riot suit"
	cases = list("противоударная броня", "противоударной брони", "противоударной броне", "противоударную броню", "противоударной бронёй", "противоударной броне")
	desc = "Бронекостюм с тяжелой подкладкой для защиты от атак в ближнем бою."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 80, bullet = 10, laser = 25, energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/armor/bulletproof
	name = "bulletproof fullbody armor"
	cases = list("пуленепробиваемая броня", "пуленепробиваемой брони", "пуленепробиваемой броне", "пуленепробиваемую броню", "пуленепробиваемой бронёй", "пуленепробиваемой броне")
	desc = "Комплект брони, покрывающий всё тело и отлично защищающий носителя от снарядов, летящих на высокой скорости."
	icon_state = "bulletproof_fullbody"
	item_state = "bulletproof_fullbody"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 80, laser = 20, energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/storage/flak/bulletproof
	name = "bulletproof fullbody armor"
	cases = list("пуленепробиваемая броня", "пуленепробиваемой брони", "пуленепробиваемой броне", "пуленепробиваемую броню", "пуленепробиваемой бронёй", "пуленепробиваемой броне")
	desc = "Комплект брони, покрывающий всё тело и отлично защищающий носителя от снарядов, летящих на высокой скорости."
	icon_state = "bulletproof_fullbody"
	item_state = "bulletproof_fullbody"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 80, laser = 20, energy = 20, bomb = 35, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	flags = HEAR_TALK

/obj/item/clothing/suit/storage/flak/bulletproof/atom_init()
	. = ..()
	pockets = new/obj/item/weapon/storage/internal(src)
	pockets.set_slots(slots = 5, slot_size = SIZE_TINY)

/obj/item/clothing/suit/armor/laserproof
	name = "ablative fullbody armor"
	cases = list("абляционная броня", "абляционной брони", "абляционной броне", "абляционную броню", "абляционной бронёй", "абляционной броне")
	desc = "Комплект брони, покрывающий всё тело и отлично защищающий носителя от энергетических снарядов."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	armor = list(melee = 10, bullet = 10, laser = 65, energy = 75, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/laserproof/IsReflect(def_zone)
	if(!(def_zone in list(BP_CHEST , BP_GROIN))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return 0
	if (prob(hit_reflect_chance))
		return 1

/obj/item/clothing/suit/armor/laserproof/police
	name = "police ablative armor"
	cases = list("абляционный полицейский бронежилет", "абляционного полицейского бронежилета", "абляционному полицейскому бронежилету", "абляционный полицейский бронежилет", "абляционным полицейским бронежилетом", "абляционном полицейском бронежилете")
	desc = "Экспериментальная модель аблятивной брони, выпущенная в ограниченном количестве для специальных подразделений \'ОБОП\'. Этот комплект брони защищает не только от лазеров, но также достаточно прочен, чтобы выдерживать другие виды повреждений."
	icon_state = "police_armor_inspector"
	armor = list(melee = 35, bullet = 35, laser = 65, energy = 75, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/swat
	name = "swat suit"
	cases = list("броня спецназа", "брони спецназа", "броне спецназа", "броню спецназа", "бронёй спецназа", "броне спецназа")
	desc = "Тяжелый бронированный костюм, защищающий от умеренного количества повреждений. Используется в специальных операциях."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 0.2
	armor = list(melee = 80, bullet = 70, laser = 70,energy = 70, bomb = 70, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/gun/plasma,/obj/item/weapon/gun/projectile,/obj/item/ammo_box/magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/clothing/head/helmet, /obj/item/weapon/tank)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	flags_pressure = STOPS_LOWPRESSUREDMAGE

/obj/item/clothing/suit/armor/swat/officer
	name = "officer jacket"
	cases = list("офицерская куртка", "офицерской куртки", "офицерской куртке", "офицерскую куртку", "офицерской курткой", "офицерской куртке")
	desc = "Бронированная куртка, используемая в специальных операциях."
	icon_state = "detective_trenchcoat_brown"
	item_state = "detective_trenchcoat_brown"
	blood_overlay_type = "coat"
	flags_inv = 0
	body_parts_covered = UPPER_TORSO|ARMS
	pierce_protection = UPPER_TORSO|ARMS

/obj/item/clothing/suit/armor/det_suit
	name = "armor"
	cases = list("бронежилет детектива", "бронежилета детектива", "бронежилету детектива", "бронежилет детектива", "бронежилетом детектива", "бронежилете детектива")
	desc = "Бронежилет с значком детектива."
	icon_state = "detective-armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	flags = ONESIZEFITSALL
	armor = list(melee = 50, bullet = 55, laser = 25, energy = 20, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/suit/storage/flak/blueshield
	name = "blueshield armor vest"
	cases = list("бронежилет Синего Щита", "бронежилета Синего Щита", "бронежилету Синего Щита", "бронежилет Синего Щита", "бронежилетом Синего Щита", "бронежилете Синего Щита")
	desc = "Он тяжелый и каким-то образом... удобный?"
	icon_state = "blueshield"
	item_state = "armor"
	armor = list(melee = 60, bullet = 55, laser = 50, energy = 35, bomb = 35, bio = 0, rad = 0)
	flags = ONESIZEFITSALL

//Reactive armor
//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/vest/reactive
	name = "experimental teleport armor"
	cases = list("экспериментальная броня-телепортер", "экспериментальной брони-телепортера", "экспериментальной броне-телепортеру", "экспериментальную броню-телепортер", "экспериментальной броней-телепортером", "экспериментальной броне-телепортере")
	desc = "Высокотехнологичная броня с обилием датчиков и забавных устройств внутри. Но почему эта броня была доверена учёному?"
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	var/active = FALSE

/obj/item/clothing/suit/armor/vest/reactive/Get_shield_chance()
	if(active)
		return 50
	return 0

/obj/item/clothing/suit/armor/vest/reactive/attack_self(mob/user)
	active = !(active)
	if(active)
		to_chat(user, "<span class='notice'>Система реактивной брони - активирована. Система твердотельной брони - деактивирована.</span>")
		armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
		icon_state = "reactive"
		item_state = "reactive"
		add_fingerprint(user)
	else
		to_chat(user, "<span class='notice'>Система реактивной брони - деактивирована. Система твердотельной брони - активирована.</span>")
		armor = list(melee = 50, bullet = 45, laser = 40, energy = 20, bomb = 0, bio = 0, rad = 0)
		icon_state = "reactiveoff"
		item_state = "reactiveoff"
		add_fingerprint(user)
	return

/obj/item/clothing/suit/armor/vest/reactive/emp_act(severity)
	active = FALSE
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	armor = list(melee = 50, bullet = 45, laser = 40, energy = 20, bomb = 0, bio = 0, rad = 0)
	..()

/obj/item/clothing/suit/armor/vest/reactive/proc/teleport_user(range, mob/user, text)
	if(!isnull(text))
		visible_message("<span class='userdanger'>Система реактивной телепортации перемещает [user.name] в сторону от [text]!</span>")
	var/list/turfs = list()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(5, 0, user.loc)
	smoke.attach(user)
	smoke.start()
	for(var/turf/T in orange(range))
		if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
			continue
		if(isenvironmentturf(T))
			continue
		if(T.density)
			continue
		if(T.x>world.maxx-6 || T.x<6)
			continue
		if(T.y>world.maxy-6 || T.y<6)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(range))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	user.forceMove(picked)
	playsound(user, 'sound/effects/phasein.ogg', VOL_EFFECTS_MASTER)
	return TRUE




//All of the armor below is mostly unused


/obj/item/clothing/suit/armor/centcomm
	name = "Cent. Com. armor"
	cases = list("броня центрального командования", "брони центрального командования", "броне центрального командования", "броню центрального командования", "бронёй центрального командования", "броне центрального командования")
	desc = "Костюм, защищающий от незначительных повреждений."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = SIZE_NORMAL//bulky item
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/heavy
	name = "heavy armor"
	cases = list("тяжелая броня", "тяжелой брони", "тяжелой броне", "тяжелую броню", "тяжелой бронёй", "о тяжелой броне")
	desc = "Тяжелоукреплённый костюм, защищающий от значительных повреждений."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = SIZE_NORMAL//bulky item
	gas_transfer_coefficient = 0.90
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 1.5
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/armor/tdome/red
	name = "thunderdome suit (red)"
	cases = list("красный костюм \'Thunderdome\'", "красного костюма \'Thunderdome\'", "красному костюму \'Thunderdome\'", "красный костюм \'Thunderdome\'", "красным костюмом \'Thunderdome\'", "красном костюме \'Thunderdome\'")
	desc = "Красноватая броня."
	icon_state = "tdred"
	item_state = "tdred"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tdome/green
	name = "thunderdome suit (green)"
	cases = list("зелёный костюм \'Thunderdome\'", "зелёного костюма \'Thunderdome\'", "зелёному костюму \'Thunderdome\'", "зелёный костюм \'Thunderdome\'", "зелёным костюмом \'Thunderdome\'", "зелёном костюме \'Thunderdome\'")
	desc = "Бледно-зелёная броня."
	icon_state = "tdgreen"
	item_state = "tdgreen"
	siemens_coefficient = 1

/obj/item/clothing/suit/armor/tactical
	name = "tactical armor"
	cases = list("тактическая броня", "тактической брони", "тактической броне", "тактическую броню", "тактической бронёй", "тактической броне")
	desc = "Комплект брони, наиболее часто используемый отрядами специального назначения и тактического вооружения. Включает в себя жилет с подкладкой и карманами, а также наколенники и наплечники."
	icon_state = "swatarmor"
	item_state = "armor"
	var/obj/item/weapon/gun/holstered = null
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	slowdown = 0.5
	armor = list(melee = 60, bullet = 65, laser = 50, energy = 60, bomb = 40, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/tactical/verb/holster()
	set name = "Holster"
	set category = "Object"
	set src in usr
	if(!isliving(usr)) return
	if(usr.incapacitated())
		return

	if(!holstered)
		var/obj/item/I = usr.get_active_hand()
		if(!istype(I, /obj/item/weapon/gun) && !I.can_be_holstered)
			to_chat(usr, "<span class='notice'>You need your gun equiped to holster it.</span>")
			return
		if(!I.can_be_holstered)
			to_chat(usr, "<span class='warning'>This gun won't fit in \the belt!</span>")
			return
		holstered = usr.get_active_hand()
		usr.drop_from_inventory(holstered, src)
		usr.visible_message("<span class='notice'>\The [usr] holsters \the [holstered].</span>", "You holster \the [holstered].")
	else
		if(istype(usr.get_active_hand(),/obj) && istype(usr.get_inactive_hand(),/obj))
			to_chat(usr, "<span class='warning'>You need an empty hand to draw the gun!</span>")
		else
			if(usr.a_intent == INTENT_HARM)
				usr.visible_message("<span class='warning'>\The [usr] draws \the [holstered], ready to shoot!</span>", \
				"<span class='warning'>You draw \the [holstered], ready to shoot!</span>")
			else
				usr.visible_message("<span class='notice'>\The [usr] draws \the [holstered], pointing it at the ground.</span>", \
				"<span class='notice'>You draw \the [holstered], pointing it at the ground.</span>")
			usr.put_in_hands(holstered)
		holstered = null

/obj/item/clothing/suit/armor/syndiassault
	name = "assault armor"
	cases = list("штурмовая броня", "штурмовой брони", "штурмовой броне", "штурмовую броню", "штурмовой бронёй", "штурмовой броне")
	desc = "Тяжелый бронированный костюм, разработанный для выдерживания всех видов урона, начиная от простых ударов и заканчивая мощными лазерами."
	icon_state = "assaultarmor"
	item_state = "assaultarmor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 80, bullet = 70, laser = 55, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/armor/syndilight
	name = "recon armor"
	cases = list("броня разведчика", "брони разведчика", "броне разведчика", "броню разведчика", "бронёй разведчика", "броне разведчика")
	desc = "Легкий бронированный жилет, предназначенный для разведывательных миссий. Обеспечивает надежную защиту, несмотря на всю легкость. Теперь в полноразмерном формате!"
	icon_state = "lightarmor"
	item_state = "lightarmor"
	armor = list(melee = 50, bullet = 40, laser = 40, energy = 70, bomb = 50, bio = 0, rad = 50)
	siemens_coefficient = 0.2
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/armor/m66_kevlarvest
	name = "M66 Tactical Vest"
	cases = list("тактический бронежилет М66", "М66", "тактическому бронежилету М66", "тактический бронежилет М66", "тактическим бронежилетом М66", "тактическом бронежилете М66")
	desc = "Черный тактический жилет из кевлара, используемый частными охранными фирмами. Очень тактический."
	icon_state = "M66_KevlarVest"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list(melee = 60, bullet = 80, laser = 40, energy = 50, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/armor/crusader
	name = "crusader tabard"
	cases = list("табард крестоносца", "табарда крестоносца", "табарду крестоносца", "табард крестоносца", "табардом крестоносца", "табарде крестоносца")
	desc = "Это кольчуга с тканью, накинутой сверху. \'Non nobis domini\' и всё такое..."
	icon_state = "crusader"
	item_state = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 20, bomb = 25, bio = 0, rad = 10)
	siemens_coefficient = 1.2

/obj/item/clothing/suit/armor/vest/surplus
	name = "surplus armor vest"
	cases = list("протёртый бронежилет", " потёртого бронежилета", "потёртому бронежилету", "потёртый бронежилет", "потёртым бронежилетом", "потёртом бронежилете")
	desc = "Бронежилет с устаревшими бронепластинами, который больше не используется галактическими военными. Но, по крайней мере, он дешёвый."
	icon_state = "armor_surplus_1"
	armor = list(melee = 45, bullet = 40, laser = 40, energy = 25, bomb = 35, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/vest/surplus/atom_init()
	. = ..()
	icon_state = "surplus_armor_[rand(1,2)]"

/obj/item/clothing/suit/armor/vest/durathread
	name = "durathread vest"
	cases = list("дюратканевый жилет", "дюратканевого жилета", "дюратканевому жилету", "дюратканевый жилет", "дюратканевым жилетом", "дюратканевом жилете")
	desc = "Жилет, изготовленный из дюраткани и кучи тряпок, скреплённых проводами."
	icon_state = "Duraarmor"
	item_state = "Duraarmor"
	armor = list(melee = 45, bullet = 15, laser = 50, energy = 35, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/duracoat
	name = "durathread coat"
	cases = list("дюратканевый плащ", "дюратканевого плаща", "дюратканевому плащу", "дюратканевый плащ", "дюратканевым плащом", "дюратканевом плаще")
	desc = "Плащ, изготовленный из дюраткани, выглядит стильно."
	icon_state = "Duracoat"
	item_state = "Duracoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	pierce_protection = UPPER_TORSO|LOWER_TORSO
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	armor = list(melee = 40, bullet = 5, laser = 40, energy = 25, bomb = 0, bio = 0, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0.4
