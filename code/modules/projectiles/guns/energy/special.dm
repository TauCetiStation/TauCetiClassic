/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "Портативная винтовка, созданная для уничтожения механизированных и механических противников."
	icon_state = "ionrifle"
	item_state = null
	origin_tech = "combat=2;magnets=4"
	w_class = SIZE_NORMAL
	flags =  CONDUCT
	slot_flags = SLOT_FLAGS_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	modifystate = 0

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	if(severity <= 2)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
	else
		return

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "Оружие, которое за счет большого количества контролируемого излучения постепенно разрушает цель на составные элементы."
	icon_state = "decloner"
	origin_tech = "combat=5;materials=4;powerstorage=3"
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/declone)

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "Инструмент, чей принцип работы основывается на управляемом излучениее, вызывающий мутации в клетках растений."
	icon_state = "flora"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	can_be_holstered = TRUE
	var/charge_tick = 0
	var/mode = 0 //0 = mutate, 1 = yield boost

/obj/item/weapon/gun/energy/floragun/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/floragun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/floragun/process()
	charge_tick++
	if(charge_tick < 4)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)
	update_icon()
	return 1

/obj/item/weapon/gun/energy/floragun/attack_self(mob/living/user)
	..()
	update_icon()

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "Ради бога, убедитесь, что вы нацелены правильно!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = SIZE_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/weapon/stock_parts/cell/potato
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in ticks)

/obj/item/weapon/gun/energy/meteorgun/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/energy/meteorgun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/gun/energy/meteorgun/process()
	charge_tick++
	if(charge_tick < recharge_time)
		return 0
	charge_tick = 0
	if(!power_supply)
		return 0
	power_supply.give(100)

/obj/item/weapon/gun/energy/meteorgun/update_icon()
	return

/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "Перо сильнее меча."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	can_be_holstered = TRUE
	w_class = SIZE_MINUSCULE

/obj/item/weapon/gun/energy/mindflayer
	name = "mind flayer"
	desc = "Прототип винтовки, найденный на развалинах исследовательской станции Эпсилон"
	icon_state = "xray"
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)

/obj/item/weapon/gun/energy/toxgun
	name = "phoron pistol"
	desc = "Специализированное огнестрельное оружие, предназначенное для стрельбы смертоносными зарядами форона."
	icon_state = "toxgun"
	w_class = SIZE_SMALL
	origin_tech = "combat=5;phorontech=4"
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/toxin)

/obj/item/weapon/gun/energy/sniperrifle
	name = "sniper rifle"
	desc = "Снайперская винтовка W2500-E, разработанная компанией W&J, изготовлена из легких материалов и оснащена прицелом системы SMART."
	icon = 'icons/obj/gun.dmi'
	icon_state = "w2500e"
	item_state = "w2500e"
	origin_tech = "combat=6;materials=5;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)
	slot_flags = SLOT_FLAGS_BACK
	fire_delay = 20
	w_class = SIZE_NORMAL
	var/zoom = 0

/obj/item/weapon/gun/energy/sniperrifle/atom_init()
	. = ..()
	update_icon()
	AddComponent(/datum/component/zoom, 12)

/obj/item/weapon/gun/energy/sniperrifle/attack_self(mob/user)
	SEND_SIGNAL(src, COMSIG_ZOOM_TOGGLE, user)

/obj/item/weapon/gun/energy/sniperrifle/update_icon()
	var/ratio = power_supply.charge / power_supply.maxcharge
	ratio = CEIL(ratio * 4) * 25
	switch(modifystate)
		if (0)
			if(ratio > 100)
				icon_state = "[initial(icon_state)]100"
				item_state = "[initial(item_state)]100"
			else
				icon_state = "[initial(icon_state)][ratio]"
				item_state = "[initial(item_state)][ratio]"
	return

/obj/item/weapon/gun/energy/sniperrifle/rails
	name = "Rails rifle"
	desc = "С этой пушкой вы станете боссом любой Арены."
	icon = 'icons/obj/gun.dmi'
	icon_state = "relsotron"
	item_state = "relsotron"
	origin_tech = "combat=5;materials=4;powerstorage=4;magnets=4;engineering=4"
	ammo_type = list(/obj/item/ammo_casing/energy/rails)
	fire_delay = 20
	w_class = SIZE_SMALL

