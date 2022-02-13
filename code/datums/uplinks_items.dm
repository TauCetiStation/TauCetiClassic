//var/list/uplink_items = list()

/proc/get_uplink_items(obj/item/device/uplink/uplink)
	// If not already initialized..
	if(!uplink.uplink_items.len)

		// Fill in the list	and order it like this:
		// A keyed list, acting as categories, which are lists to the datum.

		var/list/last = list()
		for(var/item in typesof(/datum/uplink_item))

			var/datum/uplink_item/I = new item()
			if(!I.item)
				continue
			if(I.uplink_types.len && !(uplink.uplink_type in I.uplink_types))
				continue
			if(I.last)
				last += I
				continue
			if(uplink.uplink_type == "dealer" && I.need_wanted_level)
				var/datum/faction/cops/cops = find_faction_by_type(/datum/faction/cops)
				if(cops && I.need_wanted_level > cops.wanted_level)
					continue

			if(!uplink.uplink_items[I.category])
				uplink.uplink_items[I.category] = list()

			uplink.uplink_items[I.category] += I

		for(var/datum/uplink_item/I in last)

			if(!uplink.uplink_items[I.category])
				uplink.uplink_items[I.category] = list()

			uplink.uplink_items[I.category] += I

	return uplink.uplink_items

// You can change the order of the list by putting datums before/after one another OR
// you can use the last variable to make sure it appears last, well have the category appear last.

/datum/uplink_item
	var/name = "item name"
	var/category = "item category"
	var/desc = "item description"
	var/item = null
	var/cost = 0
	var/last = 0 // Appear last
	var/list/uplink_types = list() //Empty list means that the object will be available in all types of uplinks. Alias you will need to state its type.

	// used for dealer items
	var/need_wanted_level

/datum/uplink_item/proc/spawn_item(turf/loc, obj/item/device/uplink/U, mob/user)
	if(item)
		U.uses -= max(cost, 0)
		feedback_add_details("traitor_uplink_items_bought", "[item]")
		return new item(loc)

/datum/uplink_item/proc/buy(obj/item/device/uplink/U, mob/user)
	if(!istype(U))
		return FALSE

	if(!user || user.incapacitated())
		return FALSE

	if(!( istype(user, /mob/living/carbon/human)))
		return FALSE

	// If the uplink's holder is in the user's contents or near him
	if(U.Adjacent(user, recurse = 2))
		user.set_machine(U)
		if(cost > U.uses)
			return FALSE

		var/obj/I = spawn_item(get_turf(user), U, user)
		if(!I)
			return FALSE
		var/icon/tempimage = icon(I.icon, I.icon_state)
		end_icons += tempimage
		var/tempstate = end_icons.len
		var/bundlename = name
		if(name == "Random Item" || name == "For showing that you are The Boss")
			bundlename = I.name
		if(I.tag)
			bundlename = "[I.tag] bundle"
			I.tag = null
		if(istype(I, /obj/item) && ishuman(user))
			var/mob/living/carbon/human/A = user
			A.put_in_any_hand_if_possible(I)
			loging(A, tempstate, bundlename)

		return TRUE
	return FALSE

/datum/uplink_item/proc/loging(mob/living/carbon/human/user, tempstate, bundlename)
	if(user.mind)
		for(var/role in user.mind.antag_roles)
			var/datum/role/R = user.mind.antag_roles[role]
			var/datum/component/gamemode/syndicate/S = R.GetComponent(/datum/component/gamemode/syndicate)
			if(!S)
				continue
			S.spent_TC += cost
			if(istype(R, /datum/role/operative))
				R.faction.faction_scoreboard_data += {"<img src="logo_[tempstate].png"> [bundlename] for [cost] TC."}
			else
				S.uplink_items_bought += {"<img src="logo_[tempstate].png"> [bundlename] for [cost] TC."}


/*
//
//	UPLINK ITEMS
//
*/

// DANGEROUS WEAPONS

/datum/uplink_item/dangerous
	category = "Conspicuous and Dangerous Weapons"

/datum/uplink_item/dangerous/revolver
	name = "TR-7 Revolver"
	desc = "Традиционный пистолет Cиндиката. Ревеольвер заряжен 7-ью патронами калибра .357 Magnum. Выглядит как игрушка."
	item = /obj/item/weapon/gun/projectile/revolver
	cost = 8
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/revolver/traitor
	name = "TR-8-R Revolver"
	desc = "Традиционный пистолет Cиндиката. Ревеольвер заряжен 7-ью патронами калибра .357 Magnum. Выглядит как игрушка."
	item = /obj/item/weapon/gun/projectile/revolver/traitor
	uplink_types = list("traitor")

/datum/uplink_item/dangerous/pistol
	name = "Stechkin Pistol"
	desc = "Компактный, незаметный пистолет, заряженный 8-ью патронами 9мм калибра. \
			Можно присоединить глушителем."
	item = /obj/item/weapon/gun/projectile/automatic/pistol
	cost = 6

