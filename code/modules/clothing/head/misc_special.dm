/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	cases = list("сварочный шлем", "сварочного шлема", "сварочному шлему", "сварочный шлем", "сварочным шлемом", "сварочном шлеме")
	desc = "Призван защитить глаза владельца от космической сварочной дуги."
	icon_state = "welding"
	flags = (HEADCOVERSEYES | HEADCOVERSMOUTH)
	item_state = "welding"
	m_amt = 3000
	g_amt = 1000
	var/up = 0
	flash_protection = FLASHES_FULL_PROTECTION
	flash_protection_slots = list(SLOT_HEAD)
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_inv = (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
	body_parts_covered = HEAD|FACE|EYES
	siemens_coefficient = 0.9
	w_class = SIZE_SMALL
	item_action_types = list(/datum/action/item_action/hands_free/flip_welding_mask)

/datum/action/item_action/hands_free/flip_welding_mask
	name = "Использовать сварочный шлем"

/obj/item/clothing/head/welding/attack_self()
	toggle()


/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(!usr.incapacitated())
		if(src.up)
			src.up = !src.up
			src.flags |= (HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv |= (HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = initial(icon_state)
			flash_protection = FLASHES_FULL_PROTECTION
			to_chat(usr, "Вы опускаете [CASE(src, ACCUSATIVE_CASE)], защищая глаза.")
		else
			src.up = !src.up
			src.flags &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
			flags_inv &= ~(HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[initial(icon_state)]up"
			flash_protection = NONE
			to_chat(usr, "Вы поднимаете [CASE(src, ACCUSATIVE_CASE)] со своего лица.")
		update_inv_mob() //so our mob-overlays update
		update_item_actions()


/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	cases = list("шляпа-торт", "шляпы-торта", "шляпе-торту", "шляпу-торт", "шляпой-тортом", "шляпе-торту")
	desc = "Выглядит вкусно!"
	icon_state = "cake0"
	flags = HEADCOVERSEYES
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.
	body_parts_covered = EYES

/obj/item/clothing/head/cakehat/get_current_temperature()
	if(onfire)
		return 700
	return 0

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		STOP_PROCESSING(SSobj, src)
		return

	var/turf/location = src.loc
	if(iscarbon(location))
		var/mob/living/carbon/M = location
		if(M.l_hand == src || M.r_hand == src || M.head == src || M.mouth == src)
			location = M.loc

	if (istype(location, /turf))
		location.hotspot_expose(700, 1)

/obj/item/clothing/head/cakehat/attack_self(mob/user)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = BURN
		src.icon_state = "cake1"
		START_PROCESSING(SSobj, src)
	else
		src.force = null
		src.damtype = BRUTE
		src.icon_state = "cake0"
	return


/*
 * Ushanka
 */
/obj/item/clothing/head/ushanka
	name = "ushanka"
	cases = list("ушанка", "ушанки", "ушанке", "ушанку", "ушанкой", "ушанке")
	desc = "Идеально подходит для сибирских зим, правда, товарищ?"
	flags_inv = HIDEEARS

	var/ushanka_state = "ushanka_black_brown"

/obj/item/clothing/head/ushanka/atom_init()
	. = ..()
	icon_state = "[ushanka_state]-down"
	item_state = "[ushanka_state]-down"

/obj/item/clothing/head/ushanka/attack_self(mob/user)
	if(flags_inv & HIDEEARS)
		icon_state = "[ushanka_state]-up"
		item_state = "[ushanka_state]-up"
		flags_inv &= ~HIDEEARS
		to_chat(user, "Вы поднимаете науши ушанки.")
	else
		icon_state = "[ushanka_state]-down"
		item_state = "[ushanka_state]-down"
		flags_inv |= HIDEEARS
		to_chat(user, "Вы опускаете науши ушанки.")

/obj/item/clothing/head/ushanka/black
	ushanka_state = "ushanka_black"

/obj/item/clothing/head/ushanka/brown
	ushanka_state = "ushanka_brown_brown"

/obj/item/clothing/head/ushanka/black_white
	ushanka_state = "ushanka_black_white"

/obj/item/clothing/head/ushanka/brown_white
	ushanka_state = "ushanka_brown_white"

/*
 * Pumpkin head
 */
/obj/item/clothing/head/hardhat/pumpkinhead
	name = "carved pumpkin"
	cases = list("резная тыква", "резной тыквы", "резной тыкве", "резную тыкву", "резной тыквой", "резной тыкве")
	desc = "Светильник из тыквы, какие обычно изготавливают во время космического Хеллоуина. Считается, что такие светильники могут отгонять злых духов."
	icon_state = "hardhat_pumpkin"//Could stand to be renamed
	item_state = "hardhat_pumpkin"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	body_parts_covered = HEAD|EYES
	brightness_on = 2 //luminosity when on
	armor = list(melee = 5, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	w_class = SIZE_SMALL

/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	cases = list("кошачьи ушки", "кошачьих ушек", "кошачьим ушкам", "кошачьи ушки", "кошачьими ушками", "кошачьих ушках")
	desc = "Пара искусственных кошачьих ушей. Мяу!"
	icon_state = "kitty"
	body_parts_covered = 0
	var/icon/mob
	var/icon/mob2
	siemens_coefficient = 1.5

/obj/item/clothing/head/kitty/update_icon(mob/living/carbon/human/user)
	if(!istype(user)) return
	mob = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty")
	mob2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kitty2")
	mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
	mob2.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

	var/icon/earbit = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner")
	var/icon/earbit2 = new/icon("icon" = 'icons/mob/head.dmi', "icon_state" = "kittyinner2")
	mob.Blend(earbit, ICON_OVERLAY)
	mob2.Blend(earbit2, ICON_OVERLAY)
