////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/drinks
	name = "drink"
	desc = "Yummy!"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	flags = OPENCONTAINER
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,25)
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/on_reagent_change()
	if (gulp_size < 5)
		gulp_size = 5
	else
		gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/weapon/reagent_containers/food/drinks/attack_self(mob/user)
	return

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/M, mob/user, def_zone)
	var/datum/reagents/R = reagents
	var/fillevel = gulp_size

	if(!R.total_volume || !R)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return 0

	if(!CanEat(user, M, src, "drink")) return

	if(M == user)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags[IS_SYNTHETIC])
				to_chat(H, "<span class='warning'>You have a monitor for a head, where do you think you're going to put that?</span>")
				return

		if(isliving(M))
			var/mob/living/L = M
			if(taste)
				L.taste_reagents(reagents)
		to_chat(M, "<span class='notice'>You swallow a gulp of [src].</span>")
		if(reagents.total_volume)
			reagents.trans_to_ingest(M, gulp_size)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1
	else
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags[IS_SYNTHETIC])
				to_chat(H, "<span class='warning'>They have a monitor for a head, where do you think you're going to put that?</span>")
				return

		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] attempts to feed [M] [src].</span>", 1)
		if(!do_mob(user, M)) return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("<span class='warning'>[user] feeds [M] [src].</span>", 1)

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [M.name] by [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		if(reagents.total_volume)
			reagents.trans_to_ingest(M, gulp_size)

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			var/refill = R.get_master_reagent_id()
			addtimer(CALLBACK(R, /datum/reagents.proc/add_reagent, refill, fillevel), 600)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		return 1

	return 0


/obj/item/weapon/reagent_containers/food/drinks/afterattack(obj/target, mob/user, proximity)
	if(!proximity) return

	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return



		var/datum/reagent/refill
		var/datum/reagent/refillName
		if(isrobot(user))
			refill = reagents.get_master_reagent_id()
			refillName = reagents.get_master_reagent_name()

		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution to [target].</span>")

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			var/chargeAmount = max(30,4*trans)
			bro.cell.use(chargeAmount)
			to_chat(user, "Now synthesizing [trans] units of [refillName]...")
			addtimer(CALLBACK(src, .proc/refill_by_borg, user, refill, trans), 300)
	return

/obj/item/weapon/reagent_containers/food/drinks/proc/refill_by_borg(user, refill, trans)
	reagents.add_reagent(refill, trans)
	to_chat(user, "Cyborg [src] refilled.")

/obj/item/weapon/reagent_containers/food/drinks/examine(mob/user)
	..()
	if(src in user)
		if(!reagents || reagents.total_volume==0)
			to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
		else if (reagents.total_volume<=src.volume/4)
			to_chat(user, "<span class='notice'>\The [src] is almost empty!</span>")
		else if (reagents.total_volume<=src.volume*0.66)
			to_chat(user, "<span class='notice'>\The [src] is half full!</span>")
		else if (reagents.total_volume<=src.volume*0.90)
			to_chat(user, "<span class='notice'>\The [src] is almost full!</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] is full!</span>")

////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////

/obj/item/weapon/reagent_containers/food/drinks/golden_cup
	desc = "A golden cup."
	name = "golden cup"
	icon_state = "golden_cup"
	item_state = "" //nope :(
	w_class = 4
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = null
	volume = 150
	flags = CONDUCT | OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/golden_cup/tournament_26_06_2011
	desc = "A golden cup. It will be presented to a winner of tournament 26 june and name of the winner will be graved on it."


///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/* Flour is no longer a reagent
/obj/item/weapon/reagent_containers/food/drinks/flour
	name = "flour sack"
	desc = "A big bag of flour. Good for baking!"
	icon = 'icons/obj/food.dmi'
	icon_state = "flour"
	item_state = "flour"

/obj/item/weapon/reagent_containers/food/drinks/flour/atom_init()
	. = ..()
	reagents.add_reagent("flour", 30)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
*/

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"

/obj/item/weapon/reagent_containers/food/drinks/coffee/atom_init()
	. = ..()
	reagents.add_reagent("coffee", 30)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"

/obj/item/weapon/reagent_containers/food/drinks/tea/atom_init()
	. = ..()
	reagents.add_reagent("tea", 30)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(0, 20)       // the teacup is very low on the 32x32 grid so if it's -y then it clips into the tile below it.

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"

/obj/item/weapon/reagent_containers/food/drinks/ice/atom_init()
	. = ..()
	reagents.add_reagent("ice", 30)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate/atom_init()
	. = ..()
	reagents.add_reagent("hot_coco", 30)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Cup Ramen"
	desc = "Just add 10ml water, self heats! A taste that reminds you of your school years."
	icon_state = "ramen"

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/atom_init()
	. = ..()
	reagents.add_reagent("dry_ramen", 30)
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)


/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "Paper Cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10

/obj/item/weapon/reagent_containers/food/drinks/sillycup/atom_init()
	. = ..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/reagent_containers/food/drinks/sillycup/on_reagent_change()
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"


//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/weapon/reagent_containers/food/drinks/shaker
	name = "Shaker"
	desc = "A metal shaker to mix drinks in."
	icon_state = "shaker"
	amount_per_transfer_from_this = 10
	volume = 100

/obj/item/weapon/reagent_containers/food/drinks/flask
	name = "Captain's Flask"
	desc = "A metal flask belonging to the captain."
	icon_state = "flask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/detflask
	name = "Detective's Flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/flask/vacuumflask
	name = "vacuum flask"
	desc = "Keeping your drinks at the perfect temperature since 1892."
	icon_state = "vacuumflask"
	volume = 60

/obj/item/weapon/reagent_containers/food/drinks/britcup
	name = "cup"
	desc = "A cup with the British flag emblazoned on it."
	icon_state = "britcup"
	volume = 30
