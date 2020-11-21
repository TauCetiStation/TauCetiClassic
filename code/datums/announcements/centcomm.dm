/* CENTRAL COMMAND */
/datum/announcement/centcomm
	title = "Central Command Update"
	subtitle = "NanoTrasen Update"
	sound = "commandreport"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND

/datum/announcement/centcomm/play()
	..()
	add_communication_log(type = "centcomm", title = title, content = message)


/datum/announcement/centcomm/admin
	name = "Centcomm: Admin Stub"
	message = "\[Enter your message for the station here.]"
	flags = ANNOUNCE_ALL

/datum/announcement/centcomm/yesert
	name = "Centcomm: ERT Approved"
	subtitle = "Central Command"
	message = "It would appear that an emergency response team was requested for Space Station 13. We will prepare and send one as soon as possible."
	sound = "yesert"
/datum/announcement/centcomm/yesert/play()
	message = "It would appear that an emergency response team was requested for [station_name()]. We will prepare and send one as soon as possible."
	..()

/datum/announcement/centcomm/noert
	name = "Centcomm: ERT Denied"
	subtitle = "Central Command"
	message = "It would appear that an emergency response team was requested for Space Station 13. Unfortunately, we were unable to send one at this time."
	sound = "yesert"
/datum/announcement/centcomm/noert/play()
	message = "It would appear that an emergency response team was requested for [station_name()]. Unfortunately, we were unable to send one at this time."
	..()
