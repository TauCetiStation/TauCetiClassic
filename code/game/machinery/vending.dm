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
	var/light_range_on = 3
	var/light_power_on = 1
	layer = 2.9
	anchored = 1
	density = 1
	allowed_checks = ALLOWED_CHECK_NONE
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.

	// To be filled out at compile time
	var/list/products	= list() // For each, use the following pattern:
	var/list/contraband	= list() // list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list() // No specified amount = only one in stock
	var/list/prices     = list() // Prices for each item, list(/type/path = price), items not in the list don't have a price.

	var/product_slogans = "" //String of slogans separated by semicolons, optional
	var/product_ads = "" //String of small ad messages in the vending screen - random chance
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
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
	var/obj/item/weapon/spacecash/ewallet/ewallet
	var/datum/wires/vending/wires = null
	var/scan_id = TRUE


/obj/machinery/vending/atom_init()
	. = ..()
	wires = new(src)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/vendor(null)

	slogan_list = splittext(product_slogans, ";")

	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)

	build_inventory(products)
	 //Add hidden inventory
	build_inventory(contraband, 1)
	build_inventory(premium, 0, 1)
	power_change()
	update_wires_check()

/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(coin)
	return ..()

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				spawn(0)
					src.malfunction()
					return
				return
		else
	return

/obj/machinery/vending/blob_act()
	if (prob(50))
		spawn(0)
			src.malfunction()
			qdel(src)
		return

	return

/obj/machinery/vending/proc/build_inventory(list/productlist,hidden=0,req_coin=0)
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
		else
			product_records += R

		var/atom/temp = typepath
		R.product_name = initial(temp.name)
	return

/obj/machinery/vending/proc/refill_inventory(obj/item/weapon/vending_refill/refill, datum/data/vending_product/machine, mob/user)  //Restocking from TG
	var/total = 0

	var/to_restock = 0
	for(var/datum/data/vending_product/machine_content in machine)
		to_restock += machine_content.max_amount - machine_content.amount

	if(to_restock <= refill.charges)
		for(var/datum/data/vending_product/machine_content in machine)
			if(machine_content.amount != machine_content.max_amount)
				to_chat(usr, "<span class='notice'>[machine_content.max_amount - machine_content.amount] of [machine_content.product_name]</span>")
				machine_content.amount = machine_content.max_amount
		refill.charges -= to_restock
		total = to_restock
	else
		var/tmp_charges = refill.charges
		for(var/datum/data/vending_product/machine_content in machine)
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

		if(iscrowbar(W))
			default_deconstruction_crowbar(W)

	if(isscrewdriver(W) && anchored)
		src.panel_open = !src.panel_open
		to_chat(user, "You [src.panel_open ? "open" : "close"] the maintenance panel.")
		src.cut_overlays()
		if(src.panel_open)
			src.add_overlay(image(src.icon, "[initial(icon_state)]-panel"))
		src.updateUsrDialog()

		return
	else if(is_wire_tool(W) && panel_open && wires.interact(user))
		return

	else if(istype(W, /obj/item/weapon/coin) && premium.len > 0)
		user.drop_item()
		W.loc = src
		coin = W
		to_chat(user, "<span class='notice'>You insert the [W] into the [src]</span>")
		return

	else if(iswrench(W))	//unwrenching vendomats
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
				var/transfered = refill_inventory(canister,product_records,user)
				if(transfered)
					to_chat(user, "<span class='notice'>You loaded [transfered] items in \the [name].</span>")
				else
					to_chat(user, "<span class='notice'>The [name] is fully stocked.</span>")
			return;
		else
			to_chat(user, "<span class='notice'>You should probably unscrew the service panel first.</span>")

	else if (istype(W, /obj/item/weapon/spacecash/ewallet))
		user.drop_item()
		W.loc = src
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
	to_chat(user, "You short out the product lock on [src]")
	return TRUE

