//TRAIN STATION 13

//Code by VoLas and Luduk/LudwigVonChesterfield.
//This module is responsible for train movement and train stations along the way with a couple others train specific features.

//Admin verb toggles

var/list/admin_verbs_trainstation_event = list(
	/client/proc/toggle_trainstation_block, //Event (admin menu) - TS13 Movement - Toggle Invisible Wall
	/client/proc/toggle_train_spawners_and_despawners, //Event (admin menu) - TS13 Decorations - Toggle Spawners on/off"
	/client/proc/change_global_spawn_list_type, //Event (admin menu) - TS13 Decorations - Change Spawn List Type
	/client/proc/spawn_signal, //Event (admin menu) - TS13 Signals - Spawn Red Signal
	/client/proc/toggle_signals, //Event (admin menu) - TS13 Signals - Toggle Signal Lights
)

//INVISIBLE WALL
//Adaptive invisible wall allows admins to control whether players can get to the train station when the train has reached the destination.

var/event_field_stage = 1 //1 - nothing, 2 - objects, 3 - all

var/list/train_block = list()

/proc/set_event_field_stage(value)
	event_field_stage = value

	for(var/obj/effect/decal/trainstation/shield in train_block)
		shield.update_icon()

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

/obj/effect/decal/trainstation/atom_init()
	. = ..()
	train_block += src
	update_icon()

/obj/effect/decal/trainstation/Destroy()
	train_block -= src
	return ..()

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
	unacidable = TRUE
	invisibility = INVISIBILITY_ABSTRACT

/obj/machinery/conveyor/train/ex_act()
	return