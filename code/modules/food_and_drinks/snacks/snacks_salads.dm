
///-----------------------------------------------------//
///														//
///						Salads							//
///		Food items made mixing ingridients in bowls.	//
///		For example - raw meat isn't snack.				//
///														//
///-----------------------------------------------------//

//Salad Bowl

/obj/item/weapon/bowl
	name = "kitchen bowl"
	desc = "It's a large deep pot, usually is used to make salads.
	icon = 'icons/obj/food_and_drinks/tools.dmi'
	icon_state = "bowl"
	w_class = 3
	throw_speed = 1
	throw_range = 3
	var/new_ingridient = null

/obj/item/weapon/bowl/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		user.drop_item()
		O.loc = src
		update_icon()
	else
		..()

/obj/item/weapon/bowl/attack_hand(mob/user)
	if(contents.len)
		var/obj/item/weapon/reagent_containers/food/snacks/choice = input("Which ingridient would you like to remove from the bowl?") in contents as obj|null
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
				return
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()

/obj/item/weapon/bowl/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/weapon/reagent_containers/food/snacks/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/weapon/reagent_containers/food/snacks/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else del(b)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/weapon/reagent_containers/food/snacks/b in contents)
					b.loc = (get_turf(src))
				qdel(src)
			return
		else
	return

/obj/item/weapon/bowl/update_icon()
	if(contents.len == 0)
		overlays.cut()
		icon_state = "bowl"
	else
		var/icon/bowl_natural = getFlatIcon(src)
		var/icon/Ingridient = icon(new_ingridient.icon, new_ingridient.icon_state)
		var/icon/bowl_overlay = icon('icons/obj/food_and_drinks/tools.dmi', "bowl_overlay")
		Ingridient.Scale(8, 8)
		bowl_natural.Blend(Ingridient,ICON_OVERLAY, 10, 13)
		overlays += bowl_overlay





//Dirty bowl
/obj/item/trash/snack_bowl/salad_bowl
	desc = "You gotta clean it up if you want to continue working with it."

/obj/item/trash/snack_bowl/salad_bowl/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/soap))
		if(do_after(user, 10, target = src) && O)
			for(var/mob/V in viewers(user, null))
				V.show_message("\blue [user] washes [src] hands using the soap.")
			var/obj/item/weapon/bowl/B = new /obj/item/weapon/bowl
			B.loc = src.loc
			qdel(src)
	else
		..()

//Salad as snack type
/obj/item/weapon/reagent_containers/food/snacks/salad
	icon = 'icons/obj/food_and_drinks/salads.dmi'
	trash = /obj/item/trash/snack_bowl









////////////////////////////////////////////////////////
//LIST OF SALADS//Please keep it in alphabetical order//
////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad
	name = "Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	filling_color = "#468C00"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/aesirsalad/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)
	reagents.add_reagent("doctorsdelight", 8)
	reagents.add_reagent("vitamin", 6)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	filling_color = "#76B87F"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/herbsalad/atom_init()
	. = ..()
	reagents.add_reagent("nutriment", 8)

///////////////////////////////////////////////

///////////////////////////////////////////////


///////////////////////////////////////////////

///////////////////////////////////////////////

///////////////////////////////////////////////

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff
	name = "Spacy Liberty Duff"
	desc = "Jello gelatin, from Alfred Hubbard's cookbook."
	icon_state = "spacylibertyduff"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#42B873"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 6)
	reagents.add_reagent("psilocybin", 6)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/tossedsalad
	name = "tossed salad"
	desc = "A proper salad, basic and simple, with little bits of carrot, tomato and apple intermingled. Vegan!"
	icon_state = "herbsalad"
	filling_color = "#76B87F"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/tossedsalad/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("vitamin", 1)

///////////////////////////////////////////////

///////////////////////////////////////////////

///////////////////////////////////////////////

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/validsalad
	name = "valid salad"
	desc = "It's just a salad of questionable 'herbs' with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	filling_color = "#76B87F"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/validsalad/atom_init()
	. = ..()
	reagents.add_reagent("plantmatter", 8)
	reagents.add_reagent("vitamin", 2)

///////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu
	name = "Wing Fang Chu"
	desc = "A savory dish of alien wing wang in soy."
	icon_state = "wingfangchu"
	trash = /obj/item/trash/snack_bowl
	filling_color = "#43DE18"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/wingfangchu/atom_init()
	. = ..()
	reagents.add_reagent("protein", 6)
	reagents.add_reagent("vitamin", 2)

///////////////////////////////////////////////

















