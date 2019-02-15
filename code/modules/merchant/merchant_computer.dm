/obj/machinery/merchant_pad
	name = "Teleportation Pad"
	desc = "Place things here to trade."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "tele0"
	anchored = 1
	density = 0

/obj/machinery/merchant_pad/proc/get_target()
	var/turf/T = get_turf(src)
	for(var/a in T)
		if(a == src || (!istype(a,/obj) && !istype(a,/mob/living)) || istype(a,/obj/effect))
			continue
		return a

/obj/machinery/merchant_pad/proc/get_targets()
	. = list()
	var/turf/T = get_turf(src)
	for(var/a in T)
		if(a == src || (!istype(a,/obj) && !istype(a,/mob/living)) || istype(a,/obj/effect))
			continue
		. += a

/obj/machinery/computer/merchant
	name = "Merchant computer"
	desc = "Allows communication and trade between passing vessels, even while jumping."
	icon_state = "crew"
	light_color = "#315ab4"
	var/obj/machinery/merchant_pad/pad = null
	var/current_merchant = 0
	var/show_trades = 0
	var/hailed_merchant = 0
	var/last_comms = null
	var/temp = null
	var/bank = 0 //A straight up money till

/obj/machinery/computer/merchant/atom_init()
	. = ..()

/obj/machinery/computer/merchant/proc/get_merchant(var/num)
	if(num > SStrade.traders.len)
		num = SStrade.traders.len
	if(num)
		return SStrade.traders[num]

/obj/machinery/computer/merchant/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)
	var/show_trade = 0
	var/datum/trader/T
	var/hailed = 0

	var/data[0]
	data["temp"] = temp
	data["mode"] = !!current_merchant
	data["last_comms"] = last_comms
	data["pad"] = !!pad
	data["bank"] = bank
	show_trade = show_trades
	hailed = hailed_merchant
	T = get_merchant(current_merchant)
	data["mode"] = !!T
	data["trades"] = null
	data["traderName"] = null
	data["origin"] = null
	data["hailed"] = null

	if(T)
		data["traderName"] = T.name
		data["origin"]     = T.origin
		data["hailed"]     = hailed
		if(show_trade)
			var/list/trades[0]
			if(T.trading_items.len)
				for(var/i in 1 to T.trading_items.len)
					trades.Add(list(list("name" = (T.print_trading_items(i)))))
			data["trades"] = trades

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "merchant.tmpl", "Merchant List", 575, 700)
		ui.set_initial_data(data)

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)
		//ui.set_auto_update_layout(1)

		ui.open()

/obj/machinery/computer/merchant/attackby(I, user)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		var/obj/item/weapon/card/emag/emag = I
		emag.uses--
		to_chat(user, "You disable the safety lock.")
		emagged = 1
	else
		..()

/obj/machinery/computer/merchant/proc/connect_pad()
	for(var/obj/machinery/merchant_pad/P in orange(1,get_turf(src)))
		pad = P
		return

/obj/machinery/computer/merchant/proc/test_fire()
	if(pad && pad.get_target())
		return TRUE
	return FALSE

/obj/machinery/computer/merchant/proc/offer_money(datum/trader/T, num)
	if(pad)
		var/response = T.offer_money_for_trade(num, bank)
		if(istext(response))
			last_comms = T.get_response(response, "No thank you.")
		else
			last_comms = T.get_response("trade_complete", "Thank you!")
			T.trade(null,num, get_turf(pad))
			bank -= response
		return
	last_comms = "PAD NOT CONNECTED"

/obj/machinery/computer/merchant/proc/bribe(datum/trader/T, amt)
	if(bank < amt)
		last_comms = "ERROR: NOT ENOUGH FUNDS."
		return

	bank -= amt
	last_comms = T.bribe_to_stay_longer(amt)

/obj/machinery/computer/merchant/proc/offer_item(datum/trader/T, num)
	if(pad)
		var/list/targets = pad.get_targets()
		for(var/target in targets)
			if(!emagged && ishuman(target))
				last_comms = "SAFETY LOCK ENABLED: SENTIENT MATTER UNTRANSMITTABLE"
				return
		var/response = T.offer_items_for_trade(targets,num, get_turf(pad))
		if(istext(response))
			last_comms = T.get_response(response,"No, a million times no.")
		else
			last_comms = T.get_response("trade_complete","Thanks for your business!")

		return
	last_comms = "PAD NOT CONNECTED"

