/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	layer = 2.9
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	flags = OPENCONTAINER | NOREACT
	var/operating = 0 // Is it on?
	var/dirty = 0 // = {0..100} Does it need cleaning?
	var/broken = 0 // ={0,1,2} How broken is it???
	var/efficiency = 0
	var/list/cook_verbs = list("Cooking")
	//Recipe & Item vars
	var/recipe_type		//Make sure to set this on the machine definition, or else you're gonna runtime on New()
	var/list/datum/recipe/available_recipes // List of the recipes you can use
	var/list/acceptable_items // List of the items you can put in
	var/list/acceptable_reagents // List of the reagents you can put in
	var/max_n_of_items = 10
	//Icon states
	var/off_icon
	var/on_icon
	var/broken_icon
	var/dirty_icon
	var/open_icon

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/atom_init()
	..()
	reagents = new/datum/reagents(100)
	reagents.my_atom = src
	if(!available_recipes)
		available_recipes = new
		acceptable_items = new
		acceptable_reagents = new
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/kitchen_machine/atom_init_late()
	for(var/type in subtypesof(recipe_type))
		var/datum/recipe/recipe = new type
		if(recipe.result) // Ignore recipe subtypes that lack a result
			available_recipes += recipe
			for(var/item in recipe.items)
				acceptable_items |= item
			for(var/reagent in recipe.reagents)
				acceptable_reagents |= reagent
		else
			qdel(recipe)
	acceptable_items |= /obj/item/weapon/reagent_containers/food/snacks/grown

/obj/machinery/kitchen_machine/RefreshParts()
	var/E
	var/max_items = 10
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		max_items = 10 * M.rating
	efficiency = E
	max_n_of_items = max_items

/*******************
*   Item Adding
********************/

/obj/machinery/kitchen_machine/attackby(obj/item/O, mob/user)
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
		if(src.broken == 2 && iswirecutter(O)) // If it's broken and they're using a wirecutters.
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [src].</span>", \
				"<span class='notice'>You start to fix part of the [src].</span>" \
			)
			if (!user.is_busy(src) && O.use_tool(src, user, 20, volume = 100))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of the [src].</span>", \
					"<span class='notice'>You have fixed part of the [src].</span>" \
				)
				src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && iswelder(O) && !user.is_busy(src)) // If it's broken and they're doing the weldingtool.
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [src].</span>", \
				"<span class='notice'>You start to fix part of the [src].</span>" \
			)
			if (!user.is_busy(src) && O.use_tool(src, user, 20, volume = 100))
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
	else if(istype(O, /obj/item/weapon/reagent_containers/spray))
		var/obj/item/weapon/reagent_containers/spray/clean_spray = O
		if(clean_spray.reagents.has_reagent("cleaner",clean_spray.amount_per_transfer_from_this))
			clean_spray.reagents.remove_reagent("cleaner",clean_spray.amount_per_transfer_from_this,1)
			playsound(src, 'sound/effects/spray3.ogg', VOL_EFFECTS_MASTER, null, null, -6)
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

	else if(istype(O, /obj/item/weapon/soap)) // If they're trying to clean it then let them
		user.visible_message( \
			"<span class='notice'>[user] starts to clean [src].</span>", \
			"<span class='notice'>You start to clean [src].</span>" \
		)
		if (!user.is_busy(src) && O.use_tool(src, user, 20, volume = 100))
			user.visible_message( \
				"<span class='notice'>[user]  has cleaned [src].</span>", \
				"<span class='notice'>You have cleaned [src].</span>" \
			)
			src.dirty = 0 // It's clean!
			src.broken = 0 // just to be sure
			src.icon_state = off_icon
			src.flags = OPENCONTAINER
	else if(src.dirty==100) // The microwave is all dirty so can't be used!
		to_chat(user, "<span class='warning'>It's dirty!</span>")
		return 1
	else if(is_type_in_list(O,acceptable_items))
		if (contents.len>=max_n_of_items)
			to_chat(user, "<span class='danger'>Tihs [src] is full of ingredients, you cannot put more.</span>")
			return 1
		var/obj/item/stack/S = O
		if (istype(S) && S.get_amount() > 1)
			new O.type (src)
			S.use(1)
			user.visible_message( \
				"<span class='notice'>[user] has added one of [O] to \the [src].</span>", \
				"<span class='notice'>You add one of [O] to \the [src].</span>")
		else
			user.drop_item(src)
			user.visible_message( \
				"<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")
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

/obj/machinery/kitchen_machine/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	return 0

/*******************
*   Kitchen Machine Menu
********************/

