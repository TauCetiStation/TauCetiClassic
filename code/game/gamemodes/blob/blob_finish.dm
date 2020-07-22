/datum/game_mode/blob/check_finished()
	if(!declared)//No blobs have been spawned yet
		return 0
	if(blobwincount <= blobs.len)//Blob took over
		return 1
	if(!blob_cores.len) // blob is dead
		return 1
	if(station_was_nuked)//Nuke went off
		return 1
	return 0


/datum/game_mode/blob/declare_completion()
	completion_text += "<h3>Blob mode resume:</h3>"
	if(blobwincount <= blobs.len)
		mode_result = "loss - blob took over"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<br><span style='font-weight: bold;'>The blob has taken over the station!</span>"
		completion_text += "<b>The entire station was eaten by the Blob.</b>"
		score["roleswon"]++
		log_game("Blob mode completed with a blob victory.")

	else if(station_was_nuked)
		mode_result = "halfwin - nuke"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<br><span style='font-weight: bold;'>Partial Win: The station has been destroyed!</span>"
		completion_text += "<b>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</b>"
		log_game("Blob mode completed with a tie (station destroyed).")

	else if(!blob_cores.len)
		mode_result = "win - blob eliminated"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<br><span style='font-weight: bold;'>The staff has won!</span>"
		completion_text += "<b>The alien organism has been eradicated from the station.</b>"

		log_game("Blob mode completed with a crew victory.")
	to_chat(world, "<br><span class='info'>Rebooting in 30s.</span>")
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_blob()
	var/text = ""
	if(istype(SSticker.mode,/datum/game_mode/blob) )
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			text += "<b>The blob[(blob_mode.infected_crew.len > 1 ? "s were" : " was")]:</b>"

			var/icon/logo = icon('icons/mob/blob.dmi', "blob_core")
			end_icons += logo
			var/tempstate = end_icons.len
			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += {"<br><img src="logo_[tempstate].png"> <b>[blob.key]</b> was <b>[blob.name]</b>"}
	
	if(text)
		antagonists_completion += list(list("mode" = "blob", "html" = text))
		text = "<div class='block'>[text]</div>"
	
	return text
