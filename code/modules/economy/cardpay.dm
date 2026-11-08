#define CARDPAY_IDLEMODE "Mode_Idle"
#define CARDPAY_PAYMODE "Mode_Pay"
#define CARDPAY_REFUNDMODE "Mode_Refund"
#define CARDPAY_ACCOUNTMODE "Mode_Account"
#define CARDPAY_ENTERPINMODE "Mode_EnterPin"

/obj/item/device/cardpay
	name = "Card pay device"
	desc = "Совершайте покупки простым движением карты."
	icon = 'icons/obj/cardpay_devices.dmi'
	icon_state = "card-pay-idle"

	slot_flags = SLOT_FLAGS_BELT
	m_amt = 7000
	g_amt = 2000

	layer = DEFAULT_MACHINERY_LAYER //Хотим чтобы предметы на столе были всегда выше терминала.

	var/linked_account = 0
	var/pay_amount = 0
	var/display_numbers = 0
	var/ram_account = 0
	var/reset = FALSE
	var/noResetChange = FALSE

	var/image/holoprice

	var/mode = CARDPAY_ACCOUNTMODE
	var/prevmode = CARDPAY_IDLEMODE

	var/basic_icon_state = "card-pay"

/obj/item/device/cardpay/atom_init(mapload)
	. = ..()
	AddComponent(/datum/component/wrench_to_table, CALLBACK(src, PROC_REF(on_wrenched)), CALLBACK(src, PROC_REF(on_unwrenched)))

	holoprice = image('icons/effects/32x32.dmi', "blank")
	holoprice.layer = INDICATOR_LAYER

	holoprice.maptext_y = 5
	holoprice.maptext_width = 40
	holoprice.maptext_x = -4

	add_overlay(holoprice)

/obj/item/device/cardpay/proc/on_wrenched()
	return

/obj/item/device/cardpay/proc/on_unwrenched()
	SStgui.close_uis(src)
	reset_anything()

