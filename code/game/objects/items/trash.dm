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
		name = "candle"
		icon = 'icons/obj/candle.dmi'
		icon_state = "candle4"
	liquidfood
		name = "\improper \"LiquidFood\" ration"
		icon_state = "liquidfood"
	fries
		name = "Space Fries"
		icon_state = "fries"
	chinese1
		name = "chow mein"
		icon_state = "chinese1"
	chinese2
		name = "Admiral Yamamoto carp"
		icon_state = "chinese2"
	chinese3
		name = "chinese newdles"
		icon_state = "chinese3"
	chinese4
		name = "fried rice"
		icon_state = "chinese4"



/obj/item/trash/candle/ghost
	icon_state = "gcandle4"

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
