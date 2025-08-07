/obj/effect/landmark/ivent/star_wars/jedi
	name = "Jedi Spawn"
	icon_state = "x3"

// artifact - force source

/obj/structure/ivent/star_wars/artifact
	name = "bluespace crystal"
	desc = "A green strange crystal"
	icon = 'icons/obj/xenoarchaeology/artifacts.dmi'
	icon_state = "artifact_11"
	density = TRUE
	anchored = TRUE
	light_color = COLOR_GREEN
	light_range = 2
	light_power = 1
	resistance_flags = FULL_INDESTRUCTIBLE

	var/list/force_users = list()
	var/next_touch = 0
	var/next_pulse = 0

	var/list/research_phrases = list(
		"Объект идентифицирован как энергетический фокус нестабильного типа.",
		"При контакте с органикой наблюдается передача аномального заряда.",
		"Избыточный контакт приводит к термическому повреждению тканей.",
		"Спонтанная эмиссия: зафиксировано случайное распределение заряда среди ближайших организмов.",
		"Активация не зависит от прямого контакта – требуется пересмотр принципов работы.",
		"Объект не имеет видимого источника питания – вероятно, использует внешние резервы.",
		"Рекомендуется осторожное обращение: паттерны излучения непредсказуемы.")

/obj/structure/ivent/star_wars/artifact/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/ivent/star_wars/artifact/attackby(obj/item/I, mob/user)
	. = ..()
	if(istype(I, /obj/item/device/science_tool) && do_after(user, 1 SECOND))
		to_chat(user, "<span class='notice'>Сканер отображает два числа [next_touch] и [next_pulse].</span>")
		to_chat(user, pick(research_phrases))

/obj/structure/ivent/star_wars/artifact/attack_hand(mob/living/carbon/user)
	if(!iscarbon(user))
		return

	if((world.time < next_touch) || (user in force_users))
		var/effect = rand(1, 5)
		switch(effect)
			if(1)
				user.electrocute_act(15, src)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
				s.set_up(3, 1, src)
				s.start()

			if(2)
				to_chat(user, "<span class='warning'>Артефакт обжигает вас!</span>")
				user.adjustFireLoss(15)

			if(3)
				empulse(src, 1, 3)
		return

	activate()
	add_force_user(user)
	next_touch = world.time + rand(10, 15) MINUTE

/obj/structure/ivent/star_wars/artifact/proc/activate()
	//playsound
	set_light(4, 2)
	icon_state = "artifact_11_active"
	addtimer(CALLBACK(src, PROC_REF(deactivate)), 2 SECOND)

/obj/structure/ivent/star_wars/artifact/proc/deactivate()
	set_light(2, 1)
	icon_state = "artifact_11"

/obj/structure/ivent/star_wars/artifact/process()
	if(world.time > next_pulse)
		pulse()

/obj/structure/ivent/star_wars/artifact/proc/pulse()
	activate()
	next_pulse = world.time + rand(10, 15) MINUTE
	var/list/candidates = global.player_list & global.carbon_list - force_users

	for(var/i in 1 to rand(2, 3))
		if(candidates.len == 0)
			break
		add_force_user(pick_n_take(candidates))

/obj/structure/ivent/star_wars/artifact/proc/add_force_user(mob/living/carbon/force_user)
	force_users += force_user

	if(ismindprotect(force_user))
		for(var/obj/item/weapon/implant/mind_protect/L in force_user.implants)
			L.meltdown(harmful = FALSE)

	var/effect = rand(1, 5)
	switch(effect)
		if(1)
			force_user.set_light(1, 1, COLOR_BLUE)
			addtimer(CALLBACK(force_user, .atom/proc/set_light, 0, 0), 2 SECOND)

		if(2)
			playsound(force_user, "sound/ambience/loop_regular.ogg", VOL_EFFECTS_MASTER)

/obj/structure/sign/departments/jedi
	name = "Jedi Orden"
	desc = "Символ Ордена Джедаев"
	icon_state = "jedi"

// clothes

/obj/item/clothing/suit/hooded/star_wars
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 30, bomb = 20, bio = 20, rad = 20)
	unacidable = 1

/obj/item/clothing/shoes/star_wars
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"
	unacidable = 1
	flags = NOSLIP

/obj/item/clothing/suit/hooded/star_wars/jedi
	name = "Jedi robe"
	desc = "."
	icon_state = "wizard"
	item_state = "wizrobe"