/obj/item/device/cardpay/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		visible_message("<span class='info'>[usr] прикладывает карту к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I
		switch(mode)
			if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
				display_numbers = Card.associated_account_number
				pay_with_account()
			if(CARDPAY_ACCOUNTMODE)
				display_numbers = Card.associated_account_number
				set_account()

	else if(istype(I, /obj/item/device/pda) && I.GetID())
		visible_message("<span class='info'>[usr] прикладывает кпк к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/card/id/Card = I.GetID()
		switch(mode)
			if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
				display_numbers = Card.associated_account_number
				pay_with_account()
			if(CARDPAY_ACCOUNTMODE)
				display_numbers = Card.associated_account_number
				set_account()

	else if(istype(I, /obj/item/weapon/ewallet))
		visible_message("<span class='info'>[usr] прикладывает чип к терминалу.</span>")
		user.SetNextMove(CLICK_CD_INTERACT)
		var/obj/item/weapon/ewallet/Wallet = I
		switch(mode)
			if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
				display_numbers = Wallet.account_number
				pay_with_account()
			if(CARDPAY_ACCOUNTMODE)
				display_numbers = Wallet.account_number
				set_account()
	else
		return ..()

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
	data["noReset"] = noResetChange
	data["mode"] = mode
	return data

/obj/item/device/cardpay/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("pressnumber")
			var/num = text2num(params["number"])
			if(isnum(num))
				press_number(num)
				playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
				return TRUE

		if("clearnumbers")
			clear_numbers()
			playsound(src, 'sound/items/buttonclick.ogg', VOL_EFFECTS_MASTER)
			return TRUE

		if("approveprice")
			approve()
			return TRUE

		if("togglereset")
			if(noResetChange)
				return
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
		if(CARDPAY_IDLEMODE)
			if(display_numbers > 999)
				display_numbers %= 1000

		if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
			if(display_numbers > 999999)
				display_numbers %= 1000000

		if(CARDPAY_ACCOUNTMODE)
			if(display_numbers > 999999)
				display_numbers %= 1000000

		if(CARDPAY_ENTERPINMODE)
			if(display_numbers > 99999)
				display_numbers %= 100000

/obj/item/device/cardpay/proc/clear_numbers()
	switch(mode)
		if(CARDPAY_IDLEMODE)
			EMPTY_BLOCK_GUARD
		if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
			if(!display_numbers)
				pay_amount = 0
				update_holoprice(clear = TRUE)
				changemode(CARDPAY_IDLEMODE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена транзакции.</span>")
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				flick("[basic_icon_state]-error", src)

		if(CARDPAY_ACCOUNTMODE)
			if(!display_numbers)
				changemode(CARDPAY_IDLEMODE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена ввода счёта.</span>")
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				flick("[basic_icon_state]-error", src)

		if(CARDPAY_ENTERPINMODE)
			if(!display_numbers)
				update_holoprice(clear = TRUE)
				changemode(CARDPAY_IDLEMODE)
				visible_message("[bicon(src)] [name] <span class='warning'>Отмена ввода пинкода.</span>")
				playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
				flick("[basic_icon_state]-error", src)

	display_numbers = 0

/obj/item/device/cardpay/proc/approve()
	switch(mode)
		if(CARDPAY_IDLEMODE)
			if(!display_numbers)
				return
			if(!linked_account)
				visible_message("[bicon(src)] [name] <span class='warning'>Нет подключённого счёта.</span>")
				flick("[basic_icon_state]-error", src)
				return
			var/datum/money_account/Acc = get_account(linked_account)
			if(!Acc || Acc.suspended)
				visible_message("[bicon(src)] [name] <span class='warning'>Подключённый счёт заблокирован.</span>")
				flick("[basic_icon_state]-error", src)
				return
			pay_amount = display_numbers
			update_holoprice(clear = FALSE)
			changemode(CARDPAY_PAYMODE)

		if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
			if(!display_numbers)
				return
			pay_with_account()

		if(CARDPAY_ACCOUNTMODE)
			if(!display_numbers)
				return
			set_account()

		if(CARDPAY_ENTERPINMODE)
			if(!display_numbers)
				return
			switch(prevmode)
				if(CARDPAY_PAYMODE)
					var/datum/money_account/Acc = get_account(ram_account)
					if(!Acc || Acc.suspended)
						visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
						flick("[basic_icon_state]-error", src)
						return
					Acc = attempt_account_access(ram_account, display_numbers, 2)
					if(!Acc)
						visible_message("[bicon(src)] [name] <span class='warning'>Невозможно оплатить с этого счёта.</span>")
						flick("[basic_icon_state]-error", src)
						return
					make_transaction(Acc, pay_amount)

				if(CARDPAY_ACCOUNTMODE)
					var/datum/money_account/Acc = get_account(linked_account)
					if(!Acc || Acc.suspended)
						visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
						flick("[basic_icon_state]-error", src)
						linked_account = 0
						reset_anything()
						return
					if(Acc.remote_access_pin == display_numbers)
						linked_account = 0
						changemode(CARDPAY_ACCOUNTMODE)
					else
						visible_message("[bicon(src)] [name] <span class='warning'>Неверный пинкод.</span>")
						flick("[basic_icon_state]-error", src)

				else
					reset_anything()
					return

/obj/item/device/cardpay/proc/set_account()
	var/datum/money_account/Acc = get_account(display_numbers)
	if(!Acc || Acc.suspended)
		visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
		flick("[basic_icon_state]-error", src)
		return
	linked_account = display_numbers
	visible_message("[bicon(src)] [name] <span class='notice'>Счёт подключён.</span>")
	flick("[basic_icon_state]-complete", src)
	playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
	changemode(CARDPAY_IDLEMODE)

/obj/item/device/cardpay/proc/pay_with_account()
	var/datum/money_account/Acc = get_account(display_numbers)
	if(!Acc || Acc.suspended)
		visible_message("[bicon(src)] [name] <span class='warning'>Счёт заблокирован.</span>")
		flick("[basic_icon_state]-error", src)
		return

	switch(mode)
		if(CARDPAY_PAYMODE)
			if(usr.mind.get_key_memory(MEM_ACCOUNT_PIN) == Acc.remote_access_pin || Acc.security_level == 0)
				make_transaction(Acc, pay_amount)
				return
			else
				ram_account = display_numbers
				changemode(CARDPAY_ENTERPINMODE)
		if(CARDPAY_REFUNDMODE)
			make_refund(Acc, pay_amount)

/obj/item/device/cardpay/proc/enter_account()
	switch(mode)
		if(CARDPAY_IDLEMODE)
			changemode(CARDPAY_ACCOUNTMODE)
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
				changemode(CARDPAY_ENTERPINMODE)
		if(CARDPAY_PAYMODE, CARDPAY_REFUNDMODE)
			return
		if(CARDPAY_ACCOUNTMODE)
			changemode(CARDPAY_IDLEMODE)
		if(CARDPAY_ENTERPINMODE)
			return

	playsound(src, 'sound/items/buttonswitch.ogg', VOL_EFFECTS_MASTER)

/obj/item/device/cardpay/proc/changemode(newmode)
	prevmode = mode
	mode = newmode
	display_numbers = 0

	switch(newmode)
		if(CARDPAY_IDLEMODE)
			icon_state = "[basic_icon_state]-idle"
		if(CARDPAY_ENTERPINMODE)
			icon_state = "[basic_icon_state]-processing"

/obj/item/device/cardpay/proc/reset_anything()
	mode = CARDPAY_IDLEMODE
	prevmode = CARDPAY_IDLEMODE
	if(!noResetChange)
		reset = FALSE
	display_numbers = 0
	pay_amount = 0
	update_holoprice(clear = TRUE)

/obj/item/device/cardpay/proc/make_transaction(datum/money_account/Acc, amount)
	if(amount > Acc.money)
		visible_message("[bicon(src)] [name] <span class='warning'>Недостаточно средств!</span>")
		flick("[basic_icon_state]-error", src)
		return FALSE

	icon_state = "[basic_icon_state]-idle"
	visible_message("[bicon(src)] [name] <span class='notice'>Оплата прошла успешно.</span>")
	flick("[basic_icon_state]-complete", src)
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)

	var/datum/money_account/D = get_account(linked_account)
	charge_to_account(Acc.account_number, "Терминал оплаты [D.owner_name] ([D.account_number])", "Оплата", src.name, -amount)
	charge_to_account(linked_account, "Терминал оплаты [D.owner_name] ([D.account_number])", "Прибыль", src.name, amount)

	if(reset)
		pay_amount = 0
		update_holoprice(clear = TRUE)
		changemode(CARDPAY_IDLEMODE)
	else
		changemode(CARDPAY_PAYMODE)

	return TRUE

/obj/item/device/cardpay/proc/make_refund(datum/money_account/Acc, amount)
	var/datum/money_account/D = get_account(linked_account)
	if(amount > D.money)
		visible_message("[bicon(src)] [name] <span class='warning'>Недостаточно средств!</span>")
		flick("[basic_icon_state]-error", src)
		return

	icon_state = "[basic_icon_state]-idle"
	visible_message("[bicon(src)] [name] <span class='notice'>Возврат средств прошёл успешно.</span>")
	flick("[basic_icon_state]-complete", src)
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)

	charge_to_account(Acc.account_number, "Терминал оплаты [D.owner_name] ([D.account_number])", "Возврат", src.name, amount)
	charge_to_account(linked_account, "Терминал оплаты [D.owner_name] ([D.account_number])", "Возврат", src.name, -amount)

	if(reset)
		pay_amount = 0
		update_holoprice(clear = TRUE)
		changemode(CARDPAY_IDLEMODE)
	else
		changemode(CARDPAY_REFUNDMODE)

/obj/item/device/cardpay/proc/update_holoprice(clear, custom_text = null)
	cut_overlay(holoprice)

	var/show_text = custom_text ? custom_text : "[pay_amount]$"
	if(clear)
		holoprice.maptext = ""
		holoprice.icon = 'icons/effects/32x32.dmi'
		holoprice.icon_state = "blank"
	else
		holoprice.maptext = {"<div style="font-size:9pt;color:#22DD22;font:'Small Fonts';text-align:center;-dm-text-outline: 1px black;" valign="top">[show_text]</div>"}
		holoprice.icon = 'icons/obj/cardpay_devices.dmi'
		holoprice.icon_state = "holo_overlay_[length(num2text(show_text))]"
	add_overlay(holoprice)





/obj/item/device/cardpay/casino
	name = "caps dealer"
	desc = "Обменник денег на фишки и наоборот."

	icon_state = "caps_dealer-idle"

	density = TRUE

	basic_icon_state = "caps_dealer"

	w_class = SIZE_LARGE

	reset = TRUE
	noResetChange = TRUE

/obj/item/device/cardpay/casino/atom_init(mapload)
	. = ..()

	holoprice.pixel_x = 9
	holoprice.pixel_y = 5

/obj/item/device/cardpay/casino/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/caps))
		var/datum/money_account/D = get_account(linked_account)
		if(!D)
			return

		var/obj/item/toy/caps/Caps = I
		var/toReturn = min(D.money, Caps.capsAmount)

		pay_amount = toReturn
		update_holoprice(clear = FALSE)
		changemode(CARDPAY_REFUNDMODE)

		if(Caps.capsAmount == toReturn)
			qdel(Caps)
		else
			Caps.capsAmount -= toReturn
	else
		return ..()

/obj/item/device/cardpay/casino/make_transaction(datum/money_account/Acc, amount)
	if(amount > Acc.money)
		visible_message("[bicon(src)] [name] <span class='warning'>Недостаточно средств!</span>")
		flick("[basic_icon_state]-error", src)
		return FALSE

	icon_state = "[basic_icon_state]-idle"
	visible_message("[bicon(src)] [name] <span class='notice'>Оплата прошла успешно.</span>")
	flick("[basic_icon_state]-complete", src)
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)

	var/datum/money_account/D = get_account(linked_account)
	charge_to_account(Acc.account_number, "Обменник фишек [D.owner_name] ([D.account_number])", "Оплата", src.name, -amount)
	charge_to_account(linked_account, "Обменник фишек [D.owner_name] ([D.account_number])", "Прибыль", src.name, amount)

	new /obj/item/toy/caps(get_turf(src), amount)

	pay_amount = 0
	update_holoprice(clear = TRUE)
	changemode(CARDPAY_IDLEMODE)

	return TRUE



