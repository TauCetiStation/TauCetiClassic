/obj/item/weapon/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'tauceti/items/weapons/explosives/syndie_bomb.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/syndieminibomb/prime()
	explosion(src.loc,1,2,4,5)
	qdel(src)