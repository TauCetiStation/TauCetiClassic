/mob/living/carbon/human
	default_emotes = list(
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