/datum/uplink_item/dangerous/deagle
	name = "Desert Eagle"
	desc = "Robust-пушка, заряжаемая патронами калибра .50 AE."
	item = /obj/item/weapon/gun/projectile/automatic/deagle/weakened
	cost = 8
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/dangerous/deagle_gold
	name = "Desert Eagle Gold"
	desc = "Позолоченный пистолет, спроектированный усилиями превосходных марсианских оружейников. Использует патроны калибра 50 АЕ."
	item = /obj/item/weapon/gun/projectile/automatic/deagle/weakened/gold
	cost = 9
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/dangerous/smg
	name = "C-20r Submachine Gun"
	desc = "Пистолет-пулемет, разработанный компанией \"Скарборо Армс\". Использует магазины на 20 патронов калибра .45  ACP. Обладает большим разнообразием боеприпасов."
	item = /obj/item/weapon/gun/projectile/automatic/c20r
	cost = 12
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/mini_uzi
	name = "Mac-10"
	desc = "Легкое и скорострельное оружие, идеально подходящее для того, чтобы кто-то быстро умер. Использует патроны калибра 9 мм. "
	item = /obj/item/weapon/gun/projectile/automatic/mini_uzi
	cost = 12
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/dangerous/tommygun
	name = "Tommygun"
	desc = "Создан на основе известной "Чикагской пишущей машинки". Использует патроны калибра .45 ACP."
	item = /obj/item/weapon/gun/projectile/automatic/tommygun
	cost = 10
	uplink_types = list("dealer")

	need_wanted_level = 2

/datum/uplink_item/dangerous/bulldog
	name = "V15 Bulldog shotgun"
	desc = "Компактный полуавтоматический дробовик магазинного типа для боя в узких пространствах. Использует различные патроны 12 калибра."
	item = /obj/item/weapon/gun/projectile/automatic/bulldog
	cost = 16
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/machinegun
	name = "L6 Squad Automatic Weapon"
	desc = "Пулемет традиционной конструкции производства AA-2531. Это смертоносное оружие имеет массивный магазин на 50 патронов калибра 7,62x51 мм. "
	item = /obj/item/weapon/gun/projectile/automatic/l6_saw
	cost = 45
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/heavyrifle
	name = "PTR-7 heavy rifle"
	desc = "Портативная тяжелая винтовка со скользящим затвором. Создана для борьбы с бронированными экзоскелетами. Стреляет бронебойными патронами калибра 14.5mm"
	item = /obj/item/weapon/gun/projectile/heavyrifle
	cost = 20
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/bazooka
	name = "Goliath missile launcher"
	desc = "Многоцелевая однозарядная ручная ракетная установка Goliath "
	item = /obj/item/weapon/gun/projectile/revolver/rocketlauncher
	cost = 35
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/a74
	name = "A74 Assault Rifle"
	desc = "Автоматическая штурмовая винтовка. Идеально справляется с подавлением целей на большой дистанции. Магазин содержит 30 /
		патронов калибра 7.74mm."
	item = /obj/item/weapon/gun/projectile/automatic/a74
	cost = 20
	uplink_types = list("nuclear", "dealer")

	need_wanted_level = 5

/datum/uplink_item/dangerous/drozd
	name = "Drozd OTs-114 Assault Carbine"
	desc = "Полуавтоматическая штурмовая винтовка с подствольным гранатомётом. Использует 12-ти зарядные магазины. Патроны большой мощности, калибра 12.7."
	item = /obj/item/weapon/gun/projectile/automatic/drozd
	cost = 20
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/crossbow
	name = "Miniature Energy Crossbow"
	desc = "Миниатюрный арбалет. Достаточно мал, чтобы незаметно поместить в карман или сумку. Стреляет болтами, смазанными парализующим токсином. \
	Болты автоматически пополняются, при попадании парализуют врагов на короткое время. Сам арбалет выглядит как игрушка.
	item = /obj/item/weapon/gun/energy/crossbow
	cost = 7
	uplink_types = list("traitor")

/datum/uplink_item/dangerous/flamethrower
	name = "Flamethrower"
	desc = "Огнемет, заправленный набором легковоспламеняющихся биотоксинов, украденных ранее у Нанотрейзен. Укажите на все недостатки швали корпорации, зажарив в их собственной жадности. Используйте с осторожностью."
	item = /obj/item/weapon/flamethrower/full/tank
	cost = 6
	uplink_types = list("nuclear") */

/datum/uplink_item/dangerous/powerfist
	name = "Power Fist"
	desc = "Силовой кастет, в виде перчатки, с поршневым двигателем внешнего подвода газа.\
	     При попадании по цели поршень выдвинется вперёд и нанесёт серьёзный урон.\
		 Использование гаечного ключа на силовом кастете позволит вам настроить количество газа, используемого для удара,\
		 чтобы нанести дополнительный урон и поразить ещё. Используйте отвёртку, чтобы вынуть все прикреплённые баллоны.
	item = /obj/item/weapon/melee/powerfist
	cost = 8
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/dangerous/sword
	name = "Energy Sword"
	desc = "Энергетический меч не нуждается в представлении. В деактивированном состоянии помещается в карман. При активации издаёт характерный звук. Выглядит как игрушка."
	item = /obj/item/weapon/melee/energy/sword
	cost = 7
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/sword/traitor
    name = "Energy Sword"
	desc = "Энергетический меч не нуждается в представлении. В деактивированном состоянии помещается в карман. При активации издаёт характерный звук. Выглядит как игрушка."
	item = /obj/item/weapon/melee/energy/sword/traitor
	uplink_types = list("traitor")

