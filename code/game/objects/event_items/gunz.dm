/obj/item/weapon/gun/projectile/automatic/stryker
	name = "Stryker assault rifle"
	icon = 'code/game/objects/event_items/gunz.dmi'
	icon_custom = 'code/game/objects/event_items/gunz.dmi'
	desc = ""
	icon_state = "stryker"
	item_state = "stryker"
	w_class = 3.0
	origin_tech = "combat=5;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/event/stryker_shot.wav'
	var/icon/mag_icon = icon('code/game/objects/event_items/gunz.dmi',"mag-stryker")

/obj/item/weapon/gun/projectile/automatic/stryker/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/gun/projectile/automatic/stryker/update_icon()
	overlays.Cut()
	if(magazine)
		overlays += mag_icon
		item_state = "[initial(icon_state)]"
	else
		item_state = "[initial(icon_state)]-e"