/obj/machinery/vending/default_deconstruction_crowbar(obj/item/O)
	var/list/all_products = product_records + hidden_records + coin_records
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
				var/attempt_pin = 0
				if(D)
					if(D.security_level > 0)
						attempt_pin = input("Enter pin code", "Vendor transaction") as num
						if(isnull(attempt_pin))
							to_chat(usr, "[bicon(src)]<span class='warning'>You entered wrong account PIN!</span>")
							return
						D = attempt_account_access(C.associated_account_number, attempt_pin, 2)

					if(D)
						var/transaction_amount = currently_vending.price
						if(transaction_amount <= D.money)

							//transfer the money
							D.adjust_money(-transaction_amount)
							vendor_account.adjust_money(transaction_amount)

							//create entries in the two account transaction logs
							var/datum/transaction/T = new()
							T.target_name = "[vendor_account.owner_name] (via [src.name])"
							T.purpose = "Purchase of [currently_vending.product_name]"
							if(transaction_amount > 0)
								T.amount = "([transaction_amount])"
							else
								T.amount = "[transaction_amount]"
							T.source_terminal = src.name
							T.date = current_date_string
							T.time = worldtime2text()
							D.transaction_log.Add(T)
							//
							T = new()
							T.target_name = D.owner_name
							T.purpose = "Purchase of [currently_vending.product_name]"
							T.amount = "[transaction_amount]"
							T.source_terminal = src.name
							T.date = current_date_string
							T.time = worldtime2text()
							vendor_account.transaction_log.Add(T)

							// Vend the item
							src.vend(src.currently_vending, usr)
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
			src.vend(src.currently_vending, usr)
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
		var/datum/browser/popup = new(user, "window=vending", "[vendorname]", 400, 550)
		popup.set_content(dat)
		popup.open()
		return

	var/dat
	dat += "<h3>Select an item</h3>"
	dat += "<div class='statusDisplay'>"

	if (product_records.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		dat += "<table>"
		dat += print_recors(product_records)
		if(extended_inventory)
			dat += print_recors(hidden_records)
		if(coin)
			dat += print_recors(coin_records)
		dat += "</table>"
	dat += "</div>"

	if (premium.len > 0)
		dat += "<b>Coin slot:</b> [coin ? coin : "No coin inserted"] <a href='byond://?src=\ref[src];remove_coin=1'>Remove</A><br>"

	if (ewallet)
		dat += "<b>Charge card's credits:</b> [ewallet ? ewallet.worth : "No charge card inserted"] (<a href='byond://?src=\ref[src];remove_ewallet=1'>Remove</A>)<br><br>"

	var/datum/browser/popup = new(user, "window=vending", "[vendorname]", 450, 500)
	popup.add_stylesheet(get_asset_datum(/datum/asset/spritesheet/vending))
	popup.set_content(dat)
	popup.open()

/obj/machinery/vending/proc/print_recors(list/record)
	var/dat
	for (var/datum/data/vending_product/R in record)
		dat += "<tr>"
		dat += {"<td><span class="vending32x32 [replacetext(replacetext("[R.product_path]", "/obj/item/", ""), "/", "-")]"></span></td>"}
		dat += {"<td><font color = '#c9c9b5'><B>[R.product_name]</B></font></td>"}
		dat += "<td><font color = '#0c4274'><b>[R.amount]</b> </font></td>"
		if(R.price)
			dat += {"<td align="center"><font color = '#ffd700'><b>$[R.price]</b></font></td>"}
		else
			dat += {"<td align="center"><font color = '#32cd32'><b>Free</b></font></td>"}
		if (R.amount > 0)
			dat += "<td align='right'><a href='byond://?src=\ref[src];vend=\ref[R]'>Vend</A></td>"
		else
			dat += "<td nowrap><font color = 'red'>SOLD OUT</font></td>"
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

		if(isrobot(usr))
			var/mob/living/silicon/robot/R = usr
			if(!(R.module && istype(R.module,/obj/item/weapon/robot_module/butler) ))
				to_chat(usr, "<span class='warning'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
				return FALSE
		else if(issilicon(usr))
			to_chat(usr, "<span class='warning'>The vending machine refuses to interface with you, as you are not in its target demographic!</span>")
			return FALSE

		if (!allowed(usr) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
			to_chat(usr, "<span class='warning'>Access denied.</span>")//Unless emagged of course
			flick(src.icon_deny, src)
			return FALSE

		var/datum/data/vending_product/R = locate(href_list["vend"])
		if (!R || !istype(R) || !R.product_path || R.amount <= 0)
			return FALSE

		if(R.price == null || isobserver(usr)) //Centcomm buys somethin at himself? Nope, because they can just take this
			src.vend(R, usr)
		else
			if (ewallet)
				if (R.price <= ewallet.worth)
					ewallet.worth -= R.price
					src.vend(R, usr)
				else
					to_chat(usr, "<span class='warning'>The ewallet doesn't have enough money to pay for that.</span>")
					src.currently_vending = R
					src.updateUsrDialog()
			else
				src.currently_vending = R
				src.updateUsrDialog()
		return

	else if (href_list["cancel_buying"])
		src.currently_vending = null
		src.updateUsrDialog()
		return

	src.updateUsrDialog()

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
			src.speak(src.vend_reply)
			src.last_reply = world.time

	use_power(5)
	if (src.icon_vend) //Show the vending animation if needed
		flick(src.icon_vend,src)
	spawn(src.vend_delay)
		new R.product_path(get_turf(src))
		playsound(src, 'sound/items/vending.ogg', VOL_EFFECTS_MASTER)
		src.vend_ready = 1
		return

	src.updateUsrDialog()

/obj/machinery/vending/proc/stock(datum/data/vending_product/R, mob/user)
	if(src.panel_open)
		to_chat(user, "<span class='notice'>You stock the [src] with \a [R.product_name]</span>")
		R.amount++

	src.updateUsrDialog()

/obj/machinery/vending/proc/say_slogan()
	if(stat & (BROKEN|NOPOWER))
		return

	//Pitch to the people!  Really sell it!
	if(slogan_list.len > 0 && !shut_up)
		var/slogan = pick(slogan_list)
		speak(slogan)

		addtimer(CALLBACK(src, .proc/say_slogan), slogan_delay + rand(0, 1000), TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/machinery/vending/proc/shoot_inventory_timer()
	if(stat & (BROKEN|NOPOWER))
		return

	if(shoot_inventory)
		throw_item()

		addtimer(CALLBACK(src, .proc/shoot_inventory_timer), rand(100, 6000), TIMER_UNIQUE|TIMER_NO_HASH_WAIT)

/obj/machinery/vending/proc/update_wires_check()
	if(stat & (BROKEN|NOPOWER))
		return

	if(slogan_list.len > 0 && !shut_up)
		addtimer(CALLBACK(src, .proc/say_slogan), rand(0, slogan_delay), TIMER_UNIQUE|TIMER_NO_HASH_WAIT|TIMER_OVERRIDE)
	if(shoot_inventory)
		addtimer(CALLBACK(src, .proc/shoot_inventory_timer), rand(100, 6000), TIMER_UNIQUE|TIMER_NO_HASH_WAIT|TIMER_OVERRIDE)

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

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		while(R.amount>0)
			new dump_path(src.loc)
			R.amount--
		continue

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

/*
/obj/machinery/vending/atmospherics //Commenting this out until someone ponies up some actual working, broken, and unpowered sprites - Quarxink
	name = "Tank Vendor"
	desc = "A vendor with a wide variety of masks and gas tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	product_paths = "/obj/item/weapon/tank/oxygen;/obj/item/weapon/tank/phoron;/obj/item/weapon/tank/emergency_oxygen;/obj/item/weapon/tank/emergency_oxygen/engi;/obj/item/clothing/mask/breath"
	product_amounts = "10;10;10;5;25"
	vend_delay = 0
*/

/obj/machinery/vending/boozeomat
	name = "Booze-O-Mat"
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	icon_state = "boozeomat"        //////////////18 drink entities below, plus the glasses, in case someone wants to edit the number of bottles
	icon_deny = "boozeomat-deny"
	light_color = "#77beda"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/gin = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tequilla = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/vermouth = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/rum = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/wine = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/cognac = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/kahlua = 5,/obj/item/weapon/reagent_containers/food/drinks/bottle/beer = 6,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/ale = 6,/obj/item/weapon/reagent_containers/food/drinks/bottle/orangejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/tomatojuice = 4,/obj/item/weapon/reagent_containers/food/drinks/bottle/limejuice = 4,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/cream = 4,/obj/item/weapon/reagent_containers/food/drinks/cans/tonic = 8,
					/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 8, /obj/item/weapon/reagent_containers/food/drinks/cans/sodawater = 15,
					/obj/item/weapon/reagent_containers/food/drinks/flask/barflask = 2, /obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask = 2,
					/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 30,/obj/item/weapon/reagent_containers/food/drinks/ice = 9,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/melonliquor = 2,/obj/item/weapon/reagent_containers/food/drinks/bottle/bluecuracao = 2,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/absinthe = 2,/obj/item/weapon/reagent_containers/food/drinks/bottle/grenadine = 5,
					/obj/item/weapon/reagent_containers/food/drinks/bottle/champagne = 5)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/tea = 10)
	vend_delay = 15
	product_slogans = "I hope nobody asks me for a bloody cup o' tea...;Alcohol is humanity's friend. Would you abandon a friend?;Quite delighted to serve you!;Is nobody thirsty on this station?"
	product_ads = "Drink up!;Booze is good for you!;Alcohol is humanity's best friend.;Quite delighted to serve you!;Care for a nice, cold beer?;Nothing cures you like booze!;Have a sip!;Have a drink!;Have a beer!;Beer is good for you!;Only the finest alcohol!;Best quality booze since 2053!;Award-winning wine!;Maximum alcohol!;Man loves beer.;A toast for progress!"
	req_access = list(25)
	refill_canister = /obj/item/weapon/vending_refill/boozeomat

/obj/machinery/vending/assist
	products = list(	/obj/item/device/assembly/prox_sensor = 5,/obj/item/device/assembly/igniter = 3,/obj/item/device/assembly/signaler = 4,
						/obj/item/weapon/wirecutters = 1, /obj/item/weapon/cartridge/signal = 4)
	contraband = list(/obj/item/device/flashlight = 5,/obj/item/device/assembly/timer = 2)
	product_ads = "Only the finest!;Have some tools.;The most robust equipment.;The finest gear in space!"
	refill_canister = /obj/item/weapon/vending_refill/assist

/obj/machinery/vending/coffee
	name = "Hot Drinks machine"
	desc = "A vending machine which dispenses hot drinks."
	product_ads = "Have a drink!;Drink up!;It's good for you!;Would you like a hot joe?;I'd kill for some coffee!;The best beans in the galaxy.;Only the finest brew for you.;Mmmm. Nothing like a coffee.;I like coffee, don't you?;Coffee helps you work!;Try some tea.;We hope you like the best!;Try our new chocolate!;Admin conspiracies"
	icon_state = "coffee"
	icon_vend = "coffee-vend"
	light_color = "#b88b2e"
	vend_delay = 34
	products = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 25,/obj/item/weapon/reagent_containers/food/drinks/tea = 25,/obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 25)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/ice = 10)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/coffee = 15, /obj/item/weapon/reagent_containers/food/drinks/tea = 15, /obj/item/weapon/reagent_containers/food/drinks/h_chocolate = 15)
	refill_canister = /obj/item/weapon/vending_refill/coffee



/obj/machinery/vending/snack
	name = "Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snackred"
	light_color = "#d00023"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/candy/candybar = 6,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 6,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen = 6,
					/obj/item/weapon/reagent_containers/food/snacks/chips = 6,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 6,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 6,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 6)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/syndicake = 6)
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/candy/candybar = 5,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen = 25,/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen = 25,
					/obj/item/weapon/reagent_containers/food/snacks/chips = 10,
					/obj/item/weapon/reagent_containers/food/snacks/sosjerky = 14,/obj/item/weapon/reagent_containers/food/snacks/no_raisin = 10,/obj/item/weapon/reagent_containers/food/snacks/spacetwinkie = 10,
					/obj/item/weapon/reagent_containers/food/snacks/cheesiehonkers = 10)
	refill_canister = /obj/item/weapon/vending_refill/snack

