/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'

	// Is heavily utilized by swiping component. Perhaps use to determine how "quick" the strikes with this weapon are?
	// See swiping.dm for more details.
	var/sweep_step = 4

/obj/item/weapon/throwing_star
	name = "throwing star"
	desc = "An ancient weapon still used to this day due to it's ease of lodging itself into victim's body parts"
	icon_state = "throwingstar"
	item_state = "eshield0"
	force = 2
	throwforce = 20
	throw_speed = 6
	w_class = ITEM_SIZE_SMALL
	sharp = 1
	edge = 1
	can_embed = 1
	materials = list(MAT_METAL=500, MAT_GLASS=500)