/obj/item/device/cardpay/menu_customer
	name = "menu"
	desc = "Электронное меню."

	icon_state = "menu_customer"

	density = TRUE

	basic_icon_state = "menu_customer"

	w_class = SIZE_LARGE

	reset = TRUE
	noResetChange = TRUE

	mode = CARDPAY_IDLEMODE

	var/obj/item/device/menu_chef/chef
	var/list/items_to_order = list()

	var/payment_timer

/obj/item/device/cardpay/menu_customer/atom_init(mapload)
	. = ..()

	holoprice.pixel_x = -1
	holoprice.pixel_y = 3

/obj/item/device/cardpay/menu_customer/Destroy()
	if(chef)
		disconnect_from_terminal(chef)

	return ..()

/obj/item/device/cardpay/menu_customer/on_wrenched()
	if(chef)
		icon_state = "[basic_icon_state]-idle"
		update_holoprice(custom_text = "№[chef.customer_menus.Find(src)]")

/obj/item/device/cardpay/menu_customer/on_unwrenched()
	..()
	icon_state = basic_icon_state

/obj/item/device/cardpay/menu_customer/set_account()
	return

/obj/item/device/cardpay/menu_customer/enter_account()
	return

/obj/item/device/cardpay/menu_customer/make_refund(datum/money_account/Acc, amount)
	return

