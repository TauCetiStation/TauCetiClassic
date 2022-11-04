/obj/machinery/kitchen_machine/barrel
	name = "barrel"
	desc = "A modern device for the rapid transformation of wort into an alcoholic drink."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "barrel_off"
	recipe_type = /datum/recipe/barrel
	off_icon = "barrel_off"
	on_icon = "barrel_on"
	broken_icon = "barrel_broke"
	dirty_icon = "barrel_dirty"
	open_icon = "barrel_generic"

/obj/machinery/kitchen_machine/barrel/default_deconstruction_crowbar()
	return FALSE

/obj/machinery/kitchen_machine/barrel/default_deconstruction_screwdriver()
	return FALSE

/obj/machinery/kitchen_machine/barrel/fail()
	if(!reagents.total_volume)
		return ..()
	/*
	need enzyme and food for fermentation
	if you have more recipes of draft alcohol, add this or id of your fructose:
	!reagents.has_reagent("honey") && !reagents.has_reagent("sugar", 5) && !reagents.has_reagent("nutriment", 10)
	*/
	if(!reagents.has_reagent("adelhyde", 5) || !reagents.has_reagent("enzyme"))
		return ..()
	var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/mash/alcomash = new(src)
	reagents.copy_to(alcomash, 25)
	reagents.clear_reagents()
	return alcomash
