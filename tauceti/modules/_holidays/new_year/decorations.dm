/obj/item/decoration
	name = "decoration"
	desc = "Winter is coming!"
	icon = 'tauceti/modules/_holidays/new_year/decorations.dmi'
	icon_state = "santa"
	layer = 4.1

///Garland
/obj/item/decoration/garland
	name = "garland"
	desc = "Beautiful lights! Shinee!"
	icon_state = "garland"
	var/on = 0
	var/brightness = 2

/obj/item/decoration/garland/initialize()
	..()
	if(on)
		icon_state = "[initial(icon_state)]_on"
		set_light(brightness)
	else
		icon_state = initial(icon_state)
		set_light(0)

/obj/item/decoration/garland/New()
	on = 1
	light_color = pick("#FF0000","#6111FF","#FFA500","#44FAFF")
	initialize()

/obj/item/decoration/garland/attack_hand()
	on = !on
	initialize()

///Tinsels
/obj/item/decoration/tinsel
	name = "tinsel"
	desc = "Soft tinsel, pleasant to the touch. Ahhh..."
	icon_state = "tinsel_g"

/obj/item/decoration/tinsel/New()
	icon_state = "tinsel[pick("_g","_r","_y","_w")]"

/obj/item/decoration/tinsel/green
	icon_state = "tinsel_g"
	New()
		return

/obj/item/decoration/tinsel/red
	icon_state = "tinsel_r"
	New()
		return

/obj/item/decoration/tinsel/yellow
	icon_state = "tinsel_y"
	New()
		return

/obj/item/decoration/tinsel/white
	icon_state = "tinsel_w"
	New()
		return

//Snowflakes
/obj/item/decoration/snowflake
	name = "snowflake"
	desc = "Snowflakes from very soft and pleasant to touch material."
	icon_state = "snowflakes_1"

/obj/item/decoration/snowflake/New()
	icon_state = "snowflakes_[rand(1,4)]"

//Snowman head
/obj/item/decoration/snowman
	name = "snowman head"
	desc = "Snowman head, which looks right into your soul."
	icon_state = "snowman"

//Xmas tree
/obj/item/device/flashlight/lamp/fir/special
	name = "present xmas tree"
	desc = "Hello, happy holidays, we have got presents..."

	layer = 5
	var/gifts_dealt = 0

/obj/item/device/flashlight/lamp/fir/special/attackby()
	return

/obj/item/device/flashlight/lamp/fir/special/attack_hand(mob/user as mob)
	shake()
	return

/obj/item/device/flashlight/lamp/fir/special/verb/shake()
	set name = "Shake tree"
	set category = "Object"
	set src in view(1)

	var/mob/living/carbon/C = usr

	if(iscarbon(C))
		C.visible_message("<span class='notice'>[C] shakes [src].</span>","<span class='notice'>You shake [src].</span>")

		if(!gifts_dealt || ((world.time - gifts_dealt) > 3000))

			if(!C.client.prefs.warnbans)
				C << "<span class='notice'>You understand that this year you was good boy!</span>"
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustFireLoss(-10)

			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			new /obj/item/weapon/present(src.loc)
			gifts_dealt = world.time
		else
			C << "<span class='notice'>You shake [src] but nothing happens.</span>"
