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
	message = "Похоже, отряд быстрого реагирования был запрошен на станцию. Мы подготовим и отправим его в кратчайшие сроки."
	sound = "yesert"
/datum/announcement/centcomm/yesert/play()
	message = "Похоже, отряд быстрого реагирования был запрошен на [station_name()]. Мы подготовим и отправим его в кратчайшие сроки."
	..()

/datum/announcement/centcomm/noert
	name = "Centcomm: ERT Denied"
	subtitle = "Central Command"
	message = "Похоже, отряд быстрого реагирования был запрошен на станцию . К сожалению, мы не смогли отправить его в этот раз."
	sound = "yesert"
/datum/announcement/centcomm/noert/play()
	message = "Похоже, отряд быстрого реагирования был запрошен на станцию [station_name()]. К сожалению, мы не смогли отправить его в этот раз."
	..()
