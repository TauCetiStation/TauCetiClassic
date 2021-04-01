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
	message = "Исход, ваш запрос одобрен. Мы соберём и отправим к вам Отряд Сме- Кхехм Кхм. Отряд Быстрого Реагирования, как только это станет возможным."
	sound = "yesert"

/datum/announcement/centcomm/noert
	name = "Centcomm: ERT Denied"
	subtitle = "Central Command"
	message = "Нет. Не будет. Никакого. ЕРТ. А теперь намотайте сопли на кулак и научитесь решать проблемы самостоятельно."
	sound = "noert"
