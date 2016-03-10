//GUNS RANDOM
/obj/random/handgun_security
	name = "Random Handgun"
	desc = "This is a random security sidearm."
	icon = 'icons/obj/gun.dmi'
	icon_state = "sigi250"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/sigi,\
					prob(1);/obj/item/weapon/gun/projectile/sigi/spec)

/obj/random/projectile_security
	name = "Random Projectile Weapon"
	desc = "This is a random security weapon."
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_to_spawn()
		return pick(prob(3);/obj/item/weapon/gun/projectile/shotgun,\
					prob(1);/obj/item/weapon/gun/projectile/shotgun/combat)