/obj/item/clothing/suit/hooded/star_wars/sith
	name = "Sith robe"
	desc = "."
	icon_state = "wizard"
	item_state = "wizrobe"

/obj/item/weapon/melee/energy/sword/star_wars
	name = "Lightsaber"
	can_be_dual = FALSE

	var/stand = 1
	var/shield_chance = 200
	var/max_shield_chance = 200
	var/list/stands = list(1, 2, 3)

/obj/item/weapon/melee/energy/sword/star_wars/dropped(mob/user)
	. = ..()
	if(active)
		attack_self(usr)

/obj/item/weapon/melee/energy/sword/star_wars/Get_shield_chance()
	if(active)
		stand = pick(stands)
		update_icon()
		update_inv_mob()

		var/mob/user = loc
		var/old_transform = user.transform
		user.transform *= 1.2
		animate(user, transform = old_transform, time = 5)

		shield_chance -= 20
		if(shield_chance < max_shield_chance)
			START_PROCESSING(SSobj, src)
		return shield_chance
	return 0

/obj/item/weapon/melee/energy/sword/star_wars/process()
	if(shield_chance < max_shield_chance)
		shield_chance = min(max_shield_chance, shield_chance + 2)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/melee/energy/sword/star_wars/update_icon()
	if(active)
		icon_state = "lightsaber_[blade_color]_[stand]"
	else
		icon_state = "lightsaber_off"

/obj/item/weapon/melee/energy/sword/star_wars/attack_self(mob/living/user)
	if(!active && !isrolebytype(/datum/role/star_wars, user))
		return
	. = ..()
	if(active)
		canremove = FALSE
		flags = NODROP | ABSTRACT
	else
		canremove = TRUE
		flags = null

// blue for jedi
/obj/item/weapon/melee/energy/sword/star_wars/jedi/atom_init()
	. = ..()
	blade_color = "blue"
	light_color = COLOR_BLUE
	stand = 2

// green for master jedi
/obj/item/weapon/melee/energy/sword/star_wars/jedi/leader/atom_init()
	. = ..()
	blade_color = "green"
	light_color = COLOR_GREEN
	stand = 1
	max_shield_chance = 240
	shield_chance = 240

// red for sith
/obj/item/weapon/melee/energy/sword/star_wars/sith/atom_init()
	. = ..()
	blade_color = "red"
	light_color = COLOR_RED
	stand = 3

// dual red for master sith
/obj/item/weapon/melee/energy/sword/star_wars/dual/atom_init()
	name = "Dual Lightsaber"
	stands = list(1, 2)
	stand = 1
	light_color = COLOR_RED
/obj/item/weapon/melee/energy/sword/star_wars/dual/update_icon()
	if(active)
		icon_state = "duallightsaber_[stand]"
	else
		icon_state = "duallightsaber_off"

// actions
/datum/action/innate/star_wars
	check_flags = AB_CHECK_INCAPACITATED

	var/datum/faction/star_wars/jedi/jedi_faction
	var/datum/faction/star_wars/sith/sith_faction

/datum/action/innate/star_wars/New()
	jedi_faction = find_faction_by_type(/datum/faction/star_wars/jedi)
	sith_faction = find_faction_by_type(/datum/faction/star_wars/sith)
	. = ..()

/datum/action/innate/star_wars/jedi/find_force
	name = "Обнаружить силу"
	button_icon_state = "jedi_find_force"
	cooldown = 2 MINUTE
/datum/action/innate/star_wars/jedi/find_force/Activate()
	to_chat(owner, "<span class='notice'>Существа в 4 метрах от вас, Силой обладающие, да засветятся синим.</span>")
	for(var/mob/living/carbon/C in view(5, owner))
		if(jedi_faction.isforceuser(C))
			C.set_light(4, 2, COLOR_BLUE)
			addtimer(CALLBACK(C, .atom/proc/set_light, 0, 0), 4 SECOND)

	StartCooldown()

/datum/action/innate/star_wars/jedi/convert
	name = "Обучить светлой стороне силы"
	button_icon_state = "jedi_convert"
	cooldown = 1 MINUTE

/datum/action/innate/star_wars/jedi/convert/Activate()
	to_chat(owner, "<span class='notice'>При следующем клике вы попытаетесь обучить цель использовать Силу.</span>")
	RegisterSignal(owner, COMSIG_MOB_CLICK, PROC_REF(convert), override = TRUE)
	. = ..()

