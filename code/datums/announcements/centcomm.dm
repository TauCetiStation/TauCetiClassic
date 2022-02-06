/* CENTRAL COMMAND */
/datum/announcement/centcomm
	title = "Оповещение Центрального Командования"
	subtitle = "Оповещение НаноТрейзен"
	sound = "commandreport"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND

/datum/announcement/centcomm/play()
	..()
	SSStatistics.add_centcomm_communication(type = "centcomm", title = title, content = message)


/datum/announcement/centcomm/admin
	name = "Centcomm: Admin Stub"
	message = "\[Введите свое сообщение здесь.\]"
	flags = ANNOUNCE_ALL

/datum/announcement/centcomm/yesert
	name = "Centcomm: ERT Approved"
	subtitle = "Центральное Командование"
	sound = "yesert"
/datum/announcement/centcomm/yesert/New()
	message = "Похоже, отряд быстрого реагирования был запрошен на [station_name_ru()]. Мы подготовим и отправим его в кратчайшие сроки."

/datum/announcement/centcomm/noert
	name = "Centcomm: ERT Denied"
	subtitle = "Центральное Командование"
	sound = "yesert"
/datum/announcement/centcomm/noert/New()
	message = "Похоже, отряд быстрого реагирования был запрошен на [station_name_ru()]. К сожалению, мы не сможем его отправить сейчас."
