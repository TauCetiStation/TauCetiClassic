/mob/living/carbon/human
	default_emotes = list(
		/datum/emote/list,
		/datum/emote/pray,
		/datum/emote/shiver,
		/datum/emote/whimper,
		/datum/emote/moan,
		/datum/emote/collapse,
		/datum/emote/faint,
		/datum/emote/roar,
		/datum/emote/clickable/help,
	)

/mob/living/carbon/human/load_default_emotes()
	default_emotes += subtypesof(/datum/emote/human)
	return ..()

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

/mob/living/carbon/human/verb/emote_panel()
	set name = "Emote Panel"
	set category = "IC"

	var/emote_icons = 'icons/misc/emotes.dmi'
	var/list/emote_choice = list()

	for(var/id in current_emotes)
		var/datum/emote/E = current_emotes[id]
		if(!(E.key in usr.client.prefs.custom_emote_panel))
			continue
		emote_choice += E.key
		emote_choice[E.key] = image(icon = emote_icons, icon_state = E.key)

	var/act = show_radial_menu(usr, src, emote_choice, radius = 54, min_angle = 36)
	emote(act)
