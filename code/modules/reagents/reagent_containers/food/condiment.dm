///------------//
///            //
/// Condiments //
///            //
///------------//
//The condiments food-subtype is for stuff you don't actually eat but you use to modify existing food. They all
//leave empty containers when used up and can be filled/re-filled with other items. Formatting for first section is identical
//to mixed-drinks code. If you want an object that starts pre-loaded, you need to make it in addition to the other code.
//
//			LIST:
//
//	*Condiment Shelf
//
//	Sacks
//	*Flour sack
//	*Sugar sack
//	*Rice sack
//
//	Sauces
//	*Soy sauce
//	*Hot sauce
//	*Ketchup
//	*Cold sauce
//	*Corn oil
//
//	Supplements(topics)
//	*Universal enzyme
//	*Salt shaker
//	*Pepper mill
//	*Honey pot
//
///-----------//

/obj/item/weapon/reagent_containers/food/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/condiments.dmi'
	icon_state = "condiment"
	flags = OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50
	var/empty_icon = "condiment" // Empty state icon

/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/living/M, mob/user, def_zone)
	if(!CanEat(user, M, src, "swallow")) return

	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		to_chat(user, "<span class='rose'> None of [src] left, oh no!</span>")
		return 0

	if(isliving(M))
		var/mob/living/L = M
		if(taste)
			L.taste_reagents(reagents)
	if(M == user)
		to_chat(M, "<span class='notice'> You swallow some of contents of the [src].</span>")
		if(reagents.total_volume)
			reagents.trans_to_ingest(M, 10)

		playsound(M, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
		return 1
	else
		user.visible_message("<span class='rose'> [user] attempts to feed [M] [src].</span>")
		if(!do_mob(user, M)) return
		user.visible_message("<span class='rose'> [user] feeds [M] [src].</span>")

		M.log_combat(user, "fed with [name] (INTENT: [uppertext(user.a_intent)])")

		if(reagents.total_volume)
			reagents.trans_to_ingest(M, 10)

		playsound(M,'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
		return 1

/obj/item/weapon/reagent_containers/food/condiment/afterattack(atom/target, mob/user, proximity, params)
	if(get_dist(src, target) > 1)
		return
	if(istype(target, /obj/structure/reagent_dispensers)) // A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='rose'> [target] is empty.</span>")
			return
		if (!reagents.maximum_volume)
			to_chat(user, "<span class='rose'> [src] can't hold this.</span>")
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='rose'> [src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You fill [src] with [trans] units of the contents of [target].</span>")

	// Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='rose'> [src] is empty.</span>")
			return
		if (!target.reagents.maximum_volume)
			to_chat(user, "<span class='rose'> [target] can't hold this.</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='rose'> you can't add anymore to [target].</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You transfer [trans] units of the condiment to [target].</span>")

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change()
	if((!reagents || (reagents && !reagents.reagent_list.len)) && empty_icon)
		icon_state = empty_icon
		return

	if(reagents.reagent_list.len == 1) // So here we change the desc if condiment contains multiple reagents
		desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
	else if(reagents.reagent_list.len > 0)
		desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."

///////////////////
//Condiment Shelf//
///////////////////
// Placed in the kitchen
/obj/item/weapon/condiment_shelf
	name = "condiment shelf"
	desc = "Its a small wooden shelf for spices and seasonings. All you need is to place it onto the wall. Buon appetito!"
	icon = 'icons/obj/cond_shelf.dmi'
	icon_state = "cond_shelf_item"
	w_class = ITEM_SIZE_NORMAL
	force = 8
	throwforce = 10
	throw_speed = 2
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/condiment_shelf/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		new /obj/item/stack/sheet/wood(loc)
		qdel(src)
		return

	if(istype(I, /obj/item/weapon/reagent_containers/food/condiment))
		to_chat(user, "<span class='rose'>You need to place it onto the wall first!</span>")
		return

	return ..()

/obj/item/weapon/condiment_shelf/afterattack(atom/target, mob/user, proximity, params)
	var/turf/T = target
	if(get_dist(T, user) > 1)
		return
	if(!istype(T, /turf/simulated/wall))
		return
	var/ndir = get_dir(user, T)
	if(!(ndir in cardinal))
		return
	user.visible_message("<span class='notice'>[user] fastens [src] to \the [T].</span>",
						 "<span class='notice'>You attach [src] to \the [T].</span>")
	new /obj/structure/condiment_shelf(get_turf(user), ndir, 1)
	qdel(src)

/obj/structure/condiment_shelf
	name = "condiment shelf"
	desc = "Its a small wooden shelf for spices and seasonings. Buon appetito!"
	icon = 'icons/obj/cond_shelf.dmi'
	icon_state = "cond_shelf"
	anchored = TRUE
	density = FALSE
	opacity = FALSE

	var/max_items_inside = 6
	var/list/can_be_placed = list(/obj/item/weapon/reagent_containers/food/condiment,
								/obj/item/weapon/reagent_containers/food/condiment/sugar,
								/obj/item/weapon/reagent_containers/food/condiment/rice,
								/obj/item/weapon/reagent_containers/food/condiment/soysauce,
								/obj/item/weapon/reagent_containers/food/condiment/hotsauce,
								/obj/item/weapon/reagent_containers/food/condiment/ketchup,
								/obj/item/weapon/reagent_containers/food/condiment/coldsauce,
								/obj/item/weapon/reagent_containers/food/condiment/cornoil,
								/obj/item/weapon/reagent_containers/food/condiment/enzyme,
								/obj/item/weapon/reagent_containers/food/condiment/saltshaker,
								/obj/item/weapon/reagent_containers/food/condiment/peppermill)

/obj/structure/condiment_shelf/atom_init(mapload, ndir, building = 0)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc)
			if(I.type in can_be_placed)
				if(contents.len < max_items_inside)
					I.loc = src
	if(building)
		pixel_x = (ndir & 3)? 0 : (ndir == EAST ? 32 : -32)
		pixel_y = (ndir & 3)? (ndir == NORTH ? 32 : -32) : 0
	update_icon()

/obj/structure/condiment_shelf/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/wrench))
		if(user.is_busy())
			return
		user.visible_message("<span class='warning'>[user] starts to disassemble \the [src].</span>")
		if(do_after(user, 20, target = src))
			playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
			new /obj/item/weapon/condiment_shelf(src.loc)
			for(var/obj/item/I in contents)
				I.forceMove(get_turf(src))
			qdel(src)
		return

	if(O.type in can_be_placed)
		if(contents.len < max_items_inside)
			user.drop_item()
			O.forceMove(src)
			update_icon()
		else
			to_chat(user, "<span class='rose'>\The [src] is full!</span>")
	else
		to_chat(user, "<span class='rose'>What? This shelf is only for spices and sauces!</span>")

