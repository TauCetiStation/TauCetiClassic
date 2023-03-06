/datum/pipe_system/component/data/sound_data
	id_component = "sound_data"
	id_data = "sound_data"
	var/sound = null
	var/volume = 100
	var/vary = FALSE
	var/extrarange = 0


/datum/pipe_system/component/data/sound_data/ChangeData(datum/pipe_system/component/data/sound_data/data)
	. = ..()

	sound = data.sound
	volume = data.volume
	vary = data.vary
	extrarange += data.extrarange

	return TRUE

/datum/pipe_system/component/data/sound_data/CopyComponentGun()

	var/datum/pipe_system/component/data/sound_data/new_component = ..()

	new_component.sound = sound
	new_component.volume = volume
	new_component.vary = vary
	new_component.extrarange = extrarange

	return new_component

/datum/pipe_system/component/data/sound_data/IsValid()
	. = ..()

	if(isnull(sound))
		return FALSE

	if(isnull(volume))
		return FALSE

	return TRUE
