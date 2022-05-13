/*****************************Money bag********************************/

/obj/item/weapon/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = CONDUCT
	force = 10.0
	throwforce = 2.0
	w_class = SIZE_NORMAL

/obj/item/weapon/moneybag/attack_hand(user)
	var/amt_mercury = 0
	var/amt_copper = 0
	var/amt_plastic = 0
	var/amt_iron = 0
	var/amt_tin = 0
	var/amt_lead = 0
	var/amt_uranium = 0
	var/amt_platinum = 0
	var/amt_phoron = 0
	var/amt_gold = 0
	var/amt_bananium = 0

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin/mercury))
			amt_mercury++;
		if (istype(C,/obj/item/weapon/coin/copper))
			amt_copper++;
		if (istype(C,/obj/item/weapon/coin/plastic))
			amt_plastic++;
		if (istype(C,/obj/item/weapon/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/coin/tin))
			amt_tin++;
		if (istype(C,/obj/item/weapon/coin/lead))
			amt_lead++;
		if (istype(C,/obj/item/weapon/coin/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/coin/platinum))
			amt_platinum++;
		if (istype(C,/obj/item/weapon/coin/phoron))
			amt_phoron++;
		if (istype(C,/obj/item/weapon/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/coin/bananium))
			amt_bananium++;

	var/dat = ""
	if (amt_mercury)
		dat += text("Gold coins: [amt_mercury] <A href='?src=\ref[src];remove=mercury'>Remove one</A><br>")
	if (amt_copper)
		dat += text("Silver coins: [amt_copper] <A href='?src=\ref[src];remove=copper'>Remove one</A><br>")
	if (amt_plastic)
		dat += text("Metal coins: [amt_plastic] <A href='?src=\ref[src];remove=plastic'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Diamond coins: [amt_iron] <A href='?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_tin)
		dat += text("Phoron coins: [amt_tin] <A href='?src=\ref[src];remove=tin'>Remove one</A><br>")
	if (amt_lead)
		dat += text("Uranium coins: [amt_lead] <A href='?src=\ref[src];remove=lead'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Bananium coins: [amt_uranium] <A href='?src=\ref[src];remove=uranium'>Remove one</A><br>")
	if (amt_platinum)
		dat += text("Platinum coins: [amt_platinum] <A href='?src=\ref[src];remove=platinum'>Remove one</A><br>")
	if (amt_phoron)
		dat += text("Mythril coins: [amt_phoron] <A href='?src=\ref[src];remove=phoron'>Remove one</A><br>")
	if (amt_gold)
		dat += text("Mythril coins: [amt_gold] <A href='?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_bananium)
		dat += text("Mythril coins: [amt_bananium] <A href='?src=\ref[src];remove=bananium'>Remove one</A><br>")

	var/datum/browser/popup = new(user, "moneybag", "The contents of the moneybag reveal...")
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/moneybag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C = I
		to_chat(user, "<span class='notice'>You add the [C.name] into the bag.</span>")
		user.drop_from_inventory(C)
		contents += C
		return
	if(istype(I, /obj/item/weapon/moneybag))
		var/obj/item/weapon/moneybag/C = I
		for (var/obj/O in C.contents)
			contents += O
		to_chat(user, "<span class='notice'>You empty the [C.name] into the bag.</span>")
		return
	return ..()

/obj/item/weapon/moneybag/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["remove"])
		var/obj/item/weapon/coin/COIN
		switch(href_list["remove"])
			if("mercury")
				COIN = locate(/obj/item/weapon/coin/mercury,src.contents)
			if("copper")
				COIN = locate(/obj/item/weapon/coin/copper,src.contents)
			if("plastic")
				COIN = locate(/obj/item/weapon/coin/plastic,src.contents)
			if("iron")
				COIN = locate(/obj/item/weapon/coin/iron,src.contents)
			if("tin")
				COIN = locate(/obj/item/weapon/coin/tin,src.contents)
			if("lead")
				COIN = locate(/obj/item/weapon/coin/lead,src.contents)
			if("uranium")
				COIN = locate(/obj/item/weapon/coin/uranium,src.contents)
			if("platinum")
				COIN = locate(/obj/item/weapon/coin/platinum,src.contents)
			if("phoron")
				COIN = locate(/obj/item/weapon/coin/phoron,src.contents)
			if("gold")
				COIN = locate(/obj/item/weapon/coin/gold,src.contents)
			if("bananium")
				COIN = locate(/obj/item/weapon/coin/bananium,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



/obj/item/weapon/moneybag/vault

/obj/item/weapon/moneybag/vault/atom_init()
	. = ..()
	for (var/i in 1 to 10)
		new /obj/item/weapon/coin/gold(src)
	for (var/i in 1 to 5)
		new /obj/item/weapon/coin/phoron(src)
	new /obj/item/weapon/coin/platinum(src)
