/obj/item/table_deco
	icon = 'icons/obj/items.dmi'

/obj/item/table_deco/pen_holder
	name = "pen holder"
	desc = "Держатель для ручки."
	icon_state = "penholder"

	var/obj/item/weapon/pen/holded

/obj/item/table_deco/pen_holder/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen) && !holded)
		user.drop_from_inventory(I, src)
		holded = I
		holded.pixel_x = -2
		holded.pixel_y = 5
		underlays += holded
		icon_state = "penholder_full"

/obj/item/table_deco/pen_holder/attack_hand(mob/user)
	if(holded)
		underlays = null
		holded.pixel_x = 0
		holded.pixel_y = 0
		user.put_in_active_hand(holded)
		holded = null
		icon_state = "penholder"
	else
		..()

/obj/item/table_deco/mars_globe
	name = "mars globe"
	desc = "Глобус Марса."
	icon_state = "globe"

/obj/item/table_deco/newtons_pendulum
	name = "newton's pendulum"
	desc = "Вечный двигатель в миниатюре."
	icon_state = "newtons_pendulum"