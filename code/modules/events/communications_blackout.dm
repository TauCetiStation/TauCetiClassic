/datum/event/communications_blackout/announce()
	var/alert = pick(	"Обнаружены ионосферные аномалии. Неизбежный временный сбой связи. Пожалуйста, свяжитесь с*%fj00)`5vc-BZZT", \
						"Обнаружены ионосферные аномалии. Неизбежный сбой свя*3mga;b4;'1vďż˝-BZZZT", \
						"Обнаружены ионосферные аномалии. Temporary telec#MCi46:5.;@63-BZZZZT", \
						"Обнаружены ионосферные анома'fZ\\kg5_0-BZZZZZT", \
						"Ионосфер:%ďż˝ MCayj^j<.3-BZZZZZZT", \
						"#4nd%;f4y6,>ďż˝%-BZZZZZZZT")

	for(var/mob/living/silicon/ai/A in player_list)	//AIs are always aware of communication blackouts.
		to_chat(A, "<br>")
		to_chat(A, "<span class='warning'><b>[alert]</b></span>")
		to_chat(A, "<br>")

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		command_alert(alert)


/datum/event/communications_blackout/start()
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emplode(1)
