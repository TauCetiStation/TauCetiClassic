/datum/nanite_program
	var/name = "Generic Nanite Program"
	var/desc = "Warn a coder if you can read this."

	var/datum/component/nanites/nanites
	var/mob/living/host_mob

	var/use_rate = 0 			//Amount of nanites used while active
	var/unique = TRUE			//If there can be more than one copy in the same nanites
	var/can_trigger = FALSE		//If the nanites have a trigger function (used for the programming UI)
	var/trigger_cost = 0		//Amount of nanites required to trigger
	var/trigger_cooldown = 50	//Deciseconds required between each trigger activation
	var/next_trigger = 0		//World time required for the next trigger activation

	var/program_flags = NONE
	var/passive_enabled = FALSE //If the nanites have an on/off-style effect, it's tracked by this var

	//The following vars are customizable
	var/activated = TRUE 			//If FALSE, the program won't process, disables passive effects, can't trigger and doesn't consume nanites

	var/timer_restart = 0 			//When deactivated, the program will wait X deciseconds before self-reactivating. Also works if the program begins deactivated.
	var/timer_shutdown = 0 			//When activated, the program will wait X deciseconds before self-deactivating. Also works if the program begins activated.
	var/timer_trigger = 0			//[Trigger only] While active, the program will attempt to trigger once every x deciseconds.
	var/timer_trigger_delay = 0				//[Trigger only] While active, the program will delay trigger signals by X deciseconds.

	//Indicates the next world.time tick where these timers will act
	var/timer_restart_next = 0
	var/timer_shutdown_next = 0
	var/timer_trigger_next = 0
	var/timer_trigger_delay_next = 0

	//Signal codes, these handle remote input to the nanites. If set to 0 they'll ignore signals.
	var/activation_code 	= 0 	//Code that activates the program [1-9999]
	var/deactivation_code 	= 0 	//Code that deactivates the program [1-9999]
	var/kill_code 			= 0		//Code that permanently removes the program [1-9999]
	var/trigger_code 		= 0 	//Code that triggers the program (if available) [1-9999]

/datum/nanite_program/Destroy()
	if(host_mob)
		if(activated)
			deactivate()
		if(passive_enabled)
			disable_passive_effect()
		on_mob_remove()
	if(nanites)
		nanites.programs -= src
	return ..()

/datum/nanite_program/proc/copy()
	var/datum/nanite_program/new_program = new type()
	copy_programming(new_program, TRUE)
	return new_program

/datum/nanite_program/proc/copy_programming(datum/nanite_program/target, copy_activated = TRUE)
	if(copy_activated)
		target.activated = activated
	target.timer_restart = timer_restart
	target.timer_shutdown = timer_shutdown
	target.timer_trigger = timer_trigger
	target.timer_trigger_delay = timer_trigger_delay
	target.activation_code = activation_code
	target.deactivation_code = deactivation_code
	target.kill_code = kill_code
	target.trigger_code = trigger_code

/datum/nanite_program/proc/on_add(datum/component/nanites/_nanites)
	nanites = _nanites
	if(nanites.host_mob)
		on_mob_add()

/datum/nanite_program/proc/on_mob_add()
	host_mob = nanites.host_mob
	if(activated) //apply activation effects depending on initial status; starts the restart and shutdown timers
		activate()
	else
		deactivate()

/datum/nanite_program/proc/on_mob_remove()
	return

/datum/nanite_program/proc/toggle()
	if(!activated)
		activate()
	else
		deactivate()

/datum/nanite_program/proc/activate()
	activated = TRUE

/datum/nanite_program/proc/deactivate()
	if(passive_enabled)
		disable_passive_effect()
	activated = FALSE

/datum/nanite_program/proc/on_process()
	return

//If false, disables active and passive effects, but doesn't consume nanites
//Can be used to avoid consuming nanites for nothing
/datum/nanite_program/proc/check_conditions()
	return TRUE

//Constantly procs as long as the program is active
/datum/nanite_program/proc/active_effect()
	return

//Procs once when the program activates
/datum/nanite_program/proc/enable_passive_effect()
	passive_enabled = TRUE

//Procs once when the program deactivates
/datum/nanite_program/proc/disable_passive_effect()
	passive_enabled = FALSE

//Checks conditions then fires the nanite trigger effect
/datum/nanite_program/proc/trigger(delayed = FALSE)
	if(!can_trigger)
		return
	if(!activated)
		return
	if(timer_trigger_delay && !delayed)
		timer_trigger_delay_next = world.time + timer_trigger_delay
		return
	if(world.time < next_trigger)
		return
	if(!check_conditions())
		return
	if(!consume_nanites(trigger_cost))
		return
	next_trigger = world.time + trigger_cooldown
	on_trigger()

//Nanite trigger effect, requires can_trigger to be used
/datum/nanite_program/proc/on_trigger()
	return

/datum/nanite_program/proc/consume_nanites(amount, force = FALSE)
	return nanites.consume_nanites(amount, force)

/datum/nanite_program/proc/on_death()
	return

/datum/nanite_program/proc/software_error(type)
	return

/datum/nanite_program/proc/receive_signal(code, source)
	if(activation_code && code == activation_code && !activated)
		activate()
	else if(deactivation_code && code == deactivation_code && activated)
		deactivate()
	if(can_trigger && trigger_code && code == trigger_code)
		trigger()
	if(kill_code && code == kill_code)
		qdel(src)
