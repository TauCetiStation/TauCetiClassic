
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Large finds - (Potentially) active alien machinery from the dawn of time
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TO DO LIST:
// * Consider about adding constructshell back
// * Do something about hoverpod, its quite useless now. Maybe get a chance to find a space pod
// * Consider adding more big artifacts
// * Add more effects from /vg/
//

/datum/artifact_find
	var/artifact_id
	var/artifact_find_type
	var/artifact_detect_range

/datum/artifact_find/New()
	artifact_detect_range = rand(5,300)

	artifact_id = "[pick("kappa","sigma","antaeres","beta","omicron","iota","epsilon","omega","gamma","delta","tau","alpha")]-[rand(100,999)]"

	artifact_find_type = pick(\
	5;/obj/machinery/power/supermatter,\
//	5;/obj/structure/constructshell,\  //
	5;/obj/machinery/syndicate_beacon,\
	25;/obj/machinery/power/supermatter/shard,\
//	50;/obj/structure/cult/pylon,\ //
	100;/obj/machinery/auto_cloner,\
	100;/obj/machinery/giga_drill,\
	100;/obj/mecha/working/hoverpod,\
	100;/obj/machinery/replicator,\
	150;/obj/machinery/power/crystal,\
	1000;/obj/machinery/artifact)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Boulders - sometimes turn up after excavating turf - excavate further to try and find large xenoarch finds

/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = 1
	anchored = TRUE
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find
	var/last_act = 0

/obj/structure/boulder/atom_init()
	. = ..()
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5,50)

/obj/structure/boulder/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/device/core_sampler))
		src.geological_data.artifact_distance = rand(-100,100) / 100
		src.geological_data.artifact_id = artifact_find.artifact_id

		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return

	if (istype(W, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = W
		C.scan_atom(user, src)
		return

	if (istype(W, /obj/item/device/measuring_tape))
		if(user.is_busy()) return
		var/obj/item/device/measuring_tape/P = W
		user.visible_message("<span class='notice'>[user] extends [P] towards [src].</span>","<span class='notice'>You extend [P] towards [src].</span>")
		if(P.use_tool(src, user, 40))
			to_chat(user, "<span class='notice'>[bicon(P)] [src] has been excavated to a depth of [2*src.excavation_level]cm.</span>")
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/P = W

		if(last_act + 50 * P.toolspeed > world.time)//prevents message spam
			return
		last_act = world.time

		to_chat(user, "<span class='warning'>You start [P.drill_verb] [src].</span>")

		if(!W.use_tool(src, user, 50, volume = 100))
			return

		to_chat(user, "<span class='notice'>You finish [P.drill_verb] [src].</span>")
		excavation_level += P.excavation_amount

		if(excavation_level > 100)
			//failure
			user.visible_message("<span class='danger'>[src] suddenly crumbles away.</span>",\
			"<span class='danger'>[src] has disintegrated under your onslaught, any secrets it was holding are long gone.</span>")
			qdel(src)
			return

		if(prob(excavation_level))
			//success
			if(artifact_find)
				var/spawn_type = artifact_find.artifact_find_type
				var/obj/O = new spawn_type(get_turf(src))
				if(istype(O,/obj/machinery/artifact))
					var/obj/machinery/artifact/A = O
					if(A.my_effect)
						A.my_effect.artifact_id = artifact_find.artifact_id
				src.visible_message("<span class='danger'>[src] suddenly crumbles away.</span>")
			else
				user.visible_message("<span class='danger'>[src] suddenly crumbles away.</span>",\
				"<span class='notice'>[src] has been whittled away under your careful excavation, but there was nothing of interest inside.</span>")
			qdel(src)

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
			attackby(H.r_hand,H)

	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)
