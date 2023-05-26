/obj/item/device/cardpay
	name = "Card pay device"
	desc = "Совершайте покупки простым движением карты."
	icon = 'icons/obj/device.dmi'
	icon_state = "card-pay-idle"

	slot_flags = SLOT_FLAGS_BELT
	m_amt = 7000
	g_amt = 2000

	var/linked_account = 0
	var/pay_amount = 0
	var/display_numbers = 0
	var/reset = TRUE
	var/enter_account = FALSE

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
	if(istype(I, /obj/item/weapon/card/id) && anchored)
		visible_message("<span class='info'>[usr] прикладывает карту к терминалу.</span>")
		if(!enter_account)
			scan_card(I)
			return
		var/obj/item/weapon/card/id/Card = I
		var/datum/money_account/D = get_account(Card.associated_account_number)
		if(!D)
			to_chat(user, "<span class='notice'>Нет аккаунта, привязанного к карте.</span>")
			return
		linked_account = D.account_number
		playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Аккаунт подключён.</span>")
	else if(istype(I, /obj/item/device/pda) && I.GetID())
		visible_message("<span class='info'>[usr] прикладывает КПК к терминалу.</span>")
		var/obj/item/weapon/card/id/Card = I.GetID()
		scan_card(Card)
	else if(istype(I, /obj/item/weapon/wrench) && isturf(src.loc))
		var/obj/item/weapon/wrench/Tool = I
		if(Tool.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			user.SetNextMove(CLICK_CD_INTERACT)
			if(!anchored)
				if(!locate(/obj/structure/table, get_turf(src)))
					to_chat(user, "<span class='warning'>Сканер можно прикрутить только к столу.</span>")
					return
				to_chat(user, "<span class='warning'>Сканер прикручен.</span>")
				anchored = TRUE
				return
			to_chat(user, "<span class='notice'>Сканер откручен.</span>")
			anchored = FALSE
			update_holoprice(clear = TRUE)
			SStgui.close_uis(src)
	else
		return ..()

/obj/item/device/cardpay/attack_self(mob/living/user)
	. = ..()

	set_dir(turn(dir,-90))

/obj/item/device/cardpay/proc/scan_card(obj/item/weapon/card/id/Card)
	if(!linked_account)
		visible_message("[bicon(src)] [name] <span class='warning'>Нет подключённого аккаунта.</span>")
		return
	var/datum/money_account/Acc = get_account(linked_account)
	if(!Acc || Acc.suspended)
		visible_message("[bicon(src)] [name] <span class='warning'>Подключённый аккаунт заблокирован.</span>")
		return
	if(pay_amount <= 0)
		return

	var/pay_holder = pay_amount

	var/datum/money_account/D = get_account(Card.associated_account_number)
	var/attempt_pin = 0
	if(D)
		if(D.security_level > 0)
			var/time_for_pin = world.time
			if(usr.mind.get_key_memory(MEM_ACCOUNT_PIN) == D.remote_access_pin)
				attempt_pin = usr.mind.get_key_memory(MEM_ACCOUNT_PIN)
			else
				attempt_pin = input("Введите ПИН-код", "Терминал оплаты") as num
			if(!usr || !usr.Adjacent(src))
				return
			if(world.time - time_for_pin > 300)
				to_chat(usr, "[bicon(src)] [name] <span class='warning'>Время операции истекло!</span>")
				return
			if(Acc != get_account(linked_account))
				to_chat(usr, "[bicon(src)] [name] <span class='warning'>Подключённый аккаунт изменён!</span>")
				return
			if(pay_holder != pay_amount)
				to_chat(usr, "[bicon(src)] [name] <span class='warning'>Сумма оплаты изменена!</span>")
				return
			if(isnull(attempt_pin))
				to_chat(usr, "[bicon(src)] [name] <span class='warning'>Неверный ПИН-код!</span>")
				return
			D = attempt_account_access(Card.associated_account_number, attempt_pin, 2)
			if(!D)
				to_chat(usr, "[bicon(src)] [name] <span class='warning'>Неверный ПИН-код!</span>")
				return

		icon_state = "card-pay-processing"
		addtimer(CALLBACK(src, .proc/make_transaction, D, pay_holder), 3 SECONDS)

/obj/item/device/cardpay/proc/make_transaction(datum/money_account/Acc, amount)
	if(!src || !Acc)
		return
	icon_state = "card-pay-idle"
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)

	if(amount > Acc.money)
		visible_message("[bicon(src)] [name] <span class='warning'>Недостаточно средств!</span>")
		flick("card-pay-error", src)
		return

	flick("card-pay-complete", src)
	charge_to_account(Acc.account_number, "Терминал оплаты", "Оплата", src.name, -amount)
	charge_to_account(linked_account, "Терминал оплаты", "Прибыль", src.name, amount)

	if(reset)
		pay_amount = 0
		update_holoprice(clear = TRUE)