/obj/item/device/cardpay/menu_customer/make_transaction(datum/money_account/Acc, amount)
	. = ..()

	if(.)
		chef.add_order(items_to_order, chef.customer_menus.Find(src))
		items_to_order = list()
		pay_amount = 0

	deltimer(payment_timer)
	payment_timer = 0

	update_holoprice(custom_text = "№[chef.customer_menus.Find(src)]")

/obj/item/device/cardpay/menu_customer/proc/cancel_order()
	mode = CARDPAY_IDLEMODE
	pay_amount = 0
	if(chef)
		update_holoprice(custom_text = "№[chef.customer_menus.Find(src)]")
	else
		update_holoprice(clear = TRUE)

	visible_message("[bicon(src)] [name] <span class='notice'>Отмена покупки.</span>")

	icon_state = "[basic_icon_state]-idle"

	payment_timer = 0

/obj/item/device/cardpay/menu_customer/tgui_interact(mob/user, datum/tgui/ui)
	if(!chef)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Menu_Customer", "Терминал")
		ui.open()

/obj/item/device/cardpay/menu_customer/tgui_data(mob/user)
	var/list/data = list()

	data["mode"] = mode
	data["menu"] = chef?.menu_items
	data["items_to_order"] = items_to_order

	data["payment_timer"] = timeleft(payment_timer)

	return data

