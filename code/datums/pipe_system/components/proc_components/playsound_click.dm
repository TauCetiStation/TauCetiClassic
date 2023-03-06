/datum/pipe_system/component/proc_gun/playsound_click
	id_component = "playsound_click"

/datum/pipe_system/component/proc_gun/playsound_click/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/sound_data/click_sound_data = process.GetCacheData("click_sound")
	var/datum/pipe_system/component/data/gun_user/gun_user_data = process.GetCacheData(USER_FIRE)

	if(!click_sound_data || !gun_user_data)
		return ..()

	if(!click_sound_data.IsValid() || !gun_user_data.IsValid())
		return ..()

	var/mob/user = gun_user_data.GetData()

	playsound(user, click_sound_data.sound, VOL_EFFECTS_MASTER, click_sound_data.volume, click_sound_data.vary)
	return ..()