/obj/random/vending/snack
	name = "random snack vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "snackrandom"

/obj/random/vending/snack/item_to_spawn()
	return pick(typesof(/obj/machinery/vending/snack))

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"
	light_color = "#5efb00"

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"
	light_color = "#ff8b02"

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"
	light_color = "#10ff1f"

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"
	light_color = "#ffc400"

/obj/machinery/vending/chinese
	name = "Mr. Chang"
	desc = "A self-serving Chinese food machine, for all your Chinese food needs."
	product_slogans = "Taste 5000 years of culture!"
	icon_state = "chang"
	light_color = "#d00023"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein = 6, /obj/item/weapon/reagent_containers/food/snacks/chinese/tao = 6, /obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball = 6, /obj/item/weapon/reagent_containers/food/snacks/chinese/newdles = 6,
					/obj/item/weapon/reagent_containers/food/snacks/chinese/rice = 6, /obj/item/weapon/kitchen/utensil/fork/sticks = 18)
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/chinese/chowmein = 25, /obj/item/weapon/reagent_containers/food/snacks/chinese/tao = 25, /obj/item/weapon/reagent_containers/food/snacks/chinese/sweetsourchickenball = 25, /obj/item/weapon/reagent_containers/food/snacks/chinese/newdles = 25,
					/obj/item/weapon/reagent_containers/food/snacks/chinese/rice = 25, /obj/item/weapon/kitchen/utensil/fork/sticks = 1)
	refill_canister = /obj/item/weapon/vending_refill/chinese

/obj/machinery/vending/cola
	name = "Robust Softdrinks"
	desc = "A softdrink vendor provided by Robust Industries, LLC."
	icon_state = "colablue"
	light_color = "#315ab4"
	product_slogans = "Robust Softdrinks: More robust than a toolbox to the head!"
	product_ads = "Refreshing!;Hope you're thirsty!;Over 1 million drinks sold!;Thirsty? Why not cola?;Please, have a drink!;Drink up!;The best drinks in space."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 10, /obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 5)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 3,/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 3,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 3,/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 3,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 2,/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 3,
					/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 3,/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 3)
	refill_canister = /obj/item/weapon/vending_refill/cola

/obj/random/vending/cola
	name = "random cola vendor"
	icon = 'icons/obj/vending.dmi'
	icon_state = "colarandom"

/obj/random/vending/cola/item_to_spawn()
	return pick(typesof(/obj/machinery/vending/cola))

/obj/machinery/vending/cola/blue

/obj/machinery/vending/cola/black
	icon_state = "colablack"
	light_color = "#dddddd"

/obj/machinery/vending/cola/red
	desc = "It vends cola, in space."
	icon_state = "colared"
	product_slogans = "Cola in space!"
	light_color = "#bf0a38"

/obj/machinery/vending/cola/spaceup
	desc = "Indulge in an explosion of flavor."
	icon_state = "spaceup"
	product_slogans = "Space-up! Like a hull breach in your mouth."
	light_color = "#18d32f"

/obj/machinery/vending/cola/starkist
	desc = "The taste of a star in liquid form."
	icon_state = "starkist"
	product_slogans = "Drink the stars! Star-kist!"
	light_color = "#d1751a"

/obj/machinery/vending/cola/soda
	icon_state = "soda"
	light_color = "c8c8be"

/obj/machinery/vending/cola/gib
	desc = "Canned explosion of different flavors in this very vendor!"
	icon_state = "gib"
	product_slogans = "You will lose your guts because of our drinks!; Explosion - in a can!"
	light_color = "d23c3c"

//This one's from bay12
/obj/machinery/vending/cart
	name = "PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	light_color = "#dddddd"
	icon_deny = "cart-deny"
	products = list(/obj/item/weapon/cartridge/medical = 10,/obj/item/weapon/cartridge/engineering = 10,/obj/item/weapon/cartridge/security = 10,
					/obj/item/weapon/cartridge/janitor = 10,/obj/item/weapon/cartridge/signal/science = 10,/obj/item/device/pda/heads = 10,
					/obj/item/weapon/cartridge/captain = 3,/obj/item/weapon/cartridge/quartermaster = 10)


/obj/machinery/vending/cigarette
	name = "Cigarette machine" //OCD had to be uppercase to look nice with the new formating
	desc = "If you want to get cancer, might as well do it in style!"
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	vend_delay = 34
	icon_state = "cigs"
	light_color = "#dddddd"
	products = list(/obj/item/weapon/storage/fancy/cigarettes = 10, /obj/item/weapon/storage/fancy/cigarettes/menthol = 5, /obj/item/weapon/storage/box/matches = 10, /obj/item/weapon/lighter/random = 4, /obj/item/clothing/mask/ecig = 4)
	contraband = list(/obj/item/weapon/lighter/zippo = 4)
	premium = list(/obj/item/clothing/mask/cigarette/cigar/havana = 2)
	prices = list(/obj/item/weapon/storage/fancy/cigarettes = 20, /obj/item/weapon/storage/fancy/cigarettes/menthol = 30, /obj/item/weapon/storage/box/matches = 10, /obj/item/weapon/lighter/random = 15, /obj/item/clothing/mask/ecig = 40)
	refill_canister = /obj/item/weapon/vending_refill/cigarette

/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	light_color = "#e6fff2"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access = list(5)
	products = list(/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
					/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
					/obj/item/weapon/reagent_containers/syringe/antiviral = 4,/obj/item/weapon/reagent_containers/syringe = 12,
					/obj/item/device/healthanalyzer = 5,/obj/item/weapon/reagent_containers/glass/beaker = 4, /obj/item/weapon/reagent_containers/dropper = 2,
					/obj/item/stack/medical/advanced/bruise_pack = 3, /obj/item/stack/medical/advanced/ointment = 3, /obj/item/stack/medical/splint = 2,
					/obj/item/stack/medical/suture = 6)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3,/obj/item/weapon/reagent_containers/pill/stox = 4,/obj/item/weapon/reagent_containers/pill/dylovene = 6)
	refill_canister = /obj/item/weapon/vending_refill/medical

//This one's from bay12
/obj/machinery/vending/phoronresearch
	name = "Toximate 3000"
	desc = "All the fine parts you need in one vending machine!"
	products = list(/obj/item/device/transfer_valve = 6,/obj/item/device/assembly/timer = 6,/obj/item/device/assembly/signaler = 6,
					/obj/item/device/assembly/prox_sensor = 6,/obj/item/device/assembly/igniter = 6)

/obj/machinery/vending/wallmed1
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?"
	icon_state = "wallmed"
	light_power_on = 1
	light_color = "#e6fff2"
	icon_deny = "wallmed-deny"
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/stack/medical/bruise_pack = 2,/obj/item/stack/medical/ointment = 2,/obj/item/weapon/reagent_containers/hypospray/autoinjector = 4,/obj/item/device/healthanalyzer = 1,
				/obj/item/stack/medical/suture = 2)
	contraband = list(/obj/item/weapon/reagent_containers/syringe/antitoxin = 4,/obj/item/weapon/reagent_containers/syringe/antiviral = 4,/obj/item/weapon/reagent_containers/pill/tox = 1)

/obj/machinery/vending/wallmed2
	name = "NanoMed"
	desc = "Wall-mounted Medical Equipment dispenser."
	icon_state = "wallmed"
	light_power_on = 1
	light_color = "#e6fff2"
	icon_deny = "wallmed-deny"
	req_access = list(5)
	density = 0 //It is wall-mounted, and thus, not dense. --Superxpdude
	products = list(/obj/item/weapon/reagent_containers/hypospray/autoinjector = 5,/obj/item/weapon/reagent_containers/syringe/antitoxin = 3,/obj/item/stack/medical/bruise_pack = 3,
					/obj/item/stack/medical/ointment =3,/obj/item/device/healthanalyzer = 3, /obj/item/stack/medical/suture = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3)

