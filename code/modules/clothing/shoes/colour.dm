/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black_shoes"
	item_state = "black_shoes"
	desc = "A pair of black shoes."

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown_shoes"
	item_state = "brown_shoes"

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	desc = "A pair of blue shoes."
	icon_state = "blue_shoes"
	item_state = "blue_shoes"

/obj/item/clothing/shoes/green
	name = "green shoes"
	desc = "A pair of green shoes."
	icon_state = "green_shoes"
	item_state = "green_shoes"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	desc = "A pair of yellow shoes."
	icon_state = "yellow_shoes"
	item_state = "yellow_shoes"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	desc = "A pair of purple shoes."
	icon_state = "purple_shoes"
	item_state = "purple_shoes"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red_shoes"
	item_state = "red_shoes"

/obj/item/clothing/shoes/red/wizard

/obj/item/clothing/shoes/red/wizard/atom_init(mapload, ...)
	. = ..()
	AddComponent(/datum/component/magic_item/wizard)

/obj/item/clothing/shoes/white
	name = "white shoes"
	desc = "A pair of white shoes."
	permeability_coefficient = 0.01
	item_state = "white_shoes"
	icon_state = "white_shoes"

/obj/item/clothing/shoes/leather
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	item_state = "rainbow_shoes"

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	desc = "A pair of orange shoes."
	icon_state = "orange_shoes"
	item_state = "orange_shoes"
	var/obj/item/weapon/handcuffs/chained = null

/obj/item/clothing/shoes/orange/proc/attach_cuffs(obj/item/weapon/handcuffs/cuffs, mob/user)
	if (src.chained)
		return
	user.drop_from_inventory(cuffs, loc)
	chained = cuffs
	slowdown = 7
	name = "shackles"
	icon_state = "orange_shoes1"
	item_state = "otange_shoes1"

/obj/item/clothing/shoes/orange/proc/remove_cuffs()
	if (!src.chained)
		return
	chained.loc = get_turf(src)
	slowdown = initial(slowdown)
	name = initial(name)
	icon_state = "orange_shoes"
	item_state = "orange_shoes"
	chained = null

/obj/item/clothing/shoes/orange/attack_self(mob/user)
	..()
	remove_cuffs()

/obj/item/clothing/shoes/orange/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/handcuffs))
		attach_cuffs(I, user)
		return
	return ..()

/obj/item/clothing/shoes/orange/attack_hand(mob/user)
	var/confirmed = 1
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(chained && src == H.shoes)
			if(user.is_busy()) return
			confirmed = 0
			H.visible_message("<span class='notice'>[H] attempts to remove the [src]!</span>",
			"<span class='notice'>You attempt to remove the [src]. (This will take around 2 minutes and you need to stand still)</span>")
			if(do_after(user,1200,target = usr))
				confirmed = 1
	if(confirmed)
		return ..()

/obj/item/clothing/shoes/orange/candals/atom_init()
	. = ..()
	chained = new /obj/item/weapon/handcuffs(src)
	slowdown = 7
	name = "shackles"
	icon_state = "orange_shoes1"
	item_state = "orange_shoes1"