/datum/uplink_item/dangerous/emp
	name = "EMP Grenades"
	desc = "Коробка с ЭМИ гранатами. Полезны для борьбы с электроникой и синтетическими формами жизни."
	item = /obj/item/weapon/storage/box/emps
	cost = 5
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/dangerous/syndicate_minibomb
	name = "Syndicate Minibomb"
	desc = "Граната с 5-ти секундным таймером."
	item = /obj/item/weapon/grenade/syndieminibomb
	cost = 6
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/viscerators
	name = "Viscerator Delivery Grenade"
	desc = "Уникальная граната, выпускающая рой роботов-висцераторов. Висцераторы будут преследовать и крошить всех, кроме агентов"
	item = /obj/item/weapon/grenade/spawnergrenade/manhacks
	cost = 7
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/bioterror
	name = "Biohazardous Chemical Sprayer"
	desc = "Химический распылитель, который позволяет свободно распылять выбранные химикаты. Специально разработанная Кооперативом "Тигр" смертоносная смесь, которой он снабжен, дезориентирует, наносит урон и выводит из строя ваших врагов... \
	Используйте с особой осторожностью, чтобы не подвергать опасности себя и своих напарников."
	item = /obj/item/weapon/reagent_containers/spray/chemsprayer/bioterror
	cost = 10
	uplink_types = list("nuclear") */

/datum/uplink_item/dangerous/gygax
	name = "Gygax Exosuit"
	desc = "Легкий экзоскелет, окрашенный в темную гамму. Его скорость и выбор снаряжения делают его отличным для атак в стиле "бей и беги". \
В этой модели отсутствует возможность для перемещения по космосу, и поэтому рекомендуется отремонтировать телепортер главного корабля, если вы хотите им воспользоваться."
	item = /obj/mecha/combat/gygax/dark
	cost = 90
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/mauler
	name = "Mauler Exosuit"
	desc = "Массивный и невероятно смертоносный экзоскелет Синдиката. Обладает функциями дальнобойного наведения, управления вектора тяги и дымовой завесы."
	item = /obj/mecha/combat/marauder/mauler
	cost = 140
	uplink_types = list("nuclear")

/datum/uplink_item/dangerous/syndieborg
	name = "Syndicate Robot"
	desc = "Робот, предназначенный для уничтожения цели и подчинения агентам синдиката. Доставляется с помощью одноразового ручного блюспейс телепорта и изначально оснащенным различным оружием и снаряжением."
	item = /obj/item/weapon/antag_spawner/borg_tele
	cost = 36
	uplink_types = list("nuclear", "traitor")

//for refunding the syndieborg teleporter
/datum/uplink_item/dangerous/syndieborg/spawn_item()
	var/obj/item/weapon/antag_spawner/borg_tele/T = ..()
	if(istype(T))
		T.TC_cost = cost

/datum/uplink_item/dangerous/light_armor
	name = "Armor Set"
	desc = "Комплект индивидуальной брони, включающий бронежилет и шлем, предназначен для обеспечения выживания агента."
	item = /obj/item/weapon/storage/box/syndie_kit/light_armor
	cost = 4
	uplink_types = list("traitor")

/datum/uplink_item/dangerous/mine
	name = "High Explosive Mine"
	desc = "Мина нажимного действия. Используйте мультитул, чтобы обезвредить её."
	item = /obj/item/mine
	cost = 3
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/dangerous/incendiary_mine
	name = "Incendiary Mine"
	desc = "Одна из разновидностей мин и она подожжёт любого, кому (не)посчастливится на нее наступить."
	item = /obj/item/mine/incendiary
	cost = 3
	uplink_types = list("nuclear", "traitor")

// AMMUNITION

/datum/uplink_item/ammo
	category = "Ammunition"

/datum/uplink_item/ammo/borg
	name = "Robot Ammo Box"
	desc = "40 зарядный магазин калибра .45 для пистолета-пулемета робота Синдиката."
	item = /obj/item/ammo_box/magazine/borg45
	cost = 3
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/ammo/pistol
	name = "9mm Handgun Magazine"
	desc = "Запасной магазин на 8 дозвуковых патронов калибра 9 мм; совместим с пистолетом Stechkin. \
			стоят дешево, но вдвое эффективнее патронов калибра .357."
	item = /obj/item/ammo_box/magazine/m9mm
	cost = 2

/datum/uplink_item/ammo/revolver
	name = "Speedloader-.357"
	desc = "Зарядник, содержащее семь дополнительных патронов для револьвера."
	item = /obj/item/ammo_box/a357
	cost = 3
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/ammo/smg
	name = "Ammo-.45 ACP"
	desc = "20-ти зарядный магазин с патронами калибра .45 ACP для пистолете-пулемете C-20r."
	item = /obj/item/ammo_box/magazine/m12mm
	cost = 3
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/uzi
	name = "9mm Mac-10 Magazine"
	desc = "32 зарядный магазин с патронами калибра 9mm для Mac-10."
	item = /obj/item/ammo_box/magazine/uzim9mm
	cost = 3
	uplink_types = list("dealer")

/datum/uplink_item/ammo/tommygun
	name = ".45 ACP Tommygun Magazine"
	desc = "50-ти зарядный магазин с патронами калибра .45 ACP для tommygun."
	item = /obj/item/ammo_box/magazine/tommygunm45
	cost = 4
	uplink_types = list("dealer")

/datum/uplink_item/ammo/deagle
	name = "Ammo-.50 AE Magazine"
	desc = "7-ми зарядный магазин с патронами калибра .50 AE для desert eagle."
	item = /obj/item/ammo_box/magazine/m50/weakened
	cost = 4
	uplink_types = list("dealer")

