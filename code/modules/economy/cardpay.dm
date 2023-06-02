#define IDLEMODE "Mode_Idle"
#define PAYMODE "Mode_Pay"
#define ACCOUNTMODE "Mode_Account"
#define ENTERPIN "Mode_EnterPin"

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
	var/ram_account = 0
	var/reset = FALSE

	var/image/holoprice

	var/mode = IDLEMODE
	var/prevmode = IDLEMODE

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
		visible_message("<span class='info'>[usr] прикладывает карту к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I
		switch(mode)
			if(PAYMODE)
				display_numbers = Card.associated_account_number
				pay_with_account()
			if(ACCOUNTMODE)
				display_numbers = Card.associated_account_number
				set_account()

	else if(istype(I, /obj/item/device/pda) && I.GetID())
		visible_message("<span class='info'>[usr] прикладывает кпк к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I.GetID()
		switch(mode)
			if(PAYMODE)
				display_numbers = Card.associated_account_number
				pay_with_account()
			if(ACCOUNTMODE)
				display_numbers = Card.associated_account_number
				set_account()

	else if(istype(I, /obj/item/weapon/ewallet))
		visible_message("<span class='info'>[usr] прикладывает чип к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/ewallet/Wallet = I
		switch(mode)
			if(PAYMODE)
				display_numbers = Wallet.account_number
				pay_with_account()
			if(ACCOUNTMODE)
				display_numbers = Wallet.account_number
				set_account()

	else if(istype(I, /obj/item/weapon/wrench) && isturf(src.loc))
		var/obj/item/weapon/wrench/Tool = I
		if(Tool.use_tool(src, user, SKILL_TASK_VERY_EASY, volume = 50))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			user.SetNextMove(CLICK_CD_INTERACT)
			var/obj/structure/table/Table = locate(/obj/structure/table, get_turf(src))
			if(!anchored)
				if(!Table)
					to_chat(user, "<span class='warning'>Сканер можно прикрутить только к столу.</span>")
					return
				to_chat(user, "<span class='warning'>Сканер прикручен.</span>")
				anchored = TRUE
				RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), .proc/unwrench)
				return
			to_chat(user, "<span class='notice'>Сканер откручен.</span>")
			anchored = FALSE
			UnregisterSignal(Table, list(COMSIG_PARENT_QDELETING))
			reset_anything()
			SStgui.close_uis(src)
	else
		return ..()

/obj/item/device/cardpay/proc/unwrench()
	anchored = FALSE

/obj/item/device/cardpay/attack_self(mob/living/user)
	. = ..()

	set_dir(turn(dir,-90))

/obj/item/device/cardpay/attack_hand(mob/user)
	. = ..()
	if(!isturf(loc))
		return

	tgui_interact(user)

/obj/item/device/cardpay/examine(mob/user)
	. = ..()
	if(linked_account)
		var/datum/money_account/Acc = get_account(linked_account)
		if(Acc)
			to_chat(user, "Принадлежит [Acc.owner_name] ([Acc.account_number])")

/obj/item/device/cardpay/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CardPay", "Терминал")
		ui.open()

/obj/item/device/cardpay/tgui_data(mob/user)
	var/list/data = list()
	data["numbers"] = display_numbers
	data["reset_numbers"] = reset
	data["mode"] = mode
	return data

/obj/item/device/cardpay/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("pressnumber")
			var/num = params["number"]
			if(isnum(num))
				press_number(num)
				playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)

		if("clearnumbers")
			clear_numbers()
			playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
			return TRUE

		if("approveprice")
			approve()
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
			enter_account()

			return TRUE

/obj/item/device/cardpay/proc/press_number(num)
	num = clamp(num, 0, 9)
	display_numbers *= 10
	display_numbers += num

	switch(mode)
		if(IDLEMODE)
			if(display_numbers > 999)
				display_numbers %= 1000

		if(PAYMODE)
			if(display_numbers > 999999)
				display_numbers %= 1000000

		if(ACCOUNTMODE)
			if(display_numbers > 999999)
				display_numbers %= 1000000

		if(ENTERPIN)
			if(display_numbers > 99999)
				display_numbers %= 100000

