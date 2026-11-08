/obj/structure/closet/secure_closet/bar
	name = "Booze"
	req_access = list(access_bar)
	icon_state = "cabinetsecure"
	icon_closed = "cabinetsecure"
	icon_opened = "cabinetsecure_open"
	overlay_locked = "cabinetsecure_locked"
	overlay_unlocked = "cabinetsecure_unlocked"
	overlay_welded = "cabinetsecure_welded"

	hit_particle_type = /particles/tool/digging/wood

/obj/structure/closet/secure_closet/bar/PopulateContents()
	new /obj/item/weapon/woodencrate/beer(src)