//Tesla Cannon
/obj/item/weapon/gun/tesla
	name = "Tesla Cannon"
	desc = "Оружие, использующие электрический заряд для поражения нескольких целей. Вращайте рукоятку генератора, чтобы зарядить её."
	icon = 'icons/obj/gun.dmi'
	icon_state = "tesla"
	item_state = "tesla"
	w_class = SIZE_NORMAL
	origin_tech = "combat=5;materials=5;powerstorage=5;magnets=5;engineering=5"
	can_be_holstered = FALSE
	var/charge = 0
	var/charging = FALSE
	var/cooldown = FALSE

/obj/item/weapon/gun/tesla/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/tesla/proc/charge(mob/living/user)
	set waitfor = FALSE
	if(do_after(user, 40 * toolspeed, target = src))
		if(charging && charge < 3)
			charge++
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			if(charge < 3)
				charge(user)
			else
				charging = FALSE
		else
			charging = FALSE
	else
		to_chat(user, "<span class='danger'>Generator is too difficult to spin while moving! Charging aborted.</span>")
		charging = FALSE
	update_icon()

/obj/item/weapon/gun/tesla/attack_self(mob/living/user)
	if(charging)
		charging = FALSE
		user.visible_message("<span class='danger'>[user] останавливает вращение рукоятки генератора на пушке Тесла!</span>",\
		                     "<span class='red'>Вы остановились заряжать пушку Тесла...</span>")
		cooldown = TRUE
		spawn(50)
			cooldown = FALSE
		return
	if(cooldown || charge == 3)
		return
	user.visible_message("<span class='danger'>[user] начинает вращать рукоятку генератор на пушке Тесла!</span>",\
	                     "<span class='red'>Вы начинаете заряжать пушку Тесла...</span>")
	charging = TRUE
	charge(user)

/obj/item/weapon/gun/tesla/special_check(mob/user, atom/target)
	if(!..())
		return FALSE
	if(!charge)
		to_chat(user, "<span class='red'>Пушка Тесла не заряжена!</span>")
	else if(!isliving(target))
		to_chat(user, "<span class='red'>Пушка Тесла должна быть направлена непосредственно на живую цель.</span>")
	else if(charging)
		to_chat(user, "<span class='red'>Вы не можете стрелять во время зарядки!</span>")
	else if(!los_check(user, target))
		to_chat(user, "<span class='red'>Что-то загораживает нам линию выстрела!</span>")
	else
		Bolt(user, target, user, charge)
		charge = 0

	update_icon()
	return 0

/obj/item/weapon/gun/tesla/proc/los_check(mob/A, mob/B)
	for(var/X in getline(A,B))
		var/turf/T = X
		if(T.density)
			return 0
	return 1

/obj/item/weapon/gun/tesla/proc/Bolt(mob/origin, mob/living/target, mob/user, jumps)
	origin.Beam(target, "lightning[rand(1,12)]", 'icons/effects/effects.dmi', time = 5)
	target.electrocute_act(15 * (jumps + 1), src, , , 1)
	playsound(target, 'sound/machines/defib_zap.ogg', VOL_EFFECTS_MASTER)
	var/list/possible_targets = new
	for(var/mob/living/M in range(2, target))
		if(user == M || !los_check(target, M) || origin == M || target == M)
			continue
		possible_targets += M
	if(!possible_targets.len)
		return
	var/mob/living/next = pick(possible_targets)
	msg_admin_attack("[origin.name] ([origin.ckey]) shot [target.name] ([target.ckey]) with a tesla bolt", origin)
	if(next && jumps > 0)
		Bolt(target, next, user, --jumps)

/obj/item/weapon/gun/tesla/update_icon()
	icon_state = "[initial(icon_state)][charge]"

/obj/item/weapon/gun/tesla/emp_act(severity)
	if(charge)
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.electrocute_act(5 * (4 - severity) * charge, src, , , 1)
		charge = 0
		update_icon()

/obj/item/weapon/gun/tesla/rifle
	name = "Tesla rifle"
	desc = "Винтовка, использующие электрический заряд для поражения нескольких целей. Вращайте рукоятку генератора, чтобы зарядить её."
	icon = 'icons/obj/gun.dmi'
	icon_state = "arctesla"
	item_state = "arctesla"
	w_class = SIZE_SMALL
	origin_tech = null
	toolspeed = 0.5

/*
	Pyrometers and stuff.
*/
/obj/item/weapon/gun/energy/pyrometer
	name = "pyrometer"
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда в результате прямого физического контакта с пользователем."

	w_class = SIZE_TINY
	icon = 'icons/obj/gun.dmi'
	icon_state = "pyrometer"
	item_state = "pyrometer"
	origin_tech = "engineering=3;magnets=3"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer)

	var/emagged = FALSE

	var/panel_open = FALSE

	// ML means my laser.
	var/obj/item/weapon/stock_parts/micro_laser/ML
	var/my_laser_type = /obj/item/weapon/stock_parts/micro_laser

