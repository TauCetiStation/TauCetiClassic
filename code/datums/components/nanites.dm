/datum/component/nanites
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/mob/living/host_mob
	var/nanite_volume = 100		//amount of nanites in the system, used as fuel for nanite programs
	var/max_nanites = 500		//maximum amount of nanites in the system
	var/regen_rate = 0.5		//nanites generated per second
	var/safety_threshold = 50	//how low nanites will get before they stop processing/triggering
	var/cloud_id = 0 			//0 if not connected to the cloud, 1-100 to set a determined cloud backup to draw from
	var/cloud_active = TRUE		//if false, won't sync to the cloud
	var/next_sync = 0
	var/list/datum/nanite_program/programs = list()
	var/max_programs = NANITE_PROGRAM_LIMIT

/datum/component/nanites/Initialize(amount = 100, cloud = 0)
	if(!isliving(parent) && !isnanitebackup(parent))
		return COMPONENT_INCOMPATIBLE

	nanite_volume = amount
	cloud_id = cloud

	//Nanites without hosts are non-interactive through normal means
	if(isliving(parent))
		host_mob = parent
		//Shouldn't happen, but this avoids HUD runtimes in case a silicon gets them somehow.
		if(issilicon(host_mob))
			return COMPONENT_INCOMPATIBLE
		if(ishuman(host_mob))
			var/mob/living/carbon/human/H = host_mob
			if(H.species?.flags[NO_BLOOD])
				return COMPONENT_INCOMPATIBLE

		host_mob.hud_set_nanite_indicator()
		START_PROCESSING(SSnanites, src)

		if(cloud_id && cloud_active)
			cloud_sync()

/datum/component/nanites/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HAS_NANITES, .proc/confirm_nanites)
	RegisterSignal(parent, COMSIG_NANITE_DELETE, .proc/delete_nanites)
	RegisterSignal(parent, COMSIG_NANITE_SET_VOLUME, .proc/set_volume)
	RegisterSignal(parent, COMSIG_NANITE_ADJUST_VOLUME, .proc/adjust_nanites)
	RegisterSignal(parent, COMSIG_NANITE_SET_MAX_VOLUME, .proc/set_max_volume)
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD, .proc/set_cloud)
	RegisterSignal(parent, COMSIG_NANITE_SET_SAFETY, .proc/set_safety)
	RegisterSignal(parent, COMSIG_NANITE_SET_REGEN, .proc/set_regen)
	RegisterSignal(parent, COMSIG_NANITE_ADD_PROGRAM, .proc/add_program)
	RegisterSignal(parent, COMSIG_NANITE_SET_CLOUD_SYNC, .proc/set_cloud_sync)
	RegisterSignal(parent, COMSIG_NANITE_SYNC, .proc/sync)

	if(isliving(parent))
		RegisterSignal(parent, COMSIG_MOB_DIED, .proc/on_death)
		RegisterSignal(parent, COMSIG_SPECIES_GAIN, .proc/check_viable_biotype)
		RegisterSignal(parent, COMSIG_NANITE_SIGNAL, .proc/receive_signal)

/datum/component/nanites/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HAS_NANITES,
								COMSIG_NANITE_DELETE,
								COMSIG_NANITE_SET_VOLUME,
								COMSIG_NANITE_ADJUST_VOLUME,
								COMSIG_NANITE_SET_MAX_VOLUME,
								COMSIG_NANITE_SET_CLOUD,
								COMSIG_NANITE_SET_CLOUD_SYNC,
								COMSIG_NANITE_SET_SAFETY,
								COMSIG_NANITE_SET_REGEN,
								COMSIG_NANITE_ADD_PROGRAM,
								COMSIG_NANITE_SYNC,
								COMSIG_MOB_DIED,
								COMSIG_SPECIES_GAIN,
								COMSIG_NANITE_SIGNAL))

/datum/component/nanites/Destroy()
	STOP_PROCESSING(SSnanites, src)
	QDEL_LIST(programs)
	if(host_mob)
		set_nanite_bar(TRUE)
		host_mob.hud_set_nanite_indicator()
	host_mob = null
	return ..()

/datum/component/nanites/InheritComponent(datum/component/nanites/new_nanites, i_am_original, amount, cloud)
	if(new_nanites)
		adjust_nanites(null, new_nanites.nanite_volume)
	else
		adjust_nanites(null, amount) //just add to the nanite volume

/datum/component/nanites/process()
	if(!IS_IN_STASIS(host_mob))
		adjust_nanites(null, regen_rate)
		for(var/X in programs)
			var/datum/nanite_program/NP = X
			NP.on_process()
		if(cloud_id && cloud_active && world.time > next_sync)
			cloud_sync()
			next_sync = world.time + NANITE_SYNC_DELAY
	set_nanite_bar()

/datum/component/nanites/proc/delete_nanites()
	SIGNAL_HANDLER
	qdel(src)