/obj/machinery/vending/security
	name = "SecTech"
	desc = "A security equipment vendor."
	product_ads = "Crack capitalist skulls!;Beat some heads in!;Don't forget - harm is good!;Your weapons are right here.;Handcuffs!;Freeze, scumbag!;Don't tase me bro!;Tase them, bro.;Why not have a donut?"
	icon_state = "sec"
	light_color = "#f1f8ff"
	icon_deny = "sec-deny"
	req_access = list(1)
	products = list(/obj/item/weapon/handcuffs = 8,/obj/item/weapon/grenade/flashbang = 4,/obj/item/device/flash = 5,
					/obj/item/weapon/reagent_containers/food/snacks/donut/normal = 12,/obj/item/weapon/storage/box/evidence = 6, /obj/item/ammo_box/c9mmr = 10)
	contraband = list(/obj/item/clothing/glasses/sunglasses = 2,/obj/item/weapon/storage/fancy/donut_box = 2,/obj/item/device/flashlight/seclite = 4)

/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor."
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	light_color = "#34ff7b"
	icon_deny = "nutri-deny"
	products = list(/obj/item/nutrient/ez = 45,/obj/item/nutrient/l4z = 25,/obj/item/nutrient/rh = 15,/obj/item/weapon/pestspray = 20,
					/obj/item/weapon/reagent_containers/syringe = 5,/obj/item/weapon/storage/bag/plants = 5)
	premium = list(/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5)
	refill_canister = /obj/item/weapon/vending_refill/hydronutrients

/obj/machinery/vending/hydroseeds
	name = "MegaSeed Servitor"
	desc = "When you need seeds fast!"
	product_slogans = "THIS'S WHERE TH' SEEDS LIVE! GIT YOU SOME!;Hands down the best seed selection on the station!;Also certain mushroom varieties available, more for experts! Get certified today!"
	product_ads = "We like plants!;Grow some crops!;Grow, baby, growww!;Aw h'yeah son!"
	icon_state = "seeds"
	light_color = "#34ff7b"
	products = list(/obj/item/seeds/ambrosiavulgarisseed = 3,/obj/item/seeds/appleseed = 3,/obj/item/seeds/bananaseed = 3,/obj/item/seeds/berryseed = 3,
						/obj/item/seeds/cabbageseed = 3,/obj/item/seeds/carrotseed = 3,/obj/item/seeds/cherryseed = 3,/obj/item/seeds/chantermycelium = 3,
						/obj/item/seeds/chiliseed = 3,/obj/item/seeds/cocoapodseed = 3,/obj/item/seeds/cornseed = 3,/obj/item/seeds/replicapod = 3,
						/obj/item/seeds/eggplantseed = 3,/obj/item/seeds/grapeseed = 3,/obj/item/seeds/grassseed = 3,/obj/item/seeds/lemonseed = 3,
						/obj/item/seeds/limeseed = 3,/obj/item/seeds/orangeseed = 3,/obj/item/seeds/plastiseed = 3,/obj/item/seeds/potatoseed = 3,
						/obj/item/seeds/poppyseed = 3,/obj/item/seeds/pumpkinseed = 3,/obj/item/seeds/riceseed= 3,/obj/item/seeds/soyaseed = 3,
						/obj/item/seeds/sunflowerseed = 3,/obj/item/seeds/tomatoseed = 3,/obj/item/seeds/towermycelium = 3,/obj/item/seeds/watermelonseed = 3,
						/obj/item/seeds/wheatseed = 3,/obj/item/seeds/whitebeetseed = 3, /obj/item/seeds/blackpepper = 5)
	contraband = list(/obj/item/seeds/amanitamycelium = 2,/obj/item/seeds/glowshroom = 2,/obj/item/seeds/libertymycelium = 2,/obj/item/seeds/mtearseed = 2,
					  /obj/item/seeds/nettleseed = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/reishimycelium = 2,/obj/item/seeds/shandseed = 2,)
	premium = list(/obj/item/toy/waterflower = 1)
	refill_canister = /obj/item/weapon/vending_refill/hydroseeds

/obj/machinery/vending/magivend
	name = "MagiVend"
	desc = "A magic vending machine."
	icon_state = "MagiVend"
	light_color = "#97429a"
	product_slogans = "Sling spells the proper way with MagiVend!;Be your own Houdini! Use MagiVend!"
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	product_ads = "FJKLFJSD;AJKFLBJAKL;1234 LOONIES LOL!;>MFW;Kill them fuckers!;GET DAT FUKKEN DISK;HONK!;EI NATH;Destroy the station!;Admin conspiracies since forever!;Space-time bending hardware!"
	products = list(/obj/item/clothing/head/wizard = 1,/obj/item/clothing/suit/wizrobe = 1,/obj/item/clothing/head/wizard/red = 1,
	/obj/item/clothing/suit/wizrobe/red = 1,/obj/item/clothing/shoes/sandal = 1,/obj/item/weapon/staff = 2, /obj/item/device/modkit/wizard/skrell = 1,
	 /obj/item/device/modkit/wizard/unathi = 1, /obj/item/device/modkit/wizard/tajaran = 1, /obj/item/device/modkit/wizard/vox = 1, /obj/item/clothing/head/wizard/redhood = 1, /obj/item/clothing/head/wizard/bluehood = 1,
	 /obj/item/clothing/suit/wizrobe/wiz_blue = 1, /obj/item/clothing/suit/wizrobe/wiz_red = 1)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/wizarditis = 1)	//No one can get to the machine to hack it anyways; for the lulz - Microwave

/obj/machinery/vending/weirdomat
	name = "Weird-O-Mat"
	desc = "A marvel, on the brink of technobabble and pixie fiction."
	icon_state = "MagiVend"
	light_color = "#97429a"
	products = list(/obj/item/weapon/occult_pinpointer = 3,
		/obj/item/device/occult_scanner = 3,
		/obj/item/clothing/mask/gas/owl_mask = 3,
		/obj/item/clothing/mask/pig = 3,
		/obj/item/clothing/mask/horsehead = 3,
		/obj/item/clothing/mask/cowmask = 3,
		/obj/item/clothing/mask/chicken = 3,
		/obj/item/weapon/kitchenknife/plastic = 3)
	prices = list(/obj/item/weapon/occult_pinpointer = 150,
		/obj/item/device/occult_scanner = 150,
		/obj/item/clothing/mask/gas/owl_mask = 100,
		/obj/item/clothing/mask/pig = 100,
		/obj/item/clothing/mask/horsehead = 100,
		/obj/item/clothing/mask/cowmask = 100,
		/obj/item/clothing/mask/chicken = 100,
		/obj/item/weapon/kitchenknife/plastic = 100)
	contraband = list(/obj/item/weapon/nullrod = 1,
		/obj/item/weapon/kitchenknife/ritual = 1)
	premium = list(/obj/item/clothing/glasses/gglasses = 1,
		/obj/item/toy/figure/wizard = 1,
		/obj/item/weapon/storage/fancy/crayons = 1)
	product_slogans = "Amicitiae nostrae memoriam spero sempiternam fore;Aequam memento rebus in arduis servare mentem;Vitanda est improba siren desidia;Serva me, servabo te;Faber est suae quisque fortunae"
	vend_reply = "Have fun! No returns!"
	product_ads = "Occult is magic;Knowledge is magic;All the magic!;None to spook us;The dice has been cast"

/obj/machinery/vending/weirdomat/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
	if(istype(I, /obj/item/weapon/reagent_containers/food/snacks/ectoplasm))
		RedeemEctoplasm(I, user)
		return
	..()