/obj/item/weapon/gun/energy/pyrometer/atom_init()
	. = ..()
	if(my_laser_type)
		ML = new my_laser_type(src)

/obj/item/weapon/gun/energy/pyrometer/newshot()
	if(!ML)
		visible_message("<span class='warning'>[src] clings, as it heats up.</span>")
		return
	return ..()

/obj/item/weapon/gun/energy/pyrometer/attack_hand(mob/user)
	if(panel_open && power_supply)
		user.put_in_hands(power_supply)
		power_supply = null
		to_chat(user, "<span class='notice'>You take \the [power_supply] out of \the [src].</span>")
	else
		..()

/obj/item/weapon/gun/energy/pyrometer/attackby(obj/item/I, mob/user, params)
	if(isscrewing(I))
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		panel_open = !panel_open
		user.visible_message("<span class='notice'>[user] [panel_open ? "un" : ""]screws [src]'s panel [panel_open ? "open" : "shut"].</span>", "<span class='notice'>You [panel_open ? "un" : ""]screw [src]'s panel [panel_open ? "open" : "shut"].</span>")

	else if(panel_open)
		if(isprying(I))
			if(ML)
				playsound(src, 'sound/items/Crowbar.ogg', VOL_EFFECTS_MASTER)
				user.put_in_hands(ML)
				ML = null
				to_chat(user, "<span class='notice'>You take \the [ML] out of \the [src].</span>")
		else if(istype(I, /obj/item/weapon/stock_parts/cell))
			user.drop_from_inventory(I, src)
			power_supply = I
			to_chat(user, "<span class='notice'>You install [I] into \the [src].</span>")
		else if(istype(I, /obj/item/weapon/stock_parts/micro_laser))
			user.drop_from_inventory(I, src)
			ML = I
			to_chat(user, "<span class='notice'>You install [I] into \the [src].</span>")

	else
		return ..()

/obj/item/weapon/gun/energy/pyrometer/emag_act(mob/user)
	if(emagged)
		return FALSE
	ammo_type += new /obj/item/ammo_casing/energy/pyrometer/emagged(src)
	fire_delay = 12
	origin_tech += ";syndicate=1"
	emagged = TRUE
	to_chat(user, "<span class='warning'>Ошибка: Обнаружен несовместимый модуль. Ошибка ошибкаааааааа .</span>")
	return TRUE

/obj/item/weapon/gun/energy/pyrometer/update_icon()
	return

/obj/item/weapon/gun/energy/pyrometer/announce_shot(mob/living/user)
	return



/obj/item/weapon/gun/energy/pyrometer/universal
	name = "universal pyrometer"
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда при непосредственном физическом контакте. Поставляется со встроенным многоцветным лазерным указателем и способен работать во всех возможных режимах!"
	icon_state = "pyrometer_robotics"
	item_state = "pyrometer_robotics"

	ammo_type = list(
		/obj/item/ammo_casing/energy/pyrometer/science_phoron,
		/obj/item/ammo_casing/energy/pyrometer/engineering,
		/obj/item/ammo_casing/energy/pyrometer/atmospherics,
		/obj/item/ammo_casing/energy/pyrometer/medical,
	)

	// Doesn't come with those built-in. Must be manually put.
	cell_type = null
	my_laser_type = null


/obj/item/weapon/gun/energy/pyrometer/ce
	name = "chief engineer's tactical pyrometer"
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда при непосредственном физическом контакте с пользователем. Поставляется со встроенным многоцветным лазерным указателем и с удобным снайперским прицелом!"
	icon_state = "pyrometer_ce"
	item_state = "pyrometer_ce"

	ammo_type = list(
		/obj/item/ammo_casing/energy/pyrometer/science_phoron,
		/obj/item/ammo_casing/energy/pyrometer/engineering,
		/obj/item/ammo_casing/energy/pyrometer/atmospherics,
	)

	my_laser_type = /obj/item/weapon/stock_parts/micro_laser/high/ultra/quadultra

/obj/item/weapon/gun/energy/pyrometer/ce/atom_init()
	. = ..()
	AddComponent(/datum/component/zoom, 12, TRUE)

