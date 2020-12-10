/datum/event/communications_blackout/announce()
	var/alert = pick(	"Обнаружена ионосферная аномалия. Временный сбой связи неизбежен. Пожалуйста, свяжи*%fj00)`5vc-БЗЗТ", \
						"Обнаружена ионосферная аномалия. Сбой связи неиз*3mga;b4;'1vďż˝-БЗЗТ", \
						"Обнаружена ионосферная аномалия. #MCi46:5.;@63-БЗЗЗЗЗТ", \
						"Обнаружена ионосферная ано'fZ\\kg5_0-БЗЗЗЗЗТ", \
						"Обнар:%ďż˝ MCayj^j<.3-БЗЗЗЗЗТ", \
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