/obj/machinery/vending/weirdomat/proc/RedeemEctoplasm(obj/plasm, redeemer)
	if(plasm.in_use)
		return
	plasm.in_use = TRUE
	var/selection = input(redeemer, "Pick your eternal reward", "Ectoplasm Redemption") in list("Misfortune Set", "Spiritual Bond Set", "Contract From Below", "Cryptorecorder", "Black Candle Box", "Cancel")
	if(!selection || !Adjacent(redeemer))
		plasm.in_use = FALSE
		return
	switch(selection)
		if("Misfortune Set")
			new /obj/item/weapon/storage/pill_bottle/ghostdice(loc)
		if("Spiritual Bond Set")
			new /obj/item/weapon/game_kit/chaplain(loc)
		if("Contract From Below")
			new /obj/item/weapon/pen/ghost(loc)
		if("Cryptorecorder")
			new /obj/item/device/camera/spooky(loc)
		if("Black Candle Box")
			new /obj/item/weapon/storage/fancy/black_candle_box(loc)
		if("Cancel")
			plasm.in_use = FALSE
			return
	qdel(plasm)

/obj/machinery/vending/barbervend
	name = "Fab-O-Vend"
	desc = "It would seem it vends dyes, and other stuff to make you pretty."
	icon_state = "barbervend"
	product_slogans = "Spread the colour, like butter, onto toast... Onto their hair.; Sometimes, I dream about dyes...; Paint 'em up and call me Mr. Painter.; Look brother, I'm a vendomat, I solve practical problems."
	product_ads = "Cut 'em all!; To sheds!; Hair be gone!; Prettify!; Beautify!"
	req_access = list(69)
	refill_canister = /obj/item/weapon/vending_refill/barbervend
	products = list(/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/white = 10,
					/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/red = 10,
					/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/green = 10,
					/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blue = 10,
					/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/black = 10,
					/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/brown = 10,
					/obj/item/weapon/reagent_containers/glass/bottle/hair_dye/blond = 10,
					/obj/item/weapon/reagent_containers/spray/hair_color_spray = 3)
	contraband = list(/obj/item/weapon/razor = 1)
	premium = list(/obj/item/weapon/scissors  = 3,
				   /obj/item/weapon/reagent_containers/glass/bottle/hair_growth_accelerator = 3,
				   /obj/item/weapon/storage/box/lipstick = 3)

/obj/machinery/vending/dinnerware
	name = "Dinnerware"
	desc = "A kitchen and restaurant equipment vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	products = list(
		/obj/item/weapon/tray = 8,
		/obj/item/weapon/kitchen/utensil/fork = 6,
		/obj/item/weapon/kitchenknife = 3,
		/obj/item/weapon/reagent_containers/food/drinks/drinkingglass = 8,
		/obj/item/clothing/suit/chef/classic = 2,
		/obj/item/weapon/kitchen/mould/bear = 1,
		/obj/item/weapon/kitchen/mould/worm = 1,
		/obj/item/weapon/kitchen/mould/bean = 1,
		/obj/item/weapon/kitchen/mould/ball = 1,
		/obj/item/weapon/kitchen/mould/cane = 1,
		/obj/item/weapon/kitchen/mould/cash = 1,
		/obj/item/weapon/kitchen/mould/coin = 1,
		/obj/item/weapon/kitchen/mould/loli = 1
	)
	contraband = list(/obj/item/weapon/kitchen/utensil/spoon = 2,/obj/item/weapon/kitchen/rollingpin = 2, /obj/item/weapon/kitchenknife/butch = 2)
	refill_canister = /obj/item/weapon/vending_refill/dinnerware

/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old sweet water vending machine, how did this end up here?"
	icon_state = "sovietsoda"
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	products = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/soda = 30)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cola = 20)

/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	light_color = "#ffcc33"
	icon_deny = "tool-deny"

	//req_access_txt = "12" //Maintenance access
	products = list(/obj/item/stack/cable_coil/random = 10,/obj/item/weapon/crowbar = 5,/obj/item/weapon/weldingtool = 3,/obj/item/weapon/wirecutters = 5,
					/obj/item/weapon/wrench = 5,/obj/item/device/analyzer = 5,/obj/item/device/t_scanner = 5,/obj/item/weapon/screwdriver = 5)
	contraband = list(/obj/item/weapon/weldingtool/hugetank = 2,/obj/item/clothing/gloves/fyellow = 2)
	premium = list(/obj/item/clothing/gloves/yellow = 1, /obj/item/weapon/gun/energy/pyrometer/engineering = 1)
	refill_canister = /obj/item/weapon/vending_refill/tool

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	light_color = "#ffcc33"
	icon_deny = "engivend-deny"
	req_access = list(11) //Engineering Equipment access
	products = list(/obj/item/clothing/glasses/meson = 2,/obj/item/device/multitool = 4, /obj/item/weapon/gun/energy/pyrometer/engineering = 4, /obj/item/weapon/airlock_electronics = 10,/obj/item/weapon/module/power_control = 10,/obj/item/weapon/airalarm_electronics = 10,/obj/item/weapon/stock_parts/cell/high = 10)
	contraband = list(/obj/item/weapon/stock_parts/cell/potato = 3)
	premium = list(/obj/item/weapon/storage/belt/utility = 3)
	refill_canister = /obj/item/weapon/vending_refill/engivend

//This one's from bay12
/obj/machinery/vending/engineering
	name = "Robco Tool Maker"
	desc = "Everything you need for do-it-yourself station repair."
	icon_state = "engi"
	icon_deny = "engi-deny"
	req_access = list(11)
	products = list(/obj/item/clothing/under/rank/chief_engineer = 4,/obj/item/clothing/under/rank/engineer = 4,/obj/item/clothing/shoes/boots/work = 4,/obj/item/clothing/head/hardhat/yellow = 4,
					/obj/item/clothing/head/hardhat/yellow/visor = 1,/obj/item/weapon/storage/belt/utility = 4,/obj/item/clothing/glasses/meson = 4,/obj/item/clothing/gloves/yellow = 4, /obj/item/weapon/screwdriver = 12,
					/obj/item/weapon/crowbar = 12,/obj/item/weapon/wirecutters = 12,/obj/item/device/multitool = 12,/obj/item/weapon/wrench = 12,/obj/item/device/t_scanner = 12,
					/obj/item/stack/cable_coil/heavyduty = 8, /obj/item/weapon/stock_parts/cell = 8, /obj/item/weapon/weldingtool = 8,/obj/item/clothing/head/welding = 8,
					/obj/item/weapon/light/tube = 10,/obj/item/clothing/suit/fire = 4, /obj/item/weapon/stock_parts/scanning_module = 5,/obj/item/weapon/stock_parts/micro_laser = 5,
					/obj/item/weapon/stock_parts/matter_bin = 5,/obj/item/weapon/stock_parts/manipulator = 5,/obj/item/weapon/stock_parts/console_screen = 5, /obj/item/weapon/gun/energy/pyrometer/engineering = 4)
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/weapon/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu

//This one's from bay12
/obj/machinery/vending/robotics
	name = "Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access = list(29)
	products = list(/obj/item/stack/cable_coil/random = 2,/obj/item/device/flash = 4,
					/obj/item/weapon/stock_parts/cell/high = 5, /obj/item/device/assembly/prox_sensor = 3,/obj/item/device/assembly/signaler = 3,/obj/item/device/healthanalyzer = 3,
					/obj/item/weapon/scalpel = 2,/obj/item/weapon/circular_saw = 2,/obj/item/weapon/tank/anesthetic = 2,/obj/item/clothing/mask/breath/medical = 2,
					/obj/item/weapon/gun/energy/pyrometer/engineering/robotics=2)
	//everything after the power cell had no amounts, I improvised.  -Sayu

