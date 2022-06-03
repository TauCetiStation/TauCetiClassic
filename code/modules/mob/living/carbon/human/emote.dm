/mob/living/carbon/human
	var/list/default_emotes = list(
		/datum/emote/list,
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
		/datum/emote/clickable/help
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

/mob/living/carbon/human/can_me_emote(message_type, intentional)
	. = ..()
	if(. && miming && message_type == SHOWMSG_AUDIO)
		if(intentional)
			to_chat(src, "You are unable to make such noises.")
		return FALSE

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
