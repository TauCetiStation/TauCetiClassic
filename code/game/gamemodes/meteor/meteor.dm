/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/meteordelay = 2000
	var/nometeors = 1
	required_players = 0

	votable = 0

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 20


/datum/game_mode/meteor/announce()
	to_chat(world, "<B>The current game mode is - Meteor!</B>")
	to_chat(world, "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>")


/datum/game_mode/meteor/post_setup()
	spawn(meteordelay)
		nometeors = 0
	return ..()


/datum/game_mode/meteor/process()
	if(nometeors) return
	/*if(prob(80))
		spawn()
			dust_swarm("norm")
	else
		spawn()
			dust_swarm("strong")*/
	spawn() spawn_meteors(6)


/datum/game_mode/meteor/declare_completion()
	var/text = ""
	var/survivors = 0
	completion_text += "<h3>Meteor mode resume:</h3>"
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if( /area/shuttle/escape/centcom )
					text += "<br><b>[player.real_name] escaped on the emergency shuttle</b>"
				if( /area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod4/centcom )
					text += "<br>[player.real_name] escaped in a life pod."
				else
					text += "<br>[player.real_name] survived but is stranded without any hope of rescue."
			survivors++

	if(survivors)
		completion_text += "<b>The following survived the meteor storm</b>:"
		completion_text += "[text]"
	else
		completion_text += "<span style='color: red; font-weight: bold;'>Nobody survived the meteor storm!</span>"

	mode_result = "end - evacuation"
	feedback_set_details("round_end_result",mode_result)
	feedback_set("round_end_result",survivors)

	..()
	return 1
