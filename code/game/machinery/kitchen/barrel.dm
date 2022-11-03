/obj/machinery/kitchen_machine/barrel
	name = "barrel"
	desc = "The stuff of nightmares for a dentist."
	icon = 'icons/obj/objects.dmi'
	icon_state = "beertankTEMP"
	recipe_type = /datum/recipe/barrel
	off_icon = "beertankTEMP"
	on_icon = "beertankTEMP"
	broken_icon = "beertankTEMP"
	dirty_icon = "beertankTEMP"
	open_icon = "beertankTEMP"

/obj/machinery/kitchen_machine/barrel/fail()
	if(!reagents.total_volume)
		return ..()
	/*
	need food for fermentation
	if you have more recipes of draft alcohol, add this or id of your fructose:
	!reagents.has_reagent("honey") && !reagents.has_reagent("sugar", 5) && !reagents.has_reagent("nutriment", 10)
	*/
	if(!reagents.has_reagent("adelhyde", 5))
		return ..()
	var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/mash/braga = new(src)
	reagents.copy_to(braga, 25)
	reagents.clear_reagents()
	return braga
