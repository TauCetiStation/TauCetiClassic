/obj/item/weapon/reagent_containers/food/drinks/cans
	name = "soda can"
	var/canopened = 0

/obj/item/weapon/reagent_containers/food/drinks/cans/atom_init()
	. = ..()

	if(!canopened)
		flags &= ~OPENCONTAINER

/obj/item/weapon/reagent_containers/food/drinks/cans/attack_self(mob/user)
	if (!canopened)
		playsound(src, pick(SOUNDIN_CAN_OPEN), VOL_EFFECTS_MASTER, rand(10, 50))
		to_chat(user, "<span class='notice'>You open the drink with an audible pop!</span>")
		flags |= OPENCONTAINER
		canopened = 1
	else
		return

/obj/item/weapon/reagent_containers/food/drinks/cans/attack(mob/living/M, mob/user, def_zone)
	if(!CanEat(user, M, src, "drink")) return

	if (!canopened)
		to_chat(user, "<span class='notice'>You need to open the drink!</span>")
		return
	var/datum/reagents/R = src.reagents
	var/fillevel = gulp_size

	if(!R.total_volume || !R)
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		return 0

	if(M == user)
		if(isliving(M))
			var/mob/living/L = M
			if(taste)
				L.taste_reagents(src.reagents)
		to_chat(M, "<span class='notice'>You swallow a gulp of [src].</span>")
		if(reagents.total_volume)
			reagents.trans_to_ingest(M, gulp_size)
			reagents.reaction(M, INGEST)
			addtimer(CALLBACK(reagents, /datum/reagents.proc/trans_to, M, gulp_size), 5)

		playsound(M, 'sound/items/drink.ogg', VOL_EFFECTS_MASTER, rand(10, 50))
		return 1
	else if (!canopened)
		to_chat(user, "<span class='notice'> You need to open the drink!</span>")
		return

	else
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
		return 1

/obj/item/weapon/reagent_containers/food/drinks/cans/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity) return

	if (!is_open_container())
		to_chat(user, "<span class='notice'>You need to open [src]!</span>")
		return

	if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
		var/obj/structure/reagent_dispensers/RD = target
		if(!RD.reagents.total_volume)
			to_chat(user, "<span class='warning'>[RD] is empty.</span>")
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
	return


//DRINKS

/obj/item/weapon/reagent_containers/food/drinks/cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	list_reagents = list("cola" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/waterbottle
	name = "Bottled Water"
	desc = "Introduced to the vending machines by Skrellian request, this water comes straight from the Martian poles."
	icon_state = "waterbottle"
	list_reagents = list("water" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list("spacemountainwind" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkeness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	list_reagents = list("thirteenloko" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list("dr_gibb" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list("cola" = 15, "orangejuice" = 15)

/obj/item/weapon/reagent_containers/food/drinks/cans/space_up
	name = "Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list("space_up" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/lemon_lime
	name = "Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list("lemon_lime" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/iced_tea
	name = "Vrisk Serket Iced Tea"
	desc = "That sweet, refreshing southern earthy flavor. That's where it's from, right? South Earth?"
	icon_state = "ice_tea_can"
	list_reagents = list("icetea" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice
	name = "Grapel Juice"
	desc = "500 pages of rules of how to appropriately enter into a combat with this juice!"
	icon_state = "purple_can"
	list_reagents = list("grapejuice" = 30)

/obj/item/weapon/reagent_containers/food/drinks/cans/tonic
	name = "T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	list_reagents = list("tonic" = 50)

/obj/item/weapon/reagent_containers/food/drinks/cans/sodawater
	name = "Soda Water"
	desc = "A can of soda water. Still water's more refreshing cousin."
	icon_state = "sodawater"
	list_reagents = list("sodawater" = 50)