/datum/uplink_item/ammo/smg_hp
	name = "Ammo-.45 ACP High Power"
	desc = "15-ти зарядный магазин с экспансивными патронами калибра .45 ACP для пистолета-пулемета C-20r. Эти патроны обладают повышенной мощностью пробития."
	item = /obj/item/ammo_box/magazine/m12mm/hp
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_hv
	name = "Ammo-.45 ACP High Velocity"
	desc = "15-ти зарядный магазин с высокоскоростныеми патронами калибра .45 ACP для пистолета-пулемета C-20r. Эти патроны испольхуются для быстрого поражения цели."
	item = /obj/item/ammo_box/magazine/m12mm/hv
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/smg_imp
	name = "Ammo-.45 ACP Impact"
	desc = "15-ти зарядный магазин с патронами калибра .45 ACP высокого останавливающего действия для пистолета-пулемета C-20r. Эти патроны отбросят и оглушат небронированные цели."
	item = /obj/item/ammo_box/magazine/m12mm/imp
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/a74standart
	name = "Ammo-7.74mm"
	desc = "30-ти зарядный магазин с патронами калибра 7.74 для штурмовой винтовки A74."
	item = /obj/item/ammo_box/magazine/a74mm
	cost = 7
	uplink_types = list("nuclear", "dealer")

/datum/uplink_item/ammo/bullbuck
	name = "Ammo-12g Buckshot"
	desc = "Запасной 8-ми зарядный магазин с картечью для дробовика Bulldog."
	item = /obj/item/ammo_box/magazine/m12g
	cost = 4
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullstun
	name = "Ammo-12g Stun Slug"
	desc = "Альтернативный 8-ми зарядный магазин с оглушающими патрона для дробовика Bulldog. Точные, надежные, эффективные."
	item = /obj/item/ammo_box/magazine/m12g/stun
	cost = 4
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/bullincendiary
	name = "Ammo-12g Incendiary"
	desc = "Альтернативный 8-ми зарядный магазин с зажигательными патронами для дробовика Bulldog."
	item = /obj/item/ammo_box/magazine/m12g/incendiary
	cost = 5
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/pistol
	name = "Ammo-10mm"
	desc = "Запасной 8-ми зарядный магазин с патронами калибра 10mm для пистолета Stetchkin."
	item = /obj/item/ammo_box/magazine/m10mm
	cost = 1
	uplink_types = list("nuclear") */

/datum/uplink_item/ammo/machinegun
	name = "Ammo-7.62x51mm"
	desc = "50-ти зарядный магазин с патронами калибра 7.62x51mm для пулемета L6 SAW. К тому моменту, когда вам нужно будет использовать его, вы уже будете стоять над кучей трупов.
	item = /obj/item/ammo_box/magazine/m762
	cost = 14
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/drozd
	name = "Ammo-12.7mm"
	desc = "12-ти зарядный магазин с патронами калибра 12.7 для автоматической винтовки Drozd OTs-114. Маленькие и опасные"
	item = /obj/item/ammo_box/magazine/drozd127
	cost = 4
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/grenade_launcher
	name = "Ammo-40x46mm (explosive)"
	desc = "Фугасная граната для использования в подствольном гранатомёте. "
	item = /obj/item/ammo_casing/r4046/explosive
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/grenade_launcher_emp
	name = "Ammo-40x46mm (EMP)"
	desc = "ЭМИ граната для использования в подствольном гранатомёте"
	item = /obj/item/ammo_casing/r4046/chem/EMP
	cost = 3
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/heavyrifle
	name = "A 14.5mm shell."
	desc = "A 14.5mm shell for use with PTR-7 heavy rifle. One shot, one kill, no luck, just skill."
	desc = "Снаряд калибра 14.5mm для тяжёлой винтовки PTR-7. Один выстрел, один труп, не удача, а просто навык"
	item = /obj/item/ammo_casing/a145
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/rocket
	name = "HE missile"
	desc = "Фугасная ракета для пусковой ручной установки Goliath."
	item = /obj/item/ammo_casing/caseless/rocket
	cost = 10
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/rocket_emp
	name = "EMP missile"
	desc = "ЭМИ ракета для пусковой ручной установки Goliath."
	item = /obj/item/ammo_casing/caseless/rocket/emp
	cost = 10
	uplink_types = list("nuclear")

/datum/uplink_item/ammo/chemicals
	name = "Chemical Warfare Tank"
	desc = "Бак с химикатами of chemicals созданный для ваших садистских увлечений доставлять медленную и мучительную смерть другим."
	item = /obj/item/device/radio/beacon/syndicate_chemicals
	cost = 10
	uplink_types = list("nuclear")

// STEALTHY WEAPONS

/datum/uplink_item/stealthy_weapons
	category = "Stealthy and Inconspicuous Weapons"
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/stealthy_weapons/dart_pistol
	name = "Dart Pistol"
	desc = "Миниатюрная версия обычного шприцемёта. Очень тихий при стрельбе и может спрятать в любое место для маленьких предметов"
	item = /obj/item/weapon/gun/syringe/syndicate
	cost = 2

/datum/uplink_item/stealthy_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. This pack contains three as well as a \
	crayon for changing their appearances."
	desc = "Эти картонные вырезки со специальным покрытием, который предотвращает обесцвечивание и делает изображения на них более реалистичными. В этом наборе три штуки,
	а также мелок для изменения их внешнего вид"
	item = /obj/item/weapon/storage/box/syndie_kit/cutouts
	cost = 1

/datum/uplink_item/stealthy_weapons/strip_gloves
	name = "Strip gloves"
	desc = "Пара черных перчаток, которые позволяют незаметно красть предметы у жертвы."
	item = /obj/item/clothing/gloves/black/strip
	cost = 3

/datum/uplink_item/stealthy_weapons/silence_gloves
	name = "Silence gloves"
	desc = "Пара черных перчаток, заглушающих все звуки вокруг носителя
	item = /obj/item/clothing/gloves/black/silence
	cost = 12

/datum/uplink_item/stealthy_weapons/soap
	name = "Syndicate Soap"
	desc = "Зловещего вида мыло, используемое для очистки пятен крови, чтобы скрыть убийства и предотвратить анализ ДНК. Вы также можете бросить его под ноги, чтобы заставить подскользнуться людей."
	item = /obj/item/weapon/soap/syndie
	cost = 1

