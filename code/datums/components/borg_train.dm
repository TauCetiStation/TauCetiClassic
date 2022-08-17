/datum/component/borg_train

/datum/component/borg_train/Initialize()
	if(!isrobot(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_BORG_TRAIN_ENABLED, .proc/already_active)
	RegisterSignal(parent, COMSIG_BORG_TRAIN_REMOVED, .proc/delete_component)
	RegisterSignal(parent, COMSIG_BORG_MOB_BUMP, .proc/knock_off)
	RegisterSignal(parent, COMSIG_BORG_CROSSED_MOB, .proc/crush)

/datum/component/borg_train/proc/already_active(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_BORG_TRAIN_BLOCK

/datum/component/borg_train/proc/delete_component(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/borg_train/proc/knock_off(datum/source, mob/victim)
	SIGNAL_HANDLER
	if(isliving(victim) || issilicon(victim))
		var/mob/living/L = victim
		var/mob/living/silicon/robot/R = parent
		var/moving_dir = get_dir(R, L)
		step(L, moving_dir)
		step(R, moving_dir)
		L.Stun(1)
		L.Weaken(3)

/datum/component/borg_train/proc/crush(datum/source, mob/victim)
	SIGNAL_HANDLER
	if(!ishuman(victim))
		return
	visible_message("<span class='warning'>[parent] crushes a [H]!</span>")
	parent.say("ЧУУХ-ЧУУХ!!!")
	playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
	var/mob/living/carbon/human/H = victim
	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, BP_HEAD)
	H.apply_damage(2*damage, BRUTE, BP_CHEST)
	H.apply_damage(0.5*damage, BRUTE, BP_L_LEG)
	H.apply_damage(0.5*damage, BRUTE, BP_R_LEG)
	H.apply_damage(0.5*damage, BRUTE, BP_L_ARM)
	H.apply_damage(0.5*damage, BRUTE, BP_R_ARM)

/datum/component/borg_train/Destroy()
	UnregisterSignal(parent, COMSIG_BORG_TRAIN_REMOVED)
	UnregisterSignal(parent, COMSIG_BORG_TRAIN_ENABLED)
	return ..()
