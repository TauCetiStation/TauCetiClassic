/obj/item/weapon/gun/energy/gun/bison
	name = "pp-91 bison"
	desc = "A trophy energy gun with two settings: stun and kill."
	icon_state = "bison"
	origin_tech = "combat=4;magnets=3"

/obj/item/weapon/gun/energy/gun/bison/atom_init()
	. = ..()
	if(power_supply)
		power_supply.maxcharge = 2000
		power_supply.charge = 2000