/datum/uplink_item/stealthy_weapons/detomatix
	name = "Detomatix PDA Cartridge"
	desc = "Вставленный в ваш ПДА, этот картридж дает вам пять попыток взорвать ПДА членов экипажа, у которых включена функция обмена сообщениями. \
	Эффект оглушения от взрыва вырубит адресата на короткое время и оглушит его на определенный срок. Осторожно, есть шанс, что взорвется ваш ПДА."
	item = /obj/item/weapon/cartridge/syndicate
	cost = 2

/datum/uplink_item/stealthy_weapons/dehy_carp
	name = "Dehydrated Space Carp"
	desc = "Просто добавьте воды, чтобы сделать своего собственного враждебного ко всем космического карпа. В сухом состоянии выглядит совсем как плюшевый."
	item = /obj/item/toy/carpplushie/dehy_carp
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/stealthy_weapons/silencer
	name = "Stetchkin Silencer"
	desc = "Самый обычный глушитель для пистолета Стечкина, благодаря которому ваши выстрелы станут бесшумными."
	item = /obj/item/weapon/silencer
	cost = 2
	uplink_types = list("nuclear") */

// STEALTHY TOOLS

/datum/uplink_item/stealthy_tools
	category = "Stealth and Camouflage Items"
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/stealthy_tools/switchblade
	name = "Switchblade"
	desc = "Острый и незаметный выкидной нож"
	item = /obj/item/weapon/switchblade
	cost = 2
	uplink_types = list("dealer")

/datum/uplink_item/stealthy_tools/icepick
	name = "Ice Pick"
	desc = "Используется для колки льда. Прекрасное оружие для убийства в стиле мафии"
	item = /obj/item/weapon/melee/icepick
	cost = 1
	uplink_types = list("dealer")

/datum/uplink_item/stealthy_tools/spraycan
	name = "Spray Can"
	desc = "Это как мелки, но лучше."
	item = /obj/item/toy/crayon/spraycan
	cost = 1
	uplink_types = list("dealer")

/datum/uplink_item/stealthy_tools/chameleon_kit
	name = "Chameleon Kit"
	desc = "Комплект одежды, используемый для имитации униформы членов экипажа станции Nanotrasen."
	item = /obj/item/weapon/storage/box/syndie_kit/chameleon
	cost = 2

/datum/uplink_item/stealthy_tools/chameleon_penstamp
	name = "Fake Bureucracy Set"
	desc = "Набор содержит универсальную печать и ручку, позволяющую подделывать любую подпись.
	item = /obj/item/weapon/storage/box/syndie_kit/fake
	cost = 4

/datum/uplink_item/stealthy_tools/smugglersatchel
	name = "Smuggler's Satchel"
	desc = "Эта сумка достаточно тонкая, чтобы ее можно было спрятать в щели между обшивкой и плиткой; отлично подходит для хранения украденных вещей. Вместе с рюкзаком так же предоставляются лом и напольная плитка. Известно, что правильно спрятанные ранцы сохранились в целости и сохранности даже после прошедших смен. "
	item = /obj/item/weapon/storage/backpack/satchel/flat
	cost = 1
	uplink_types = list()

/datum/uplink_item/stealthy_tools/syndigolashes
	name = "No-Slip Brown Shoes"
	desc = "Они помогают спокойно бегать по мокрому полу. Но смазка всё так же останется вашей слабостью"
	item = /obj/item/clothing/shoes/syndigaloshes
	cost = 1
	uplink_types = list("traitor")

/datum/uplink_item/stealthy_tools/agent_card
	name = "Agent Identification card"
	desc = "Карта агента защищает от слежки искусственного интеллекта и может копировать доступ с других ID-карт. Доступ является накопительным, поэтому сканирование одной карты не стирает доступ, полученный с прошлой."
	item = /obj/item/weapon/card/id/syndicate
	cost = 4

/datum/uplink_item/stealthy_tools/voice_changer
	name = "Voice Changer"
	item = /obj/item/clothing/mask/gas/voice
	desc = "Бросающийся в глаза противогаз, имитирующий голос, указанный в вашей ID-карте. Если вы не носите карту, то маска сделает ваш голос неузнаваемым."
	cost = 3

/datum/uplink_item/stealthy_tools/chameleon_proj
	name = "Chameleon-Projector"
	desc = "Проецирует изображение на пользователя, маскируя его под объект, отсканированный с помощью хамелеон, до тех пор, пока проектор находится у вас в руках. Замаскированный пользователь теряет возможность бегать, но зато вы можете не бояться шальной пули."
	item = /obj/item/device/chameleon
	cost = 5

/datum/uplink_item/stealthy_tools/camera_bug
	name = "Camera Bug"
	desc = "Позволяет вам узнать, кто сейчас находится в интересующем вас отсеке. Также, после взлома камеры этим устройством, вы сможете отключить её дистанционно."
	item = /obj/item/device/camera_bug
	cost = 2

/datum/uplink_item/stealthy_weapons/silencer
	name = "Syndicate Silencer"
	desc = "Универсальный глушитель является идеальным выбором для скрытых оперативников. Благодаря нему ваши выстрелы из мелкокалиберного оружия будут бесшумными."
	item = /obj/item/weapon/silencer
	cost = 2

