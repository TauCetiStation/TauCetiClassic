/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	item_state = "bl_shoes"
	desc = "A pair of black shoes."
	clipped_status = CLIPPABLE

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	item_state = "r_shoes"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	item_state = "w_shoes"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/leather
	name = "Башмаки"
	desc = "Башмаки из жопы свиньи"
	icon_state = "leather"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	item_state = "o_shoes"
	var/obj/item/weapon/handcuffs/chained = null
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/orange/proc/attach_cuffs(obj/item/weapon/handcuffs/cuffs, mob/user)
	if (src.chained)
		return
	user.drop_from_inventory(cuffs, loc)
	chained = cuffs
	slowdown = 7
	name = "shackles"
	icon_state = "orange1"
	item_state = "o_shoes1"

/obj/item/clothing/shoes/orange/proc/remove_cuffs()
	if (!src.chained)
		return
	chained.loc = get_turf(src)
	slowdown = initial(slowdown)
	name = initial(name)
	icon_state = "orange"
	item_state = "o_shoes"
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
	icon_state = "orange1"
	item_state = "o_shoes1"
