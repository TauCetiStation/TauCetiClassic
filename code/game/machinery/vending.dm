/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/amount = 0
	var/max_amount = 0
	var/price = 0

/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/vending.dmi'
	icon_state = "generic"

	var/subname = null // subname for vendor's circuit name

	var/light_range_on = 3
	var/light_power_on = 1
	layer = 2.9
	anchored = TRUE
	density = TRUE
	allowed_checks = ALLOWED_CHECK_NONE
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.

	// To be filled out at compile time
	var/list/products	= list() // For each, use the following pattern:
	var/list/contraband	= list() // list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list() // No specified amount = only one in stock
	var/list/syndie	= list()
	var/list/prices     = list() // Prices for each item, list(/type/path = price), items not in the list don't have a price.

	var/product_slogans = "" //String of slogans separated by semicolons, optional
	var/product_ads = "" //String of small ad messages in the vending screen - random chance
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/emag_records = list()
	var/list/slogan_list = list()
	var/list/small_ads = list() // small ad messages in the vending screen - random chance of popping up whenever you open it
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 6000 //How long until we can pitch again?
	var/icon_vend //Icon_state when vending!
	var/icon_deny //Icon_state when vending!
	var/icon_hacked //Passive hacked icon_state
	//var/emagged = 0 //Ignores if somebody doesn't have card access to that machine.
	var/electrified_until = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/shut_up = 1 //Stop spouting those godawful pitches!
	var/extended_inventory = 0 //can we access the hidden inventory?
	var/obj/item/weapon/coin/coin
	var/obj/item/weapon/vending_refill/refill_canister = null		//The type of refill canisters used by this machine.

	var/check_accounts = 1		// 1 = requires PIN and checks accounts.  0 = You slide an ID, it vends, SPACE COMMUNISM!
	var/obj/item/weapon/ewallet/ewallet
	var/datum/wires/vending/wires = null
	var/scan_id = TRUE

	var/private = TRUE // Whether the vending machine is privately operated, and thus must not start with a deficit of goods.


/obj/machinery/vending/atom_init()
	. = ..()
	wires = new(src)
	src.anchored = TRUE
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/vendor(null)

	slogan_list = splittext(product_slogans, ";")

	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)

	build_inventory(products)
	 //Add hidden inventory
	build_inventory(contraband, hidden = 1)
	build_inventory(premium, req_coin = 1)
	build_inventory(syndie, req_emag = 1)
	power_change()
	update_wires_check()

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	return ..()

/obj/machinery/vending/RefreshParts()
	..()
	// eat refills
	for(var/obj/item/weapon/vending_refill/refill in component_parts)
		component_parts -= refill
		qdel(refill)

/obj/machinery/vending/deconstruct(disassembled = TRUE)
	if(refill_canister)
		return ..()
	//the non constructable vendors drop metal instead of a machine frame.
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 3)
	qdel(src)

/obj/machinery/vending/atom_break(damage_flag)
	. = ..()
	if(.)
		malfunction()

/obj/machinery/vending/proc/build_inventory(list/productlist, hidden = 0, req_coin = 0 , req_emag = 0)
	for(var/typepath in productlist)
		var/amount = productlist[typepath]

		var/price = prices[typepath]
		if(isnull(amount)) amount = 1

		var/datum/data/vending_product/R = new /datum/data/vending_product()
		global.vending_products[typepath] = 1
		R.product_path = typepath
		R.amount = amount
		R.max_amount = amount
		R.price = price

		if(hidden)
			hidden_records += R
		else if(req_coin)
			coin_records += R
		else if(req_emag)
			emag_records += R
		else
			product_records += R

		var/atom/temp = typepath
		R.product_name = initial(temp.name)
	return

