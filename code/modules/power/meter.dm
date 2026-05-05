var/global/list/power_meters = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/power/meter, power_meters)
/obj/machinery/power/meter
	name = "power meter unit"
	cases = list("счётчик электроэнергии", "счётчика электроэнергии", "счётчику электроэнергии", "счётчик электроэнергии", "счётчиком электроэнергии", "счётчике электроэнергии")
	desc = "Счётчик используемой электроэнергии."
	icon_state = "powermeter"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_NONE

	process_last = TRUE

	required_skills = null

	var/obj/machinery/power/terminal/terminal = null

	var/powerused = 0
	var/powerused_last = 0

	var/image/holoprice

	var/connected_account_number = 0
	var/paid = TRUE

	var/credits_per_kwh = 250

/obj/machinery/power/meter/atom_init()
	. = ..()

	update_icon()

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
	terminal.master = src
	connect_to_network()

/obj/machinery/power/meter/Destroy()
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/meter/attack_hand(mob/user)
	. = ..()
	if(!paid)
		try_retrieve_funds()

/obj/machinery/power/meter/proc/try_retrieve_funds()
	if(!powerused || !credits_per_kwh)
		return

	if(!connected_account_number || !isnum(connected_account_number))
		paid = FALSE
		update_icon()
		return

	if(!get_account(connected_account_number))
		paid = FALSE
		update_icon()
		return

	var/datum/money_account/Acc = get_account(connected_account_number)

	var/pay_amount = round(powerused / 3600000 * credits_per_kwh)

	if(Acc.money < pay_amount)
		paid = FALSE
		update_icon()
		return

	charge_to_account(Acc.account_number, "Счётчик электроэнергии", "Оплата электроэнергии", src.name, -pay_amount)
	charge_to_account(global.department_accounts["Engineering"], "Счётчик электроэнергии", "Прибыль за электроэнергию", src.name, pay_amount)

	powerused = 0
	paid = TRUE

/obj/machinery/power/meter/attackby(obj/item/I, mob/user)
	// opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
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
		connect_to_network()
		update_icon()
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
			terminal.connect_to_network()
		return

	// disassembling the terminal
	if(iscutter(I) && terminal && panel_open)
		terminal.dismantle(user)


	if(istype(I, /obj/item/weapon/card/id))
		visible_message("<span class='info'>[usr] прикладывает карту к [C_CASE(src, DATIVE_CASE)].</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I
		connected_account_number = Card.associated_account_number

	else if(istype(I, /obj/item/device/pda) && I.GetID())
		visible_message("<span class='info'>[usr] прикладывает кпк к [C_CASE(src, DATIVE_CASE)].</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I.GetID()
		connected_account_number = Card.associated_account_number

	else if(istype(I, /obj/item/weapon/ewallet))
		visible_message("<span class='info'>[usr] прикладывает чип к [C_CASE(src, DATIVE_CASE)].</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/ewallet/Wallet = I
		connected_account_number = Wallet.account_number

	// crowbarring it!
	if(!default_deconstruction_crowbar(I))
		return ..()

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

	if(panel_open)
		return FALSE

	if(!powernet || !terminal.powernet)
		return FALSE

	if(powernet == terminal.powernet)
		return FALSE

	return paid

/obj/machinery/power/meter/process()
	if(!can_operate())
		return

	var/available_power = max(0, min(load(), terminal.surplus()))
	terminal.add_load(load())
	add_avail(available_power)

	powerused_last = powerused
	powerused += available_power

	update_icon()

/obj/machinery/power/meter/update_icon()
	if(can_operate() && (powerused - powerused_last) > 0)
		icon_state = "[initial(icon_state)]_w"
	else if(panel_open)
		icon_state = "[initial(icon_state)]-o"
	else
		icon_state = initial(icon_state)

	if(!holoprice)
		holoprice = image('icons/effects/32x32.dmi', "blank")
		holoprice.layer = INDICATOR_LAYER

		holoprice.maptext_y = 5
		holoprice.maptext_width = 40
		holoprice.maptext_x = -4

		holoprice.pixel_y = 4

	cut_overlay(holoprice)
	holoprice.maptext = {"<div style="font-size:9pt;color:#22DD22;font:'Small Fonts';text-align:center;-dm-text-outline: 1px black;" valign="top">[round(powerused / 3600000 * credits_per_kwh)]$</div>"}
	holoprice.icon = 'icons/obj/device.dmi'
	holoprice.icon_state = "holo_overlay_[min(length(num2text(powerused / 3600000 * credits_per_kwh)), 3)]"
	add_overlay(holoprice)
