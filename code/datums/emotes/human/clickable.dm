
/datum/emote/clickable
	var/duration

/datum/emote/clickable/add_cloud(mob/user)
	var/atom/movable/emote_bubble = new()
	emote_bubble.icon_state = cloud
	emote_bubble.icon = 'icons/mob/emote.dmi'
	user.vis_contents += emote_bubble
	RegisterSignal(emote_bubble, list(COMSIG_CLICK), CALLBACK(src, .proc/on_cloud_click_handler, user))
	QDEL_IN(emote_bubble, duration)


/datum/emote/clickable/proc/on_cloud_click_handler(target, p, location, control, params, clicker)
	SIGNAL_HANDLER
	if(!istype(target, /mob/living/carbon/human/) || !istype(clicker, /mob/living/carbon/human/))
		return FALSE

	var/mob/living/carbon/human/t = target
	var/mob/living/carbon/human/c = clicker
	if(c.incapacitated() || c.lying || c.crawling || c.resting || c.is_busy() || c.get_active_hand())
		return FALSE
	on_cloud_click(t,c)

	return TRUE

/datum/emote/clickable/proc/on_cloud_click(mob/living/carbon/target, mob/living/carbon/clicker)
	return

/datum/emote/clickable/help
	key = "help"

	message_1p = "You asked for help."
	message_3p = "needs help."
	cooldown = 7 SECONDS
	duration = 5 SECONDS
	message_type = SHOWMSG_AUDIO

	cloud = "cloud-medic"
	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE)
	)

/datum/emote/clickable/help/on_cloud_click(mob/living/carbon/human/target, mob/living/carbon/human/clicker)
	if(target != clicker)
		clicker.help_other(target)
	
