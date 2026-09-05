/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	desc = "Оружие, чьи снаряды изменяют температуру цели."
	icon_state = "freezegun"
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/temp, /obj/item/ammo_casing/energy/temp/hot)
	cell_type = /obj/item/weapon/stock_parts/cell/high

/obj/item/weapon/gun/energy/temperature/attack_self(mob/living/user)
	..()
	update_icon()
