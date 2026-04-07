/obj/item/weapon/grenade/empgrenade
	name = "classic emp grenade"
	icon_state = "emp"
	item_state = "emp"
	origin_tech = "materials=2;magnets=3"
	activate_sound = 'sound/weapons/sound_effects_sebb_beep.ogg'

/obj/item/weapon/grenade/empgrenade/prime()
	..()
	if(empulse(src, 4, 10, custom_effects = EMP_SEBB))
		qdel(src)
	return