//Syncs the nanite component to another, making it so programs are the same with the same programming (except activation status)
/datum/component/nanites/proc/sync(datum/signal_source, datum/component/nanites/source, full_overwrite = TRUE, copy_activation = FALSE)
	SIGNAL_HANDLER
	var/list/programs_to_remove = programs.Copy()
	var/list/programs_to_add = source.programs.Copy()
	for(var/X in programs)
		var/datum/nanite_program/NP = X
		for(var/Y in programs_to_add)
			var/datum/nanite_program/SNP = Y
			if(NP.type == SNP.type)
				programs_to_remove -= NP
				programs_to_add -= SNP
				SNP.copy_programming(NP, copy_activation)
				break
	if(full_overwrite)
		for(var/X in programs_to_remove)
			qdel(X)
	for(var/X in programs_to_add)
		var/datum/nanite_program/SNP = X
		add_program(null, SNP.copy())

///Syncs the nanites to their assigned cloud copy, if it is available. If it is not, there is a small chance of a software error instead.
/datum/component/nanites/proc/cloud_sync()
	if(cloud_id)
		var/datum/nanite_cloud_backup/backup = SSnanites.get_cloud_backup(cloud_id)
		if(backup)
			var/datum/component/nanites/cloud_copy = backup.nanites
			if(cloud_copy)
				sync(null, cloud_copy)
				return
	//Without cloud syncing nanites can accumulate errors and/or defects TODO: REMOVE THAT SHIT
	if(prob(8) && programs.len)
		var/datum/nanite_program/NP = pick(programs)
		NP.software_error()

///Adds a nanite program, replacing existing unique programs of the same type. A source program can be specified to copy its programming onto the new one.
/datum/component/nanites/proc/add_program(datum/source, datum/nanite_program/new_program, datum/nanite_program/source_program)
	SIGNAL_HANDLER
	for(var/datum/nanite_program/NP as anything in programs)
		if(NP.unique && NP.type == new_program.type)
			qdel(NP)
	if(programs.len >= max_programs)
		return COMPONENT_PROGRAM_NOT_INSTALLED
	if(source_program)
		source_program.copy_programming(new_program)
	programs += new_program
	new_program.on_add(src)

/datum/component/nanites/proc/consume_nanites(amount, force = FALSE)
	if(!force)
		if(safety_threshold && (nanite_volume - amount < safety_threshold))
			return FALSE
		//bloodloss = nanite loss. Programs suspended
		if(host_mob && ishuman(host_mob))
			var/mob/living/carbon/human/H = host_mob
			var/probability_denied = clamp(BLOOD_VOLUME_OKAY - H.blood_amount(), 0, 100)
			if(prob(probability_denied))
				return FALSE
	adjust_nanites(null, -amount)
	return (nanite_volume > 0)

///Modifies the current nanite volume, then checks if the nanites are depleted or exceeding the maximum amount
/datum/component/nanites/proc/adjust_nanites(datum/source, amount)
	SIGNAL_HANDLER

	nanite_volume += amount
	if(nanite_volume <= 0) //oops we ran out
		qdel(src)

///Updates the nanite volume bar visible in diagnostic HUDs
/datum/component/nanites/proc/set_nanite_bar(remove = FALSE)
	var/image/holder = host_mob.hud_list[DIAG_NANITE_FULL_HUD]
	var/icon/I = icon(host_mob.icon, host_mob.icon_state, host_mob.dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(remove)
		return //bye icon
	var/nanite_percent = (nanite_volume / max_nanites) * 100
	nanite_percent = clamp(CEILING(nanite_percent, 10), 10, 100)
	holder.icon_state = "nanites[nanite_percent]"

/datum/component/nanites/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	for(var/datum/nanite_program/NP as anything in programs)
		NP.on_death(gibbed)

/datum/component/nanites/proc/receive_signal(datum/source, code, source = "an unidentified source")
	SIGNAL_HANDLER
	for(var/datum/nanite_program/NP as anything in programs)
		NP.receive_signal(code, source)

/datum/component/nanites/proc/check_viable_biotype(datum/source, species)
	SIGNAL_HANDLER
	//bodytype no longer sustains nanites
	if(issilicon(host_mob))
		qdel(src)
	var/datum/species/S = species
	if(S.flags[NO_BLOOD])
		qdel(src)

/datum/component/nanites/proc/set_volume(datum/source, amount)
	SIGNAL_HANDLER
	nanite_volume = clamp(amount, 0, max_nanites)

/datum/component/nanites/proc/set_max_volume(datum/source, amount)
	SIGNAL_HANDLER
	max_nanites = max(1, amount)

/datum/component/nanites/proc/set_cloud(datum/source, amount)
	SIGNAL_HANDLER
	cloud_id = clamp(amount, 0, 100)

/datum/component/nanites/proc/set_cloud_sync(datum/source, method)
	SIGNAL_HANDLER
	switch(method)
		if(NANITE_CLOUD_TOGGLE)
			cloud_active = !cloud_active
		if(NANITE_CLOUD_DISABLE)
			cloud_active = FALSE
		if(NANITE_CLOUD_ENABLE)
			cloud_active = TRUE

/datum/component/nanites/proc/set_safety(datum/source, amount)
	SIGNAL_HANDLER
	safety_threshold = clamp(amount, 0, max_nanites)

/datum/component/nanites/proc/set_regen(datum/source, amount)
	SIGNAL_HANDLER
	regen_rate = amount

/datum/component/nanites/proc/confirm_nanites()
	SIGNAL_HANDLER
	return COMPONENT_NANITES_DETECTED