/obj/item/device/cardpay/menu_customer/tgui_act(action, params)
	. = ..()
	if(.)
		return

	flick("[basic_icon_state]-scroll", src)
	playsound(src, pick(SOUNDIN_PDA_TAPS), VOL_EFFECTS_MASTER, 15, FALSE)

	if(!chef)
		return

	switch(action)
		if("add_to_orders")
			var/item_name = params["item_name"]
			if(!item_name || !istext(item_name))
				return

			if(!items_to_order[item_name])
				items_to_order[item_name] = 1
			else
				items_to_order[item_name]++

			return TRUE

		if("remove_from_oders")
			var/item_name = params["item_name"]
			if(!item_name || !istext(item_name))
				return

			if(!items_to_order[item_name])
				return

			items_to_order[item_name]--

			if(items_to_order[item_name] == 0)
				items_to_order -= item_name

			return TRUE

		if("order")
			if(payment_timer)
				return

			var/datum/money_account/D = get_account(chef.linked_account)
			if(!D)
				visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
				return

			if(!(items_to_order.len))
				return

			pay_amount = 0
			for(var/item in items_to_order)
				pay_amount += (chef.menu_items[item] * items_to_order[item])

			mode = CARDPAY_PAYMODE
			update_holoprice()

			icon_state = "[basic_icon_state]-processing"

			payment_timer = addtimer(CALLBACK(src, PROC_REF(cancel_order)), 15 SECONDS, TIMER_STOPPABLE)

			return TRUE

		if("enterpin")
			var/pin = text2num(params["pin"])
			if(!pin || !isnum(pin))
				return

			display_numbers = pin
			approve()
			return TRUE


/obj/item/device/cardpay/menu_customer/proc/connect_to_terminal(obj/item/device/menu_chef/terminal)
	if(chef)
		chef.customer_menus -= src

	chef = terminal
	linked_account = chef.linked_account
	chef.customer_menus += src

	update_holoprice(custom_text = "№[chef.customer_menus.Find(src)]")

	icon_state = "[basic_icon_state]-idle"

/obj/item/device/cardpay/menu_customer/proc/disconnect_from_terminal(obj/item/device/menu_chef/terminal)
	if(chef)
		chef.customer_menus -= src
		chef = null
	linked_account = 0
	update_holoprice(clear = TRUE)

	items_to_order = list()

	icon_state = basic_icon_state


#define CARDPAY_ORDERSMODE "Mode_Orders"

/obj/item/device/menu_chef
	name = "Menu management device"
	desc = "Терминал для изменения электронного меню и просмотра рецептов."
	icon = 'icons/obj/cardpay_devices.dmi'
	icon_state = "menu_chef"

	w_class = SIZE_LARGE
	m_amt = 25000
	g_amt = 5000

	layer = DEFAULT_MACHINERY_LAYER //Хотим чтобы предметы на столе были всегда выше терминала.

	var/linked_account = 0

	var/list/customer_menus = list()
	var/list/menu_items = list()

	var/list/orders = list()
	var/neworders = 0

	var/ordernum = 1

/obj/item/device/menu_chef/atom_init(mapload)
	. = ..()
	AddComponent(/datum/component/wrench_to_table, CALLBACK(src, PROC_REF(on_wrenched)), CALLBACK(src, PROC_REF(on_unwrenched)))

/obj/item/device/menu_chef/Destroy()
	for(var/obj/item/device/cardpay/menu_customer/menu)
		menu.disconnect_from_terminal(src)

	return ..()

