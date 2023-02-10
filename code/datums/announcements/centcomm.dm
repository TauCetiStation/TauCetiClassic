/* CENTRAL COMMAND */
/datum/announcement/centcomm
	title = "Оповещение Центрального Командования"
	subtitle = "Оповещение НаноТрейзен"
	sound = "commandreport"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND

/datum/announcement/centcomm/play()
	..()
	SSStatistics.add_communication_log(type = "centcomm", title = title, content = message)


/datum/announcement/centcomm/admin
	name = "Centcomm: Admin Stub"
	message = "\[Введите свое сообщение здесь.\]"
	flags = ANNOUNCE_ALL

/datum/announcement/centcomm/yesert
	name = "Centcomm: ERT Approved"
	subtitle = "Центральное Командование"
	sound = "yesert"
/datum/announcement/centcomm/yesert/New()
	message = "Внимание! Мы получили запрос на отряд быстрого реагирования. Запрос одобрен. Отряд будет подготовлен и отправлен в кратчайшие сроки."

/datum/announcement/centcomm/noert
	name = "Centcomm: ERT Denied"
	subtitle = "Центральное Командование"
	sound = "noert"
/datum/announcement/centcomm/noert/New()
	message = "Внимание! Мы получили запрос на отряд быстрого реагирования. Запрос отклонен. Попытайтесь решить проблемы своими силами."

/datum/announcement/centcomm/narsie_summon
	name = "Central Command Higher Dimensional Affairs"
	subtitle = "Центральное Командование"
	sound = "portal"
/datum/announcement/centcomm/narsie_summon/New(mob/user)
	message = "Зафиксирована блюспейс аномалия в [get_area(user)], возможно раскрытие неизвестного портала."