/obj/structure/condiment_shelf/attack_hand(mob/user)
	if(contents.len)
		var/obj/item/weapon/reagent_containers/food/condiment/choice = input("Which condiment would you like to remove from the shelf?") in contents
		if(choice)
			if(!in_range(loc, usr) || usr.incapacitated())
				return
			if(ishuman(user))
				user.put_in_hands(choice)
			else
				choice.forceMove(get_turf(src))
			update_icon()

/obj/structure/condiment_shelf/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/weapon/reagent_containers/food/condiment/b in contents)
				qdel(b)
			qdel(src)
		if(2.0)
			for(var/obj/item/weapon/reagent_containers/food/condiment/b in contents)
				if(prob(50))
					b.forceMove(get_turf(src))
				else qdel(b)
			qdel(src)
		if(3.0)
			if(prob(50))
				for(var/obj/item/weapon/reagent_containers/food/condiment/b in contents)
					b.forceMove(get_turf(src))
				qdel(src)

/obj/structure/condiment_shelf/update_icon()
	cut_overlays()
	if(!contents.len)
		return
	var/cond_number = 0
	for(var/obj/item/F in contents)
		if(F.type in can_be_placed)
			var/mutable_appearance/condiment = mutable_appearance(icon, "[initial(F.icon_state)]")
			condiment.pixel_x += cond_number
			add_overlay(condiment)
			cond_number += 4

//////////////////////
//LIST OF CONDIMENTS//
//////////////////////

// SACKS

/obj/item/weapon/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A small bag filled with some flour."
	icon_state = "flour"
	item_state = "flour"
	empty_icon = "flour_empty"
	list_reagents = list("flour" = 30)

/obj/item/weapon/reagent_containers/food/condiment/sugar
	name = "sugar sack"
	desc = "Tastey space sugar!"
	icon_state = "sugar"
	item_state = "sugar"
	empty_icon = "sugar_empty"
	list_reagents = list("sugar" = 40)

/obj/item/weapon/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "Salt. From space oceans, presumably. Good for cooking!"
	icon_state = "rice"
	item_state = "rice"
	empty_icon = "rice_empty"
	list_reagents = list("rice" = 30)

// SAUCES

/obj/item/weapon/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	empty_icon = "soysauce_empty"
	list_reagents = list("soysauce" = 40)

/obj/item/weapon/reagent_containers/food/condiment/hotsauce
	name = "hot sauce"
	desc = "You can almost TASTE the stomach ulcers now!"
	icon_state = "hotsauce"
	empty_icon = "hotsauce_empty"
	list_reagents = list("capsaicin" = 30)

/obj/item/weapon/reagent_containers/food/condiment/ketchup
	name = "ketchup"
	desc = "You feel more American already."
	icon_state = "ketchup"
	empty_icon = "ketchup_empty"
	list_reagents = list("ketchup" = 50)

/obj/item/weapon/reagent_containers/food/condiment/coldsauce
	name = "cold sauce"
	desc = "Leaves the tongue numb in its passage."
	icon_state = "coldsauce"
	list_reagents = list("frostoil" = 30)

/obj/item/weapon/reagent_containers/food/condiment/cornoil
	name = "corn oil"
	desc = "A delicious oil used in cooking. Made from corn."
	icon_state = "cornoil"
	empty_icon = "cornoil_empty"
	list_reagents = list("cornoil" = 40)

// SUPPLEMENTS

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	item_state = "enzyme"
	empty_icon = "enzyme_empty"
	list_reagents = list("enzyme" = 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker
	name = "salt shaker"
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	empty_icon = "saltshakersmall_empty"
	possible_transfer_amounts = list(1,20) // for the clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) // for the clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)

/obj/item/weapon/reagent_containers/food/condiment/honey
	name = "honey pot"
	desc = "Sweet and healthy!"
	icon_state = "honey"
	list_reagents = list("honey" = 40)
