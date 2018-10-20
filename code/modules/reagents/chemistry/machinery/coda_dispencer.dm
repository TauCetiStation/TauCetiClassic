/obj/machinery/chem_dispenser/soda
	icon_state = "soda_dispenser"
	name = "soda fountain"
	desc = "A drink fabricating machine, capable of producing many sugary drinks with just one touch."
	ui_title = "Soda Dispens-o-matic"
	energy = 100
	accept_glass = 1
	max_energy = 100
	dispensable_reagents = list("water","ice","coffee","cream","tea","icetea","cola","spacemountainwind","dr_gibb","space_up","tonic","sodawater","lemon_lime","sugar","orangejuice","limejuice","watermelonjuice")

	/obj/machinery/chem_dispenser/soda/attackby(obj/item/weapon/B, mob/user)
		..()
		if(istype(B, /obj/item/device/multitool))
			if(hackedcheck == 0)
				to_chat(user, "You change the mode from 'McNano' to 'Pizza King'.")
				dispensable_reagents += list("thirteenloko","grapesoda")
				hackedcheck = 1
				return

			else
				to_chat(user, "You change the mode from 'Pizza King' to 'McNano'.")
				dispensable_reagents -= list("thirteenloko")
				hackedcheck = 0
				return

		else if(istype(B, /obj/item/weapon/wrench))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return
/obj/machinery/chem_dispenser/beer
	icon_state = "booze_dispenser"
	name = "booze dispenser"
	ui_title = "Booze Portal 9001"
	energy = 100
	accept_glass = 1
	max_energy = 100
	desc = "A technological marvel, supposedly able to mix just the mixture you'd like to drink the moment you ask for one."
	dispensable_reagents = list("lemon_lime","sugar","orangejuice","limejuice","sodawater","tonic","beer","kahlua","whiskey","wine","vodka","gin","rum","tequilla","vermouth","cognac","ale","mead")

	/obj/machinery/chem_dispenser/beer/attackby(obj/item/weapon/B, mob/user)
		..()

		if(istype(B, /obj/item/device/multitool))
			if(hackedcheck == 0)
				to_chat(user, "You disable the 'nanotrasen-are-cheap-bastards' lock, enabling hidden and very expensive boozes.")
				dispensable_reagents += list("goldschlager","patron","watermelonjuice","berryjuice")
				hackedcheck = 1
				return

			else
				to_chat(user, "You re-enable the 'nanotrasen-are-cheap-bastards' lock, disabling hidden and very expensive boozes.")
				dispensable_reagents -= list("goldschlager","patron","watermelonjuice","berryjuice")
				hackedcheck = 0
				return

		else if(istype(B, /obj/item/weapon/wrench))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
		return