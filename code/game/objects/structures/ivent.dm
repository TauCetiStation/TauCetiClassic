/obj/structure/ivent/dj_booth
	name = "DJ Booth"
	cases = list("диджейский пульт", "диджейского пульта", "диджейскому пульту", "диджейский пульт", "диджейским пультом", "диджейском пульте")
	desc = "Аче, качает."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dj_booth"
	density = TRUE
	anchored = TRUE
	resistance_flags = FULL_INDESTRUCTIBLE

/obj/structure/ivent/dj_booth/attack_hand(mob/user)
	if(!Adjacent(user))
		return
	if(ishuman(user))
		var/choice = tgui_alert(usr,"Category",, list("Cache", "File", "Cancel"))
		var/sound/S

		switch(choice)
			if("Cache")
				if(!length(sounds_cache_global))
					to_chat(src, "<span class='notice'>Operation aborted. Reason: no cache.</span>")
					return
				S = input("Select a sound from the server to play") as null|anything in sounds_cache_global
			if("File")
				S = input("Select a sound from the local repository") as null|sound
				sounds_cache_global |= S

		if(!isfile(S))
			to_chat(src, "<span class='notice'>Operation aborted. Reason: no input sound.</span>")
			return

		log_admin("[key_name(src)] played sound [S].")
		message_admins("[key_name_admin(src)] played sound [S].")

		for(var/mob/M in player_list)
			M.playsound_stop(CHANNEL_ADMIN)
			M.playsound_music(S, VOL_ADMIN, null, TRUE, CHANNEL_ADMIN, 250, SOUND_STREAM)

		feedback_add_details("admin_verb","PGS")
