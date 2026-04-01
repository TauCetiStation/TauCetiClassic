/obj/item/weapon/grenade/smokebomb
	desc = "Таймер установлен на 2 секунды."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	slot_flags = SLOT_FLAGS_BELT
	var/datum/effect/effect/system/smoke_spread/bad/smoke

/obj/item/weapon/grenade/smokebomb/atom_init()
	. = ..()
	smoke = new /datum/effect/effect/system/smoke_spread/bad()
	smoke.attach(src)

/obj/item/weapon/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/weapon/grenade/smokebomb/prime()
	playsound(src, 'sound/effects/smoke.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -3)
	smoke.set_up(10, 0, src.loc)
	spawn(0)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()
		sleep(10)
		smoke.start()

	for(var/obj/structure/blob/B in view(8,src))
		var/damage = round(30 / (get_dist(B, src) + 1)) // why the fuck it's here?
		B.take_damage(damage * B.brute_resist, BRUTE, ENERGY)
	sleep(80)
	qdel(src)
