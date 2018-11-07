












/*
/obj/machinery/stove
	name = "Kitchen stove"
	desc = "Chef's best friend."
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	flags = OPENCONTAINER | NOREACT

	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???

	var/efficiency = 0

	var/list/cook_verbs = list("Cooking")

	var/list/pan_list
	var/list/pot_list
	var/list/oven_list

	//Recipe & Item vars
	var/recipe_type_oven = /datum/recipe/oven
	var/recipe_type_pot	= /datum/recipe/pot
	var/recipe_type_pan	= /datum/recipe/pan
	var/list/datum/recipe/available_recipes_oven // List of the recipes you can use
	var/list/datum/recipe/available_recipes_pot
	var/list/datum/recipe/available_recipes_pan
	var/list/acceptable_items // List of the items you can put in
	var/list/acceptable_reagents // List of the reagents you can put in
	var/max_n_of_items = 20

	//Icon states
	icon = 'icons/obj/food_and_drinks/machinery.dmi'
	icon_state = "oven_off"
	off_icon = "oven_off"
	on_icon = "oven_on"
	broken_icon = "oven_broke"
	dirty_icon = "oven_dirty"
	open_icon = "oven_open"

/*******************
*   Initialising
********************/

/obj/machinery/stove/atom_init()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/stove(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/random(null, 2)
	RefreshParts()
	reagents = new/datum/reagents(100)
	reagents.my_atom = src
	if(!available_recipes_oven ||!available_recipes_pot || !available_recipes_pan)
		available_recipes_oven = new
		available_recipes_pot = new
		available_recipes_pan = new
		acceptable_items = new
		acceptable_reagents = new
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/stove/atom_init_late()
	for(var/type in subtypesof(recipe_type_pan))
		var/datum/recipe/recipePAN = new type
		if(recipePAN.result) // Ignore recipe subtypes that lack a result
			available_recipes_pan += recipePAN
			for(var/item in recipePAN.items)
				acceptable_items |= item
			for(var/reagent in recipePAN.reagents)
				acceptable_reagents |= reagent
		else
			qdel(recipe)
	for(var/type in subtypesof(recipe_type_pot))
		var/datum/recipe/recipePOT = new type
		if(recipePOT.result) // Ignore recipe subtypes that lack a result
			available_recipes_pot += recipePOT
			for(var/item in recipePOT.items)
				acceptable_items |= item
			for(var/reagent in recipePOT.reagents)
				acceptable_reagents |= reagent
		else
			qdel(recipe)
	for(var/type in subtypesof(recipe_type_oven))
		var/datum/recipe/recipeOVEN = new type
		if(recipeOVEN.result) // Ignore recipe subtypes that lack a result
			available_recipes_oven += recipeOVEN
			for(var/item in recipeOVEN.items)
				acceptable_items |= item
			for(var/reagent in recipeOVEN.reagents)
				acceptable_reagents |= reagent
		else
			qdel(recipe)
	acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown


/obj/machinery/stove/RefreshParts()
	var/E
	var/max_items = 20
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		max_items = 20 * M.rating
	efficiency = E
	max_n_of_items = max_items

/*******************
*   Item Adding
********************/

/obj/machinery/stove/attackby(obj/item/O, mob/user)
	if(operating)
		return
	if(!broken && dirty<100)
		if(default_deconstruction_screwdriver(user, open_icon, off_icon, O))
			return
		if(default_unfasten_wrench(user, O))
			return
		if(exchange_parts(user, O))
			return

	default_deconstruction_crowbar(O)

	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/wirecutters)) // If it's broken and they're using a wirecutters.
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [src].</span>", \
				"<span class='notice'>You start to fix part of the [src].</span>" \
			)
			if (!user.is_busy(src) && do_after(user,20,target = src))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of the [src].</span>", \
					"<span class='notice'>You have fixed part of the [src].</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/weldingtool) && !user.is_busy(src)) // If it's broken and they're doing the weldingtool.
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [src].</span>", \
				"<span class='notice'>You start to fix part of the [src].</span>" \
			)
			if (!user.is_busy(src) && do_after(user,20,target = src))
				user.visible_message( \
					"<span class='notice'>[user] fixes the [src].</span>", \
					"<span class='notice'>You have fixed the [src].</span>" \
				)
				src.icon_state = off_icon
				src.broken = 0 // Fix it!
				src.dirty = 0 // just to be sure
				src.flags = OPENCONTAINER
				return 0 //to use some fuel
		else
			to_chat(user, "<span class='danger'>It's broken!</span>")
			return 1
	else if(istype(O, /obj/item/weapon/reagent_containers/spray/))
		var/obj/item/weapon/reagent_containers/spray/clean_spray = O
		if(clean_spray.reagents.has_reagent("cleaner",clean_spray.amount_per_transfer_from_this))
			clean_spray.reagents.remove_reagent("cleaner",clean_spray.amount_per_transfer_from_this,1)
			playsound(loc, 'sound/effects/spray3.ogg', 50, 1, -6)
			user.visible_message( \
				"<span class='notice'>[user] has cleaned [src].</span>", \
				"<span class='notice'>You have cleaned [src].</span>" \
			)
			src.dirty = 0 // It's clean!
			src.broken = 0 // just to be sure
			src.icon_state = off_icon
			src.flags = OPENCONTAINER
			src.updateUsrDialog()
			return 1 // Disables the after-attack so we don't spray the floor/user.
		else
			to_chat(user, "<span class='danger'>You need more space cleaner!</span>")
			return 1

	else if(istype(O, /obj/item/weapon/soap/)) // If they're trying to clean it then let them
		user.visible_message( \
			"<span class='notice'>[user] starts to clean [src].</span>", \
			"<span class='notice'>You start to clean [src].</span>" \
		)
		if (!user.is_busy(src) && do_after(user,20,target=src))
			user.visible_message( \
				"<span class='notice'>[user]  has cleaned [src].</span>", \
				"<span class='notice'>You have cleaned [src].</span>" \
			)
			src.dirty = 0 // It's clean!
			src.broken = 0 // just to be sure
			src.icon_state = off_icon
			src.flags = OPENCONTAINER
	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		to_chat(user, "\red It's dirty!")
		return 1
	else if(is_type_in_list(O,acceptable_items))
		if (contents.len>=max_n_of_items)
			to_chat(user, "<span class='danger'>This [src] is full of ingredients, you cannot put more.</span>")
			return 1
		var/choice = alert("Where do you want to put it?","Frying pan","Pot","Oven")
		if(choice == "Frying pan")
			var/obj/item/stack/S = O
			if (istype(S) && S.get_amount() > 1)
				var/obj/item/stack/NEWSTACK = new O.type (src)
				pan_list += NEWSTACK
				S.use(1)
				qdel(O)
				qdel(NEWSTACK)
				user.visible_message( \
					"<span class='notice'>[user] has added one of [O] to the frying pan.</span>", \
					"<span class='notice'>You add one of [O] to the frying pan.</span>")
			else
				pan_list += O
				qdel(O)
				qdel(NEWSTACK)
				user.visible_message( \
					"<span class='notice'>[user] has added \the [O] to the frying pan.</span>", \
					"<span class='notice'>You add \the [O] to the frying pan.</span>")
		if(choice == "Pot")
			var/obj/item/stack/S = O
			if (istype(S) && S.get_amount() > 1)
				var/obj/item/stack/NEWSTACK = new O.type (src)
				oven_list += NEWSTACK
				S.use(1)
				qdel(O)
				qdel(NEWSTACK)
				user.visible_message( \
					"<span class='notice'>[user] has added one of [O] to the oven.</span>", \
					"<span class='notice'>You add one of [O] to the oven.</span>")
			else
				oven_list += O
				qdel(O)
				user.visible_message( \
					"<span class='notice'>[user] has added \the [O] to the oven.</span>", \
					"<span class='notice'>You add \the [O] to the oven.</span>")
		if(choice == "Oven")
			var/obj/item/stack/S = O
			if (istype(S) && S.get_amount() > 1)
				var/obj/item/stack/NEWSTACK = new O.type (src)
				pot_list += NEWSTACK
				S.use(1)
				qdel(O)
				qdel(NEWSTACK)
				user.visible_message( \
					"<span class='notice'>[user] has added one of [O] to the pot.</span>", \
					"<span class='notice'>You add one of [O] to the pot.</span>")
			else
				pot_list += O
				qdel(O)
				qdel(NEWSTACK)
				user.visible_message( \
					"<span class='notice'>[user] has added \the [O] to the pot.</span>", \
					"<span class='notice'>You add \the [O] to the pot.</span>")
	else if(istype(O,/obj/item/weapon/reagent_containers/glass) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/drinks) || \
	        istype(O,/obj/item/weapon/reagent_containers/food/condiment) \
		)
		if (!O.reagents)
			return 1
		for (var/datum/reagent/R in O.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				to_chat(user, "Your [O] contains components unsuitable for cookery")
				return 1
		//G.reagents.trans_to(src,G.amount_per_transfer_from_this)
	else if(istype(O,/obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		to_chat(user, "<span class='danger'>You can not fit \the [G.affecting] in this [src].</span>")
		return 1
	else
		to_chat(user, "<span class='danger'>You have no idea what you can cook with this [O].</span>")
		return 1
	src.updateUsrDialog()

/obj/machinery/stove/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	return 0

/*******************
*   Stove Menu
********************/

/obj/machinery/stove/ui_interact(mob/user)
	var/dat = "<div class='statusDisplay'>"
	if(src.broken > 0)
		dat += "ERROR: >> 0 --Responce input zero<BR>Contact your operator of the device manifactor support.</div>"
	else if(src.operating)
		dat += "Cooking in progress!<BR>Please wait...!</div>"
	else if(src.dirty==100)
		dat += "ERROR: >> 0 --Responce input zero<BR>Contact your operator of the device manifactor support.</div>"
	else
		var/list/items_counts_pan = new
		var/list/items_measures_pan = new
		var/list/items_measures_p_pan = new
		var/list/items_counts_pot = new
		var/list/items_measures_pot = new
		var/list/items_measures_p_pot = new
		var/list/items_counts_oven = new
		var/list/items_measures_oven = new
		var/list/items_measures_p_oven = new
		for (var/obj/O in pan_list)
			var/display_name = O.name
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures_pan[display_name] = "egg"
				items_measures_p_pan[display_name] = "eggs"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures_pan[display_name] = "tofu chunk"
				items_measures_p_pan[display_name] = "tofu chunks"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures_pan[display_name] = "slab of meat"
				items_measures_p_pan[display_name] = "slabs of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures_pan[display_name] = "turnover"
				items_measures_p_pan[display_name] = "turnovers"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures_pan[display_name] = "fillet of meat"
				items_measures_p_pan[display_name] = "fillets of meat"
			items_counts_pan[display_name]++
		for (var/obj/V in pot_list)
			var/display_name = V.name
			if (istype(V,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures_pot[display_name] = "egg"
				items_measures_p_pot[display_name] = "eggs"
			if (istype(V,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures_pot[display_name] = "tofu chunk"
				items_measures_p_pot[display_name] = "tofu chunks"
			if (istype(V,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures_pot[display_name] = "slab of meat"
				items_measures_p_pot[display_name] = "slabs of meat"
			if (istype(V,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures_pot[display_name] = "turnover"
				items_measures_p_pot[display_name] = "turnovers"
			if (istype(V,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures_pot[display_name] = "fillet of meat"
				items_measures_p_pot[display_name] = "fillets of meat"
			items_counts_pot[display_name]++
		for (var/obj/C in oven_list)
			var/display_name = C.name
			if (istype(C,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures_oven[display_name] = "egg"
				items_measures_p_oven[display_name] = "eggs"
			if (istype(C,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures_oven[display_name] = "tofu chunk"
				items_measures_p_oven[display_name] = "tofu chunks"
			if (istype(C,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures_oven[display_name] = "slab of meat"
				items_measures_p_oven[display_name] = "slabs of meat"
			if (istype(C,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures_oven[display_name] = "turnover"
				items_measures_p_oven[display_name] = "turnovers"
			if (istype(C,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures_oven[display_name] = "fillet of meat"
				items_measures_p_oven[display_name] = "fillets of meat"
			items_counts_oven[display_name]++
		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == "capsaicin")
				display_name = "Hotsauce"
			if (R.id == "frostoil")
				display_name = "Coldsauce"
			dat += "[display_name]: [R.volume] unit\s<BR>"
		if (pan_list.len==0 && reagents.reagent_list.len==0)
			dat += "Frying pan is empty.<BR>"
		else
			var/dat_pan
			for (var/O in pan_list)
				var/N = items_counts_pan[O]
				if (!(O in items_measures_pan))
					dat_pan += "*[capitalize(O)]: [N] [lowertext(O)]\s<BR>"
				else
					if (N==1)
						dat_pan += "*[capitalize(O)]: [N] [items_measures_pan[O]]<BR>"
					else
						dat_pan += "*[capitalize(O)]: [N] [items_measures_p_pan[O]]<BR>"
			dat += "<h3>Frying pan contests:</h3>[dat_pan]<BR>"
		if (pot_list.len==0 && reagents.reagent_list.len==0)
			dat += "Pot is empty.<BR>"
		else
			var/dat_pot
			for (var/D in pot_list)
				var/T = items_counts_pot[D]
				if (!(D in items_measures_pot))
					dat_pot += "*[capitalize(D)]: [T] [lowertext(D)]\s<BR>"
				else
					if (T==1)
						dat_pot += "*[capitalize(D)]: [T] [items_measures_pot[D]]<BR>"
					else
						dat_pot += "*[capitalize(D)]: [T] [items_measures_p_pot[D]]<BR>"
			dat += "<h3>Pot contests:</h3>[dat_pot]<BR>"
		if (oven_list.len==0 && reagents.reagent_list.len==0)
			dat += "Oven is empty.</div>"
		else
			var/dat_oven
			for (var/Q in oven_list)
				var/K = items_counts_oven[Q]
				if (!(Q in items_measures))
					dat_oven += "*[capitalize(Q)]: [K] [lowertext(Q)]\s<BR>"
				else
					if (K==1)
						dat_oven += "*[capitalize(Q)]: [K] [items_measures_oven[Q]]<BR>"
					else
						dat_oven += "*[capitalize(Q)]: [K] [items_measures_p_oven[Q]]<BR>"
			dat += "<h3>Oven contests:</h3>[dat_oven]</div>"
		dat += "<A href='?src=\ref[src];action=stove_turnon'>Turn on the stove</A><BR>"
		dat += "<A href='?src=\ref[src];action=oven_turnon'>Turn on the oven</A><BR>"
		dat += "<A href='?src=\ref[src];action=dispose'>Eject ingredients</A>"

	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "[name]")

/***********************************
*   Stove Handling/Cooking
************************************/

/obj/machinery/stove/proc/oven_turnon()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if (reagents.total_volume==0 && !(locate(/obj) in contents)) //dry run
		if (!cook_process(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes,src)
	var/obj/cooked
	var/obj/byproduct
	if (!recipe)
		dirty += 1
		if (prob(max(10,dirty*5)))
			if (!cook_process(4))
				abort()
				return
			muck_start()
			cook_process(4)
			muck_finish()
			cooked = fail()
			cooked.loc = src.loc
			return
		else if (has_extra_item())
			if (!cook_process(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.loc = src.loc
			return
		else
			if (!cook_process(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.loc = src.loc
			return
	else
		var/halftime = round(recipe.time/10/2)
		if (!cook_process(halftime))
			abort()
			return
		if (!cook_process(halftime))
			abort()
			cooked = fail()
			cooked.loc = src.loc
			return
		cooked = recipe.make_food(src)
		byproduct = recipe.get_byproduct()
		stop()
		if(cooked)
			cooked.loc = src.loc
		for(var/i=1,i<efficiency,i++)
			cooked = new cooked.type(loc)
		if(byproduct)
			new byproduct(loc)
		score["meals"]++
		return

/obj/machinery/kitchen_machine/proc/cook_process(seconds)
	for (var/i=1 to seconds)
		if (stat & (NOPOWER|BROKEN))
			return 0
		use_power(500)
		sleep(10)
	return 1

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for (var/obj/O in contents)
		if ( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return 1
	return 0

/obj/machinery/kitchen_machine/proc/start()
	src.visible_message("\blue [src] turns on.", "\blue You hear a [src].")
	src.operating = 1
	src.icon_state = on_icon
	src.updateUsrDialog()
	if(on_icon == "mw1")
		playsound(src.loc, 'sound/machines/microwave.ogg', 70)
	if(on_icon == "oven_on")
		playsound(src.loc, 'sound/machines/stove.ogg', 80)
	if(on_icon == "candymaker_on")
		playsound(src.loc, 'sound/machines/candy.ogg', 90)
	if(on_icon == "grill_on")
		playsound(src.loc, 'sound/machines/grill.ogg', 80)
	return

/obj/machinery/kitchen_machine/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = off_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/stop()
	playsound(src.loc, 'sound/machines/ding.ogg', 60, 1)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = off_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	if (src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	to_chat(usr, "\blue You dispose of [src] contents.")
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1) // Play a splat sound
	src.icon_state = dirty_icon // Make it look dirty!!

/obj/machinery/kitchen_machine/proc/muck_finish()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	src.visible_message("\red [src] gets covered in muck!")
	src.dirty = 100 // Make it dirty so it can't be used util cleaned
	src.flags = null //So you can't add condiments
	src.icon_state = dirty_icon // Make it look dirty too
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	src.icon_state = broken_icon // Make it look all busted up and shit
	src.visible_message("\red [src] breaks!") //Let them know they're stupid
	src.broken = 2 // Make it broken so it can't be used util fixed
	src.flags = null //So you can't add condiments
	src.operating = 0 // Turn it off again aferwards
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for (var/obj/O in contents-ffuu)
		amount++
		if (O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount+=O.reagents.get_reagent_amount(id)
		qdel(O)
	src.reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("toxin", amount/10)
	return ffuu

/obj/machinery/kitchen_machine/Topic(href, href_list)
	. = ..()
	if(!. || panel_open)
		return FALSE

	if(src.operating)
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("cook")
			cook()

		if ("dispose")
			dispose()
	updateUsrDialog()