/datum/action/innate/star_wars/jedi/convert/Deactivate()
	to_chat(owner, "<span class='notice'>Вы больше не будете при клике пытаться обучить Силе.</span>")
	UnregisterSignal(owner, COMSIG_MOB_CLICK)
	. = ..()

/datum/action/innate/star_wars/jedi/convert/proc/convert(mob/user, atom/target, params)
	SIGNAL_HANDLER
	Deactivate()

	if(!iscarbon(target))
		to_chat(user, "<span class='warning'>[target] не может быть носителем Силы.</span>")
		return

	if(!in_range(target, user))
		to_chat(user, "<span class='warning'>Нужно находиться ближе!</span>")
		return

	if(!jedi_faction.isforceuser(target))
		to_chat(user, "<span class='warning'>Цель не является носителем Силы!</span>")
		StartCooldown()
		return

	if((target in jedi_faction.members) || (target in sith_faction.members))
		to_chat(user, "<span class='warning'>Цель уже принадлежит одной из сторон!</span>")
		StartCooldown()
		return

	INVOKE_ASYNC(src, PROC_REF(offer), user, target)

/datum/action/innate/star_wars/jedi/convert/proc/offer(mob/user, mob/living/carbon/target)
	var/choice = tgui_alert(target, "[user] спрашивает вас: Хотите ли вы перейти на светлую сторону Силы?",
		"Присоединиться к джедаям?", list("Да!","Нет!"))
	if(choice == "Да!")
		add_faction_member(jedi_faction, target)
		to_chat(user, "<span class='notice'>[target] присоединился к светлой стороне Силы!</span>")
		StartCooldown()
	else
		to_chat(target, "<span class='warning'>Вы отказались присоединяться к светлой стороне Силы!</span>")
		to_chat(user, "<span class='bold warning'>[target] отказался присоединяться к светлой стороне Силы!</span>")

// sith actions

/datum/action/innate/star_wars/sith/find_force
	name = "Обнаружить силу"
	button_icon_state = "sith_find_force"
	cooldown = 5 SECOND

/datum/action/innate/star_wars/sith/find_force/Activate()
	to_chat(owner, "<span class='notice'>При следующем клике вы узнаете, является ли цель носителем Силы.</span>")
	RegisterSignal(owner, COMSIG_MOB_CLICK, PROC_REF(check), override = TRUE)
	. = ..()

/datum/action/innate/star_wars/sith/find_force/Deactivate()
	to_chat(owner, "<span class='notice'>Вы больше не будете при клике пытаться обнаркжить Силу.</span>")
	UnregisterSignal(owner, COMSIG_MOB_CLICK)
	. = ..()

/datum/action/innate/star_wars/sith/find_force/proc/check(mob/user, atom/target, params)
	SIGNAL_HANDLER
	Deactivate()

	if(!iscarbon(target))
		to_chat(user, "<span class='warning'>[target] не может быть носителем Силы.</span>")
		return

	StartCooldown()

	if(target in jedi_faction.members)
		to_chat(user, "<span class='bold warning'>[target] является джедаем!</span>")
	else if(target in sith_faction.members)
		to_chat(user, "<span class='notice'>[target] является ситхом!</span>")
	else if(sith_faction.isforceuser(target))
		to_chat(user, "<span class='notice'>[target] является носителем Силы!</span>")

/datum/action/innate/star_wars/sith/convert
	name = "Обучить тёмной стороне силы"
	button_icon_state = "sith_convert"
	cooldown = 5 SECOND

/datum/action/innate/star_wars/sith/convert/Activate()
	to_chat(owner, "<span class='notice'>При следующем клике вы попытаетесь обучить цель использовать Силу.</span>")
	RegisterSignal(owner, COMSIG_MOB_CLICK, PROC_REF(convert), override = TRUE)
	. = ..()

/datum/action/innate/star_wars/sith/convert/Deactivate()
	to_chat(owner, "<span class='notice'>Вы больше не будете при клике пытаться обучить Силе.</span>")
	UnregisterSignal(owner, COMSIG_MOB_CLICK)
	. = ..()

