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
	completion_text += "<B>Blob mode resume:</B><BR>"
	if(blobwincount <= blobs.len)
		feedback_set_details("round_end_result","loss - blob took over")
		completion_text += "<BR><FONT size = 3><B>The blob has taken over the station!</B></FONT>"
		completion_text += "<B>The entire station was eaten by the Blob.</B>"
		score["roleswon"]++
		log_game("Blob mode completed with a blob victory.")

	else if(station_was_nuked)
		feedback_set_details("round_end_result","halfwin - nuke")
		completion_text += "<BR><FONT size = 3><B>Partial Win: The station has been destroyed!</B></FONT>"
		completion_text += "<B>Directive 7-12 has been successfully carried out preventing the Blob from spreading.</B>"
		log_game("Blob mode completed with a tie (station destroyed).")

	else if(!blob_cores.len)
		feedback_set_details("round_end_result","win - blob eliminated")
		completion_text += "<BR><FONT size = 3><B>The staff has won!</B></FONT>"
		completion_text += "<B>The alien organism has been eradicated from the station.</B>"

		log_game("Blob mode completed with a crew victory.")
	to_chat(world, "<BR><span class='info'>Rebooting in 30s.</span>")
	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_blob()
	var/text = ""
	if(istype(ticker.mode,/datum/game_mode/blob) )
		var/datum/game_mode/blob/blob_mode = src
		if(blob_mode.infected_crew.len)
			text += "<B>The blob[(blob_mode.infected_crew.len > 1 ? "s were" : " was")]:</B>"

			var/icon/logo = icon('icons/mob/blob.dmi', "blob_core")
			end_icons += logo
			var/tempstate = end_icons.len
			for(var/datum/mind/blob in blob_mode.infected_crew)
				text += {"<BR><img src="logo_[tempstate].png"> <B>[blob.key]</B> was <B>[blob.name]</B>"}
		text += "<BR><HR>"
	return text
