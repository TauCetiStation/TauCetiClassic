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

/obj/item/weapon/reagent_containers/food/drinks/attack(mob/living/M, mob/user, def_zone)
	var/datum/reagents/R = reagents
	var/fillevel = gulp_size

	if (!src.is_open_container())
		return 0

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

		playsound(M, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
		update_icon()
		return 1
	else
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags[IS_SYNTHETIC])
				to_chat(H, "<span class='warning'>They have a monitor for a head, where do you think you're going to put that?</span>")
				return

		user.visible_message("<span class='warning'>[user] attempts to feed [M] [src].</span>")
		if(!do_mob(user, M)) return
		user.visible_message("<span class='warning'>[user] feeds [M] [src].</span>")

		M.log_combat(user, "fed [name], reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)])")

		if(reagents.total_volume)
			reagents.trans_to_ingest(M, gulp_size)

		if(isrobot(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			var/refill = R.get_master_reagent_id()
			addtimer(CALLBACK(R, /datum/reagents.proc/add_reagent, refill, fillevel), 600)

		playsound(M, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
		update_icon()
		return 1


/obj/item/weapon/reagent_containers/food/drinks/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if (!is_open_container())
		to_chat(user, "<span class='notice'>You need to open [src]!</span>")
		return

	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
		var/obj/structure/reagent_dispensers/RD = target

		if(!RD.reagents.total_volume)
			to_chat(user, "<span class='warning'>[RD] is empty.</span>")
			return
		if (!reagents.maximum_volume) // Locked or broken container
			to_chat(user, "<span class='warning'> [src] can't hold this.</span>")
			return
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		var/trans = RD.reagents.trans_to(src, RD.amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [target].</span>")

	else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] is empty.</span>")
			return
		if(!target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'> [target] can't hold this.</span>")
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

	else if((user.a_intent == INTENT_HARM) && reagents.total_volume && istype(target, /turf/simulated))
		to_chat(user, "<span class = 'notice'>You splash the solution onto [target].</span>")

		reagents.reaction(target, TOUCH)
		reagents.clear_reagents()

		var/turf/T = get_turf(src)
		message_admins("[key_name_admin(usr)] splashed [reagents.get_reagents()] on [target], location ([T.x],[T.y],[T.z]) [ADMIN_JMP(usr)]")
		log_game("[key_name(usr)] splashed [reagents.get_reagents()] on [target], location ([T.x],[T.y],[T.z])")
	update_icon()

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
	w_class = ITEM_SIZE_LARGE
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

/obj/item/weapon/reagent_containers/food/drinks/milk
	name = "Space Milk"
	desc = "It's milk. White and nutritious goodness!"
	icon_state = "milk"
	item_state = "carton"
	list_reagents = list("milk" = 50)

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

/obj/item/weapon/reagent_containers/food/drinks/soymilk
	name = "SoyMilk"
	desc = "It's soy milk. White and nutritious goodness!"
	icon_state = "soymilk"
	item_state = "carton"
	list_reagents = list("soymilk" = 50)

/obj/item/weapon/reagent_containers/food/drinks/coffee
	name = "Robust Coffee"
	desc = "Careful, the beverage you're about to enjoy is extremely hot."
	icon_state = "coffee"
	list_reagents = list("coffee" = 30)

/obj/item/weapon/reagent_containers/food/drinks/tea
	name = "Duke Purple Tea"
	desc = "An insult to Duke Purple is an insult to the Space Queen! Any proper gentleman will fight you, if you sully this tea."
	icon_state = "teacup"
	item_state = "coffee"
	list_reagents = list("tea" = 30)

/obj/item/weapon/reagent_containers/food/drinks/tea/atom_init()
	. = ..()
	pixel_y = rand(0, 20)       // the teacup is very low on the 32x32 grid so if it's -y then it clips into the tile below it.

/obj/item/weapon/reagent_containers/food/drinks/ice
	name = "Ice Cup"
	desc = "Careful, cold ice, do not chew."
	icon_state = "coffee"
	list_reagents = list("ice" = 30)

/obj/item/weapon/reagent_containers/food/drinks/h_chocolate
	name = "Dutch Hot Coco"
	desc = "Made in Space South America."
	icon_state = "hot_coco"
	item_state = "coffee"
	list_reagents = list("hot_coco" = 30)

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen
	name = "Dosi Ramen"
	desc = "Just add 10ml water, self heats! Most cheapest and popular noodle in space. Classic ramen with chicken flavor." // Now this is a reference not to original ramen.
	icon_state = "ramen"
	list_reagents = list("dry_ramen" = 30)
	flags = 0 // Default - closed container

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/update_icon()
	if(!is_open_container())
		icon_state = initial(icon_state)
	else if(!reagents.total_volume)
		icon_state = "ramen_empty"
	else
		icon_state = "ramen_open"

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/attack_self(mob/user)
	if (!is_open_container())
		flags |= OPENCONTAINER
		playsound(src, 'sound/items/crumple.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
		to_chat(user, "<span class='notice'>You open the [src].</span>")
		update_icon()

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/on_reagent_change()
	// Don't trust total_volume before all reactions end
	if(!reagents.total_volume && !reagents.is_reaction_in_proccessing())
		// Ramen can't be refilled. We have only one icon for content of ramen container and it's dohi ramen
		// If ramen container empty and no reaction proccessing - remove volume
		// Locking container return it to initial state and show message to open the container
		reagents.maximum_volume = 0
		update_icon()
		return
	update_icon()
	..()

/obj/item/weapon/reagent_containers/food/drinks/dry_ramen/hell_ramen
	name = "Dosi Ramen (Spicy)"
	desc = "Just add 10ml water, self heats! Unathi's favorite noodle with spicy flavor. DANGER: VERY SPICY! NOT TAJARAN FRIENDLY!"
	icon_state = "ramen_spicy"
	list_reagents = list("hell_ramen" = 30)

/obj/item/weapon/reagent_containers/food/drinks/sillycup
	name = "Paper Cup"
	desc = "A paper water cup."
	icon_state = "water_cup_e"
	possible_transfer_amounts = null
	volume = 10

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