/obj/item/device/cardpay/proc/clear_numbers()
	switch(mode)
		if(IDLEMODE)
		if(PAYMODE)
			if(!display_numbers)
				pay_amount = 0
				update_holoprice(clear = TRUE)
				changemode(IDLEMODE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена транзакции.</span>")
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				flick("card-pay-error", src)

		if(ACCOUNTMODE)
			if(!display_numbers)
				changemode(IDLEMODE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена ввода счёта.</span>")
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				flick("card-pay-error", src)

		if(ENTERPIN)
			if(!display_numbers)
				update_holoprice(clear = TRUE)
				changemode(IDLEMODE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена ввода пинкода.</span>")
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				flick("card-pay-error", src)

	display_numbers = 0

/obj/item/device/cardpay/proc/approve()
	switch(mode)
		if(IDLEMODE)
			if(!display_numbers)
				return
			if(!linked_account)
				visible_message("[bicon(src)] [name] <span class='warning'>Нет подключённого счёта.</span>")
				flick("card-pay-error", src)
				return
			var/datum/money_account/Acc = get_account(linked_account)
			if(!Acc || Acc.suspended)
				visible_message("[bicon(src)] [name] <span class='warning'>Подключённый счёт заблокирован.</span>")
				flick("card-pay-error", src)
				return
			pay_amount = display_numbers
			update_holoprice(clear = FALSE)
			changemode(PAYMODE)

		if(PAYMODE)
			if(!display_numbers)
				return
			pay_with_account()

		if(ACCOUNTMODE)
			if(!display_numbers)
				return
			set_account()

		if(ENTERPIN)
			if(!display_numbers)
				return
			switch(prevmode)
				if(PAYMODE)
					var/datum/money_account/Acc = get_account(ram_account)
					if(!Acc || Acc.suspended)
						visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
						flick("card-pay-error", src)
						return
					Acc = attempt_account_access(ram_account, display_numbers, 2)
					if(!Acc)
						visible_message("[bicon(src)] [name] <span class='warning'>Невозможно оплатить с этого счёта.</span>")
						flick("card-pay-error", src)
						return
					make_transaction(Acc, pay_amount)

				if(ACCOUNTMODE)
					var/datum/money_account/Acc = get_account(linked_account)
					if(!Acc || Acc.suspended)
						visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
						flick("card-pay-error", src)
						linked_account = 0
						reset_anything()
						return
					if(Acc.remote_access_pin == display_numbers)
						linked_account = 0
						changemode(ACCOUNTMODE)
					else
						visible_message("[bicon(src)] [name] <span class='warning'>Неверный пинкод.</span>")
						flick("card-pay-error", src)

				else
					reset_anything()
					return

/obj/item/device/cardpay/proc/set_account()
	var/datum/money_account/Acc = get_account(display_numbers)
	if(!Acc || Acc.suspended)
		visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
		flick("card-pay-error", src)
		return
	linked_account = display_numbers
	visible_message("[bicon(src)] [name] <span class='notice'>Счёт подключён.</span>")
	flick("card-pay-complete", src)
	playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
	changemode(IDLEMODE)

/obj/item/device/cardpay/proc/pay_with_account()
	var/datum/money_account/Acc = get_account(display_numbers)
	if(!Acc || Acc.suspended)
		visible_message("[bicon(src)] [name] <span class='warning'>Счёт заблокирован.</span>")
		flick("card-pay-error", src)
		return
	if(usr.mind.get_key_memory(MEM_ACCOUNT_PIN) == Acc.remote_access_pin || Acc.security_level == 0)
		make_transaction(Acc, pay_amount)
		return
	else
		ram_account = display_numbers
		changemode(ENTERPIN)

/obj/item/device/cardpay/proc/enter_account()
	switch(mode)
		if(IDLEMODE)
			changemode(ACCOUNTMODE)
			if(!linked_account)
				return
			var/datum/money_account/Acc = get_account(linked_account)
			if(!Acc || Acc.suspended)
				visible_message("[bicon(src)] [name] <span class='warning'>Подключённого счёта не существует. Введите новый счёт.</span>")
				linked_account = 0
				return
			if(Acc.security_level > 0)
				if(usr.mind.get_key_memory(MEM_ACCOUNT_PIN) == Acc.remote_access_pin || Acc.security_level == 0)
					linked_account = 0
					return
				changemode(ENTERPIN)
		if(PAYMODE)
			return
		if(ACCOUNTMODE)
			changemode(IDLEMODE)
		if(ENTERPIN)
			return

	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)

/obj/item/device/cardpay/proc/changemode(newmode)
	prevmode = mode
	mode = newmode
	display_numbers = 0

	switch(newmode)
		if(IDLEMODE)
			icon_state = "card-pay-idle"
		if(ENTERPIN)
			icon_state = "card-pay-processing"

/obj/item/device/cardpay/proc/reset_anything()
	mode = IDLEMODE
	prevmode = IDLEMODE
	reset = FALSE
	display_numbers = 0
	pay_amount = 0
	update_holoprice(clear = TRUE)

/obj/item/device/cardpay/proc/make_transaction(datum/money_account/Acc, amount)
	if(amount > Acc.money)
		visible_message("[bicon(src)] [name] <span class='warning'>Недостаточно средств!</span>")
		flick("card-pay-error", src)
		return

	icon_state = "card-pay-idle"
	visible_message("[bicon(src)] [name] <span class='notice'>Оплата прошла успешно.</span>")
	flick("card-pay-complete", src)
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)

	var/datum/money_account/D = get_account(linked_account)
	charge_to_account(Acc.account_number, "Терминал оплаты [D.owner_name] ([D.account_number])", "Оплата", src.name, -amount)
	charge_to_account(linked_account, "Терминал оплаты [D.owner_name] ([D.account_number])", "Прибыль", src.name, amount)

	if(reset)
		pay_amount = 0
		update_holoprice(clear = TRUE)
		changemode(IDLEMODE)
	else
		changemode(PAYMODE)

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

#undef IDLEMODE
#undef PAYMODE
#undef ACCOUNTMODE
#undef ENTERPIN