/obj/machinery/computer/merchant/proc/sell_items(datum/trader/T)
	if(pad)
		var/list/targets = pad.get_targets()
		var/response = T.sell_items(targets)
		if(istext(response))
			last_comms = T.get_response(response, "Nope. Nope nope nope.")
		else
			last_comms = T.get_response("trade_complete", "Glad to be of service!")
			bank += response
		return
	last_comms = "PAD NOT CONNECTED"

/obj/machinery/computer/merchant/proc/get_money()
	if(!pad)
		last_comms = "PAD NOT CONNECTED. CANNOT TRANSFER"
		return
	var/turf/T = get_turf(pad)
	spawn_money(bank, T)
	bank = 0

/obj/machinery/computer/merchant/proc/transfer_to_bank()
	if(pad)
		var/list/targets = pad.get_targets()
		for(var/target in targets)
			if(istype(target, /obj/item/weapon/spacecash))
				var/obj/item/weapon/spacecash/cash = target
				bank += cash.worth
				qdel(target)
		last_comms = "ALL MONEY DETECTED ON PAD TRANSFERED"
		return
	last_comms = "PAD NOT CONNECTED"

/obj/machinery/computer/merchant/Topic(href, href_list)
	var/mob/user = usr
	if(href_list["PRG_connect_pad"])
		. = 1
		connect_pad()
	if(href_list["PRG_continue"])
		. = 1
		temp = null
	if(href_list["PRG_transfer_to_bank"])
		. = 1
		transfer_to_bank()
	if(href_list["PRG_get_money"])
		. = 1
		get_money()
	if(href_list["PRG_main_menu"])
		. = 1
		current_merchant = 0
	if(href_list["PRG_merchant_list"])
		if(SStrade.traders.len == 0)
			. = 0
			temp = "Cannot find any traders within broadcasting range."
		else
			. = 1
			current_merchant = 1
			hailed_merchant = 0
			last_comms = null
	if(href_list["PRG_test_fire"])
		. = 1
		if(test_fire())
			temp = "Test Fire Successful"
		else
			temp = "Test Fire Unsuccessful"
	if(href_list["PRG_scroll"])
		. = 1
		var/scrolled = 0
		switch(href_list["PRG_scroll"])
			if("right")
				scrolled = 1
			if("left")
				scrolled = -1
		var/new_merchant  = Clamp(current_merchant + scrolled, 1, SStrade.traders.len)
		if(new_merchant != current_merchant)
			hailed_merchant = 0
			last_comms = null
		current_merchant = new_merchant
	if(current_merchant)
		var/datum/trader/T = get_merchant(current_merchant)
		if(!T.can_hail())
			last_comms = T.get_response("hail_deny", "No, I'm not speaking with you.")
			. = 1
		else
			if(href_list["PRG_hail"])
				. = 1
				last_comms = T.hail(user)
				show_trades = 0
				hailed_merchant = 1
			if(href_list["PRG_show_trades"])
				. = 1
				show_trades = !show_trades
			if(href_list["PRG_insult"])
				. = 1
				last_comms = T.insult()
			if(href_list["PRG_compliment"])
				. = 1
				last_comms = T.compliment()
			if(href_list["PRG_offer_item"])
				. = 1
				offer_item(T,text2num(href_list["PRG_offer_item"]) + 1)
			if(href_list["PRG_how_much_do_you_want"])
				. = 1
				last_comms = T.how_much_do_you_want(text2num(href_list["PRG_how_much_do_you_want"]) + 1)
			if(href_list["PRG_offer_money_for_item"])
				. = 1
				offer_money(T, text2num(href_list["PRG_offer_money_for_item"])+1)
			if(href_list["PRG_what_do_you_want"])
				. = 1
				last_comms = T.what_do_you_want()
			if(href_list["PRG_sell_items"])
				. = 1
				sell_items(T)
			if(href_list["PRG_bribe"])
				. = 1
				bribe(T, text2num(href_list["PRG_bribe"]))