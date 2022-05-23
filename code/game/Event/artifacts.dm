/obj/structure/closet/crate/miningcar/unlimited_wood
	name = "Странная тележка"
	desc = "Ощущается странность"

/obj/structure/closet/crate/miningcar/unlimited_wood/open()
	..()
	new/obj/item/stack/sheet/wood(loc)

/obj/structure/closet/crate/miningcar/unlimited_silver
	name = "Странная тележка"
	desc = "Ощущается странность"

/obj/structure/closet/crate/miningcar/unlimited_silver/open()
	..()
	new/obj/item/weapon/ore/silver(loc)

/obj/item/shakal_skull
	name = "Проклятый Череп Шакала"
	desc = "Не трогай его"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "penlight"
	item_state = ""

/obj/item/shakal_skull/pickup(mob/user)
	..()
	user.add_filter("wave_filter",1,wave_filter(0,3))