///-----------------------------------------------------//
///														//
///						Condiments						//
///														//
///-----------------------------------------------------//
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
///-----------------------------------------------------//

/obj/item/weapon/reagent_containers/food/condiment
	name = "Condiment Container"
	desc = "Just your average condiment container."
	icon = 'icons/obj/food_and_drinks/condiments.dmi'
	icon_state = "condiment"
	flags = OPENCONTAINER
	possible_transfer_amounts = list(1,5,10)
	volume = 50
	var/empty = icon_state//Empty state icon

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/weapon/W, mob/user)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/condiment/attack(mob/M, mob/user, def_zone)
	if(!CanEat(user, M, src, "swallow")) return

	var/datum/reagents/R = src.reagents

	if(!R || !R.total_volume)
		to_chat(user, "\red None of [src] left, oh no!")
		return 0

	if(isliving(M))
		var/mob/living/L = M
		if(taste)
			L.taste_reagents(reagents)
	if(M == user)
		to_chat(M, "\blue You swallow some of contents of the [src].")
		if(reagents.total_volume)
			reagents.trans_to_ingest(M, 10)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	else

		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] attempts to feed [M] [src].", 1)
		if(!do_mob(user, M)) return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] feeds [M] [src].", 1)

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		msg_admin_attack("[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		if(reagents.total_volume)
			reagents.trans_to_ingest(M, 10)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/condiment/attackby(obj/item/I, mob/user)
		return

/obj/item/weapon/reagent_containers/food/condiment/afterattack(obj/target, mob/user , flag)
	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='rose'> [target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='rose'> [src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You fill [src] with [trans] units of the contents of [target].</span>")

	//Something like a glass or a food item. Player probably wants to transfer TO it.
	else if(target.is_open_container() || istype(target, /obj/item/weapon/reagent_containers/food/snacks))
		if(!reagents.total_volume)
			to_chat(user, "<span class='rose'> [src] is empty.</span>")
			return
		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='rose'> you can't add anymore to [target].</span>")
			return
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'> You transfer [trans] units of the condiment to [target].</span>")
		if(istype(target, /obj/item/weapon/reagent_containers/food/snacks))
			if(target.sauced_icon && target.icon_state == target.initial(icon_state))
				if((target.get_reagent_amount("ketchup") > 1) || (target.get_reagent_amount("capsaicin") > 1))
					target.icon_state = target.sauced_icon
					target.desc = "[target.desc]<br><span class='rose'>It has [src] on it</span>"

/obj/item/weapon/reagent_containers/food/condiment/on_reagent_change()
	if(reagents.reagent_list.len == 0 && empty)//If its empty we change the sprite and desc
		icon_state = empty
		desc = "An empty [src.name].[initial(desc)]"
		return

	if(reagents.reagent_list.len > 0)//So here we change the desc if condiment contains multiple reagents
		switch(reagents.get_master_reagent_id())
			if("sodiumchloride")
				return
			if("blackpepper")
				return
			if("ketchup")
				return
			if("capsaicin")
				return
			if("enzyme")
				return
			if("soysauce")
				return
			if("frostoil")
				return
			if("sodiumchloride")
				return
			if("rice")
				return
			if("blackpepper")
				return
			if("cornoil")
				return
			if("flour")
				return
			if("sugar")
				return
			if("honey")
				return
			else
				if (reagents.reagent_list.len==1)
					desc = "Looks like it is [reagents.get_master_reagent_name()], but you are not sure."
				else
					desc = "A mixture of various condiments. [reagents.get_master_reagent_name()] is one of them."

///////////////////
//Condiment Shelf//
///////////////////
//Placed in the kitchen

/obj/structure/condiment_shelf
	name = "condiment shelf"
	desc = "Its a small wooden shelf for spices and seasonings. Buon appetito!"
	icon = 'icons/obj/food_and_drinks/cond_shelf.dmi'
	icon_state = "cond_shelf"
	anchored = 1
	density = 1
	opacity = 1
	var/input_shelf = null
	var/list/can_be_placed = list(/obj/item/weapon/reagent_containers/food/condiment, // Stuff that we can put on the shelf
					/obj/item/weapon/reagent_containers/food/condiment/sugar,
					/obj/item/weapon/reagent_containers/food/condiment/rice,
					/obj/item/weapon/reagent_containers/food/condiment/soysauce,
					/obj/item/weapon/reagent_containers/food/condiment/hotsauce,
					/obj/item/weapon/reagent_containers/food/condiment/ketchup,
					/obj/item/weapon/reagent_containers/food/condiment/coldsauce,
					/obj/item/weapon/reagent_containers/food/condiment/cornoil,
					/obj/item/weapon/reagent_containers/food/condiment/enzyme,
					/obj/item/weapon/reagent_containers/food/condiment/saltshaker,
					/obj/item/weapon/reagent_containers/food/condiment/peppermill,)

/obj/structure/condiment_shelf/atom_init()
	. = ..()
	new /obj/item/weapon/reagent_containers/food/condiment/sugar(src)
	new /obj/item/weapon/reagent_containers/food/condiment/rice(src)
	new /obj/item/weapon/reagent_containers/food/condiment/ketchup(src)
	new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
	new /obj/item/weapon/reagent_containers/food/condiment/saltshaker(src)
	new /obj/item/weapon/reagent_containers/food/condiment/peppermill(src)
	for(var/obj/item/I in loc)
		if(I == can_be_placed)
			I.loc = src
	update_icon()

/obj/structure/condiment_shelf/attackby(obj/O, mob/user)
	if(O == can_be_placed)
		if(contents.len < 7)
			user.drop_item()
			O.loc = src
			input_shelf = O
			update_icon()
		else
			to_chat(user, "<span class='rose'>[src] is full!</span>")
	else
		to_chat(user, "<span class='rose'>What? This shelf is only for spices and sauces!</span>")
		..()

/obj/structure/condiment_shelf/attack_hand(mob/user)
	if(contents.len)
		var/obj/item/weapon/reagent_containers/food/condiment/choice = input("Which condiment would you like to remove from the shelf?") in contents as obj|null
		if(choice)
			if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
				return
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()

/obj/structure/condiment_shelf/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/weapon/reagent_containers/food/condiment/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/weapon/reagent_containers/food/condiment/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else del(b)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/weapon/reagent_containers/food/condiment/b in contents)
					b.loc = (get_turf(src))
				qdel(src)
			return
		else
	return

/obj/structure/condiment_shelf/update_icon()
	overlays.cut()
	if(contents.len == 0)
		return
	var/number = 0
	for(var/obj/item/F in contents)
		if(F == can_be_placed)
			var/icon/condiment = icon('icons/obj/food_and_drinks/cond_shelf.dmi',"[F.icon_state]")
			var/icon/main_icon = getFlatIcon(src)
			main_icon.Blend(condiment, ICON_OVERLAY, 0, number)
			number ++
	number = 0

//////////////////////
//LIST OF CONDIMENTS//
//////////////////////

//SACKS

/obj/item/weapon/reagent_containers/food/condiment/flour
	name = "flour sack"
	desc = "A small bag filled with some flour."
	icon_state = "flour"
	item_state = "flour"
	empty = "flour_empty"
	list_reagents = list("flour" = 30)

/obj/item/weapon/reagent_containers/food/condiment/sugar
	name = "sugar sack"
	desc = "Tastey space sugar!"
	icon_state = "sugar"
	item_state = "sugar"
	empty = "sugar_empty"
	list_reagents = list("sugar" = 40)

/obj/item/weapon/reagent_containers/food/condiment/rice
	name = "rice sack"
	desc = "Salt. From space oceans, presumably. Good for cooking!"
	icon_state = "rice"
	item_state = "rice"
	empty = "rice_empty"
	list_reagents = list("rice" = 30)

//SAUCES

/obj/item/weapon/reagent_containers/food/condiment/soysauce
	name = "soy sauce"
	desc = "A salty soy-based flavoring."
	icon_state = "soysauce"
	empty = "soysauce_empty"
	list_reagents = list("soysauce" = 40)

/obj/item/weapon/reagent_containers/food/condiment/hotsauce
	name = "hot sauce"
	desc = "You can almost TASTE the stomach ulcers now!"
	icon_state = "hotsauce"
	empty = "hotsauce_empty"
	list_reagents = list("capsaicin" = 30)

/obj/item/weapon/reagent_containers/food/condiment/ketchup
	name = "ketchup"
	desc = "You feel more American already."
	icon_state = "ketchup"
	empty = "ketchup_empty"
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
	empty = "cornoil_empty"
	list_reagents = list("cornoil" = 40)

//SUPPLEMENTS

/obj/item/weapon/reagent_containers/food/condiment/enzyme
	name = "universal enzyme"
	desc = "Used in cooking various dishes."
	icon_state = "enzyme"
	item_state = "enzyme"
	empty = "enzyme_empty"
	list_reagents = list("enzyme" = 50)

/obj/item/weapon/reagent_containers/food/condiment/saltshaker		//Seperate from above since it's a small shaker rather then
	name = "salt shaker"											//	a large one.
	desc = "Salt. From space oceans, presumably."
	icon_state = "saltshakersmall"
	empty = "saltshakersmall_empty"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("sodiumchloride" = 20)

/obj/item/weapon/reagent_containers/food/condiment/peppermill
	name = "pepper mill"
	desc = "Often used to flavor food or make people sneeze."
	icon_state = "peppermillsmall"
	possible_transfer_amounts = list(1,20) //for clown turning the lid off
	amount_per_transfer_from_this = 1
	volume = 20
	list_reagents = list("blackpepper" = 20)

/obj/item/weapon/reagent_containers/food/condiment/honey
	name = "honey pot"
	desc = "Sweet and healthy!"
	icon_state = "honey"
	list_reagents = list("honey" = 40)
