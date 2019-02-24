/obj/item/weapon/grenade/electric
	name = "electric smoke grenade"
	icon_state = "flashbang"
	item_state = "flashbang"
	det_time = 30
	origin_tech = "materials=4;combat=4"

/obj/item/weapon/grenade/electric/prime()
	var/datum/effect/effect/system/smoke_spread/electric/S = new
	S.attach(get_turf(src))
	S.set_up(30, 0, get_turf(src))
	S.start()
	qdel(src)
	return