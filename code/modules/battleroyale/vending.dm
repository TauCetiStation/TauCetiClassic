/obj/machinery/vending/battle_royale
	name = "Battle Royale Show Ticket System"
	desc = "desc"
	product_slogans = "Battle Royale Show: best show in all world!"
	//product_ads = ""
	products = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 10,/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 10,
					/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 10, /obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 10)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko = 5)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola = 1,/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind = 1,
					/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb = 1,/obj/item/weapon/reagent_containers/food/drinks/cans/starkist = 1,
					/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle = 2,/obj/item/weapon/reagent_containers/food/drinks/cans/space_up = 1,
					/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea = 1,/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice = 1)

/obj/machinery/vending/brticket_console/refill_inventory(obj/item/weapon/vending_refill/refill, datum/data/vending_product/machine, mob/user)
	return 0

/obj/machinery/vending/brticket_console/refill_inventory(datum/data/vending_product/R, mob/user)
	if (!allowed(user) && !emagged && scan_id) //For SECURE VENDING MACHINES YEAH
		to_chat(user, "<span class='warning'>Access denied.</span>")//Unless emagged of course
		flick(src.icon_deny,src)
		return
	src.vend_ready = 0 //One thing at a time!!

	if (R in coin_records)
		if(!coin)
			to_chat(user, "\blue You need to insert a coin to get this item.")
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, "\blue You successfully pull the coin out before the [src] could swallow it.")
			else
				to_chat(user, "\blue You weren't able to pull the coin out fast enough, the machine ate it, string and all.")
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
		playsound(src, 'sound/items/vending.ogg', 50, 1, 1)
		src.vend_ready = 1
		return

	src.updateUsrDialog()


/obj/machinery/vending/brticket_console/attackby(obj/item/weapon/W, mob/user)
	..()

	if(istype(W, /obj/item/device/pda) && W.GetID())
		var/obj/item/weapon/card/I = W.GetID()
		scan_card(I)
	else if(istype(W, /obj/item/weapon/card))
		var/obj/item/weapon/card/I = W
		scan_card(I)

/obj/machinery/vending/brticket_console/ui_interact(mob/user)


	dat += "Tickets:<br>"

	dat += "<a href='?src=\ref[src];ticket=participant'>Participant ticket (500)</A><br>"
	dat += "<br>"
	dat += "<a href='?src=\ref[src];ticket=spectator'>Spectator ticket (100)</A><br>"

	dat += "<hr>"
	dat += "Current list of participants:"

	for(var/player in battreroyale_players)
		dat += "[player]<br>"

	var/datum/browser/popup = new(user, "brticket_console", "Battle Royale Show Ticket System", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()