#define NOT_BROKEN  0
#define HALF_BROKEN 1
#define FULL_BROKEN 2
#define MAX_DIRTY   100

/obj/machinery/kitchen_machine
	name = "Base Kitchen Machine"
	desc = "If you are seeing this, a coder/mapper messed up. Please report it."
	layer = DEFAULT_MACHINERY_LAYER
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	var/operating = FALSE // Is it on?
	var/dirty = 0 // {0 - MAX_DIRTY} Does it need cleaning?
	var/broken = NOT_BROKEN // How broken is it???
	var/efficiency = 0
	var/list/cook_verbs = list("Cooking")
	var/on_sound // the sound produced during operation
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
	..()

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
	if(!broken && dirty < MAX_DIRTY)
		if(default_deconstruction_screwdriver(user, open_icon, off_icon, O))
			return
		if(default_unfasten_wrench(user, O))
			return
		if(exchange_parts(user, O))
			return

	default_deconstruction_crowbar(O)

	if(broken)
		if(broken == FULL_BROKEN && iscutter(O)) // If it's broken and they're using a wirecutters.
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [src].</span>", \
				"<span class='notice'>You start to fix part of the [src].</span>" \
			)
			if(O.use_tool(src, user, 10 SECONDS, volume = 100))
				user.visible_message( \
					"<span class='notice'>[user] fixes part of the [src].</span>", \
					"<span class='notice'>You have fixed part of the [src].</span>" \
				)
				broken = HALF_BROKEN // Fix it a bit
				update_icon()
				return TRUE

		else if(broken == HALF_BROKEN && iswelding(O) && !user.is_busy(src)) // If it's broken and they're doing the weldingtool.
			user.visible_message( \
				"<span class='notice'>[user] starts to fix part of the [src].</span>", \
				"<span class='notice'>You start to fix part of the [src].</span>" \
			)
			if(O.use_tool(src, user, 10 SECONDS, volume = 100))
				user.visible_message( \
					"<span class='notice'>[user] fixes the [src].</span>", \
					"<span class='notice'>You have fixed the [src].</span>" \
				)
				broken = NOT_BROKEN // Fix it!
				update_icon()
				return TRUE
		else
			to_chat(user, "<span class='warning'>It doesn't react. Examine to find out the reason.</span>")
			return TRUE

	else if(istype(O, /obj/item/weapon/reagent_containers/spray))
		var/obj/item/weapon/reagent_containers/spray/clean_spray = O
		if(clean_spray.reagents.has_reagent("cleaner", clean_spray.amount_per_transfer_from_this))
			clean_spray.reagents.remove_reagent("cleaner", clean_spray.amount_per_transfer_from_this, TRUE)
			playsound(src, 'sound/effects/spray3.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -6)
			user.visible_message( \
				"<span class='notice'>[user] has cleaned [src].</span>", \
				"<span class='notice'>You have cleaned [src].</span>" \
			)
			dirty = 0 // It's clean!
			update_icon()
			return TRUE // Disables the after-attack so we don't spray the floor/user.

		else
			to_chat(user, "<span class='danger'>You need more space cleaner!</span>")
			return TRUE

	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/soap)) // If they're trying to clean it then let them
		user.visible_message( \
			"<span class='notice'>[user] starts to clean [src].</span>", \
			"<span class='notice'>You start to clean [src].</span>" \
		)
		if(O.use_tool(src, user, 2 SECONDS, volume = 100))
			user.visible_message( \
				"<span class='notice'>[user] has cleaned [src].</span>", \
				"<span class='notice'>You have cleaned [src].</span>" \
			)
			dirty = 0 // It's clean!
			update_icon()
			return TRUE

	else if(dirty == MAX_DIRTY) // The microwave is all dirty so can't be used!
		to_chat(user, "<span class='warning'>It doesn't react. Examine to find out the reason.</span>")
		return TRUE

	else if(is_type_in_list(O, acceptable_items))
		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='danger'>\The [src] is full of ingredients, you cannot put more.</span>")
			return TRUE

		var/obj/item/stack/S = O
		if(istype(S) && S.get_amount() > 1)
			new O.type (src)
			S.use(1)
			user.visible_message( \
				"<span class='notice'>[user] has added one of [O] to \the [src].</span>", \
				"<span class='notice'>You add one of [O] to \the [src].</span>")
		else
			user.drop_from_inventory(O, src)
			user.visible_message( \
				"<span class='notice'>[user] has added \the [O] to \the [src].</span>", \
				"<span class='notice'>You add \the [O] to \the [src].</span>")
		return TRUE

	else if(istype(O, /obj/item/weapon/reagent_containers))
		var/obj/item/weapon/reagent_containers/RC = O
		if(!RC.reagents)
			return TRUE
		for(var/datum/reagent/R in RC.reagents.reagent_list)
			if (!(R.id in acceptable_reagents))
				to_chat(user, "Your [RC] contains components unsuitable for cookery")
				return TRUE
		var/trans = RC.reagents.trans_to(src, RC.amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [src].</span>")

	else if(istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		to_chat(user, "<span class='danger'>You can not fit \the [G.affecting] in this [src].</span>")
		return TRUE
	else
		to_chat(user, "<span class='danger'>You have no idea what you can cook with this [O].</span>")
		return TRUE

/obj/machinery/kitchen_machine/attack_ai(mob/user)
	ui_interact(user, FALSE)

/*******************
*   Kitchen Machine Menu
********************/

/obj/machinery/kitchen_machine/ui_interact(mob/user, require_near = TRUE)
	if(user.is_busy())
		return
	if(!Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		return

	if(broken || dirty == MAX_DIRTY)
		to_chat(user, "<span class='warning'>It doesn't react. Examine to find out the reason.</span>")
		return
	else if(operating)
		to_chat(user, "<span class='notice'>Cooking in progress. Please wait!</span>")
		return
	else if(!length(contents) && !length(reagents.reagent_list))
		to_chat(user, "<span class='warning'>It's empty.</span>")
		return

	var/static/icon/radial_icons = 'icons/hud/radial.dmi'
	var/static/radial_on = image(icon = radial_icons, icon_state = "radial_on")
	var/static/radial_eject = image(icon = radial_icons, icon_state = "radial_eject")
	var/static/radial_info = image(icon = radial_icons, icon_state = "radial_info")
	var/list/options = list()

	options["Turn On"] = radial_on
	options["Eject Contents"] = radial_eject
	options["Check Contents"] = radial_info

	var/choice = show_radial_menu(user, src, options, require_near = require_near, tooltips = TRUE)

	switch(choice)
		if("Turn On")
			cook()
		if("Eject Contents")
			dispose()
		if("Check Contents")
			show_contents(user)

	update_icon()

/***********************************
*   Kitchen Machine Handling/Cooking
************************************/

/obj/machinery/kitchen_machine/proc/cook()
	if(stat & (NOPOWER|BROKEN))
		return
	start()
	if(!reagents.total_volume && !contents) //dry run
		if(!cook_process(10))
			abort()
			return
		stop()
		return

	var/datum/recipe/recipe = select_recipe(available_recipes, src)
	var/obj/cooked
	var/obj/byproduct
	if(!recipe)
		dirty += 1
		if(prob(max(10, dirty * 5)))
			if(!cook_process(4))
				abort()
				return
			playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER) // Play a splat sound
			cook_process(4)
			muck()
			cooked = fail()
			cooked.loc = loc
			return
		else if(has_extra_item())
			if(!cook_process(4))
				abort()
				return
			broke()
			cooked = fail()
			cooked.loc = loc
			return
		else
			if(!cook_process(10))
				abort()
				return
			stop()
			cooked = fail()
			cooked.loc = loc
			return
	else
		var/halftime = round(recipe.time / 10 / 2) // /10 is converting to seconds, /2 is halving
		if(!cook_process(halftime))
			abort()
			return
		if(!cook_process(halftime))
			abort()
			cooked = fail()
			cooked.loc = loc
			return
		cooked = recipe.make_food(src)
		byproduct = recipe.get_byproduct()
		stop()
		if(cooked)
			cooked.loc = loc
		for(var/i = 1, i < efficiency, i++)
			cooked = new cooked.type(loc)
		if(byproduct)
			new byproduct(loc)
		SSStatistics.score.meals++
		return

/obj/machinery/kitchen_machine/proc/cook_process(seconds)
	for(var/i = 1 to seconds)
		if(stat & (NOPOWER|BROKEN))
			return
		use_power(500)
		sleep(10)
	return TRUE

/obj/machinery/kitchen_machine/proc/has_extra_item()
	for(var/obj/O in contents)
		if( \
				!istype(O,/obj/item/weapon/reagent_containers/food) && \
				!istype(O, /obj/item/weapon/grown) \
			)
			return TRUE
	return

/obj/machinery/kitchen_machine/proc/start()
	visible_message("<span class='notice'>[src] turns on.</span>", "<span class='notice'>You hear a [src].</span>")
	operating = TRUE
	update_icon()
	if(on_sound)
		playsound(src, on_sound, VOL_EFFECTS_MASTER)
	return

/obj/machinery/kitchen_machine/proc/abort()
	operating = FALSE // Turn it off again aferwards
	update_icon()

/obj/machinery/kitchen_machine/proc/stop()
	playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
	abort()

/obj/machinery/kitchen_machine/proc/dispose()
	for(var/obj/O in contents)
		O.loc = loc
	if(reagents.total_volume)
		dirty++
	reagents.clear_reagents()
	to_chat(usr, "<span class='notice'>You dispose of [src] contents.</span>")

/obj/machinery/kitchen_machine/proc/muck()
	playsound(src, 'sound/machines/ding.ogg', VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'>[src] gets covered in muck!</span>")
	dirty = MAX_DIRTY // Make it dirty so it can't be used util cleaned
	abort()

/obj/machinery/kitchen_machine/proc/broke()
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	visible_message("<span class='warning'>[src] breaks!</span>") //Let them know they're stupid
	broken = FULL_BROKEN // Make it broken so it can't be used util fixed
	abort()

/obj/machinery/kitchen_machine/proc/fail()
	var/obj/item/weapon/reagent_containers/food/snacks/badrecipe/ffuu = new(src)
	var/amount = 0
	for(var/obj/O in contents-ffuu)
		amount++
		if(O.reagents)
			var/id = O.reagents.get_master_reagent_id()
			if (id)
				amount += O.reagents.get_reagent_amount(id)
		qdel(O)
	reagents.clear_reagents()
	ffuu.reagents.add_reagent("carbon", amount)
	ffuu.reagents.add_reagent("toxin", amount / 10)
	return ffuu

/obj/machinery/kitchen_machine/examine(mob/user)
	. = ..()
	if(dirty == MAX_DIRTY)
		to_chat(user, EMBED_TIP("<span class='warning'>It looks dirty. Maybe you should call a janitor?</span>", "Use a space cleaner or soap to clean this."))
	if(broken)
		to_chat(user, EMBED_TIP("<span class='warning'>It looks broken. Maybe you should call an engineer?</span>", "Use a wirecutters and welding tool to repair this."))
	show_contents(user)

/obj/machinery/kitchen_machine/proc/show_contents(mob/user)
	if(!length(contents) && !length(reagents.reagent_list))
		return
	to_chat(user, "<span class='notice'>It contains:</span>")
	var/list/items_counts = list()
	var/list/items_measures = list()
	var/list/items_measures_p = list()
	for(var/obj/O in contents)
		var/display_name = O.name
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/egg))
			items_measures[display_name] = "egg"
			items_measures_p[display_name] = "eggs"
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/tofu))
			items_measures[display_name] = "tofu chunk"
			items_measures_p[display_name] = "tofu chunks"
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/meat)) //any meat
			items_measures[display_name] = "slab of meat"
			items_measures_p[display_name] = "slabs of meat"
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/donkpocket))
			display_name = "Turnovers"
			items_measures[display_name] = "turnover"
			items_measures_p[display_name] = "turnovers"
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/carpmeat))
			items_measures[display_name] = "fillet of meat"
			items_measures_p[display_name] = "fillets of meat"
		items_counts[display_name]++
	for(var/O in items_counts)
		var/N = items_counts[O]
		if(!(O in items_measures))
			to_chat(user, "<span class='notice'>[capitalize(O)]: [N] [lowertext(O)]\s</span>")
		else
			if(N == 1)
				to_chat(user, "<span class='notice'>[capitalize(O)]: [N] [items_measures[O]]</span>")
			else
				to_chat(user, "<span class='notice'>[capitalize(O)]: [N] [items_measures_p[O]]</span>")

	for(var/datum/reagent/R in reagents.reagent_list)
		var/display_name = R.name
		if(R.id == "capsaicin")
			display_name = "Hotsauce"
		if(R.id == "frostoil")
			display_name = "Coldsauce"
		to_chat(user, "<span class='notice'>[display_name]: [R.volume] unit\s</span>")

/obj/machinery/kitchen_machine/update_icon()
	icon_state = off_icon
	if(broken)
		icon_state = broken_icon
	else if(dirty == MAX_DIRTY)
		icon_state = dirty_icon
	else if(panel_open)
		icon_state = open_icon
	else if(operating)
		icon_state = on_icon

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
	on_sound = 'sound/machines/microwave.ogg'

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
	on_sound = 'sound/machines/stove.ogg'

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
	on_sound = 'sound/machines/grill.ogg'

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
	on_sound = 'sound/machines/candy.ogg'

/obj/machinery/kitchen_machine/candymaker/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/candymaker(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()

#undef FULL_BROKEN
#undef HALF_BROKEN
#undef NOT_BROKEN
#undef MAX_DIRTY