/obj/item/weapon/gun/energy/pyrometer/science_phoron
	name = "phoron-orienter pyrometer"
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда при непосредственном физическом контакте с пользователем. Поставляется со встроенным многоцветным лазерным указателем. Настроен для определения момента прорыва трубы."
	icon_state = "pyrometer_science_phoron"
	item_state = "pyrometer_science_phoron"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/science_phoron)



/obj/item/weapon/gun/energy/pyrometer/engineering
	name = "machinery pyrometer"
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда при непосредственном физическом контакте с пользователем. Поставляется со встроенным многоцветным лазерным указателем. Обнаруживает перегрев оборудования."
	icon_state = "pyrometer_engineering"
	item_state = "pyrometer_engineering"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/engineering)

/obj/item/weapon/gun/energy/pyrometer/engineering/robotics
	icon_state = "pyrometer_robotics"
	item_state = "pyrometer_robotics"



/obj/item/weapon/gun/energy/pyrometer/atmospherics
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда при непосредственном физическом контакте с пользователем. Поставляется со встроенной многоцветной лазерной указкой. Используется для определения того, насколько сильно пострадает живой человек, если он будет дышать воздухом, находящимся в комнате \"scan\"."
	icon_state = "pyrometer_atmospherics"
	item_state = "pyrometer_atmospherics"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/atmospherics)



/obj/item/weapon/gun/energy/pyrometer/medical
	name = "NC thermometer"
	desc = "Инструмент, используемый для быстрого измерения температуры без опасения получения вреда при непосредственном физическом контакте с пользователем. Поставляется со встроенной многоцветной лазерной указкой. Используется для определения температуры скелета в шкафу."
	icon_state = "pyrometer_medical"
	item_state = "pyrometer_medical"

	ammo_type = list(/obj/item/ammo_casing/energy/pyrometer/medical)

	my_laser_type = /obj/item/weapon/stock_parts/micro_laser/high/ultra

/obj/item/weapon/gun/energy/gun/portal
	name = "bluespace wormhole projector"
	desc = "Проектор, излучающий квантово-связанные блюспейс лучи высокой плотности. Для работы требуется ядро аномалии. Помещается в сумку."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	icon_state = "portal"
	modifystate = 0
	can_suicide_with = FALSE

	var/obj/effect/portal/p_blue
	var/obj/effect/portal/p_orange
	var/obj/item/device/assembly/signaler/anomaly/firing_core = null

/obj/item/weapon/gun/energy/gun/portal/Destroy()
	qdel(p_blue)
	qdel(p_orange)
	qdel(firing_core)
	return ..()

/obj/item/weapon/gun/energy/gun/portal/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(!prob(reliability))
		if(firing_core && !is_centcom_level(z))
			to_chat(user, "<span class='warning'>Проектор червоточины неисправен, оно телепортирует прочь!</span>")
			user.drop_from_inventory(src)
			do_teleport(src, get_turf(src), 7, asoundin = 'sound/effects/phasein.ogg')
			return
	..()

/obj/item/weapon/gun/energy/gun/portal/special_check(mob/M, atom/target)
	if(!firing_core)
		return FALSE
	return TRUE

