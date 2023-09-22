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

/obj/item/table_deco/clocks
	name = "table clock"
	desc = "Точное время в любое время."
	icon_state = "clock"

	maptext_x = 1
	maptext_y = 1

/obj/item/table_deco/clocks/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/table_deco/clocks/process()
	var/time = world.time
	var/new_text = {"<div style="font-size:3;color:#61a53f;font-family:'TINIESTONE';text-align:center;" valign="middle">[round(time / 36000)+12] [(time / 600 % 60) < 10 ? add_zero(time / 600 % 60, 1) : time / 600 % 60]</div>"}

	if(maptext != new_text)
		maptext = ""
		sleep(5)
		maptext = new_text

		desc = "'Точное время в любое время'. Показывают: [worldtime2text()]"