/obj/machinery/vending/proc/refill_inventory(obj/item/weapon/vending_refill/refill, mob/user)  //Restocking from TG
	var/total = 0

	var/to_restock = 0
	for(var/datum/data/vending_product/machine_content in product_records)
		to_restock += machine_content.max_amount - machine_content.amount

	if(to_restock <= refill.charges)
		for(var/datum/data/vending_product/machine_content in product_records)
			if(machine_content.amount != machine_content.max_amount)
				to_chat(usr, "<span class='notice'>[machine_content.max_amount - machine_content.amount] of [machine_content.product_name]</span>")
				machine_content.amount = machine_content.max_amount
		refill.charges -= to_restock
		total = to_restock
	else
		var/tmp_charges = refill.charges
		for(var/datum/data/vending_product/machine_content in product_records)
			var/restock = CEIL(((machine_content.max_amount - machine_content.amount) / to_restock) * tmp_charges)
			if(restock > refill.charges)
				restock = refill.charges
			machine_content.amount += restock
			refill.charges -= restock
			total += restock
			if(restock)
				to_chat(usr, "<span class='notice'>[restock] of [machine_content.product_name]</span>")
			if(refill.charges == 0) //due to rounding, we ran out of refill charges, exit.
				break
	return total

/obj/machinery/vending/attackby(obj/item/weapon/W, mob/user)
	if(panel_open)
		if(default_unfasten_wrench(user, W, time = 60))
			return

		if(isprying(W))
			default_deconstruction_crowbar(W)

	if(isscrewing(W) && anchored)
		src.panel_open = !src.panel_open
		to_chat(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		cut_overlays()
		if(src.panel_open)
			add_overlay(image(src.icon, "[initial(icon_state)]-panel"))
		updateUsrDialog()

		return
	else if(is_wire_tool(W) && panel_open && wires.interact(user))
		return

	else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
		user.drop_from_inventory(W, src)
		coin = W
		to_chat(user, "<span class='notice'>You insert the [W] into the [src]</span>")
		return

	else if(iswrenching(W))	//unwrenching vendomats
		var/turf/T = user.loc
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You begin [anchored ? "unwrenching" : "wrenching"] the [src].</span>")
		if(W.use_tool(src, user, 20, volume = 50))
			if(!istype(src, /obj/machinery/vending) || !user || !W || !T)
				return
			if(user.loc == T && user.get_active_hand() == W)
				anchored = !anchored
				to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
				if (!(src.anchored & powered()))
					src.icon_state = "[initial(icon_state)]-off"
					stat |= NOPOWER
					set_light(0)
				else
					icon_state = initial(icon_state)
					stat &= ~NOPOWER
					set_light(light_range_on, light_power_on)
				wrenched_change()

	else if(currently_vending && istype(W, /obj/item/device/pda) && W.GetID())
		var/obj/item/weapon/card/I = W.GetID()
		scan_card(I)

	else if(currently_vending && istype(W, /obj/item/weapon/card))
		var/obj/item/weapon/card/I = W
		scan_card(I)

	else if(istype(W, refill_canister) && refill_canister != null)
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='notice'>It does nothing.</span>")
		else if(panel_open)
			//if the panel is open we attempt to refill the machine
			var/obj/item/weapon/vending_refill/canister = W
			if(canister.charges == 0)
				to_chat(user, "<span class='notice'>This [canister.name] is empty!</span>")
			else
				var/transfered = refill_inventory(canister, user)
				if(transfered)
					to_chat(user, "<span class='notice'>You loaded [transfered] items in \the [name].</span>")
				else
					to_chat(user, "<span class='notice'>The [name] is fully stocked.</span>")
			return;
		else
			to_chat(user, "<span class='notice'>You should probably unscrew the service panel first.</span>")

	else if (istype(W, /obj/item/weapon/ewallet))
		user.drop_from_inventory(W, src)
		ewallet = W
		to_chat(user, "<span class='notice'>You insert the [W] into the [src]</span>")

	else if(src.panel_open)
		for(var/datum/data/vending_product/R in product_records)
			if(istype(W, R.product_path))
				stock(R, user)
				qdel(W)
	else
		..()

/obj/machinery/vending/emag_act(mob/user)
	if(emagged)
		return FALSE
	src.emagged = 1
	if(syndie.len)
		to_chat(user, "You short out the product lock on [src] and reveal hidden products.")
	else
		to_chat(user, "You short out the product lock on [src].")
	return TRUE

/obj/machinery/vending/default_deconstruction_crowbar(obj/item/O)
	var/list/all_products = product_records + hidden_records + coin_records + emag_records
	for(var/datum/data/vending_product/machine_content in all_products)
		while(machine_content.amount !=0)
			var/safety = 0 //to avoid infinite loop
			for(var/obj/item/weapon/vending_refill/VR in component_parts)
				safety++
				if(VR.charges < initial(VR.charges))
					VR.charges++
					machine_content.amount--
					if(!machine_content.amount)
						break
				else
					safety--
			if(safety <= 0)
				break
	..()

/obj/machinery/vending/proc/scan_card(obj/item/weapon/card/I)
	if(!currently_vending)
		return
	if (istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		if(check_accounts)
			if(vendor_account)
				var/datum/money_account/D = get_account(C.associated_account_number)
				if(D)
					D = attempt_account_access_with_user_input(C.associated_account_number, ACCOUNT_SECURITY_LEVEL_MAXIMUM, usr)
					if(usr.incapacitated() || !Adjacent(usr))
						return
					if(D)
						var/transaction_amount = currently_vending.price
						if(transaction_amount <= D.money)

							//transfer the money
							var/tax = round(transaction_amount * SSeconomy.tax_vendomat_sales * 0.01)
							charge_to_account(global.station_account.account_number, global.station_account.owner_name, "Налог на продажу в вендомате", src.name, tax)

							//create entries in the two account transaction logs
							charge_to_account(D.account_number, "[global.cargo_account.owner_name] (via [src.name])", "Покупка: [currently_vending.product_name]", src.name, -transaction_amount)
							//
							charge_to_account(global.cargo_account.account_number, global.cargo_account.owner_name, "Продажа: [currently_vending.product_name]", src.name, transaction_amount - tax)

							// Vend the item
							vend(src.currently_vending, usr)
							currently_vending = null
						else
							to_chat(usr, "[bicon(src)]<span class='warning'>You don't have that much money!</span>")
					else
						to_chat(usr, "[bicon(src)]<span class='warning'>You entered wrong account PIN!</span>")
				else
					to_chat(usr, "[bicon(src)]<span class='warning'>Unable to find your money account!</span>")
			else
				to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access account. Check security settings and try again.</span>")
		else
			//Just Vend it.
			vend(src.currently_vending, usr)
			currently_vending = null
	else
		to_chat(usr, "[bicon(src)]<span class='warning'>Unable to access vendor account. Please record the machine ID and call CentComm Support.</span>")

/obj/machinery/vending/proc/set_extended_inventory(state)
	extended_inventory = state
	if(state && icon_hacked)
		icon_state = icon_hacked
	else
		icon_state = initial(icon_state)

/obj/machinery/vending/ui_interact(mob/user)
	if((world.time < electrified_until || electrified_until < 0) && !issilicon(user) && !isobserver(user))
		if(shock(user, 100))
			return

	var/vendorname = name  //import the machine's name

	if(currently_vending)
		var/dat
		dat += "<b>You have selected [currently_vending.product_name].<br>Please swipe your ID to pay for the article.</b><br>"
		dat += "<a href='byond://?src=\ref[src];cancel_buying=1'>Cancel</a>"
		var/datum/browser/popup = new(user, "window=vending", "[vendorname]", 450, 600)
		popup.set_content(dat)
		popup.open()
		return

	var/dat
	dat += "<div class='Section__title'>Products</div>"
	dat += "<div class='Section'>"

	if (product_records.len == 0)
		dat += "<span class='red'>No product loaded!</span>"
	else
		dat += "<table>"
		dat += print_recors(product_records)
		if(extended_inventory)
			dat += print_recors(hidden_records)
		if(coin)
			dat += print_recors(coin_records)
		if(emagged)
			dat += print_recors(emag_records)
		dat += "</table>"
	dat += "</div>"

	if (premium.len > 0)
		dat += "<b>Coin slot:</b> [coin ? coin : "No coin inserted"] <a href='byond://?src=\ref[src];remove_coin=1'>Remove</A><br>"

	if (ewallet)
		dat += "<b>Charge card's credits:</b> [ewallet ? ewallet.get_money() : "No charge card inserted"] (<a href='byond://?src=\ref[src];remove_ewallet=1'>Remove</A>)<br><br>"

	var/datum/browser/popup = new(user, "window=vending", "[vendorname]", 450, 600)
	popup.add_stylesheet(get_asset_datum(/datum/asset/spritesheet/vending))
	popup.set_content(dat)
	popup.open()

/obj/machinery/vending/proc/print_recors(list/record)
	var/dat
	for (var/datum/data/vending_product/R in record)
		dat += "<tr>"
		dat += "<td class='collapsing'><span class='vending32x32 [replacetext(replacetext("[R.product_path]", "[/obj/item]/", ""), "/", "-")]'></span></td>"
		dat += "<td><B>[R.product_name]</B></td>"
		dat += "<td class='collapsing' align='center'><span class='[1 < R.amount ? "good" : R.amount == 1 ? "average" : "bad"]'>[R.amount] in stock</span></td>"
		if (R.amount > 0)
			dat += "<td class='collapsing' align='center'><a class='fluid' href='byond://?src=\ref[src];vend=\ref[R]'>[R.price ? "[R.price] cr." : "FREE"]</A></td>"
		else
			dat += "<td class='collapsing' align='center'><div class='disabled fluid'>[R.price ? "[R.price] cr." : "FREE"]</div></td>"
		dat += "</tr>"
	return dat

/obj/machinery/vending/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["remove_coin"] && !issilicon(usr) && !isobserver(usr))
		if(!coin)
			to_chat(usr, "There is no coin in this machine.")
			return FALSE

		coin.loc = loc
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		to_chat(usr, "<span class='notice'>You remove the [coin] from the [src]</span>")
		coin = null

	else if(href_list["remove_ewallet"] && !issilicon(usr) && !isobserver(usr))
		if (!ewallet)
			to_chat(usr, "There is no charge card in this machine.")
			return
		ewallet.loc = loc
		if(!usr.get_active_hand())
			usr.put_in_hands(ewallet)
		to_chat(usr, "<span class='notice'>You remove the [ewallet] from the [src]</span>")
		ewallet = null

	else if (href_list["vend"] && vend_ready && !currently_vending)

		if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>")//Unless emagged of course
			flick(src.icon_deny, src)
			return FALSE

		var/datum/data/vending_product/R = locate(href_list["vend"])
		if (!R || !istype(R) || !R.product_path || R.amount <= 0)
			return FALSE

		if(R.price == null || isobserver(usr)) //Centcomm buys somethin at himself? Nope, because they can just take this
			vend(R, usr)
		else
			if (ewallet)
				if (R.price <= ewallet.get_money())
					ewallet.remove_money(R.price)
					vend(R, usr)
				else
					to_chat(usr, "<span class='warning'>The ewallet doesn't have enough money to pay for that.</span>")
					src.currently_vending = R
					updateUsrDialog()
			else
				src.currently_vending = R
				updateUsrDialog()
		return

	else if (href_list["cancel_buying"])
		src.currently_vending = null
		updateUsrDialog()
		return

	updateUsrDialog()

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if (!allowed(user) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
		to_chat(user, "<span class='warning'>Access denied.</span>")//Unless emagged of course
		flick(src.icon_deny,src)
		return
	src.vend_ready = 0 //One thing at a time!!

	if (R in coin_records)
		if(!coin)
			to_chat(user, "<span class='notice'>You need to insert a coin to get this item.</span>")
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, "<span class='notice'>You successfully pull the coin out before the [src] could swallow it.</span>")
			else
				to_chat(user, "<span class='notice'>You weren't able to pull the coin out fast enough, the machine ate it, string and all.</span>")
				QDEL_NULL(coin)
		else
			QDEL_NULL(coin)

	R.amount--

	if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
		spawn(0)
			speak(src.vend_reply)
			src.last_reply = world.time

	use_power(5)
	if (src.icon_vend) //Show the vending animation if needed
		flick(src.icon_vend,src)
	spawn(src.vend_delay)
		new R.product_path(get_turf(src))
		playsound(src, 'sound/items/vending.ogg', VOL_EFFECTS_MASTER)
		src.vend_ready = 1
		src.currently_vending = null
		updateUsrDialog()

/obj/machinery/vending/proc/stock(datum/data/vending_product/R, mob/user)
	if(src.panel_open)
		to_chat(user, "<span class='notice'>You stock the [src] with \a [R.product_name]</span>")
		R.amount++

	updateUsrDialog()

/obj/machinery/vending/proc/say_slogan()
	if(stat & (BROKEN|NOPOWER))
		return

	//Pitch to the people!  Really sell it!
	if(slogan_list.len > 0 && !shut_up)
		var/slogan = pick(slogan_list)
		speak(slogan)

		addtimer(CALLBACK(src, PROC_REF(say_slogan)), slogan_delay + rand(0, 1000), TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/machinery/vending/proc/shoot_inventory_timer()
	if(stat & (BROKEN|NOPOWER))
		return

	if(shoot_inventory)
		throw_item()

		addtimer(CALLBACK(src, PROC_REF(shoot_inventory_timer)), rand(100, 6000), TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/machinery/vending/proc/update_wires_check()
	if(stat & (BROKEN|NOPOWER))
		return

	if(slogan_list.len > 0 && !shut_up)
		addtimer(CALLBACK(src, PROC_REF(say_slogan)), rand(0, slogan_delay), TIMER_UNIQUE|TIMER_NO_HASH_WAIT|TIMER_OVERRIDE)
	if(shoot_inventory)
		addtimer(CALLBACK(src, PROC_REF(shoot_inventory_timer)), rand(100, 6000), TIMER_UNIQUE|TIMER_NO_HASH_WAIT|TIMER_OVERRIDE)

/obj/machinery/vending/proc/speak(message)
	if(stat & NOPOWER)
		return

	if (!message)
		return

	audible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span>")

/obj/machinery/vending/power_change()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		set_light(0)
	else
		if( powered() & src.anchored )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			set_light(light_range_on, light_power_on)
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"
				stat |= NOPOWER
				set_light(0)
				update_power_use()
	update_power_use()

/obj/machinery/vending/turn_light_off()
	. = ..()
	stat |= NOPOWER
	icon_state = "[initial(icon_state)]-off"
	update_power_use()

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	if(refill_canister)
		//Dropping actual items
		var/max_drop = rand(5, 7)
		for(var/i = 1, i < max_drop, i++)
			var/datum/data/vending_product/R = pick(src.product_records)
			var/dump_path = R.product_path
			if(!R.amount)
				continue
			new dump_path(src.loc)
			R.amount--

		//Dropping remaining items in a pack
		var/refilling = 0
		for(var/datum/data/vending_product/R in src.product_records)
			while(R.amount > 0)
				refilling++
				R.amount--

		var/obj/item/weapon/vending_refill/Refill = new refill_canister(src.loc)
		Refill.charges = refilling
	else //If no canister - drop everything
		for(var/datum/data/vending_product/R in src.product_records)
			while(R.amount > 0)
				var/dump_path = R.product_path
				new dump_path(src.loc)
				R.amount--

	stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"

	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		R.amount--
		throw_item = new dump_path(src.loc)
		break
	if (!throw_item)
		return 0
	throw_item.throw_at(target, 16, 3)
	visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")
	return 1

/obj/machinery/vending/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/*
 * Vending machine types
 */

/*

/obj/machinery/vending/[vendors name here]   // --vending machine template   :)
	name = ""
	desc = ""
	icon = ''
	icon_state = ""
	vend_delay = 15
	products = list()
	contraband = list()
	premium = list()

*/
