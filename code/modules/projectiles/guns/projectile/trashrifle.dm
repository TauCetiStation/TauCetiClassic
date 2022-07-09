/obj/item/weapon/gun/projectile/heavyrifle/trashriflee
	name = "Single-shot rifle"
	desc = "Single-shot rifle made from scrap materials."
	icon_state = "boltrifle"
	item_state = "boltrifletrash"
	w_class = SIZE_NORMAL
	force = 10
	slot_flags = SLOT_FLAGS_BACK
	recoil = 3 //extra kickback
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rifle763
	fire_sound = 'sound/weapons/guns/gunshot_trashriflebolt.ogg'
	can_be_holstered = FALSE

/obj/item/weapon/gun/projectile/heavyrifle/trashriflee/update_icon(mob/user)
	if(bolt_open)
		icon_state = "boltrifle_open"
	else
		icon_state = "boltrifle"

// TrashRifle craft in recipes.dm

/obj/item/weapon/bolt
	name = "Bolt action for rifle"
	desc = "The shutter required for the operation of the rifle."
	icon = 'icons/obj/gun.dmi'
	icon_state = "bolt"