/obj/machinery/kitchen_machine/ui_interact(mob/user)
	var/dat = "<div class='statusDisplay'>"
	if(src.broken > 0)
		dat += "ERROR: >> 0 --Responce input zero<BR>Contact your operator of the device manifactor support.</div>"
	else if(src.operating)
		dat += "Cooking in progress!<BR>Please wait...!</div>"
	else if(src.dirty==100)
		dat += "ERROR: >> 0 --Responce input zero<BR>Contact your operator of the device manifactor support.</div>"
	else
		var/list/items_counts = new
		var/list/items_measures = new
		var/list/items_measures_p = new
		for (var/obj/O in contents)
			var/display_name = O.name
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg))
				items_measures[display_name] = "egg"
				items_measures_p[display_name] = "eggs"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/tofu))
				items_measures[display_name] = "tofu chunk"
				items_measures_p[display_name] = "tofu chunks"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
				items_measures[display_name] = "slab of meat"
				items_measures_p[display_name] = "slabs of meat"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/donkpocket))
				display_name = "Turnovers"
				items_measures[display_name] = "turnover"
				items_measures_p[display_name] = "turnovers"
			if (istype(O,/obj/item/weapon/reagent_containers/food/snacks/carpmeat))
				items_measures[display_name] = "fillet of meat"
				items_measures_p[display_name] = "fillets of meat"
			items_counts[display_name]++
		for (var/O in items_counts)
			var/N = items_counts[O]
			if (!(O in items_measures))
				dat += "[capitalize(O)]: [N] [lowertext(O)]\s<BR>"
			else
				if (N==1)
					dat += "[capitalize(O)]: [N] [items_measures[O]]<BR>"
				else
					dat += "[capitalize(O)]: [N] [items_measures_p[O]]<BR>"

		for (var/datum/reagent/R in reagents.reagent_list)
			var/display_name = R.name
			if (R.id == "capsaicin")
				display_name = "Hotsauce"
			if (R.id == "frostoil")
				display_name = "Coldsauce"
			dat += "[display_name]: [R.volume] unit\s<BR>"

		if (items_counts.len==0 && reagents.reagent_list.len==0)
			dat += "[src] is empty.</div>"
		else
			dat = "<h3>Ingredients:</h3>[dat]</div>"
		dat += "<A href='?src=\ref[src];action=cook'>Turn on</A>"
		dat += "<A href='?src=\ref[src];action=dispose'>Eject ingredients</A>"

	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "[name]")

/***********************************
*   Kitchen Machine Handling/Cooking
************************************/

/obj/machinery/kitchen_machine/proc/cook()
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
	src.visible_message("<span class='notice'>[src] turns on.</span>", "<span class='notice'>You hear a [src].</span>")
	src.operating = 1
	src.icon_state = on_icon
	src.updateUsrDialog()
	if(on_icon == "mw1")
		playsound(src, 'sound/machines/microwave.ogg', VOL_EFFECTS_MASTER)
	if(on_icon == "oven_on")
		playsound(src, 'sound/machines/stove.ogg', VOL_EFFECTS_MASTER)
	if(on_icon == "candymaker_on")
		playsound(src, 'sound/machines/candy.ogg', VOL_EFFECTS_MASTER)
	if(on_icon == "grill_on")
		playsound(src, 'sound/machines/grill.ogg', VOL_EFFECTS_MASTER)
	return

/obj/machinery/kitchen_machine/proc/abort()
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = off_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/stop()
	playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
	src.operating = 0 // Turn it off again aferwards
	src.icon_state = off_icon
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/dispose()
	for (var/obj/O in contents)
		O.loc = src.loc
	if (src.reagents.total_volume)
		src.dirty++
	src.reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of [src] contents.</span>")
	src.updateUsrDialog()

/obj/machinery/kitchen_machine/proc/muck_start()
	playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER) // Play a splat sound
	src.icon_state = dirty_icon // Make it look dirty!!

/obj/machinery/kitchen_machine/proc/muck_finish()
	playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
	src.visible_message("<span class='warning'>[src] gets covered in muck!</span>")
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
	src.visible_message("<span class='warning'>[src] breaks!</span>") //Let them know they're stupid
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

/*******************
*   Microwave
********************/

/obj/machinery/kitchen_machine/microwave
	name = "microwave"
	desc = "A microwave, perfect for reheating things with radiation."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"
	recipe_type = /datum/recipe/microwave
	off_icon = "mw"
	on_icon = "mw1"
	broken_icon = "mwb"
	dirty_icon = "mwbloody"
	open_icon = "mw-o"

/obj/machinery/kitchen_machine/microwave/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/microwave(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "oven_off"
	recipe_type = /datum/recipe/oven
	off_icon = "oven_off"
	on_icon = "oven_on"
	broken_icon = "oven_broke"
	dirty_icon = "oven_dirty"
	open_icon = "oven_open"

/obj/machinery/kitchen_machine/oven/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/oven(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grill_off"
	recipe_type = /datum/recipe/grill
	off_icon = "grill_off"
	on_icon = "grill_on"
	broken_icon = "grill_broke"
	dirty_icon = "grill_dirty"
	open_icon = "grill_open"

/obj/machinery/kitchen_machine/grill/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/grill(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()

/obj/machinery/kitchen_machine/candymaker
	name = "candy machine"
	desc = "The stuff of nightmares for a dentist."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "candymaker_off"
	recipe_type = /datum/recipe/candy
	off_icon = "candymaker_off"
	on_icon = "candymaker_on"
	broken_icon = "candymaker_broke"
	dirty_icon = "candymaker_dirty"
	open_icon = "candymaker_open"

/obj/machinery/kitchen_machine/candymaker/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/candymaker(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()
