/var/list/reagentfillings_icon_cache = list()

/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = ITEM_SIZE_SMALL
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/list/list_reagents = null
	var/volume = 30

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/atom_init()
	. = ..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	var/datum/reagents/R = new/datum/reagents(volume)
	reagents = R
	R.my_atom = src
	add_initial_reagents()

/obj/item/weapon/reagent_containers/proc/add_initial_reagents()
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/weapon/reagent_containers/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM) // Since we usually splash mobs or whatever, now we will also hit them.
		..()

/obj/item/weapon/reagent_containers/afterattack(atom/target, mob/user, proximity, params)
	return

/obj/item/weapon/reagent_containers/proc/reagentlist(obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for (var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] units); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else return "No reagents"

/obj/item/weapon/reagent_containers/proc/show_filler_on_icon(filler_margin_y, filler_height, current_offset)
/*
	Show containers content on icon
	filler_icon_y_position - Y-indent. Array in Byond start at 1.
	filler_margin_y - height of a liquid column
*/
	if(reagents.total_volume == 0)
		underlays.Cut()
		return

	var/offset = round((reagents.total_volume / volume) * filler_height) + filler_margin_y
	if(offset == current_offset)	// If height of a liquid column isn't changed
		return current_offset

	if (offset == filler_margin_y)		// if content exist, but not it is enough to 1 pixel
		offset++		// let it will be 1 pixel

	var/icon/filler = get_filler(offset)	 // get height of a liquid column from cache or generate it

	underlays.Cut()
	underlays += filler

	current_offset = offset
	return current_offset

/obj/item/weapon/reagent_containers/proc/get_filler(offset)
/*
	Get height of a liquid column from cache or generate it
	We get 2 sprites for drawing : the transparent places of a container and pink square.
	The pink square crop a liquid column using offset.
*/
	var/cached_icon_string = "[src.icon_state]||[offset]"
	var/image/filler

	if(cached_icon_string in reagentfillings_icon_cache)
		filler = reagentfillings_icon_cache[cached_icon_string]
	else
		var/icon/I = new('icons/obj/reagentfillings.dmi',src.icon_state)		// transparent places sprite
		var/icon/cut = new('icons/obj/reagentfillings.dmi', "cut")		//  pink square sprite

		I.Blend(cut, ICON_OVERLAY, 1, offset)		// We superimpose a pink square offsetting it
		I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))		// delete pink
		reagentfillings_icon_cache[cached_icon_string] = image(I, icon_state)		// Save to cache
		filler = reagentfillings_icon_cache[cached_icon_string]

	var/list/mc = ReadRGB(mix_color_from_reagents(reagents.reagent_list))
	filler.color = RGB_CONTRAST(mc[1], mc[2], mc[3])		// paint in color of drink
	return filler
