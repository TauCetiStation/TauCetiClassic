/// The subsystem for controlling drastic performance enhancements aimed at reducing server load for a smoother albeit slightly duller gaming experience
SUBSYSTEM_DEF(lag_switch)
	name = "Lag Switch"
	flags = SS_NO_FIRE

	/// If the lag switch measures should attempt to trigger automatically, TRUE if a config value exists
	var/auto_switch = FALSE
	/// Amount of connected clients at which the Lag Switch should engage, set via config or admin panel
	var/trigger_pop = INFINITY - 1337
	/// List of bools corresponding to code/__DEFINES/lag_switch.dm
	var/static/list/measures[MEASURES_AMOUNT]
	/// List of measures that toggle automatically
	var/list/auto_measures = list(DISABLE_GHOST_ZOOM, DISABLE_RUNECHAT, DISABLE_PARALLAX, DISABLE_BICON, DISABLE_FOOTSTEPS)
	/// Timer ID for the automatic veto period
	var/veto_timer_id
	/// Cooldown between say verb uses when slowmode is enabled
	var/slowmode_cooldown = 3 SECONDS

/datum/controller/subsystem/lag_switch/Initialize()
	for(var/i in 1 to measures.len)
		measures[i] = FALSE
	if(config.auto_lag_switch_pop)
		auto_switch = TRUE
		trigger_pop = config.auto_lag_switch_pop
		RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))
	return ..()

/datum/controller/subsystem/lag_switch/proc/client_connected(datum/source, client/connected)
	SIGNAL_HANDLER
	if(length(global.clients) < trigger_pop)
		return

	auto_switch = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT)
	veto_timer_id = addtimer(CALLBACK(src, PROC_REF(set_all_measures), TRUE, TRUE), 20 SECONDS, TIMER_STOPPABLE)
	message_admins("Lag Switch population threshold reached. Automatic activation of lag mitigation measures occuring in 20 seconds. (<a href='?_src_=holder;change_lag_switch_option=CANCEL'>CANCEL</a>)")
	log_admin("Lag Switch population threshold reached. Automatic activation of lag mitigation measures occuring in 20 seconds.")

/// (En/Dis)able automatic triggering of switches based on client count
/datum/controller/subsystem/lag_switch/proc/toggle_auto_enable()
	auto_switch = !auto_switch
	if(auto_switch)
		RegisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT, PROC_REF(client_connected))
	else
		UnregisterSignal(SSdcs, COMSIG_GLOB_CLIENT_CONNECT)

/// Called from an admin chat link
/datum/controller/subsystem/lag_switch/proc/cancel_auto_enable_in_progress()
	if(!veto_timer_id)
		return FALSE

	deltimer(veto_timer_id)
	veto_timer_id = null
	return TRUE

/// Update the slowmode timer length and clear existing ones if reduced
/datum/controller/subsystem/lag_switch/proc/change_slowmode_cooldown(length)
	if(!length)
		return FALSE

	var/length_secs = length SECONDS
	if(length_secs <= 0)
		length_secs = 1 // one tick because cooldowns do not like 0

	if(length_secs < slowmode_cooldown)
		for(var/client/C as anything in global.clients)
			COOLDOWN_RESET(C, say_slowmode)

	slowmode_cooldown = length_secs
	if(measures[SLOWMODE_IC_CHAT])
		global_ooc_info("Slowmode timer has been changed to [length] seconds by an admin.")
	return TRUE

/// Handle the state change for individual measures
/datum/controller/subsystem/lag_switch/proc/set_measure(measure_key, state)
	if(isnull(measure_key) || isnull(state))
		stack_trace("SSlag_switch.set_measure() was called with a null arg")
		return FALSE
	if(isnull(LAZYACCESS(measures, measure_key)))
		stack_trace("SSlag_switch.set_measure() was called with a measure_key not in the list of measures")
		return FALSE
	if(measures[measure_key] == state)
		return TRUE

	measures[measure_key] = state

	switch(measure_key)
		if(DISABLE_DEAD_KEYLOOP)
			if(state)
				for(var/mob/user as anything in global.player_list)
					if(user.stat == DEAD && !user.client?.holder)
						global.keyloop_list -= user
				to_chat(observer_list, "<span class='bold notice'>To increase performance Observer freelook is now disabled. Please use Orbit, Teleport, and Jump to look around.</span>")
			else
				global.keyloop_list |= global.player_list
				to_chat(observer_list, "<span class='bold notice'>Observer freelook has been re-enabled. Enjoy your wooshing.</span>")

		if(DISABLE_GHOST_ZOOM)
			if(state)
				for(var/mob/user as anything in global.observer_list)
					user.client?.change_view(world.view)
				to_chat(observer_list, "<span class='bold notice'>Observer zoom has been disabled.</span>")
			else
				to_chat(observer_list, "<span class='bold notice'>Observer zoom has been enabled.</span>")

		if(SLOWMODE_IC_CHAT)
			if(state)
				global_ooc_info("Slowmode for IC/dead chat has been enabled with [slowmode_cooldown/10] seconds between messages.")
			else
				for(var/client/C as anything in global.clients)
					COOLDOWN_RESET(C, say_slowmode)
				global_ooc_info("Slowmode for IC/dead chat has been disabled by an admin.")

		if(DISABLE_NON_OBSJOBS)
			world.update_status()

		if(DISABLE_PARALLAX)
			if (state)
				global_ooc_info("Parallax has been disabled for performance concerns.")
			else
				global_ooc_info("Parallax has been re-enabled.")

			for (var/mob/mob as anything in global.mob_list)
				mob.hud_used?.update_parallax_pref()

		if (DISABLE_BICON)
			if (state)
				global_ooc_info("Examine icons have been disabled for performance concerns.")
			else
				global_ooc_info("Examine icons have been re-enabled.")

		if (DISABLE_RUNECHAT)
			if (state)
				global_ooc_info("Runechat has been disabled for performance concerns.")
			else
				global_ooc_info("Runechat has been re-enabled.")

		if (DISABLE_FOOTSTEPS) // todo: more playsounds
			if (state)
				global_ooc_info("Footstep sounds have been disabled for performance concerns.")
			else
				global_ooc_info("Footstep sounds have been re-enabled.")

	return TRUE

/// Helper to loop over all measures for mass changes
/datum/controller/subsystem/lag_switch/proc/set_all_measures(state, automatic = FALSE)
	if(isnull(state))
		stack_trace("SSlag_switch.set_all_measures() was called with a null state arg")
		return FALSE

	if(automatic)
		message_admins("Lag Switch enabling automatic measures now.")
		log_admin("Lag Switch enabling automatic measures now.")
		veto_timer_id = null
		for(var/i in 1 to auto_measures.len)
			set_measure(auto_measures[i], state)
		return TRUE

	for(var/i in 1 to measures.len)
		set_measure(i, state)
	return TRUE
