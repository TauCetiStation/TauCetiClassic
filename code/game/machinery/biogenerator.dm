/obj/machinery/biogenerator
	name = "Biogenerator"
	desc = "Splits the vegetation into micro and macro nutriments, synthesizers, fertilizers, fiber, and etc."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen-empty"
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	var/processing = 0
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/points = 0
	var/menustat = "menu"
	var/efficiency = 0
	var/productivity = 0
	var/max_items = 10

/obj/machinery/biogenerator/atom_init()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/biogenerator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/biogenerator/RefreshParts()
	var/E = 0
	var/P = 0
	var/max_storage = 10
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		P += B.rating
		max_storage = B.rating * 3 + 10
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E
	productivity = P
	max_items = max_storage

/obj/machinery/biogenerator/on_reagent_change()
	update_icon()

/obj/machinery/biogenerator/update_icon()
	if(panel_open)
		icon_state = "biogen-empty-o"
	else if(!src.beaker)
		icon_state = "biogen-empty"
	else if(!src.processing)
		icon_state = "biogen-stand"
	else
		icon_state = "biogen-work"
	return

/obj/machinery/biogenerator/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/glass) && !panel_open)
		if(beaker)
			to_chat(user, "<span class='warning'>The biogenerator already occuped.</span>")
		else
			user.drop_from_inventory(O, src) 
			beaker = O
			updateUsrDialog()
	else if(processing)
		to_chat(user, "<span class='warning'>The biogenerator is currently processing.</span>")
	else if(istype(O, /obj/item/weapon/storage/bag/plants))
		var/obj/item/weapon/storage/bag/plants/P = O
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is already full! Activate it.</span>")
		else
			for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in O.contents)
				if(i >= max_items)
					break
				P.remove_from_storage(G, src)
				i++
			if(i<max_items)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator.</span>")
			else if(O.contents.len == 0)
				to_chat(user, "<span class='info'>You empty the plant bag into the biogenerator, filling it to its capacity.</span>")
			else
				to_chat(user, "<span class='info'>You fill the biogenerator to its capacity.</span>")


	else if(!istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
		to_chat(user, "<span class='warning'>You cannot put this in [src.name]</span>")
	else
		var/i = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/grown/G in contents)
			i++
		if(i >= max_items)
			to_chat(user, "<span class='warning'>The biogenerator is full! Activate it.</span>")
		else
			user.drop_from_inventory(O, src)
			to_chat(user, "<span class='info'>You put [O.name] in [src.name]</span>")

	if(!processing)
		if(default_deconstruction_screwdriver(user, "biogen-empty-o", "biogen-empty", O))
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.loc = loc
				beaker = null

	if(exchange_parts(user, O))
		return

	default_deconstruction_crowbar(O)

	update_icon()
	return

/obj/machinery/biogenerator/ui_interact(mob/user)
	var/dat
	if(processing)
		dat += "<div class='statusDisplay'>Biogenerator is processing! Please wait...</div><BR>"
	else
		switch(menustat)
			if("nopoints")
				dat += "<div class='statusDisplay'>You do not have biomass to create products.<BR>Please, put growns into reactor and activate it.</div>"
				menustat = "menu"
			if("complete")
				dat += "<div class='statusDisplay'>Operation complete.</div>"
				menustat = "menu"
			if("void")
				dat += "<div class='statusDisplay'>Error: No growns inside.<BR>Please, put growns into reactor.</div>"
				menustat = "menu"
		if(beaker)
			dat += "<div class='statusDisplay'>Biomass: [points] units.</div><BR>"
			dat += "<A href='?src=\ref[src];action=activate'>Activate</A><A href='?src=\ref[src];action=detach'>Detach Container</A>"
			dat += "<h3>Food:</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "10 milk: <A href='?src=\ref[src];action=create;item=milk'>Make</A> ([20/efficiency])<BR>"
			dat += "10 cream: <A href='?src=\ref[src];action=create;item=cream'>Make</A> ([30/efficiency])<BR>"
			dat += "Monkey cube: <A href='?src=\ref[src];action=create;item=monkey'>Make</A> ([250/efficiency])<BR>"
			dat += "Meat slice: <A href='?src=\ref[src];action=create;item=meat'>Make</A><A href='?src=\ref[src];action=create;item=meat5'>x5</A> ([80/efficiency])<BR>"
			dat += "</div>"
			dat += "<h3>Nutrients:</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "E-Z-Nutrient: <A href='?src=\ref[src];action=create;item=ez'>Make</A><A href='?src=\ref[src];action=create;item=ez5'>x5</A> ([10/efficiency])<BR>"
			dat += "Left 4 Zed: <A href='?src=\ref[src];action=create;item=l4z'>Make</A><A href='?src=\ref[src];action=create;item=l4z5'>x5</A> ([20/efficiency])<BR>"
			dat += "Robust Harvest: <A href='?src=\ref[src];action=create;item=rh'>Make</A><A href='?src=\ref[src];action=create;item=rh5'>x5</A> ([25/efficiency])<BR>"
			dat += "</div>"
			dat += "<h3>Leather:</h3>"
			dat += "<div class='statusDisplay'>"
			dat += "Wallet: <A href='?src=\ref[src];action=create;item=wallet'>Make</A> ([100/efficiency])<BR>"
			//dat += "Book bag: <A href='?src=\ref[src];action=create;item=bkbag'>Make</A> ([200/efficiency])<BR>"
			dat += "Plant bag: <A href='?src=\ref[src];action=create;item=ptbag'>Make</A> ([200/efficiency])<BR>"
			dat += "Mining satchel: <A href='?src=\ref[src];action=create;item=mnbag'>Make</A> ([200/efficiency])<BR>"
			dat += "Botanical gloves: <A href='?src=\ref[src];action=create;item=gloves'>Make</A> ([250/efficiency])<BR>"
			dat += "Brown shoes: <A href='?src=\ref[src];action=create;item=bshoes'>Make</A> ([250/efficiency])<BR>"
			dat += "Utility belt: <A href='?src=\ref[src];action=create;item=tbelt'>Make</A> ([300/efficiency])<BR>"
			dat += "Leather Satchel: <A href='?src=\ref[src];action=create;item=satchel'>Make</A> ([400/efficiency])<BR>"
			dat += "Cash Bag: <A href='?src=\ref[src];action=create;item=cashbag'>Make</A> ([400/efficiency])<BR>"
			dat += "Leather Jacket: <A href='?src=\ref[src];action=create;item=jacket'>Make</A> ([500/efficiency])<BR>"
			dat += "Leather Overcoat: <A href='?src=\ref[src];action=create;item=overcoat'>Make</A> ([1000/efficiency])<BR>"
			dat += "</div>"
		else
			dat += "<div class='statusDisplay'>No beaker inside, please insert beaker.</div>"

	var/datum/browser/popup = new(user, "biogen", name, 350, 520)
	popup.set_content(dat)
	popup.open()