/obj/item/device/menu_chef/proc/on_wrenched()
	icon_state = "menu_chef-idle"

/obj/item/device/menu_chef/proc/on_unwrenched()
	SStgui.close_uis(src)

	for(var/obj/item/device/cardpay/menu_customer/menu)
		menu.disconnect_from_terminal(src)

	icon_state = "menu_chef"

/obj/item/device/menu_chef/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/cardpay/menu_customer) && !(I in customer_menus))
		var/obj/item/device/cardpay/menu_customer/menu = I

		menu.connect_to_terminal(src)

		visible_message("<span class='info'>Меню подключено к терминалу.</span>")
		return

	return ..()

/obj/item/device/menu_chef/attack_hand(mob/user)
	. = ..()
	if(!isturf(loc))
		return

	tgui_interact(user)

/obj/item/device/menu_chef/examine(mob/user)
	. = ..()
	if(linked_account)
		var/datum/money_account/Acc = get_account(linked_account)
		if(Acc)
			to_chat(user, "Принадлежит [Acc.owner_name] ([Acc.account_number])")

/obj/item/device/menu_chef/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Menu_Chef", "Терминал")
		ui.open()

/obj/item/device/menu_chef/tgui_static_data(mob/user)
	return list("recipes_list" = recipes_for_menu)

/obj/item/device/menu_chef/tgui_data(mob/user)
	var/list/data = list()

	data["linked_account"] = linked_account
	data["customer_menus"] = customer_menus.len
	data["menu_items"] = menu_items
	data["orders"] = orders
	data["neworders"] = neworders

	return data

/obj/item/device/menu_chef/tgui_act(action, params)
	. = ..()
	if(.)
		return

	flick("menu_chef-scroll", src)
	playsound(src, pick(SOUNDIN_PDA_TAPS), VOL_EFFECTS_MASTER, 15, FALSE)

	switch(action)
		if("add_to_menu")
			var/item_name = params["item_name"]

			if(!item_name || !istext(item_name))
				return

			if(!isnull(menu_items[item_name]))
				menu_items -= item_name
				for(var/obj/item/device/cardpay/menu_customer/cust in customer_menus)
					cust.items_to_order -= item_name
			else
				menu_items[item_name] = 0

			return TRUE

		if("change_price")
			var/item_name = params["item_name"]
			var/price = text2num(params["item_price"])

			if(!item_name || !istext(item_name) || !price || !isnum(price))
				return

			menu_items[item_name] = price

			return TRUE

		if("new_account_number")
			var/account_number = text2num(params["number"])
			if(!account_number || !isnum(account_number))
				return

			var/datum/money_account/D = get_account(account_number)
			if(!D)
				visible_message("[bicon(src)] [name] <span class='warning'>Счёта не существует.</span>")
				return

			visible_message("[bicon(src)] [name] <span class='notice'>Счёт подключён.</span>")
			playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
			linked_account = account_number
			update_customer_menus()

			return TRUE

		if("delete_order")
			var/order_id = text2num(params["order_id"])
			if(!order_id || !isnum(order_id))
				return

			for(var/list/order in orders)
				if(order["id"] != order_id)
					continue

				orders -= list(order)
			return TRUE

		if("orders_opened")
			neworders = 0
			return TRUE

/obj/item/device/menu_chef/proc/update_customer_menus()
	for(var/obj/item/device/cardpay/menu_customer/menu in customer_menus)
		menu.linked_account = linked_account

/obj/item/device/menu_chef/proc/add_order(list/order, number)
	orders += list(list("table" = number, "order" = order, "id" = ordernum))
	ordernum++

	flick("menu_chef-order", src)
	visible_message("[bicon(src)] [name] <span class='notice'>Новый заказ!</span>")
	playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)

	var/obj/item/I = new /obj/item/weapon/card/ticket(loc, number)
	I.pixel_x = rand(-5, 5)
	I.pixel_y = rand(-5, 5)

	neworders++

#undef CARDPAY_IDLEMODE
#undef CARDPAY_PAYMODE
#undef CARDPAY_REFUNDMODE
#undef CARDPAY_ACCOUNTMODE
#undef CARDPAY_ENTERPINMODE
