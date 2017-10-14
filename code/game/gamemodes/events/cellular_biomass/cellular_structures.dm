////////////////////////////
//      BASIC CLASS     ////
////////////////////////////

/obj/structure/cellular_biomass
	name = "basic biomass"
	desc = "basic biomass"
	icon = null
	icon_state = "null"

	anchored = 1
	density = 0
	opacity = 0
	var/faction = "generic"
	var/grip = 0
	var/health = 100
	var/obj/effect/cellular_biomass_controller/master = null

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

/obj/structure/cellular_biomass/proc/healthcheck()
	if(health <=0)
		qdel(src)
	return

/obj/structure/cellular_biomass/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/structure/cellular_biomass/ex_act(severity)
	health -= 100 / severity
	healthcheck()
	return

/obj/structure/cellular_biomass/blob_act()
	health -= 50
	healthcheck()
	return

/obj/structure/cellular_biomass/meteorhit()
	health -= 100
	healthcheck()
	return

/obj/structure/cellular_biomass/attack_hand()
	..()
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	return

/obj/structure/cellular_biomass/attack_paw()
	return attack_hand()

/obj/structure/cellular_biomass/attack_alien()
	return attack_hand()

/obj/structure/cellular_biomass/attackby(obj/item/weapon/W, mob/user)
	..()
	health -= W.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	return

////////////////////////////
// WALLS GRASS AND CORES////
////////////////////////////

/obj/structure/cellular_biomass/wall
	anchored = 1
	density = 1
	opacity = 1
	layer = 4

/obj/structure/cellular_biomass/wall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/cellular_biomass/grass
	health = 40
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
	health = 120
	luminosity = 3
	light_color = "#710F8C"
	icon_state = "light_1"

/obj/structure/cellular_biomass/core/atom_init()
	. = ..()
	icon_state = "light_[pick(1,2)]"
	set_light(luminosity)

/obj/structure/cellular_biomass/core/process()
	health = max(120, health + 1)





////////////////////////
// MOBS   ////
////////////////////////

/obj/effect/decal/cleanable/cellular
	name = "horror"
	desc = "You don't whant to know what is this..."
	icon = 'code/game/gamemodes/events/cellular_biomass/meatland_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("creep_1", "creep_2", "creep_3", "creep_4", "creep_5", "creep_6", "creep_7", "creep_8", "creep_9")