/obj/item/device/cardpay/attack_hand(mob/user)
	. = ..()
	if(!isturf(loc))
		return

	if(anchored && is_the_opposite_dir(src.dir, get_dir(src, user)))
		tgui_interact(user)

/obj/item/device/cardpay/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardPay", "Терминал")
		ui.open()

/obj/item/device/cardpay/tgui_data(mob/user)
	var/list/data = list()
	data["numbers"] = display_numbers
	data["reset_numbers"] = reset
	data["enter_account"] = enter_account
	return data

/obj/item/device/cardpay/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(!is_the_opposite_dir(src.dir, get_dir(src, usr)))
		SStgui.close_user_uis(usr, src)
		return

	switch(action)
		if("pressnumber")
			var/num = params["number"]
			if(isnum(num))
				num = clamp(num, 0, 9)
				display_numbers *= 10
				display_numbers += num
				if(enter_account && display_numbers > 999999)
					display_numbers %= 1000000
				else if(!enter_account && display_numbers > 999)
					display_numbers %= 1000
				playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
				return TRUE
		if("clearnumbers")
			if(display_numbers == 0)
				pay_amount = 0
			display_numbers = 0
			update_holoprice(clear = TRUE)
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			return TRUE
		if("approveprice")
			if(display_numbers > 0)
				if(enter_account)
					if(display_numbers >= 111111 && display_numbers <= 999999)
						var/datum/money_account/D = get_account(display_numbers)
						if(D)
							linked_account = display_numbers
				else
					pay_amount = display_numbers
					update_holoprice(clear = FALSE)
				display_numbers = 0
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				return TRUE
		if("togglereset")
			reset = !reset
			if(reset)
				to_chat(usr, "<span class='notice'>Включён режим оплаты.</span>")
			else
				to_chat(usr, "<span class='notice'>Включён режим пожертвований.</span>")
			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
			return TRUE
		if("toggleenteraccount")
			display_numbers = 0
			enter_account = !enter_account
			if(enter_account)
				to_chat(usr, "<span class='notice'>Включён режим ввода аккаунта.</span>")
			else
				to_chat(usr, "<span class='notice'>Включён режим ввода цены.</span>")
			update_holoprice(clear = TRUE)
			playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)
			return TRUE

/obj/item/device/cardpay/proc/update_holoprice(clear)
	cut_overlay(holoprice)
	if(clear)
		holoprice.maptext = ""
		holoprice.icon = 'icons/effects/32x32.dmi'
		holoprice.icon_state = "blank"
	else
		holoprice.maptext = {"<div style="font-size:9pt;color:#22DD22;font:'Small Fonts';text-align:center;-dm-text-outline: 1px black;" valign="top">[pay_amount]$</div>"}
		holoprice.icon = 'icons/obj/device.dmi'
		holoprice.icon_state = "holo_overlay"
	add_overlay(holoprice)
