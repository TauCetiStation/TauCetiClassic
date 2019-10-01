/obj/item/device/breadgrenade
	name = "Breadgrenade"
	desc = "Science is cool"
	icon = 'icons/obj/biocan.dmi'
	icon_state = "breadgrenade"
	origin_tech = "biotech=5;materials=4;magnets=4"
	w_class = ITEM_SIZE_NORMAL

/obj/item/device/breadgrenade/throw_impact(atom/hit_atom)
	new /obj/item/weapon/shard(loc)
	playsound(src, pick(SOUNDIN_SHATTER), VOL_EFFECTS_MASTER)
	new /mob/living/simple_animal/hostile/bread(get_turf(hit_atom))
	qdel(src)