/datum/uplink_item/stealthy_weapons/throwingweapons
	name = "Box of Throwing Weapons"
	desc = "Коробка сюрикенов и усиленных бол, созданных ещё в древние времена. Но как метательное оружие идеально выполняет свои функции. \
			 Бола поможет повалить цель на землю, а сюрикены застрянут в конечностях."
	item = /obj/item/weapon/storage/box/syndie_kit/throwing_weapon
	cost = 6

/datum/uplink_item/stealthy_weapons/edagger
	name = "Energy Dagger"
	desc = "Уменьшенная версия энергитического меча, но в выключенном состоянии работает и выглядит как обычная ручка"
	item = /obj/item/weapon/pen/edagger
	cost = 5

/datum/uplink_item/stealthy_weapons/soap_clusterbang
	name = "Slipocalypse Clusterbang"
	desc = "A traditional clusterbang grenade with a payload consisting entirely of Syndicate soap. Useful in any scenario!"
	desc = "Традиционная кассетная граната полностью снаряженная мылом Синдиката. Полезна при любом раскладе!"
	item = /obj/item/weapon/grenade/clusterbuster/soap
	cost = 3

// DEVICE AND TOOLS

/datum/uplink_item/device_tools
	category = "Devices and Tools"

/datum/uplink_item/device_tools/rad_laser
	name = "Radioactive Microlaser"
	desc = "Радиоактивный микролазер, замаскированный под стандартизированный анализатор здоровья Nanotrasen. При использовании он излучает \
			мощный всплеск ионизирующего излучения, который, после небольшой зедержки, может облучить и вывести из строя всех, кроме \
			людей в защите от радиации. Имеет два уровня настройки: интенсивность, которая регулирует мощность излучения, \
			и длина, которая определяет длительность задержки излучения."
	item = /obj/item/device/healthanalyzer/rad_laser
	cost = 7
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "Электромагнитная карта-это небольшая карта, которая позволяет открывать скрытые функции в электронных устройствах и снимать их механизмы безопасности."
	item = /obj/item/weapon/card/emag
	cost = 6
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "Набор инструментов синдиката подозрительно черно-красного цвета. Помимо обычных инструментов в нем так же есть мультитул. Изоляционные перчатки в комплект не входят."
	item = /obj/item/weapon/storage/toolbox/syndicate
	cost = 1

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Dufflebag"
	desc = "Хирургический вещевой мешок Синдиката - это набор инструментов, содержащий все хирургические инструменты, \
			смирительная рубашка и кляп."
	item = /obj/item/weapon/storage/backpack/dufflebag/surgery
	cost = 4

/datum/uplink_item/device_tools/c4bag
	name = "Bag of C-4 explosives"
	desc = "Иногда количество-качество. Содержит 5 зарядов взрывчатки С-4"
	item = /obj/item/weapon/storage/backpack/dufflebag/c4
	cost = 4 //10% discount!
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/military_belt
	name = "Military Belt"
	desc = "Прочный красный пояс с семью карманами, который способен вместить все виды тактического снаряжения."
	item = /obj/item/weapon/storage/belt/military
	cost = 1

/datum/uplink_item/device_tools/medkit
	name = "Syndicate Medical Supply Kit"
	desc = "Аптечка синдиката подозрительного цвета хаки. Cодержит инъектор боевого стимулятора для ускоренного восстановления, медицинский анализатор для быстрого анализа ранения товарищей, \
	и другие медицинские принадлежности, полезные для оперативника-медика."
	item = /obj/item/weapon/storage/firstaid/tactical
	cost = 10
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/medkit_small
	name = "Syndicate Medical Small Kit"
	desc = "Боевая аптчека синдиката. Cодержит инъектор боевого стимулятора для ускоренного восстановления.
	item = /obj/item/weapon/storage/firstaid/small_firstaid_kit/combat
	cost = 5

/datum/uplink_item/device_tools/bonepen
	name = "Prototype Bone Repair Kit"
	desc = "Украденый прототип нанитов, сращивающих кости. Содержит четыре инжектора.
	item = /obj/item/weapon/storage/box/syndie_kit/bonepen
	cost = 4
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/stealthy_tools/mulligan
	name = "Mulligan"
	desc = "Натворил делов, и теперь у тебя на хвосте охрана? Этот полезный шприц придаст вам совершенно новый внешний вид."
	item = /obj/item/weapon/reagent_containers/syringe/mulligan
	cost = 4

/datum/uplink_item/device_tools/space_suit
	name = "Syndicate Space Suit"
	desc = "Красный скафандр Синдиката не такой неудобный, чем обычные ERVOS, помещается в сумки и имеет слот для оружия. Члены экипажа станции непременно сообщат если увидят этот крансый костюм."
	item = /obj/item/weapon/storage/box/syndie_kit/space
	cost = 4
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "Термальные очки, удобно замаскированные под мезонный сканнер. \
	Они позволяют видеть любые организмы сквозь стены, улавливая их спектр инфракрасного излучения, излучаемого объектами в виде тепла и света. \
	Более горячие объекты, такие кибернетические организмы и ядро искусственного интеллекта, излучают больше этого света, чем более холодные объекты, такие как стены и воздушные шлюзы."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 5
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/thermal/dealer
	item = /obj/item/clothing/glasses/thermal/dealer
	cost = 8
	uplink_types = list("dealer")

	need_wanted_level = 3

