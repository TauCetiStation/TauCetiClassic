/obj/item/device/cardpay
	name = "Card pay device"
	desc = "Scan your ID card to make purchases electronically."
	icon = 'icons/obj/device.dmi'
	icon_state = "card-pay-idle"

	slot_flags = SLOT_FLAGS_BELT
	m_amt = 7000
	g_amt = 2000

	var/datum/money_account/linked_account
	var/pay_amount = 0
	var/reset = TRUE

/obj/item/device/cardpay/atom_init(mapload)
	. = ..()

	if(mapload && locate(/obj/structure/table, get_turf(src)))
		anchored = TRUE

/obj/item/device/cardpay/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		if(src.loc == user)
			var/obj/item/weapon/card/id/Card = I
			var/datum/money_account/D = get_account(Card.associated_account_number)
			if(D)
				linked_account = D
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
	visible_message("<span class='info'>[usr] waves a card through [src].</span>")
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
		addtimer(CALLBACK(src, .proc/make_transaction, D, pay_amount), 3 SECONDS)

/obj/item/device/cardpay/proc/make_transaction(datum/money_account/Acc, amount)
	icon_state = "card-pay-idle"
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	if(amount <= Acc.money)
		flick("card-pay-complete", src)
		if(amount > 0)
			charge_to_account(Acc.account_number, "Терминал оплаты", "Оплата", src.name, -amount)
			charge_to_account(linked_account.account_number, "Терминал оплаты", "Прибыль", src.name, amount)
		if(reset)
			amount = 0
	else
		visible_message("[bicon(src)]<span class='warning'>Недостаточно средств!</span>")
		flick("card-pay-error", src)
