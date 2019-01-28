//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = 2.0
	desc = "This is rubbish."
	raisins
		name = "4no raisins"
		icon_state= "4no_raisins"
	candy
		name = "Candy"
		icon_state= "candy"
	cheesie
		name = "Cheesie honkers"
		icon_state = "cheesie_honkers"
	chips
		name = "Chips"
		icon_state = "chips"
	popcorn
		name = "Popcorn"
		icon_state = "popcorn"
	sosjerky
		name = "Scaredy's Private Reserve Beef Jerky"
		icon_state = "sosjerky"
	syndi_cakes
		name = "Syndi cakes"
		icon_state = "syndi_cakes"
	waffles
		name = "Waffles"
		icon_state = "waffles"
	plate
		name = "Plate"
		icon_state = "plate"
	snack_bowl
		name = "Snack bowl"
		icon_state	= "snack_bowl"
	pistachios
		name = "Pistachios pack"
		icon_state = "pistachios_pack"
	semki
		name = "Semki pack"
		icon_state = "semki_pack"
	tray
		name = "Tray"
		icon_state = "tray"
	candle
		name = "white candle"
		icon = 'icons/obj/candle.dmi'
		icon_state = "white_candle4"
	liquidfood
		name = "\improper \"LiquidFood\" ration"
		icon_state = "liquidfood"

/obj/item/trash/candle/ghost
	name = "black candle"
	icon_state = "black_candle4"

/obj/item/trash/candle/red
	name = "red candle"
	icon_state = "red_candle4"


/obj/item/trash/candle/ghost/attackby(obj/item/weapon/W, mob/living/carbon/human/user)
	..()
	if(user.getBrainLoss() >= 60 || user.mind.assigned_role == "Chaplain" || user.mind.role_alt_title == "Paranormal Investigator")
		if(istype(W, /obj/item/weapon/nullrod))
			var/obj/item/trash/candle/C = new /obj/item/trash/candle(loc)
			if(istype(loc, /mob))
				user.put_in_hands(C)
				dropped()
			qdel(src)

/obj/item/trash/attack(mob/M, mob/living/user)
	return