/obj/machinery/biogenerator/proc/activate()
	if(processing)
		to_chat(usr, "<span class='warning'>The biogenerator is in the process of working.</span>")
		return

	var/S = 0
	for(var/obj/item/weapon/reagent_containers/food/snacks/grown/I in contents)
		S += 5
		if(I.reagents.get_reagent_amount("nutriment") < 0.1)
			points += 1*productivity
		else points += I.reagents.get_reagent_amount("nutriment")*10*productivity
		qdel(I)

	if(S)
		processing = 1
		update_icon()
		updateUsrDialog()
		playsound(src, 'sound/machines/blender.ogg', VOL_EFFECTS_MASTER, 35)
		use_power(S*30)
		sleep(S+15/productivity)
		processing = 0
		update_icon()
	else
		menustat = "void"

/obj/machinery/biogenerator/proc/check_cost(cost)
	if (cost > points)
		menustat = "nopoints"
		return 1
	else
		points -= cost
		processing = 1
		update_icon()
		updateUsrDialog()
		sleep(30)
		return 0

/obj/machinery/biogenerator/proc/create_product(create)
	switch(create)
		if("milk")
			if (check_cost(20/efficiency)) return 0
			else beaker.reagents.add_reagent("milk",10)
		if("cream")
			if (check_cost(30/efficiency)) return 0
			else beaker.reagents.add_reagent("cream",10)
		if("meat")
			if (check_cost(80/efficiency)) return 0
			else new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
		if("monkey")
			if(check_cost(250/efficiency)) return 0
			else new/obj/item/weapon/reagent_containers/food/snacks/monkeycube(src.loc)
		if("ez")
			if (check_cost(10/efficiency)) return 0
			else new/obj/item/nutrient/ez(src.loc)
		if("l4z")
			if (check_cost(20/efficiency)) return 0
			else new/obj/item/nutrient/l4z(src.loc)
		if("rh")
			if (check_cost(25/efficiency)) return 0
			else new/obj/item/nutrient/rh(src.loc)
		if("ez5") //It's not an elegant method, but it's safe and easy. -Cheridan
			if (check_cost(50/efficiency)) return 0
			else
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
				new/obj/item/nutrient/ez(src.loc)
		if("l4z5")
			if (check_cost(100/efficiency)) return 0
			else
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
				new/obj/item/nutrient/l4z(src.loc)
		if("rh5")
			if (check_cost(125/efficiency)) return 0
			else
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
				new/obj/item/nutrient/rh(src.loc)
		if("meat5")
			if (check_cost(400/efficiency)) return 0
			else
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
				new/obj/item/weapon/reagent_containers/food/snacks/meat(src.loc)
		if("wallet")
			if (check_cost(100/efficiency)) return 0
			else new/obj/item/weapon/storage/wallet(src.loc)
		//if("bkbag")
		//	if (check_cost(200/efficiency)) return 0
		//	else new/obj/item/weapon/storage/bag/books(src.loc)
		if("ptbag")
			if (check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/plants(src.loc)
		if("mnbag")
			if (check_cost(200/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/ore(src.loc)
		if("gloves")
			if (check_cost(250/efficiency)) return 0
			else new/obj/item/clothing/gloves/botanic_leather(src.loc)
		if("bshoes")
			if (check_cost(250/efficiency)) return 0
			else new/obj/item/clothing/shoes/brown(src.loc)
		if("tbelt")
			if (check_cost(300/efficiency)) return 0
			else new/obj/item/weapon/storage/belt/utility(src.loc)
		if("satchel")
			if (check_cost(400/efficiency)) return 0
			else new/obj/item/weapon/storage/backpack/satchel(src.loc)
		if("cashbag")
			if (check_cost(400/efficiency)) return 0
			else new/obj/item/weapon/storage/bag/cash(src.loc)
		if("jacket")
			if (check_cost(500/efficiency)) return 0
			else new/obj/item/clothing/suit/jacket/leather(src.loc)
		if("overcoat")
			if (check_cost(1000/efficiency)) return 0
			else new/obj/item/clothing/suit/jacket/leather/overcoat(src.loc)
	processing = 0
	menustat = "complete"
	update_icon()
	return 1

/obj/machinery/biogenerator/Topic(href, href_list)
	. = ..()
	if(!. || panel_open)
		return

	switch(href_list["action"])
		if("activate")
			activate()
		if("detach")
			if(beaker)
				beaker.loc = src.loc
				beaker = null
				update_icon()
		if("create")
			create_product(href_list["item"])
		if("menu")
			menustat = "menu"

	updateUsrDialog()
