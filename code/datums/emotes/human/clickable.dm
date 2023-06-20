
/datum/emote/clickable
	var/duration

/atom/movable/clickable_cloud
	icon = 'icons/mob/emote.dmi'

/atom/movable/clickable_cloud/proc/add_to_user(mob/user, duration, state)
	icon_state = state
	user.vis_contents += src
	QDEL_IN(src, duration)

/datum/emote/clickable/add_cloud(mob/user)
	var/atom/movable/clickable_cloud/bubble = new()
	bubble.add_to_user(user, duration, cloud)
	RegisterSignal(bubble, list(COMSIG_CLICK), CALLBACK(src, PROC_REF(on_cloud_click_handler), user))

/datum/emote/clickable/proc/on_cloud_click_handler(target, p, location, control, params, clicker)
	SIGNAL_HANDLER
	if(!ishuman(target) || !ishuman(clicker))
		return

	var/mob/living/carbon/human/t = target
	var/mob/living/carbon/human/c = clicker
	if(c.incapacitated() || c.crawling || c.is_busy() || c.get_active_hand() || !c.Adjacent(t))
		return

	on_cloud_click(t, c)

/datum/emote/clickable/proc/on_cloud_click(mob/living/carbon/target, mob/living/carbon/clicker)
	return

/datum/emote/clickable/help
	key = "help"
	message_1p = "You asked for help."
	message_3p = "needs help."
	cooldown = 10 SECONDS
	duration = 7 SECONDS
	message_type = SHOWMSG_AUDIO

	cloud = "cloud-medic"
	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE)
	)

/datum/emote/clickable/help/add_cloud(mob/user)
	. = ..()
	for(var/mob/living/carbon/M in get_hearers_in_view(emote_range, user))
		if(M != user)
			to_chat(M, "<span class='notice'>[HELP_LINK(M, user)]</span>")

/datum/emote/clickable/help/on_cloud_click(mob/living/carbon/human/target, mob/living/carbon/human/clicker)
	if(target != clicker)
		clicker.help_other(target)
