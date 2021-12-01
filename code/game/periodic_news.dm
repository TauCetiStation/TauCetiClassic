// This system defines news that will be displayed in the course of a round.
// Uses BYOND's type system to put everything into a nice format

/datum/news_announcement
	var/round_time // time of the round at which this should be announced, in seconds
	var/message // body of the message
	var/author = "NanoTrasen Editor"
	var/channel_name = "Tau Ceti Daily"
	var/can_be_redacted = 0

/datum/news_announcement/New()
	if(channel_name == "Tau Ceti Daily")
		channel_name = "[system_name()] Daily" // meh but whatever

/proc/set_news_timers()
	for(var/subtype in subtypesof(/datum/news_announcement))
		var/datum/news_announcement/news_type = subtype
		if(!initial(news_type.round_time))
			continue
		var/datum/news_announcement/news = new subtype()
		addtimer(CALLBACK(GLOBAL_PROC, .proc/announce_newscaster_news, news), news.round_time)

/proc/announce_newscaster_news(datum/news_announcement/news)
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = news.author
	newMsg.is_admin_message = !news.can_be_redacted

	newMsg.body = news.message

	var/datum/feed_channel/sendto
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == news.channel_name)
			sendto = FC
			break

	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = news.channel_name
		sendto.author = news.author
		sendto.locked = 1
		sendto.is_admin_channel = 1
		news_network.network_channels += sendto

	sendto.messages += newMsg

	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert(news.channel_name)

/datum/news_announcement/changling_meta
	round_time = 1800
	author = "Mike Hammers - abobus"
	channel_name = "The Gibson Gazette"
	message = {"
<center><b><font size="3">Новая угроза в секторе Тау Кита</font></b></center><br><br>

До недавнего времени обстановка в секторе была довольно спокойной, но буквально несколько дней назад начала поступать волна сообщений о найденных высушенных трупах. Очевидцы сравнивают это с проделками существ из древних земных мифов - вампиров, и очень этим обеспокоены. Такие случаи имели место быть и раньше, однако им не придавали должного внимания, а власти списывали всё на случайность, но не в этот раз.<br><br>

Участившиеся случаи вызывают серьёзное беспокойство, а чиновники в свою очередь призывают сохранять спокойствие и грозятся ввести комендантский час. Мы связались с НаноТрейзен, которая обладает наибольшим контролем в нашем секторе. Рассказать о текущей ситуации нам согласился уполномоченный представитель корпорации Эрнест Медичи: "В данный момент в управлении обсуждают возможность введения комендантского часа, а в будущем и увеличение военного контингента в секторе. Вскоре будет официальный комментарий об этой ситуации".<br><br>

На данный момент существует несколько популярных версий о причинах смерти этих сотрудников. Некоторые из них пробирают до мурашек! Небольшая группа учёных планеты Рид и вовсе заявила, что это штамм чёртового птичьего гриппа передающегося от воксов! Всегда знал, что с этими кочевниками что-то не чисто! В свою очередь НТ в  пресс релизе заявила, что это результаты деятельности неких "генокрадов". Также чиновники решили опубликовать один очень занимательный документ, в котором, как они заявляют, сказано всё. Выглядит как очередная попытка сказать, что у них всё под контролем, придумали себе инопланетян и генокрадов, и говорят что они всё знают! Сколько уже было таких сказок? Сколько раз они нас обманывали? Чувствую, если не принять никаких мер, мы и дальше останемся в неведении. Напомню нашим читателям, что подобные ситуации – далеко не исключение! И да напоследок хотелось бы сказать пару слов о авторе этих документов - никакой вы не учёный! Обычный конспиролог и шарлатан!
"}