//This one's from NTstation
//don't forget to change the refill size if you change the machine's contents!
/obj/machinery/vending/clothing
	name = "ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."
	icon_state = "clothes"
	product_slogans = "Dress for success!;Prepare to look swagalicious!;Look at all this free swag!;Why leave style up to fate? Use the ClothesMate!"
	vend_delay = 15
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/that=4,/obj/item/clothing/head/fedora=2,/obj/item/clothing/glasses/monocle=2,
	/obj/item/clothing/suit/jacket=4,/obj/item/clothing/head/chep=2, /obj/item/clothing/suit/jacket/puffer/vest=4, /obj/item/clothing/suit/jacket/puffer=4,
	/obj/item/clothing/under/suit_jacket/navy=2,/obj/item/clothing/under/suit_jacket/really_black=2,/obj/item/clothing/under/suit_jacket/burgundy=2,
	/obj/item/clothing/under/suit_jacket/charcoal=2, /obj/item/clothing/under/suit_jacket/white=2,/obj/item/clothing/under/kilt=2,/obj/item/clothing/under/overalls=2,
	/obj/item/clothing/under/suit_jacket/really_black=4,/obj/item/clothing/under/suit_jacket/rouge =4,/obj/item/clothing/under/pants/jeans=6,/obj/item/clothing/under/pants/classicjeans=4,
	/obj/item/clothing/under/pants/camo = 2,/obj/item/clothing/under/pants/blackjeans=4,/obj/item/clothing/under/pants/khaki=4,
	/obj/item/clothing/under/pants/white=4,/obj/item/clothing/under/pants/red=2,/obj/item/clothing/under/pants/black=4,
	/obj/item/clothing/under/pants/tan=4,/obj/item/clothing/under/pants/blue=2,/obj/item/clothing/under/pants/track=2,
	/obj/item/clothing/under/sundress=4,/obj/item/clothing/under/blacktango=2,
	/obj/item/clothing/suit/jacket=6,/obj/item/clothing/glasses/regular=4,/obj/item/clothing/head/sombrero=2,
	/obj/item/clothing/suit/poncho=2,/obj/item/clothing/suit/ianshirt=1,/obj/item/clothing/shoes/laceup=4,
	/obj/item/clothing/shoes/sandal=2,/obj/item/clothing/head/byzantine_hat=1,/obj/item/clothing/suit/byzantine_dress=1,
	/obj/item/clothing/mask/bandana/black=2,/obj/item/clothing/mask/bandana/skull=2,/obj/item/clothing/mask/bandana/green=2,/obj/item/clothing/mask/bandana/gold=2,
	/obj/item/clothing/mask/bandana/blue=2,/obj/item/clothing/mask/scarf/blue=2,/obj/item/clothing/mask/scarf/red=2,/obj/item/clothing/mask/scarf/green=2,
	/obj/item/clothing/mask/scarf/yellow=2,/obj/item/clothing/mask/scarf/violet=2,
	/obj/item/clothing/suit/wintercoat=3,/obj/item/clothing/shoes/winterboots=3,/obj/item/clothing/head/santa=3,
	/obj/item/clothing/suit/storage/miljacket_army=3,/obj/item/clothing/suit/storage/miljacket_army/miljacket_ranger=2,/obj/item/clothing/suit/storage/miljacket_army/miljacket_navy=2,
	/obj/item/clothing/suit/student_jacket=3,/obj/item/clothing/suit/shawl=2,/obj/item/clothing/suit/atlas_jacket=4,/obj/item/clothing/under/sukeban_pants=2,
	/obj/item/clothing/under/sukeban_dress=2,/obj/item/clothing/suit/sukeban_coat=4,/obj/item/clothing/under/pinkpolo=3,/obj/item/clothing/under/pretty_dress=1,
	/obj/item/clothing/under/dress/dress_summer=2,/obj/item/clothing/under/dress/dress_vintage=2,/obj/item/clothing/under/dress/dress_evening=2,/obj/item/clothing/under/dress/dress_party=2,
	/obj/item/clothing/glasses/aviator_orange=2, /obj/item/clothing/glasses/aviator_black=2, /obj/item/clothing/glasses/aviator_red=2, /obj/item/clothing/glasses/aviator_mirror=2,
	/obj/item/clothing/glasses/jerusalem=2, /obj/item/clothing/glasses/threedglasses=2, /obj/item/clothing/glasses/gar=2)

	contraband = list(/obj/item/clothing/under/syndicate/tacticool=4,/obj/item/clothing/mask/balaclava=4,/obj/item/clothing/head/tacticool_hat=4, /obj/item/clothing/head/ushanka=2,/obj/item/clothing/under/soviet=2,/obj/item/clothing/mask/gas/fawkes = 6)

	premium = list(/obj/item/clothing/under/suit_jacket/checkered=2,/obj/item/clothing/head/mailman=2,/obj/item/clothing/under/rank/mailman=2,/obj/item/clothing/suit/jacket/leather=2,
	/obj/item/clothing/suit/jacket/leather/overcoat=2,/obj/item/clothing/under/pants/mustangjeans=2,/obj/item/clothing/glasses/sunglasses/gar=1,/obj/item/clothing/glasses/sunglasses=1)

	prices = list(/obj/item/clothing/head/that=50,/obj/item/clothing/head/fedora=50,/obj/item/clothing/glasses/monocle=20,
	/obj/item/clothing/suit/jacket=75,/obj/item/clothing/head/chep=30, /obj/item/clothing/suit/jacket/puffer/vest=70, /obj/item/clothing/suit/jacket/puffer=85,
	/obj/item/clothing/under/suit_jacket/navy=119,/obj/item/clothing/under/suit_jacket/really_black=119,/obj/item/clothing/under/suit_jacket/burgundy=119,
	/obj/item/clothing/under/suit_jacket/charcoal=119, /obj/item/clothing/under/suit_jacket/white=119,/obj/item/clothing/under/kilt=85,/obj/item/clothing/under/overalls=50,
	/obj/item/clothing/under/suit_jacket/really_black=142,/obj/item/clothing/under/suit_jacket/rouge =148,/obj/item/clothing/under/pants/jeans=105,
	/obj/item/clothing/under/pants/classicjeans=105,/obj/item/clothing/under/pants/camo = 105,/obj/item/clothing/under/pants/blackjeans=105,/obj/item/clothing/under/pants/khaki=105,
	/obj/item/clothing/under/pants/white=105,/obj/item/clothing/under/pants/red=105,/obj/item/clothing/under/pants/black=105,
	/obj/item/clothing/under/pants/tan=105,/obj/item/clothing/under/pants/blue=105,/obj/item/clothing/under/pants/track=105,
	/obj/item/clothing/under/sundress=85,/obj/item/clothing/under/blacktango=99,
	/obj/item/clothing/suit/jacket=138,/obj/item/clothing/glasses/regular=55,/obj/item/clothing/head/sombrero=45,
	/obj/item/clothing/suit/poncho=70,/obj/item/clothing/suit/ianshirt=999,/obj/item/clothing/shoes/laceup=99,
	/obj/item/clothing/shoes/sandal=35,/obj/item/clothing/head/byzantine_hat=95,/obj/item/clothing/suit/byzantine_dress=120,
	/obj/item/clothing/mask/bandana/black=40,/obj/item/clothing/mask/bandana/skull=40,/obj/item/clothing/mask/bandana/green=40,/obj/item/clothing/mask/bandana/gold=40,
	/obj/item/clothing/mask/bandana/blue=40,/obj/item/clothing/mask/scarf/blue=30,/obj/item/clothing/mask/scarf/red=30,/obj/item/clothing/mask/scarf/green=30,
	/obj/item/clothing/mask/scarf/yellow=30,/obj/item/clothing/mask/scarf/violet=30,
	/obj/item/clothing/suit/wintercoat=130,/obj/item/clothing/shoes/winterboots=70,/obj/item/clothing/head/santa=50,
	/obj/item/clothing/suit/storage/miljacket_army=155,/obj/item/clothing/suit/storage/miljacket_army/miljacket_ranger=155,/obj/item/clothing/suit/storage/miljacket_army/miljacket_navy=155,
	/obj/item/clothing/suit/student_jacket=120,/obj/item/clothing/suit/shawl=144,/obj/item/clothing/suit/atlas_jacket=95,/obj/item/clothing/under/sukeban_pants=160,
	/obj/item/clothing/under/sukeban_dress=140,/obj/item/clothing/suit/sukeban_coat=135,/obj/item/clothing/under/pinkpolo=75,/obj/item/clothing/under/pretty_dress=85,
	/obj/item/clothing/under/dress/dress_summer=100,/obj/item/clothing/under/dress/dress_vintage=120,/obj/item/clothing/under/dress/dress_evening=125,/obj/item/clothing/under/dress/dress_party=110,
    /obj/item/clothing/glasses/aviator_orange=35, /obj/item/clothing/glasses/aviator_black=40, /obj/item/clothing/glasses/aviator_red=37, /obj/item/clothing/glasses/aviator_mirror=30,
	/obj/item/clothing/glasses/jerusalem=30, /obj/item/clothing/glasses/threedglasses=25, /obj/item/clothing/glasses/gar=34)
	refill_canister = /obj/item/weapon/vending_refill/clothing

