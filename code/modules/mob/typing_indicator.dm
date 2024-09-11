/mob/proc/set_typing_indicator(state)
	if(!typing_indicator)
		typing_indicator = new(null, "[typing_indicator_type]0")

	if(typing_indicator.icon_state != "[typing_indicator_type]0")
		typing_indicator.icon_state = "[typing_indicator_type]0"

	if(state)
		if(client && stat == CONSCIOUS)
			vis_contents += typing_indicator
			typing = TRUE
	else
		vis_contents -= typing_indicator
		typing = FALSE
