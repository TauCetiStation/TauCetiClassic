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
	var/reset = FALSE
	var/enter_account = FALSE

	var/paying = FALSE

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
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!enter_account)
			var/obj/item/weapon/card/id/Card = I
			pay_with_account(get_account(Card.associated_account_number))
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
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I.GetID()
		pay_with_account(get_account(Card.associated_account_number))
	else if(istype(I, /obj/item/weapon/ewallet))
		var/obj/item/weapon/ewallet/Wallet = I
		visible_message("<span class='info'>[usr] прикладывает чип оплаты к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		if(!enter_account)
			pay_with_account(get_account(Wallet.account_number))
			return
		if(!get_account(Wallet.account_number))
			to_chat(user, "<span class='notice'>Нет аккаунта, привязанного к чипу.</span>")
			return
		linked_account = Wallet.account_number
		playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>Аккаунт подключён.</span>")
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
				RegisterSignal(Table, list(COMSIG_PARENT_QDELETING), PROC_REF(unwrench))
				return
			to_chat(user, "<span class='notice'>Сканер откручен.</span>")
			anchored = FALSE
			UnregisterSignal(Table, list(COMSIG_PARENT_QDELETING))
			pay_amount = 0
			paying = FALSE
			update_holoprice(clear = TRUE)
			SStgui.close_uis(src)
	else
		return ..()

/obj/item/device/cardpay/proc/unwrench()
	anchored = FALSE

/obj/item/device/cardpay/attack_self(mob/living/user)
	. = ..()

	set_dir(turn(dir,-90))

/obj/item/device/cardpay/proc/pay_with_account(datum/money_account/D)
	if(!linked_account)
		visible_message("[bicon(src)] [name] <span class='warning'>Нет подключённого аккаунта.</span>")
		return
	var/datum/money_account/Acc = get_account(linked_account)
	if(!Acc || Acc.suspended)
		visible_message("[bicon(src)] [name] <span class='warning'>Подключённый аккаунт заблокирован.</span>")
		return
	if(pay_amount <= 0)
		return

	if(paying)
		return

	var/pay_holder = pay_amount

	if(!D)
		return

	if(!check_pincode(D))
		return
	if(pay_holder != pay_amount)
		to_chat(usr, "[bicon(src)] [name] <span class='warning'>Сумма оплаты изменена!</span>")
		return FALSE
	if(Acc != get_account(linked_account))
		to_chat(usr, "[bicon(src)] [name] <span class='warning'>Подключённый аккаунт изменён!</span>")
		return FALSE

	icon_state = "card-pay-processing"

	paying = TRUE

	addtimer(CALLBACK(src, PROC_REF(make_transaction), D, pay_holder), 3 SECONDS)

/obj/item/device/cardpay/proc/check_pincode(datum/money_account/Acc)
    var/time_for_pin = world.time
    Acc = attempt_account_access_with_user_input(Acc.account_number, ACCOUNT_SECURITY_LEVEL_MAXIMUM, usr)
    if(usr.incapacitated() || !Adjacent(usr))
        return FALSE
    if(world.time - time_for_pin > 300)
        to_chat(usr, "[bicon(src)] [name] <span class='warning'>Время операции истекло!</span>")
        return FALSE
    if(!Acc)
        to_chat(usr, "[bicon(src)] [name] <span class='warning'>Неверный ПИН-код!</span>")
        return FALSE
		
    return TRUE

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
	var/datum/money_account/D = get_account(linked_account)
	charge_to_account(Acc.account_number, "Терминал оплаты [D.owner_name] ([D.account_number])", "Оплата", src.name, -amount)
	charge_to_account(linked_account, "Терминал оплаты [D.owner_name] ([D.account_number])", "Прибыль", src.name, amount)

	paying = FALSE

	if(reset)
		pay_amount = 0
		update_holoprice(clear = TRUE)

/obj/item/device/cardpay/attack_hand(mob/user)
	. = ..()
	if(!isturf(loc))
		return

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
	data["pay_amount"] = pay_amount
	return data

/obj/item/device/cardpay/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("pressnumber")
			var/num = params["number"]
			if(isnum(num))
				num = clamp(num, 0, 9)
				display_numbers *= 10
				display_numbers += num
				if((enter_account || (pay_amount > 0)))
					if(display_numbers > 999999)
						display_numbers %= 1000000
				else if(display_numbers > 999)
					display_numbers %= 1000
				playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
				return TRUE
		if("clearnumbers")
			if(display_numbers == 0)
				pay_amount = 0
				update_holoprice(clear = TRUE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена транзакции.</span>")
			display_numbers = 0
			playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
			return TRUE
		if("approveprice")
			if(display_numbers > 0)
				if(enter_account || (pay_amount > 0))
					if(display_numbers >= 111111 && display_numbers <= 999999)
						var/datum/money_account/D = get_account(display_numbers)
						if(D)
							if(enter_account)
								linked_account = display_numbers
								to_chat(usr, "<span class='notice'>Аккаунт подключён.</span>")
								enter_account = FALSE
							else
								pay_with_account(D)
						else
							visible_message("[bicon(src)] [name] <span class='warning'>Номер аккаунта не существует.</span>")
				else
					if(!linked_account)
						visible_message("[bicon(src)] [name] <span class='warning'>Нет подключённого аккаунта.</span>")
						return
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
			if(enter_account)
				to_chat(usr, "<span class='notice'>Включён режим ввода цены.</span>")
			else if(linked_account && get_account(linked_account))
				if(!check_pincode(get_account(linked_account)))
					return
				to_chat(usr, "<span class='notice'>Включён режим ввода аккаунта.</span>")

			display_numbers = 0
			enter_account = !enter_account

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
		holoprice.icon_state = "holo_overlay_[length(num2text(pay_amount))]"
	add_overlay(holoprice)

/obj/item/device/cardpay/examine(mob/user)
	. = ..()
	if(linked_account)
		var/datum/money_account/Acc = get_account(linked_account)
		if(Acc)
			to_chat(user, "Принадлежит [Acc.owner_name] ([Acc.account_number])")
