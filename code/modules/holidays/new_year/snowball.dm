/obj/item/snowball
	name = "snowball"
	desc = "Get ready for a snowball fight!"
	force = 0
	throwforce = 10
	icon_state = "snowball"

/obj/item/snowball/throw_impact(atom/target)
	..()
	qdel(src)

/obj/item/snowball/fire_act()
	qdel(src)

/obj/item/snowball/ex_act(severity)
	qdel(src)