//from old nanotrasen
/obj/machinery/vending/blood
	name = "Blood'O'Matic"
	desc = "Human blood dispenser. With internal freezer. Brought to you by EmpireV corp."
	icon_state = "blood2"
	icon_deny = "blood2-deny"
	light_color = "#ffc0c0"
	product_ads = "Go and grab some blood!;I'm hope you are not bloody vampire.;Only from nice virgins!;Natural liquids!;This stuff saves lives."
	//req_access_txt = "5"
	products = list(/obj/item/weapon/reagent_containers/blood/APlus = 7, /obj/item/weapon/reagent_containers/blood/AMinus = 4,
					/obj/item/weapon/reagent_containers/blood/BPlus = 4, /obj/item/weapon/reagent_containers/blood/BMinus = 2,
					/obj/item/weapon/reagent_containers/blood/OPlus = 7, /obj/item/weapon/reagent_containers/blood/OMinus = 4)
	contraband = list(/obj/item/weapon/reagent_containers/pill/stox = 10, /obj/item/weapon/reagent_containers/blood/empty = 10)
	refill_canister = /obj/item/weapon/vending_refill/blood

//from old nanotrasen
/obj/machinery/vending/holy
	name = "HolyVend"
	desc = "Special items to prayers, sacrifices, rites and other methods to tell your God: I remember you!"
	icon_state = "holy"
	icon_hacked = "holy-hacked"
	product_slogans = "HolyVend: Select your Religion today"
	product_ads = "Pray now!;Atheists are heretic;Everything 100% Holy;Thirsty? Wanna pray? Why without candles?"
	products = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater = 5,
		/obj/item/weapon/storage/fancy/candle_box = 20,
		/obj/item/weapon/storage/fancy/candle_box/red = 25,
		/obj/item/clothing/accessory/metal_cross = 10,
		/obj/item/clothing/accessory/bronze_cross = 10,
		/obj/item/clothing/mask/tie/silver_cross = 5,
		/obj/item/clothing/mask/tie/golden_cross = 5,
		/obj/item/clothing/shoes/jolly_gravedigger = 4)
	contraband = list(/obj/item/weapon/nullrod = 1)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater = 40,
					/obj/item/weapon/storage/fancy/candle_box = 20,
					/obj/item/weapon/storage/fancy/candle_box/red = 20,
					/obj/item/weapon/nullrod = 400,
					/obj/item/clothing/accessory/metal_cross = 40,
					/obj/item/clothing/accessory/bronze_cross = 80,
					/obj/item/clothing/mask/tie/silver_cross = 400,
					/obj/item/clothing/mask/tie/golden_cross = 1000,
					/obj/item/clothing/shoes/jolly_gravedigger = 200)

/obj/machinery/vending/eva
	name = "Hardsuit Kits"
	desc = "Conversion kits for your alien hardsuit needs."
	products = list(/obj/item/device/modkit/engineering/tajaran = 5, /obj/item/device/modkit/engineering/unathi = 5, /obj/item/device/modkit/engineering/skrell = 5, /obj/item/device/modkit/engineering/vox = 5,
					/obj/item/device/modkit/atmos/tajaran = 5, /obj/item/device/modkit/atmos/unathi = 5, /obj/item/device/modkit/atmos/skrell = 5, /obj/item/device/modkit/atmos/vox = 5,
					/obj/item/device/modkit/med/tajaran = 5, /obj/item/device/modkit/med/unathi = 5, /obj/item/device/modkit/med/skrell = 5, /obj/item/device/modkit/med/vox = 5,
					/obj/item/device/modkit/sec/tajaran = 5, /obj/item/device/modkit/sec/unathi = 5, /obj/item/device/modkit/sec/skrell = 5, /obj/item/device/modkit/sec/vox = 5,
					/obj/item/device/modkit/mining/tajaran = 5, /obj/item/device/modkit/mining/unathi = 5, /obj/item/device/modkit/mining/skrell = 5, /obj/item/device/modkit/mining/vox = 5,
					/obj/item/device/modkit/engineering/chief/tajaran = 1, /obj/item/device/modkit/engineering/chief/unathi = 1, /obj/item/device/modkit/engineering/chief/skrell = 1, /obj/item/device/modkit/engineering/chief/vox = 1,
					/obj/item/device/modkit/med/cmo/tajaran = 1, /obj/item/device/modkit/med/cmo/unathi = 1, /obj/item/device/modkit/med/cmo/skrell = 1, /obj/item/device/modkit/med/cmo/vox = 1,
					/obj/item/device/modkit/sec/hos/tajaran = 1, /obj/item/device/modkit/sec/hos/unathi = 1, /obj/item/device/modkit/sec/hos/skrell = 1, /obj/item/device/modkit/sec/hos/vox = 1,
					/obj/item/device/modkit = 10)

/obj/machinery/vending/eva/mining
	name = "Mining Hardsuit Kits"
	desc = "Conversion kits for your alien mining hardsuits."
	icon_state = "evamine"
	products = list(/obj/item/device/modkit/mining/tajaran = 3, /obj/item/device/modkit/mining/unathi = 3, /obj/item/device/modkit/mining/skrell = 3, /obj/item/device/modkit/mining/vox = 3, /obj/item/device/modkit = 5)

/obj/machinery/vending/eva/engineering
	name = "Engineering Hardsuit Kits"
	desc = "Conversion kits for your alien engineering and atmos hardsuits."
	icon_state = "evaengi"
	// why the fuck do we have CE modifications here, if we don't have xeno-heads? and why are they not in CE's office or sumthin smh.
	products = list(/obj/item/device/modkit/engineering/tajaran = 3, /obj/item/device/modkit/engineering/unathi = 3, /obj/item/device/modkit/engineering/skrell = 3, /obj/item/device/modkit/engineering/vox = 3,
					/obj/item/device/modkit/atmos/tajaran = 3, /obj/item/device/modkit/atmos/unathi = 3, /obj/item/device/modkit/atmos/skrell = 3, /obj/item/device/modkit/atmos/vox = 3,
					/obj/item/device/modkit/engineering/chief/tajaran = 1, /obj/item/device/modkit/engineering/chief/unathi = 1, /obj/item/device/modkit/engineering/chief/skrell = 1, /obj/item/device/modkit/engineering/chief/vox = 1,
					/obj/item/device/modkit = 6)


//from old nanotrasen
//i deleted all drugs here, now it's just a joke
/obj/machinery/vending/omskvend
	name = "Omsk-o-mat"
	desc = "Drug dispenser."
	icon_state = "omskvend"
	product_ads = "NORKOMAN SUKA SHTOLE?;STOP NARTCOTICS!; so i heard u liek mudkipz; METRO ZATOPEELO"
	products = list(/obj/item/device/healthanalyzer = 5)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4)

/obj/item/weapon/reagent_containers/pill/LSD
	name = "LSD"
	desc = "Ahaha oh wow."
	icon_state = "pill9"

/obj/item/weapon/reagent_containers/pill/LSD/atom_init()
	. = ..()
	reagents.add_reagent("mindbreaker", 0)

/obj/item/weapon/reagent_containers/glass/beaker/LSD
	name = "LSD IV"
	desc = "Ahaha oh wow."

/obj/item/weapon/reagent_containers/glass/beaker/LSD/atom_init()
	. = ..()
	reagents.add_reagent("mindbreaker", 0)
	update_icon()

