/obj/item/device/cardpay
	name = "Card pay device"
	desc = "Совершайте покупки простым движением карты."
	icon = 'icons/obj/device.dmi'
	icon_state = "card-pay-idle"

	slot_flags = SLOT_FLAGS_BELT
	m_amt = 7000
	g_amt = 2000

	var/datum/money_account/linked_account
	var/pay_amount = 0
	var/display_price = 0
	var/reset = TRUE

	var/image/holoprice

/obj/item/device/cardpay/atom_init(mapload)
	. = ..()

	if(mapload && locate(/obj/structure/table, get_turf(src)))
		anchored = TRUE

	holoprice = image('icons/effects/32x32.dmi', "blank")
	holoprice.layer = INDICATOR_LAYER

	holoprice.maptext_y = 5
	holoprice.maptext_width = 40
	holoprice.maptext_x = -4

	add_overlay(holoprice)

/obj/item/device/cardpay/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		if(src.loc == user)
			var/obj/item/weapon/card/id/Card = I
			var/datum/money_account/D = get_account(Card.associated_account_number)
			if(D)
				linked_account = D
				playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
				to_chat(user, "<span class='notice'>Аккаунт подключён.</span>")
			else
				to_chat(user, "<span class='notice'>Нет аккаунта, привязанного к карте.</span>")
		else
			scan_card(I)
	else if(istype(I, /obj/item/weapon/wrench) && isturf(src.loc))
		var/obj/item/weapon/wrench/Tool = I
		if(Tool.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			user.SetNextMove(CLICK_CD_INTERACT)
			if(user.is_busy())
				return
			if(anchored)
				to_chat(user, "<span class='notice'>Сканер откручен.</span>")
				anchored = FALSE
				update_holoprice(TRUE)
				SStgui.close_uis(src)
			else
				if(locate(/obj/structure/table, get_turf(src)))
					to_chat(user, "<span class='warning'>Сканер прикручен.</span>")
					anchored = TRUE
				else
					to_chat(user, "<span class='warning'>Сканер можно прикрутить только к столу.</span>")
	else
		. = ..()

/obj/item/device/cardpay/attack_self(mob/living/user)
	. = ..()

	if(user && !isturf(src.loc))
		set_dir(turn(dir,-90))

/obj/item/device/cardpay/proc/scan_card(obj/item/weapon/card/id/Card)
	visible_message("<span class='info'>[usr] прикладывает карту к терминалу.</span>")
	if(!linked_account)
		visible_message("[bicon(src)]<span class='warning'>Нет подключённого аккаунта.</span>")
		return
	if(linked_account.suspended)
		visible_message("[bicon(src)]<span class='warning'>Подключённый аккаунт заблокирован.</span>")
		return

	var/datum/money_account/D = get_account(Card.associated_account_number)
	var/attempt_pin = 0
	if(D)
		if(D.security_level > 0)
			attempt_pin = input("Введите ПИН-код", "Терминал оплаты") as num
			if(isnull(attempt_pin))
				to_chat(usr, "[bicon(src)]<span class='warning'>Неверный ПИН-код!</span>")
				return
			D = attempt_account_access(Card.associated_account_number, attempt_pin, 2)
		icon_state = "card-pay-processing"
		if(pay_amount > 0)
			addtimer(CALLBACK(src, .proc/make_transaction, D, pay_amount), 3 SECONDS)

/obj/item/device/cardpay/proc/make_transaction(datum/money_account/Acc, amount)
	icon_state = "card-pay-idle"
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	if(amount <= Acc.money)
		flick("card-pay-complete", src)
		charge_to_account(Acc.account_number, "Терминал оплаты", "Оплата", src.name, -amount)
		charge_to_account(linked_account.account_number, "Терминал оплаты", "Прибыль", src.name, amount)
		if(reset)
			pay_amount = 0
			update_holoprice(TRUE)
	else
		visible_message("[bicon(src)]<span class='warning'>Недостаточно средств!</span>")
		flick("card-pay-error", src)

/obj/item/device/cardpay/attack_hand(mob/user)
	. = ..()
	if(!isturf(src.loc))
		return

	if(anchored && check_direction(user))
		tgui_interact(user)

/obj/item/device/cardpay/CtrlClick(mob/user)
	if(!Adjacent(user))
		return ..()
	if(user.incapacitated())
		return
	if(usr.get_active_hand() != src && !isAI(usr))
		return ..()

	var/acc_number = 0

	var/list/memory_numbers = list(MEM_ACCOUNT_NUMBER)
	if(user.mind.has_key_memory(MEM_DEPARTMENT_ACCOUNT_NUMBER))
		memory_numbers += MEM_DEPARTMENT_ACCOUNT_NUMBER
	memory_numbers += "Ввести"

	var/choice = tgui_alert(user,"Номер аккаунта",, memory_numbers)
	if(choice == "Ввести")
		var/customnum = sanitize(input(user, "Введите номер аккаунта", "Номер", "111111") as text)
		if(customnum)
			acc_number = text2num(customnum)
	else
		acc_number = user.mind.get_key_memory(choice)

	var/datum/money_account/D = get_account(acc_number)
	if(D)
		linked_account = D
		playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Аккаунт подключён.</span>")
	else
		to_chat(user, "<span class='notice'>Нет аккаунта под указанным номером.</span>")

/obj/item/device/cardpay/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardPay", "Терминал")
		ui.open()

/obj/item/device/cardpay/tgui_data(mob/user)
	var/list/data = list()
	data["numbers"] = display_price
	data["reset_numbers"] = reset
	return data

/obj/item/device/cardpay/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(!check_direction(usr))
		SStgui.force_close_window(usr, SStgui.get_open_ui(usr, src).window.id)
		return

	switch(action)
		if("pressnumber")
			var/num = params["number"]
			if(isnum(num))
				num = clamp(num, 0, 9)
				display_price *= 10
				display_price += num
				if(display_price > 999)
					display_price %= 1000
				playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
				return TRUE
		if("clearnumbers")
			if(display_price == 0)
				pay_amount = 0
			display_price = 0
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			return TRUE
		if("approveprice")
			if(display_price > 0)
				pay_amount = display_price
				display_price = 0
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				update_holoprice(FALSE)
				return TRUE
		if("togglereset")
			reset = !reset
			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
			return TRUE

/obj/item/device/cardpay/proc/update_holoprice(clear)
	cut_overlay(holoprice)
	if(clear)
		holoprice.maptext = ""
		holoprice.icon = 'icons/effects/32x32.dmi'
		holoprice.icon_state = "blank"
	else
		holoprice.maptext = {"<div style="font-size:9pt;color:#22DD22;font:'Arial Black';text-align:center;" valign="top">[pay_amount]$</div>"}
		holoprice.icon = 'icons/obj/device.dmi'
		holoprice.icon_state = "holo_overlay"
	add_overlay(holoprice)

/obj/item/device/cardpay/proc/check_direction(mob/user)
	return is_the_opposite_dir(src.dir, get_dir(src, user))