/datum/uplink_item/stealthy_tools/emplight
	name = "EMP Flashlight"
	desc = "Маленькое самозаряжающееся ЭМИ-устройство ближнего действия, замаскированное под фонарик. \
		Полезно для отключения гарнитур, камер и боргов во время скрытных операций."
	item = /obj/item/device/flashlight/emp
	cost = 4

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "Ключ шифрования, который при вставке в радиогарнитуру позволяет слушать и разговаривать с искусственными интеллектами и кибернетическими организмами на бинарном языке."
	item = /obj/item/device/encryptionkey/binary
	cost = 3
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/encryptionkey
	name = "Syndicate Encryption Key"
	desc = "Ключ шифрования, который при вставке в радиогарнитуру позволяет прослушивать все каналы отдела радиостанций \
			а также разговаривать по зашифрованному каналу Синдиката с другими агентами, имеющими тот же ключ."
	item = /obj/item/device/encryptionkey/syndicate
	cost = 2

/datum/uplink_item/device_tools/poster_kit
	name = "Poster kit"
	desc = "Набор запрёщенных постеров"
	item = /obj/item/weapon/storage/box/syndie_kit/posters
	cost = 1
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/headcan
	name = "Biogel can"
	desc = "Хитроумное устройство для поддержания жизнидеятельности головы в течение длительного периода"
	item = /obj/item/device/biocan
	cost = 1
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/ai_detector
	name = "Artificial Intelligence Detector" // changed name in case newfriends thought it detected disguised ai's
	desc = "На первый взгляд, обычный мультитул, но благодаря его красному индикатору можно узнать, когда искусственный интеллект, наблюдает за вами. Знание того, когда искусственный интеллект наблюдает за вами, полезно для того, чтобы знать, когда нужно сохранять прикрытие."
	item = /obj/item/device/multitool/ai_detect
	cost = 2
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "При использовании с консолью загрузки этот модуль позволяет загрузить в ИИ законы с приоритетом. Будьте осторожны с их формулировками, так как искусственный интеллект может искать лазейки для использования."
	item = /obj/item/weapon/aiModule/freeform/syndicate
	cost = 12
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/plastic_explosives
	name = "Composition C-4"
	desc = "C-4 представляет собой разновидность пластичных взрывчатых веществ. Вы можете использовать его для разрушения стен, прикреплять к людям, чтобы уничтожить их, или подключать сигнализатор к его проводке, чтобы сделать его удаленным. \
	Он имеет настраиваемый таймер с минимальной настройкой в 10 секунд."
	item = /obj/item/weapon/plastique
	cost = 1

/datum/uplink_item/device_tools/powersink
	name = "Power sink"
	desc = "Привинченное к проводке и подключенное к электрической сети, а затем активированное, это большое устройство создает чрезмерную нагрузку на сеть, вызывая отключение электроэнергии по всей станции. Это устройство нельзя переносить из-за его чрезмерных размеров. \
	Заказав это, вы получите небольшой маяк, который телепортирует поглотитель энергии в ваше местоположение при активации."
	item = /obj/item/device/powersink
	cost = 12
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/device_tools/syndcodebook
	name = "Sy-Code Book"
	desc = "Агенты Синдиката могут выучить и использовать серию кодовых слов для передачи сложной информации, которая звучит как случайные буквы и названия напитков для любого слушающего. \
	Эта книга научит вас С-коду Одноразовая. Используйте :0 до того, чтобы сказать что-то на С-коде."
	item = /obj/item/weapon/syndcodebook
	cost = 1
	uplink_types = list("traitor", "dealer")

/datum/uplink_item/device_tools/singularity_beacon
	name = "Singularity Beacon"
	desc = "Привинченное к проводке и подключенное к электрической сети, а затем активированное, это большое устройство притягивает сингулярность к себе. \
	Не работает, если сингулярность находится в защитном поле. Маяк сингулярности может нанести катастрофический ущерб космической станции, \
	что приведет к экстренной эвакуации. Из-за своих размеров нельзя носить с собой. Заказав это, вы получите небольшой маяк, который телепортирует маяк сингулярности вместо активации."
	item = /obj/item/device/radio/beacon/syndicate
	cost = 14
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/syndicate_bomb
	name = "Syndicate Bomb"
	desc = "Бомба Синдиката имеет регулируемый таймер с минимальной настройкой в 60 секунд. При заказе бомбы, вам присылается небольшой маяк, который телепортирует взрывчатку в ваше местоположение, когда вы его активируете. \
	Вы можете прикрутить бомбу к полу, чтобы предотвратить ее перемещение. Но не забывайте, экипаж может попытаться обезвредить бомбу."
	item = /obj/item/device/radio/beacon/syndicate_bomb
	cost = 12
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/syndicate_detonator
	name = "Syndicate Detonator"
	desc = "Детонатор Синдиката - это дополнительное устройство к бомбе Синдиката. Просто нажмите на кноаку, и сигнал даст команду всем бомбам Синдиката взорваться. \
	Полезно, когда вы хотите синхронизировать несколько взрывов бомб. Обязательно отойдите подальше от радиуса взрыва, прежде чем использовать детонатор.""
	item = /obj/item/device/syndicatedetonator
	cost = 2
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/shield
	name = "Energy Shield"
	desc = "Невероятно полезный проектор щита. Имеет возможность отражать энергоснаряды и даёт защиту от других атак.
	item = /obj/item/weapon/shield/energy
	cost = 16
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/traitor_caller
	name = "Traitor Caller"
	desc = "Позволяет сделать звонок "спящему" агенту, который находится на станции.
	item = /obj/item/device/traitor_caller
	cost = 55
	uplink_types = list("nuclear")

/datum/uplink_item/device_tools/syndidrone
	name = "Syndicate drone"
	desc = "Устройство для дистанционного управления дроном, замаскированного под технического дрона НТ. Поставлется с очками дистанционного управления. "
	item = /obj/item/weapon/storage/box/syndie_kit/drone
	cost = 14
	uplink_types = list("nuclear", "traitor")

// IMPLANTS

