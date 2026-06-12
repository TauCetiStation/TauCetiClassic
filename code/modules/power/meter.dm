var/global/list/power_meters = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/power/meter, power_meters)
/obj/machinery/power/meter
	name = "power meter unit"
	cases = list("счётчик электроэнергии", "счётчика электроэнергии", "счётчику электроэнергии", "счётчик электроэнергии", "счётчиком электроэнергии", "счётчике электроэнергии")
	desc = "Опломбированный счётчик используемой электроэнергии."
	icon_state = "powermeter"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_NONE

	process_last = TRUE

	required_skills = null

	armor = list(MELEE = 75, BULLET = 25, LASER = 25, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 100, ACID = 100)
	damage_deflection = 30

	resistance_flags = CAN_BE_HIT|FIRE_PROOF

	var/obj/machinery/power/terminal/terminal = null

	var/powerused = 0
	var/powerused_last = 0

	var/image/holoprice

	var/connected_account_number = 0
	var/paid = TRUE

	var/credits_per_kwh = 100
	var/new_credits_per_kwh = 100

	var/actual_load = 0

/obj/machinery/power/meter/atom_init(mapload)
	. = ..()

	if(!mapload)
		anchored = FALSE

	update_icon()

	if(!anchored)
		return

	dir_loop:
		for(var/d in cardinal)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop

	if(!terminal)
		stat |= BROKEN
		return

	if(mapload)
		credits_per_kwh = round(credits_per_kwh * (rand(8, 12) / 10))
		new_credits_per_kwh = round(new_credits_per_kwh * (rand(8, 12) / 10))

	terminal.master = src
	try_connect()

/obj/machinery/power/meter/Destroy()
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/meter/examine(mob/user)
	..()
	to_chat(user, "Нагрузка: [DisplayPower(actual_load)] | Потреблено: [round(powerused KWH, 0.01)]кВт/ч | Цена за кВт/ч: [credits_per_kwh]$")

/obj/machinery/power/meter/attack_hand(mob/user)
	. = ..()
	if(panel_open)
		var/account_num = input("Введите номер счёта", "") as num|null
		if(!Adjacent(user))
			return
		if(!account_num)
			return

		var/datum/money_account/meter_acc = attempt_account_access_with_user_input(account_num, 2, user)
		if(!meter_acc)
			to_chat(user, "<span class='notice'>Счёта не существует или пин-код набран неправильно</span>")
			return

		connected_account_number = account_num
		account_connected_message(user)
		return

	if(!paid)
		try_retrieve_funds()

/obj/machinery/power/meter/proc/account_connected_message(mob/user)
	to_chat(user, "Счёт подключен успешно")
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER, 25, TRUE)

/obj/machinery/power/meter/proc/fail_retrieve()
	paid = FALSE
	update_icon()
	playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER, 25, TRUE)

/obj/machinery/power/meter/proc/try_retrieve_funds()
	if(!powerused || !credits_per_kwh)
		return

	if(!connected_account_number || !isnum(connected_account_number))
		fail_retrieve()
		return

	var/datum/money_account/meter_acc = get_account(connected_account_number)
	if(!meter_acc)
		fail_retrieve()
		return

	var/pay_amount = round(powerused KWH * credits_per_kwh)

	if(meter_acc.money < pay_amount)
		fail_retrieve()
		return

	charge_to_account(meter_acc.account_number, "Счётчик электроэнергии", "Оплата электроэнергии", src.name, -pay_amount)
	charge_to_account(global.department_accounts[DEP_ENGINEERING].account_number, "Счётчик электроэнергии", "Прибыль за электроэнергию", src.name, pay_amount)

	powerused = 0
	paid = TRUE

	if(new_credits_per_kwh != credits_per_kwh)
		credits_per_kwh = new_credits_per_kwh

/obj/machinery/power/meter/proc/change_rate(newrate)
	if(!connected_account_number || !isnum(connected_account_number))
		return FALSE

	var/datum/money_account/meter_acc = get_account(connected_account_number)
	if(!meter_acc)
		return FALSE

	charge_to_account(meter_acc.account_number, "Счётчик электроэнергии", "Изменение цены за кВт/ч, начиная со следующего отчётного периода, с [credits_per_kwh] до [newrate]$", src.name, 0)

	new_credits_per_kwh = newrate

	return TRUE