/obj/machinery/vending/sustenance
	name = "Sustenance Vendor"
	desc = "A vending machine which vends food, as required by section 47-C of the NT's Prisoner Ethical Treatment Agreement."
	product_slogans = "Enjoy your meal.;Enough calories to support strenuous labor."
	product_ads = "Sufficiently healthy.;Efficiently produced tofu!;Mmm! So good!;Have a meal.;You need food to live!;Have some more candy corn!;Try our new ice cups!"
	icon_state = "sustenance"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/tofu = 20,
					/obj/item/weapon/reagent_containers/food/drinks/ice = 12,
					/obj/item/weapon/reagent_containers/food/snacks/candy_corn = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cracker = 20,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 12)
	contraband = list(/obj/item/weapon/kitchenknife = 6)

//from old nanotrasen
/obj/machinery/vending/theater
	name = "Theater-o-mat"
	desc = "Special costume pack to add randomness in boring life."
	icon_state = "Theater"
	products = list(/obj/item/clothing/head/xenos = 5, /obj/item/clothing/suit/xenos = 5, /obj/item/clothing/suit/monkeysuit = 5, /obj/item/clothing/suit/syndicatefake = 5, /obj/item/clothing/head/syndicatefake = 5,
					/obj/item/clothing/head/collectable/slime = 5, /obj/item/clothing/head/collectable/xenom = 5, /obj/item/clothing/head/collectable/petehat = 5, /obj/item/clothing/head/kitty = 5,
					/obj/item/clothing/head/pumpkinhead = 5, /obj/item/clothing/head/ushanka = 5, /obj/item/clothing/head/cardborg = 5, /obj/item/clothing/suit/cardborg = 5, /obj/item/clothing/head/bearpelt = 5,
					/obj/item/clothing/mask/fakemoustache = 5, /obj/item/clothing/head/santahat = 5, /obj/item/clothing/suit/santa = 5, /obj/item/weapon/storage/backpack/santabag = 5,
					/obj/item/clothing/mask/gas/sexyclown = 5, /obj/item/clothing/mask/gas/sexymime = 5, /obj/item/clothing/mask/horsehead = 5, /obj/item/clothing/suit/apron = 5, /obj/item/clothing/suit/apron/overalls = 5,
					/obj/item/clothing/suit/chickensuit = 5, /obj/item/clothing/head/chicken = 5, /obj/item/clothing/under/fluff/tian_dress = 5, /obj/item/clothing/under/fluff/wyatt_1 = 5,
					/obj/item/clothing/under/fluff/olddressuniform = 5, /obj/item/clothing/under/fluff/jumpsuitdown = 5, /obj/item/clothing/under/fluff/jane_sidsuit = 5, /obj/item/clothing/under/sundress = 5,
					/obj/item/clothing/under/roman = 3, /obj/item/clothing/shoes/roman = 3, /obj/item/clothing/head/helmet/roman = 2, /obj/item/clothing/head/helmet/roman/legionaire = 1, /obj/item/clothing/under/smoking = 3,
					/obj/item/clothing/suit/tuxedo = 3,/obj/item/clothing/under/popking = 1, /obj/item/clothing/under/popking/alternate = 1, /obj/item/clothing/suit/hooded/angel_suit = 1,
					/obj/item/clothing/mask/fake_face = 2, /obj/item/clothing/suit/hooded/ian_costume = 1, /obj/item/clothing/suit/hooded/carp_costume = 1)
	prices = list(/obj/item/clothing/head/xenos = 50, /obj/item/clothing/suit/xenos = 80, /obj/item/clothing/suit/monkeysuit = 80, /obj/item/clothing/suit/hooded/carp_costume = 100)
	contraband = list(/obj/item/clothing/mask/gas/fawkes = 2)

/obj/machinery/vending/junkfood
	name = "McNuffin's Fast Food"
	desc = "Fastest food on the station, unhealthiest yet."
	product_slogans = "I'm lovin it!;You deserve a break today!;Nobody can do it like McNuffin's can" //mcdonald's slogans adapted
	product_ads = "One Two Three Four... Big Bite burger!;I'm lovin it!;Two meaty cutlets, special sauce, cheese -- everything on a bland bun. Right, it's a Big Bite!"
	icon_state = "junkfood"
	products = list(/obj/item/weapon/reagent_containers/food/snacks/monkeyburger = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheeseburger = 4,
					/obj/item/weapon/reagent_containers/food/snacks/fries/cardboard = 6,
					/obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard = 4,
					/obj/item/weapon/reagent_containers/food/snacks/hotdog = 5,
					/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 5,
					/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 5,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 5)
	prices = list(/obj/item/weapon/reagent_containers/food/snacks/monkeyburger = 10,
				  /obj/item/weapon/reagent_containers/food/snacks/cheeseburger = 15,
				  /obj/item/weapon/reagent_containers/food/snacks/fries/cardboard = 6,
				  /obj/item/weapon/reagent_containers/food/snacks/cheesyfries/cardboard = 9,
				  /obj/item/weapon/reagent_containers/food/snacks/hotdog = 9,
				  /obj/item/weapon/reagent_containers/food/drinks/cans/cola = 3,
				  /obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 3,
				  /obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 3)
	contraband = list(/obj/item/weapon/reagent_containers/food/snacks/fishfingers = 2)
	refill_canister = /obj/item/weapon/vending_refill/junkfood

/obj/machinery/vending/noiromat
	name = "Noir-O-Mat"
	desc = "It smells like an old novel."
	icon_state = "noiromat"
	icon_deny = "noiromat-deny"
	light_color = "#ffc444"
	products = list(/obj/item/clothing/glasses/sunglasses/noir = 2, /obj/item/clothing/gloves/black = 2,
					/obj/item/clothing/head/det_hat = 1, /obj/item/clothing/head/det_hat = 1,
					/obj/item/clothing/head/det_hat/grey = 1, /obj/item/clothing/head/det_hat/darkgrey = 1,
					/obj/item/clothing/head/det_hat/black = 1, /obj/item/clothing/head/fedora = 1, /obj/item/clothing/head/fedora/white = 1,
					/obj/item/clothing/gloves/black = 2, /obj/item/clothing/under/det = 1, /obj/item/clothing/under/det/black = 1,
					/obj/item/clothing/under/det/slob = 1, /obj/item/clothing/under/det/max_payne = 1, /obj/item/clothing/suit/storage/det_suit = 1,
					/obj/item/clothing/suit/storage/det_suit/grey = 1, /obj/item/clothing/suit/storage/det_suit/black = 1,
					/obj/item/clothing/suit/storage/det_suit/noir_trenchcoat = 1, /obj/item/clothing/accessory/tie/black = 2,
					/obj/item/clothing/accessory/tie/red = 2, /obj/item/clothing/shoes/brown = 2,
					/obj/item/clothing/shoes/black = 2, /obj/item/clothing/accessory/holster/armpit = 1,
					/obj/item/taperoll/police = 2, /obj/item/toy/crayon/chalk = 2,
					/obj/item/device/detective_scanner = 1, /obj/item/weapon/storage/box/evidence = 2,
					/obj/item/weapon/storage/fancy/cigarettes = 10, /obj/item/weapon/storage/fancy/cigarettes/menthol = 5, /obj/item/weapon/storage/box/matches = 10)
	prices = list(/obj/item/weapon/storage/fancy/cigarettes = 30, /obj/item/weapon/storage/fancy/cigarettes/menthol = 40, /obj/item/weapon/storage/box/matches = 10)
	product_slogans = "The cheaper the crook, the gaudier the patter.;Dead men are heavier than broken hearts.;Life is a bucket of shit with a barbed wire handle.;After all, you are only an immortal until someone manages to kill you. After that, you were just long-lived.;The rain fell like dead bullets.;Though I often run out of courage and good sense, stubbornness keeps me going."
	product_ads = "Keep your mind too open, and you never know what might walk in.;After all, you are only an immortal until someone manages to kill you. After that, you were just long-lived.;If you don't trust anyone, they can't let you down.;Wait. You've got principles? We'll have to update your file.;I always feel most alive when everything else is dying all around me."
	req_access = list(68)
