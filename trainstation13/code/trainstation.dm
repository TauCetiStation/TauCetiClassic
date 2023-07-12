//TRAIN STATION 13

//This module is responsible for train movement and train stations along the way with a couple others train specific features.
//Code by VoLas and Luduk/LudwigVonChesterfield.

//Admin verb toggles

var/list/admin_verbs_trainstation_event = list(
	/client/proc/change_global_train_decorations, //Event (admin menu) - TS13 Decorations - Change Decorations Type
	/client/proc/toggle_train_spawners_and_despawners, //Event (admin menu) - TS13 Decorations - Toggle Spawners on/off
	/client/proc/toggle_trainstation_block, //Event (admin menu) - TS13 Movement - Toggle Invisible Wall
	/client/proc/spawn_signal, //Event (admin menu) - TS13 Signals - Spawn Signal
	/client/proc/toggle_signals, //Event (admin menu) - TS13 Signals - Toggle Signal Lights
)

//INVISIBLE WALL
//Adaptive invisible wall allows admins to control whether players can get to the train station when the train has reached the destination.

var/event_field_stage = 1 //1 - nothing, 2 - objects, 3 - all

var/list/train_block = list()

/proc/set_event_field_stage(value)
	event_field_stage = value

	for(var/obj/effect/decal/trainstation/shield in global.train_block)
		shield.update_icon()

ADD_TO_GLOBAL_LIST(/obj/effect/decal/trainstation, global.train_block)

/obj/effect/decal/trainstation
	name = "..."
	desc = "Allright! Move on! Nothing to see here. Please disperse! Nothing to see here! Please!"
	density = 0
	anchored = 1
	layer = 2
	icon = 'trainstation13/icons/trainbackstage.dmi'
	icon_state = "block"
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/decal/trainstation/ex_act()
	return

/obj/effect/decal/trainstation/CanPass(atom/movable/mover)
	if(event_field_stage==3)
		return 1
	else if(isobj(mover) && event_field_stage==2)
		return 1
	else
		return 0

/obj/effect/decal/trainstation/update_icon()
	switch(event_field_stage)
		if(1)
			desc = "The show is too deep here, and the wind is too strong to throw anything through."
			icon_state = "block"
		if(2)
			desc = "The show is too deep here. No one would be able to pass through unless Mr. Plow would clean it up a little."
			icon_state = "block"
		if(3)
			desc = "This snow is deeper than usual, but it's passable."
			icon_state = "block"

//1 - nothing, 2 - objects, 3 - all

/client/proc/toggle_trainstation_block()
	set category = "Event"
	set name = "TS13 Movement - Toggle Invisible Wall"

	var/msg
	if(event_field_stage==1)
		event_field_stage=2
		msg = "OBJECTS may pass"
	else if(event_field_stage==2)
		event_field_stage=3
		msg = "OBJECTS and MOBS may pass"
	else if(event_field_stage==3)
		event_field_stage=1
		msg = "NOTHING may pass"

	log_admin("[usr.key] has toggled event invisible wall, now [msg].")
	message_admins("[key_name_admin(usr)] has toggled event invisible wall, now [msg].")

	for(var/obj/effect/decal/trainstation/shield in train_block)
		shield.update_icon()

//TRAIN MOVEMENT IS BASED ON CONVEYOR BELTS CODE
//I wonder why no one has tried this one before, was it lag or the fact this would be generally considered a shitcode? - BartNixon

/obj/machinery/conveyor/train
	name = "ice"
	desc = "Layer of ice has formed on top of the snow. You see nothing out of the ordinary."
	icon = 'trainstation13/icons/trainbackstage.dmi'
	color = "#ff4343"
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/machinery/conveyor/train/ex_act()
	return

/obj/machinery/conveyor/train/main
	color = "#4fff43"
	operating = 1
	var/list/affecting_turfs = list()

/obj/machinery/conveyor/train/main/atom_init()
	. = ..()
	affecting_turfs += get_turf(get_step(get_turf(get_step(src, NORTH)), NORTH))
	affecting_turfs += get_turf(get_step(src, NORTH))
	affecting_turfs += get_turf(src)
	affecting_turfs += get_turf(get_step(src, SOUTH))
	affecting_turfs += get_turf(get_step(get_turf(get_step(src, SOUTH)), SOUTH))

/obj/machinery/conveyor/train/main/process()
	if(stat & (BROKEN | NOPOWER))
		return
	if(!operating)
		return
	use_power(100)
	affecting = list()
	for(var/turf/T in affecting_turfs)
		affecting += T.contents - src

	sleep(1)    // slight delay to prevent infinite propagation due to map order
	var/items_moved = 0
	for(var/atom/movable/A in affecting)
		if(!A.anchored && !(A.flags & ABSTRACT))
			step(A,movedir)
		items_moved++
		if(items_moved >= 10)
			break

//EXITING MOVING TRAIN GIBS MOBS

var/global/list/train_special_effects = list()

ADD_TO_GLOBAL_LIST(/obj/effect/decal/train_special_effects, train_special_effects)

/obj/effect/decal/train_special_effects
	name = "special effect"
	desc = "You should not see this, but if you do - on behalf of entire Train Station 13 team, we wish you a nice day!"
	icon = 'trainstation13/icons/trainareas.dmi'
	icon_state = "trainstation13"
	anchored = TRUE
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	var/still_icon_state = "trainstation13"

/obj/effect/decal/train_special_effects/ex_act()
	return

/obj/effect/decal/train_special_effects/proc/change_movement(moving)
	icon_state = "[still_icon_state]_[moving ? "moving" : "still"]"

/obj/effect/decal/train_special_effects/injurebox
	name = "injure box"
	desc = "Whoever crosses this marker will get stunned and slightly injured."
	icon = 'trainstation13/icons/trainareas.dmi'
	icon_state = "bone_still"
	still_icon_state = "bone"

/obj/effect/decal/train_special_effects/injurebox/Crossed(atom/movable/AM)
	if(icon_state == "bone_moving" && isliving(AM))
		var/mob/living/L = AM
		L.Stun(5)
		L.Weaken(5)
		L.adjustBruteLoss(2)

/obj/effect/decal/train_special_effects/killbox
	name = "kill box"
	desc = "Whoever crosses this marker will turn into ground beef."
	icon = 'trainstation13/icons/trainareas.dmi'
	icon_state = "roger_still"
	still_icon_state = "roger"

/obj/effect/decal/train_special_effects/killbox/Crossed(atom/movable/AM)
	if(icon_state == "roger_moving" && isliving(AM))
		var/mob/living/L = AM
		L.gib()