////////////////////////////
//      BASIC CLASS     ////
////////////////////////////

/obj/structure/cellular_biomass
	name = "basic biomass"
	desc = "basic biomass"
	icon = null
	icon_state = "null"

	anchored = TRUE
	density = FALSE
	opacity = 0
	var/faction = "generic"
	var/grip = 0
	var/obj/effect/cellular_biomass_controller/master = null

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/cellular_biomass/Destroy()
	if(density)
		SSair.mark_for_update(get_turf(src))
	if(master)
		master.remove_biomass(src)
	..()
	return QDEL_HINT_QUEUE

/obj/structure/cellular_biomass/proc/set_master(obj/effect/cellular_biomass_controller/newmaster)
	master = newmaster
	return

/obj/structure/cellular_biomass/attack_hand(mob/user)
	..()
	user.SetNextMove(CLICK_CD_MELEE)
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	return

/obj/structure/cellular_biomass/attack_paw()
	return attack_hand()

/obj/structure/cellular_biomass/attack_alien()
	return attack_hand()

/obj/structure/cellular_biomass/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)


////////////////////////////
// WALLS GRASS AND CORES////
////////////////////////////

/obj/structure/cellular_biomass/wall
	anchored = TRUE
	density = TRUE
	can_block_air = TRUE
	opacity = 1
	layer = 4

/obj/structure/cellular_biomass/wall/CanPass(atom/movable/mover, turf/target, height=0)
	return FALSE

/obj/structure/cellular_biomass/grass
	max_integrity = 40
	layer = 2

/obj/structure/cellular_biomass/grass/atom_init()
	. = ..()
	icon_state = "bloodfloor_[pick(1,2,3)]"


/obj/structure/cellular_biomass/grass/Destroy()
	for(var/obj/effect/decal/cleanable/cellular/clean in src.loc)
		qdel(clean)
	return ..()

/obj/structure/cellular_biomass/core
	layer = 3
	max_integrity = 120
	light_color = "#710f8c"
	light_range = 3
	icon_state = "light_1"

/obj/structure/cellular_biomass/core/atom_init()
	. = ..()
	icon_state = "light_[pick(1,2)]"
	set_light(light_range)

/obj/structure/cellular_biomass/core/process()
	if(get_integrity() < max_integrity)
		repair_damage(1)





////////////////////////
// MOBS   ////
////////////////////////

/obj/effect/decal/cleanable/cellular
	name = "horror"
	desc = "You don't whant to know what is this..."
	icon = 'icons/obj/structures/cellular_biomass/meatland_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("creep_1", "creep_2", "creep_3", "creep_4", "creep_5", "creep_6", "creep_7", "creep_8", "creep_9")
