//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = ITEM_SIZE_SMALL
	desc = "This is rubbish."

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "Candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "Cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "Chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "Popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "Syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "Waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "Plate"
	icon_state = "plate"

/obj/item/trash/snack_bowl
	name = "Snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/pistachios
	name = "Pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "Semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "Tray"
	icon_state = "tray"

/obj/item/trash/candle
	name = "white candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "white_candle4"

/obj/item/trash/liquidfood
	name = "\"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/candle/ghost
	name = "black candle"
	icon_state = "black_candle4"

/obj/item/trash/candle/red
	name = "red candle"
	icon_state = "red_candle4"

/obj/item/trash/chinese1
	name = "chow mein"
	icon_state = "chinese1"

/obj/item/trash/chinese2
	name = "Admiral Yamamoto carp"
	icon_state = "chinese2"

/obj/item/trash/chinese3
	name = "chinese newdles"
	icon_state = "chinese3"

/obj/item/trash/chinese4
	name = "fried rice"
	icon_state = "chinese4"

/obj/item/trash/fries
	name = "Space Fries"
	icon_state = "fries"


/obj/item/trash/candle/ghost/attackby(obj/item/I, mob/user, params)
	var/chaplain_check = FALSE

	if(isliving(user))
		var/mob/living/L = user
		if(L.getBrainLoss() >= 60 || L.mind.holy_role || L.mind.role_alt_title == "Paranormal Investigator")
			chaplain_check = TRUE

	if(chaplain_check)
		if(istype(I, /obj/item/weapon/nullrod))
			var/obj/item/trash/candle/C = new /obj/item/trash/candle(loc)
			if(istype(loc, /mob))
				user.put_in_hands(C)
				dropped()
			qdel(src)
	else
		return ..()

/obj/item/trash/attack(mob/M, mob/living/user)
	return
