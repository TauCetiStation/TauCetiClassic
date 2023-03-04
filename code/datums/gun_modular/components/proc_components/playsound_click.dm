/datum/gun_modular/component/proc_gun/playsound_click
	id_component = "playsound_click"

/datum/gun_modular/component/proc_gun/playsound_click/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/sound_data/click_sound_data = process.GetCacheData("click_sound")
	var/datum/gun_modular/component/data/gun_user/gun_user_data = process.GetCacheData(USER_FIRE)

	if(!click_sound_data || !gun_user_data)
		return ..()

	if(!click_sound_data.IsValid() || !gun_user_data.IsValid())
		return ..()

	var/mob/user = gun_user_data.GetData()

	playsound(user, click_sound_data.sound, VOL_EFFECTS_MASTER, click_sound_data.volume, click_sound_data.vary)
	return ..()