/datum/uplink_item/implants
	category = "Implants"
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/implants/freedom
	name = "Freedom Implant"
	desc = "Имплантат, введенный в тело и затем активированный с помощью разных эмоций, даст возможность снять наручники."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_freedom
	cost = 5

/datum/uplink_item/implants/uplink
	name = "Uplink Implant"
	desc = "Имплантат, введенный в тело, а затем активированный с помощью разных эмоций,позволит открыть ваш аплинк с 10 телекристаллами. \
	Возможность агента открывать аплинк после того, как у него отобрали всё имущество, делает этот имплантат отличным средством для побега из заключения."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_uplink
	cost = 20

/datum/uplink_item/implants/storage
	name = "Compressed Implant"
	desc = "An implant, that can compress items and later activated at the user's will."
	desc = "Имлпант с блюспейс карманом. Может хранить в себе два средних предмета."
	item = /obj/item/weapon/implanter/storage
	cost = 7

/datum/uplink_item/implants/adrenaline
	name = "Adrenaline Implant"
	desc = "Имплантат, который будет вводить химический коктейль с мягким лечебным эффектом, а также устраняющий все оглушения и увеличивающий скорость. Может быть активирован по желанию пользователя."
	item = /obj/item/weapon/storage/box/syndie_kit/imp_adrenaline
	cost = 6

/datum/uplink_item/implants/emp
	name = "EMP Implant"
	desc = "Имплант содержащий три ЭМИ заряда. Активируется по желанию носителя"
	item = /obj/item/weapon/storage/box/syndie_kit/imp_emp
	cost = 3

/datum/uplink_item/implants/explosive
	name = "Explosive Implant"
	desc = "Имплант со взрывчатым веществом. Активируется кодовым словом."
	item = /obj/item/weapon/implanter/explosive
	cost = 3

// TELECRYSTALS

/datum/uplink_item/telecrystals
	category = "Telecrystals"

/datum/uplink_item/telecrystals/one
	name = "1 Telecrystal"
	desc = "Извлекает один необработанный телекристалл, чтобы поделиться им со своими приятелями-убийцами."
	item = /obj/item/stack/telecrystal
	cost = 1

/datum/uplink_item/telecrystals/five
	name = "5 Telecrystals"
	desc = "Извлекает пять необработанных телекристаллов, чтобы подарить их своему любимому партнеру по преступлению."
	item = /obj/item/stack/telecrystal/five
	cost = 5

/datum/uplink_item/telecrystals/twenty
	name = "20 Telecrystals"
	desc = "Извлекает двадцать необработанных телекристаллов, чтобы полностью доверить себя в руки ваших сообщников."
	item = /obj/item/stack/telecrystal/twenty
	cost = 20

// POINTLESS BADASSERY

/datum/uplink_item/badass
	category = "(Pointless) Badassery"
	uplink_types = list("nuclear", "traitor")

/datum/uplink_item/badass/bundle
	name = "Syndicate Bundle"
	desc = "Набор Синдиката - это специализированные комплекты вещей, которые поступают в обычной коробке. Эти предметы в совокупности стоят более 10 телекристаллов, но вы не знаете, какую специализацию вы получите."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 20

/datum/uplink_item/badass/merch
	name = "Syndicate Merchandise"
	desc = "Покажите вашу лояльность Синдикату! Вы получите футболку с логотипом Синдиката, красную кепку и чуденсый надувной шарик!"
	item = /obj/item/weapon/storage/box/syndie_kit/merch
	cost = 20

/datum/uplink_item/badass/syndiecigs
	name = "Syndicate Smokes"
	desc = "Насыщенный аромат, густой дым, cодержит трик."
	item = /obj/item/weapon/storage/fancy/cigarettes/cigpack_syndicate
	cost = 2

/datum/uplink_item/badass/syndiedonuts
	name = "Syndicate Donuts"
	desc = "Специальное предложение от Waffle Co., коробка, содержащая 6 вкуснейших пончиков! Но будьте осторожны, некоторые из них отравлены!"
    item = /obj/item/weapon/storage/fancy/donut_box/traitor
	cost = 2

/datum/uplink_item/badass/syndiecash
	name = "Syndicate Briefcase Full of Cash"
	desc = "Дипломат с кодовым замком, содержащий 4000 кредитов. Полезно для подкупа персонала или приобретения предметов и услуг по выгодным ценам. \
	Дипломат ощущается немного тяжелым в руке; он был специально изготовлен, если вашему клиенту нужно больше "веских" причин для принятия взятки."
	item = /obj/item/weapon/storage/secure/briefcase/syndie
	cost = 1

/datum/uplink_item/badass/random
	name = "Random Item"
	desc = "Выбрав этот вариант, вы получите случайный предмет из списка. Полезно, когда вы не можете придумать стратегию для достижения своих целей."
	item = /obj/item/weapon/storage/box/syndicate
	cost = 0

/datum/uplink_item/badass/random/spawn_item(turf/loc, obj/item/device/uplink/U, mob/user)

	var/list/buyable_items = get_uplink_items(U)
	var/list/possible_items = list()

	for(var/category in buyable_items)
		for(var/datum/uplink_item/I in buyable_items[category])
			if(I == src)
				continue
			if(I.cost > U.uses)
				continue
			possible_items += I

	if(possible_items.len)
		var/datum/uplink_item/I = pick(possible_items)
		U.uses -= max(0, I.cost)
		feedback_add_details("traitor_uplink_items_bought","RN")
		return new I.item(loc)
	else
		to_chat(user, "<span class='warning'>There is no available items you could buy for [U.uses] TK.</span>")
