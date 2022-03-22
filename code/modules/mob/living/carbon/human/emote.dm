/mob/living/carbon/human
	var/list/default_emotes = list(
		/datum/emote/help,
		/datum/emote/laugh,
		/datum/emote/giggle,
		/datum/emote/grunt,
		/datum/emote/groan,
		/datum/emote/scream,
		/datum/emote/cough,
		/datum/emote/hiccup,
		/datum/emote/choke,
		/datum/emote/snore,
		/datum/emote/whimper,
		/datum/emote/sniff,
		/datum/emote/sneeze,
		/datum/emote/gasp,
		/datum/emote/moan,
		/datum/emote/sigh,
		/datum/emote/mumble,
		/datum/emote/raisehand,
		/datum/emote/rock,
		/datum/emote/paper,
		/datum/emote/scissors,
		/datum/emote/shiver,
		/datum/emote/collapse,
		/datum/emote/pray,
		/datum/emote/bow,
		/datum/emote/yawn,
		/datum/emote/blink,
		/datum/emote/wink,
		/datum/emote/grin,
		/datum/emote/drool,
		/datum/emote/smile,
		/datum/emote/frown,
		/datum/emote/eyebrow,
		/datum/emote/shrug,
		/datum/emote/nod,
		/datum/emote/clap,
		/datum/emote/wave,
		/datum/emote/salute,
		/datum/emote/twitch,
		/datum/emote/deathgasp,
	)
	var/list/current_emotes = list(
	)

	var/list/next_emote_use
	var/list/next_audio_emote_produce

/mob/living/carbon/human/atom_init()
	. = ..()
	for(var/emote in default_emotes)
		var/datum/emote/E = global.all_emotes[emote]
		set_emote(E.key, E)
	default_emotes = null

/mob/living/carbon/human/proc/get_emote(key)
	return current_emotes[key]

/mob/living/carbon/human/proc/set_emote(key, datum/emote/emo)
	current_emotes[key] = emo

/mob/living/carbon/human/proc/clear_emote(key)
	current_emotes.Remove(key)

/mob/living/carbon/human/emote(act = "", message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	var/datum/emote/emo = get_emote(act)
	if(!emo)
		return

	if(!emo.can_emote(src, !auto))
		return

	emo.do_emote(src, act, !auto)

// A simpler emote. Just the message, and it's type. If you want anything more complex - make a datumized emote.
/mob/proc/me_emote(message, message_type = SHOWMSG_VISUAL, intentional=FALSE)
	log_emote("[key_name(src)] : [message]")

	var/msg = "<b>[src]</b> <i>[message]</i>"
	if(message_type & SHOWMSG_VISUAL)
		visible_message(msg, ignored_mobs = observer_list)
	else
		audible_message(msg, ignored_mobs = observer_list)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue

		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				// ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
				to_chat(M, "[FOLLOW_LINK(M, src)] [msg]")
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(intentional)
					to_chat(M, "[FOLLOW_LINK(M, src)] [msg]")

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(input(usr, "This is [src]. \He is...", "Pose", null)  as text)

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text)
