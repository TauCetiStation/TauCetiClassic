/datum/pipe_system/component/proc_gun/user_recoil
	id_component = "user_recoil"

/datum/pipe_system/component/proc_gun/user_recoil/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_user/user_data = process.GetCacheData(USER_FIRE)
	var/datum/pipe_system/component/data/gun_user/recoil_data = process.GetCacheData(RECOIL)

	if(!user_data || !recoil_data)
		return ..()

	if(!user_data.IsValid() || !recoil_data.IsValid())
		return ..()

	var/mob/user = user_data.value
	var/recoil = recoil_data.value

	var/skill_recoil = max(0, apply_skill_bonus(user, recoil, list(/datum/skill/firearms = SKILL_LEVEL_TRAINED), multiplier = -0.5))
	if(skill_recoil)
		shake_camera(user, skill_recoil + 1, skill_recoil)

	return ..()
