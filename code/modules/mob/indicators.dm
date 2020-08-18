// Typing indicators could be moved here too.

// Vars related to indicators (can be improved into something similar like alerts framework with assoc list).
/mob
	var/image/stat_indicator

// Unconscious status indicator
// Has two icons, blue when mob has client inside, and red when there is no client.
// Currently added only for humans, but can be expanded to monkeys, ian and so on.

/mob/proc/throw_stat_indicator(state)
	if(!stat_indicator)
		stat_indicator = image('icons/mob/indicators.dmi')
		stat_indicator.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		stat_indicator.layer = INDICATOR_LAYER

	if(stat_indicator.icon_state == state)
		return

	cut_overlay(stat_indicator) // we can't do anything with overlays, so we need to re-apply it (incase of question).
	stat_indicator.icon_state = state
	add_overlay(stat_indicator)

/mob/proc/clear_stat_indicator()
	if(!stat_indicator || !stat_indicator.icon_state)
		return

	cut_overlay(stat_indicator)
	stat_indicator.icon_state = null