/datum/action/innate/star_wars/sith/convert/proc/convert(mob/user, atom/target, params)
	SIGNAL_HANDLER
	Deactivate()

	if(!iscarbon(target))
		to_chat(user, "<span class='warning'>[target] не может быть носителем Силы.</span>")
		return

	if(!in_range(target, user))
		to_chat(user, "<span class='warning'>Нужно находиться ближе!</span>")
		return

	if(!sith_faction.isforceuser(target))
		to_chat(user, "<span class='warning'>Цель не является носителем Силы!</span>")
		return

	if((target in jedi_faction.members) || (target in sith_faction.members))
		to_chat(user, "<span class='warning'>Цель уже принадлежит одной из сторон!</span>")
		return

	INVOKE_ASYNC(src, PROC_REF(offer), user, target)

/datum/action/innate/star_wars/sith/convert/proc/offer(mob/user, mob/living/carbon/target)
	var/choice = tgui_alert(target, "[user] спрашивает вас: Хотите ли вы перейти на тёмную сторону Силы?",
		"Присоединиться к ситхам?", list("Да!","Нет!"))
	if(choice == "Да!")
		add_faction_member(sith_faction, target)
		to_chat(user, "<span class='notice'>[target] присоединился к тёмной стороне Силы!</span>")
		StartCooldown()
	else
		to_chat(target, "<span class='warning'>Вы отказались присоединяться к тёмной стороне Силы!</span>")
		to_chat(user, "<span class='bold warning'>[target] отказался присоединяться к тёмной стороне Силы!</span>")

/datum/action/innate/star_wars/sith/force_convert
	name = "Промыть мозги"
	button_icon_state = "sith_convert"
	cooldown = 3 MINUTE

/datum/action/innate/star_wars/sith/force_convert/Activate()
	to_chat(owner, "<span class='notice'>При следующем клике вы попытаетесь промыть цели мозги.</span>")
	RegisterSignal(owner, COMSIG_MOB_CLICK, PROC_REF(convert), override = TRUE)
	. = ..()

/datum/action/innate/star_wars/sith/force_convert/Deactivate()
	to_chat(owner, "<span class='notice'>Вы больше не будете при клике пытаться промыть мозги.</span>")
	UnregisterSignal(owner, COMSIG_MOB_CLICK)
	. = ..()

/datum/action/innate/star_wars/sith/force_convert/proc/convert(mob/user, atom/target, params)
	SIGNAL_HANDLER
	Deactivate()

	if(!iscarbon(target))
		return

	if(get_dist(target, user) > 2)
		to_chat(user, "<span class='warning'>Нужно находиться ближе!</span>")
		return

	if(target in jedi_faction.members)
		to_chat(user, "<span class='bold warning'>[target] является джедаем!</span>")
		return

	var/mob/living/carbon/C = target
	if(ismindprotect(C))
		to_chat(user, "<span class='bold warning'>Разум [target] защищён от псионических воздействий!</span>")
		return

	INVOKE_ASYNC(src, PROC_REF(mindwash), user, target)

/datum/action/innate/star_wars/sith/force_convert/proc/mindwash(mob/user, mob/living/carbon/target)
	if(sith_faction.isforceuser(target))
		StartCooldown()
		to_chat(target, "<span class='bold warning'>[user] посеял сомненья в ваш разум, отныне вы принадлежите тёмной стороне силы!</span>")
		add_faction_member(sith_faction, target)
	else
		var/message = input(user, "Отдайте короткий приказ, цель будет обязана его выполнить и забыть об этом.", "Короткий приказ") as text|null
		if(message)
			StartCooldown()
			to_chat(target, "<span class='big'>Ситх завладел вашим разумом, вы ОБЯЗАНЫ исполнить следующий приказ и ЗАБЫТЬ о произошедшем!</span>")
			to_chat(target, "<span class='reallybig'>[message]</span>")


/obj/effect/proc_holder/spell/in_hand/heal/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 1 MINUTE

/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 1 MINUTE
	emp_heavy = 3
	emp_light = 5

/obj/effect/proc_holder/spell/targeted/summonitem/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 10 SECOND

/obj/effect/proc_holder/spell/aoe_turf/repulse/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 1 MINUTE
	maxthrow = 3

/obj/effect/proc_holder/spell/targeted/forcewall/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 1 MINUTE

/obj/effect/proc_holder/spell/in_hand/tesla/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 1 MINUTE

/obj/effect/proc_holder/spell/targeted/lighting_shock/star_wars
	invocation = ""
	clothes_req = FALSE
	charge_max = 1 MINUTE