/obj/item/weapon/gun/energy/gun/portal/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/device/assembly/signaler/anomaly))
		if(firing_core)
			to_chat(user, "<span class='warning'>В проекторе червоточины уже установлено ядро аномалии!</span>")
			playsound(user, 'sound/machines/airlock/access_denied.ogg', VOL_EFFECTS_MASTER)
			return
		user.drop_from_inventory(C, src)
		to_chat(user, "<span class='notice'>Вы вставляете [C] в проектор червоточины, и устройство начинает мягко гудеть.</span>")
		playsound(user, 'sound/weapons/guns/plasma10_load.ogg', VOL_EFFECTS_MASTER)
		firing_core = C
		modifystate = 2
		update_icon()
		update_inv_mob()

	if(isscrewing(C))
		if(!firing_core)
			to_chat(user, "<span class='warning'>В нем не установлено ядро аномалии!</span>")
			return
		firing_core.forceMove(get_turf(user))
		firing_core = null
		to_chat(user, "<span class='notice'>Вы извлекли ядро аномалии из проектора.</span>")
		playsound(user, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		icon_state = "portal"
		modifystate = 0
		update_icon()
		update_inv_mob()

	return ..()

/obj/item/weapon/gun/energy/gun/portal/proc/on_portal_destroy(obj/effect/portal/P)
	SIGNAL_HANDLER
	if(P == p_blue)
		p_blue = null
	else if(P == p_orange)
		p_orange = null

/obj/item/weapon/gun/energy/gun/portal/proc/has_blue_portal()
	if(istype(p_blue) && !QDELETED(p_blue))
		return TRUE
	return FALSE

/obj/item/weapon/gun/energy/gun/portal/proc/has_orange_portal()
	if(istype(p_orange) && !QDELETED(p_orange))
		return TRUE
	return FALSE

/obj/item/weapon/gun/energy/gun/portal/proc/crosslink()
	if(!has_blue_portal() && !has_orange_portal())
		return
	if(!has_blue_portal() && has_orange_portal())
		p_orange.target = null
		return
	if(!has_orange_portal() && has_blue_portal())
		p_blue.target = null
		return
	p_orange.target = p_blue
	p_blue.target = p_orange

/obj/item/weapon/gun/energy/gun/portal/proc/create_portal(obj/item/projectile/beam/wormhole/W, turf/target)
	var/obj/effect/portal/P = new /obj/effect/portal/portalgun(target, null, 10)
	RegisterSignal(P, COMSIG_PARENT_QDELETING, PROC_REF(on_portal_destroy))
	if(istype(W, /obj/item/projectile/beam/wormhole/orange))
		qdel(p_orange)
		p_orange = P
		P.icon_state = "portalorange"
	else
		qdel(p_blue)
		p_blue = P
	crosslink()

/obj/item/weapon/gun/energy/gun/portal/emp_act(severity)
	return

/obj/item/weapon/gun/energy/retro
	name ="retro phaser"
	icon_state = "retro"
	item_state = null
	desc = "Устаревшая модель стандартного лазерного оружия, больше не используемая ни службами безопасности, ни военными силами НаноТрейзен. Тем не менее, он все еще достаточно смертоносен и прост в обслуживании, что делает его любимым среди пиратов и других преступников."
	can_be_holstered = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/phaser)

/obj/item/weapon/gun/energy/retro/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 1500
		power_supply.charge = 1500

/obj/item/weapon/gun/medbeam
	name = "prototype medical retrosynchronizer"
	desc = "Прототип лечебной пушки, которая медленно возвращает органику в прежнее состояние, исцеляя их."
	icon_state = "medigun"
	item_state = "medigun"
	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = FALSE
	var/beam_state = "medbeam"
	var/datum/beam/current_beam = null

/obj/item/weapon/gun/medbeam/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/medbeam/Destroy()
	LoseTarget()
	return ..()

/obj/item/weapon/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget()

/obj/item/weapon/gun/medbeam/attack(atom/target, mob/living/user)
	if(user.a_intent != INTENT_HARM)
		Fire(target, user)
		return
	return ..()

/obj/item/weapon/gun/medbeam/proc/LoseTarget()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
	current_target = null

/obj/item/weapon/gun/medbeam/Fire(atom/target, mob/living/user, params, reflex = 0)
	if(isliving(user))
		add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target) || user == target)
		return

	current_target = target
	RegisterSignal(current_target, COMSIG_PARENT_QDELETING, PROC_REF(LoseTarget))
	active = TRUE
	current_beam = new(user, current_target, time = 6000, beam_icon_state = beam_state, btype = /obj/effect/ebeam/medical)
	INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
	user.visible_message("<span class='notice'>[user] aims their [src] at [target]!</span>")
	playsound(user, 'sound/weapons/guns/medbeam.ogg', VOL_EFFECTS_MASTER)

/obj/item/weapon/gun/medbeam/process()
	var/source = loc
	if(!isliving(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check + check_delay)
		return

	last_check = world.time

	if(get_dist(source, current_target) > max_range || !check_trajectory(source, current_target, pass_flags = PASSTABLE, flags = 0))
		LoseTarget()
		to_chat(source, "<span class='warning'>Вы потеряли контроль над лучом!</span>")
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/weapon/gun/medbeam/proc/on_beam_tick()
	if(current_target.stat == DEAD)
		LoseTarget()
		return

	current_target.adjustBruteLoss(-5)
	current_target.adjustFireLoss(-5)
	current_target.adjustToxLoss(-2)
	current_target.adjustOxyLoss(-2)

/obj/item/weapon/gun/medbeam/syndi
	name = "ominous medical retrosynchronizer"
	desc = "Кроме цветовой гаммы, эта лечебная пушка НаноТрейзен ничем не отличается от своего аналога. Звучит знакомо."
	icon_state = "medigun_syndi"
	item_state = "medigun_syndi"
	beam_state = "medbeam_syndi"

/obj/effect/ebeam/medical
	name = "medical beam"
	icon_state = "medbeam"