/obj/machinery/power/meter/attackby(obj/item/I, mob/user)
	// opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return

	//anchoring
	if(iswelding(I))
		if(terminal)
			to_chat(user, "<span class='notice'>Cut terminal first!</span>")
			return
		if(user.is_busy()) return
		var/obj/item/weapon/weldingtool/W = I
		if(!W.use(0,user))
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return
		to_chat(user, "You start slicing the brackets of the [src].")
		if(I.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50, quality = QUALITY_WELDING, required_skills_override = list(/datum/skill/engineering = SKILL_LEVEL_TRAINED)))
			if(anchored)
				anchored = FALSE
				to_chat(user, "You unweld the [src] from the floor.")
				disconnect_terminal()
				disconnect_from_network()
			else
				anchored = TRUE
				to_chat(user, "You weld the [src] to the floor.")
				connect_to_network()

			update_icon()
			return

	// changing direction using wrench
	if(default_change_direction_wrench(user, I))
		terminal = null
		var/turf/T = get_step(src, dir)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(dir, 180))
				terminal = term
				to_chat(user, "<span class='notice'>Terminal found.</span>")
				break
		if(!terminal)
			stat |= BROKEN
			to_chat(user, "<span class='alert'>No power source found.</span>")
			return
		terminal.master = src
		stat &= ~BROKEN
		try_connect()
		return

	// building and linking a terminal
	if(iscoil(I))
		var/dir = get_dir(user, src)
		if(dir & (dir - 1)) // we don't want diagonal click
			return

		if(terminal) // is there already a terminal ?
			to_chat(user, "<span class='warning'>This power meter already have a power terminal!</span>")
			return

		if(!panel_open) // is the panel open ?
			to_chat(user, "<span class='warning'>You must open the maintenance panel first!</span>")
			return

		var/turf/T = get_turf(user)
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
			to_chat(user, "<span class='warning'>You must first remove the floor plating!</span>")
			return

		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires!</span>")
			return

		if(user.is_busy())
			return

		to_chat(user, "<span class='notice'>You start building the power terminal...</span>")
		if(I.use_tool(src, user, 20, volume = 50) && C.get_amount() >= 10)
			var/obj/structure/cable/N = T.get_cable_node() // get the connecting node cable, if there's one
			if (prob(50) && electrocute_mob(usr, N, N)) // animate the electrocution if uncautious and unlucky
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return

			C.use(10)
			user.visible_message(\
				"[user.name] has built a power terminal.",\
				"<span class='notice'>You build the power terminal.</span>")

			// build the terminal and link it to the network
			make_terminal(T)
		return

	// disassembling the terminal
	if(iscutter(I) && terminal && panel_open)
		terminal.dismantle(user)


	if(panel_open && istype(I, /obj/item/weapon/card/id))
		visible_message("<span class='info'>[user] прикладывает карту к [C_CASE(src, DATIVE_CASE)].</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I
		connected_account_number = Card.associated_account_number
		account_connected_message(user)

	else if(panel_open && istype(I, /obj/item/device/pda) && I.GetID())
		visible_message("<span class='info'>[user] прикладывает кпк к [C_CASE(src, DATIVE_CASE)].</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I.GetID()
		connected_account_number = Card.associated_account_number
		account_connected_message(user)

	else if(panel_open && istype(I, /obj/item/weapon/ewallet))
		visible_message("<span class='info'>[user] прикладывает чип к [C_CASE(src, DATIVE_CASE)].</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/ewallet/Wallet = I
		connected_account_number = Wallet.account_number
		account_connected_message(user)

	return ..()

/obj/machinery/power/meter/proc/try_connect()
	if(!can_operate())
		stat |= BROKEN
		return

	for(var/obj/machinery/power/meter/M in (powernet.nodes - src))
		stat |= BROKEN
		return

	for(var/obj/machinery/power/terminal/Term in powernet.nodes)
		if(Term.master && istype(Term.master, /obj/machinery/power/meter))
			stat |= BROKEN
			return

	terminal.connect_to_network()
	connect_to_network()

	update_icon()

// create a terminal object pointing towards the SMES
// wires will attach to this
/obj/machinery/power/meter/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.set_dir(get_dir(T, src))
	terminal.master = src

/obj/machinery/power/meter/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/meter/proc/can_operate()
	if(stat & BROKEN)
		return FALSE

	if(!anchored)
		return FALSE

	if(panel_open)
		return FALSE

	if(!terminal)
		stat |= BROKEN
		return FALSE

	if(!powernet || !terminal.powernet)
		stat |= BROKEN
		return FALSE

	if(powernet == terminal.powernet)
		stat |= BROKEN
		return FALSE

	return paid

/obj/machinery/power/meter/process()
	if(!can_operate())
		return

	actual_load = load() - newavail() //load minus our own production

	var/available_power = max(0, min(actual_load, terminal.surplus()))
	terminal.add_load(max(0, actual_load))
	add_avail(max(0, terminal.surplus()))

	powerused_last = powerused
	powerused += available_power

	if(round(powerused_last KWH * credits_per_kwh) < round(powerused KWH * credits_per_kwh))
		playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER, 10, TRUE, extrarange = -(world.view - 1))

	update_icon()

/obj/machinery/power/meter/update_icon()
	if(can_operate() && (powerused > powerused_last))
		icon_state = "[initial(icon_state)]_w"
	else if(panel_open)
		icon_state = "[initial(icon_state)][anchored ? "" : "_notanchored"]-o"
	else if(!anchored)
		icon_state = "[initial(icon_state)]_notanchored"
	else if(!paid || (stat & BROKEN))
		icon_state = "[initial(icon_state)]_fail"
	else
		icon_state = initial(icon_state)

	if(!holoprice)
		holoprice = image('icons/effects/32x32.dmi', "blank")
		holoprice.layer = INDICATOR_LAYER

		holoprice.maptext_y = 5
		holoprice.maptext_width = 40
		holoprice.maptext_x = -4

		holoprice.pixel_y = 4

	if(!can_operate())
		cut_overlay(holoprice)
		return

	if(powerused < powerused_last)
		return

	cut_overlay(holoprice)
	holoprice.maptext = {"<div style="font-size:9pt;color:#22DD22;font:'Small Fonts';text-align:center;-dm-text-outline: 1px black;" valign="top">[round(powerused KWH * credits_per_kwh)]$</div>"}
	holoprice.icon = 'icons/obj/device.dmi'
	holoprice.icon_state = "holo_overlay_[min(length(num2text(round(powerused KWH * credits_per_kwh))), 3)]"
	add_overlay(holoprice)
