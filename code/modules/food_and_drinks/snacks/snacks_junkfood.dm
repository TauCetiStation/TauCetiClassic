///-----------------------------------------------------//
///														//
///					Junk food							//
///				Cant be put on a plate.					//
///														//
///-----------------------------------------------------//

/obj/item/weapon/reagent_containers/food/snacks/chips
	name = "chips"
	desc = "Commander Riker's What-The-Crisps"
	icon_state = "chips"
	trash = /obj/item/trash/chips
	filling_color = "#E8C31E"
	bitesize = 1
	cant_be_put_on_plate = TRUE
	list_reagents = list("nutriment" = 3, "sodiumchloride" = 1, "sugar" = 1)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	name = "Donk-pocket"
	desc = "The food of choice for the seasoned traitor."
	icon_state = "donkpocket"
	filling_color = "#DEDEAB"
	var/warm = 0
	list_reagents = list("nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/donkpocket/proc/cooltime()
	if (src.warm)
		spawn( 4200 )
			src.warm = 0
			src.reagents.del_reagent("tricordrazine")
			src.name = "donk-pocket"
	return