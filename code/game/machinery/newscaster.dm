//##############################################
//################### NEWSCASTERS BE HERE! ####
//###-Agouri###################################

#define COMMENTS_ON_PAGE 5 //number of comments per page

/datum/feed_message
	var/author = ""
	var/body = ""
	//var/parent_channel
	var/backup_body = ""
	var/backup_author = ""
	var/is_admin_message = 0
	var/icon/img = null
	var/icon/backup_img
	var/list/voters = list() //stores a string with voters
	var/likes = 0
	var/dislikes = 0
	var/count_comments = 0
	var/comments_closed = TRUE //spoiler
	var/list/datum/comment_pages/pages = list()

/datum/comment_pages
	var/list/datum/message_comment/comments = list() //stores COMMENTS_ON_PAGE comments

/datum/message_comment
	var/author = ""
	var/backup_author = ""
	var/body = ""
	var/backup_body = ""
	var/time = ""

/datum/feed_channel
	var/channel_name = ""
	var/list/datum/feed_message/messages = list()
	//var/message_count = 0
	var/locked = 0
	var/lock_comments = FALSE
	var/author = ""
	var/backup_author = ""
	var/censored = 0
	var/is_admin_channel = 0
	//var/page = null //For newspapers

/datum/feed_message/proc/clear()
	src.author = ""
	src.body = ""
	src.backup_body = ""
	src.backup_author = ""
	src.img = null
	src.backup_img = null

/datum/feed_channel/proc/clear()
	src.channel_name = ""
	src.messages = list()
	src.locked = 0
	src.author = ""
	src.backup_author = ""
	src.censored = 0
	src.is_admin_channel = 0

/datum/feed_message/Destroy()
	QDEL_LIST(pages)
	return ..()

/datum/comment_pages/Destroy()
	QDEL_LIST(comments)
	return ..()

/datum/feed_network
	var/list/datum/feed_channel/network_channels = list()
	var/datum/feed_message/wanted_issue

var/datum/feed_network/news_network = new /datum/feed_network     //The global news-network, which is coincidentally a global list.

var/list/obj/machinery/newscaster/allCasters = list() //Global list that will contain reference to all newscasters in existence.

/obj/item/newscaster_frame
	name = "newscaster frame"
	desc = "Used to build newscasters, just secure to the wall."
	icon_state = "newscaster"
	item_state = "syringe_kit"
	m_amt = 25000
	g_amt = 15000

/obj/item/newscaster_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='alert'>Newscaster cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "<span class='alert'>Newscaster cannot be placed in this area.</span>")
		return
	for(var/obj/machinery/newscaster/T in loc)
		to_chat(usr, "<span class='alert'>There is another newscaster here.</span>")
		return
	var/obj/machinery/newscaster/N = new(loc)
	N.pixel_y -= (loc.y - on_wall.y) * 32
	N.pixel_x -= (loc.x - on_wall.x) * 32
	qdel(src)




/obj/machinery/newscaster
	name = "Newscaster"
	desc = "A standard Nanotrasen-licensed newsfeed handler for use in commercial space stations. All the news you absolutely have no use for, in one place!"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "newscaster_normal"
	var/isbroken = 0  //1 if someone banged it with something heavy
	var/ispowered = 1 //starts powered, changes with power_change()
	//var/list/datum/feed_channel/channel_list = list() //This list will contain the names of the feed channels. Each name will refer to a data region where the messages of the feed channels are stored.
	//OBSOLETE: We're now using a global news network
	var/screen = 0                  //Or maybe I'll make it into a list within a list afterwards... whichever I prefer, go fuck yourselves :3
		// 0 = welcome screen - main menu
		// 1 = view feed channels
		// 2 = create feed channel
		// 3 = create feed story
		// 4 = feed story submited sucessfully
		// 5 = feed channel created successfully
		// 6 = ERROR: Cannot create feed story
		// 7 = ERROR: Cannot create feed channel
		// 8 = print newspaper
		// 9 = viewing channel feeds
		// 10 = censor feed story
		// 11 = censor feed channel
		// 12 = pick censor channel
		// 13 = pick d notice
		// 14 = wanted issue handler
		// 15 = create wanted issue
		// 16 = ERROR: Cannot create wanted issue
		// 17 = wanted issue deleted
		// 18 = view wanted issue
		// 19 = wanted issue edited
		// 20 = orinting successful
		// 21 = need more paper
		// 22 = ERROR: Cannot create comment
		// 23 = all comment
		// 24 = all comment for security
		//Holy shit this is outdated, made this when I was still starting newscasters :3
	var/paper_remaining = 0
	var/securityCaster = 0
		// 0 = Caster cannot be used to issue wanted posters
		// 1 = the opposite
	var/unit_no = 0 //Each newscaster has a unit number
	//var/datum/feed_message/wanted //We're gonna use a feed_message to store data of the wanted person because fields are similar
	//var/wanted_issue = 0          //OBSOLETE
		// 0 = there's no WANTED issued, we don't need a special icon_state
		// 1 = Guess what.
	var/alert_delay = 500
	var/alert = 0
		// 0 = there hasn't been a news/wanted update in the last alert_delay
		// 1 = there has
	var/scanned_user = "Unknown" //Will contain the name of the person who currently uses the newscaster
	var/msg = ""                //Feed message
	var/obj/item/weapon/photo/photo = null
	var/channel_name = "" //the feed channel which will be receiving the feed, or being created
	var/c_locked = 0        //Will our new channel be locked to public submissions?
	var/hitstaken = 0      //Death at 3 hits from an item with force>=15
	var/datum/feed_channel/viewing_channel = null
	light_range = 0
	anchored = TRUE
	var/comment_msg = "" //stores a comment that has not yet been posted
	var/datum/comment_pages/current_page = null
	var/datum/feed_message/viewing_message = null

/obj/machinery/newscaster/security_unit                   //Security unit
	name = "Security Newscaster"
	securityCaster = 1

/obj/machinery/newscaster/atom_init()         //Constructor, ho~
	allCasters += src
	paper_remaining = 15            // Will probably change this to something better
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters) // Let's give it an appropriate unit number
		unit_no++
	update_icon() //for any custom ones on the map...
	. = ..()                                //I just realised the newscasters weren't in the global machines list. The superconstructor call will tend to that

/obj/machinery/newscaster/Destroy()
	allCasters -= src
	return ..()

/obj/machinery/newscaster/update_icon()
	if(!ispowered || isbroken)
		icon_state = "newscaster_off"
		if(isbroken) //If the thing is smashed, add crack overlay on top of the unpowered sprite.
			cut_overlays()
			add_overlay(image(src.icon, "crack3"))
		return

	cut_overlays() //reset overlays

	if(news_network.wanted_issue) //wanted icon state, there can be no overlays on it as it's a priority message
		icon_state = "newscaster_wanted"
		return

	if(alert) //new message alert overlay
		add_overlay("newscaster_alert")

	if(hitstaken > 0) //Cosmetic damage overlay
		add_overlay(image(src.icon, "crack[hitstaken]"))

	icon_state = "newscaster_normal"
	return

/obj/machinery/newscaster/power_change()
	if(isbroken) //Broken shit can't be powered.
		return
	if( powered() )
		src.ispowered = 1
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			src.ispowered = 0
			stat |= NOPOWER
			update_icon()
	update_power_use()

/obj/machinery/newscaster/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			src.isbroken=1
			if(prob(50))
				qdel(src)
			else
				update_icon() //can't place it above the return and outside the if-else. or we might get runtimes of null.update_icon() if(prob(50)) goes in.
			return
		else
			if(prob(50))
				src.isbroken=1
			update_icon()
			return

/obj/machinery/newscaster/ui_interact(mob/user)            //########### THE MAIN BEEF IS HERE! And in the proc below this...############
	if(isbroken)
		return

	if(isobserver(user))
		to_chat(user, "[src]'s UI has no support for observer.")
		return

	if(ishuman(user) || issilicon(user)) // need abit of rewriting this to make it work for observers.
		var/mob/living/human_or_robot_user = user
		var/dat
		dat = ""

		scan_user(human_or_robot_user) //Newscaster scans you

		switch(screen)
			if(0)
				dat += "Добро пожаловать в Новостной Модуль #[src.unit_no].<BR><FONT SIZE=1> Все системы новостной сети функционируют.</FONT>"
				dat += "<BR><FONT SIZE=1>Собственность Nanotrasen Corp.</FONT>"
				if(news_network.wanted_issue)
					dat+= "<HR><A href='?src=\ref[src];view_wanted=1'>Раздел \"Розыск\"</A>"
				dat+= "<HR><BR><A href='?src=\ref[src];create_channel=1'>Создать Новостной Канал</A>"
				dat+= "<BR><A href='?src=\ref[src];view=1'>Новостные Каналы</A>"
				dat+= "<BR><A href='?src=\ref[src];create_feed_story=1'>Создать Историю</A>"
				dat+= "<BR><A href='?src=\ref[src];menu_paper=1'>Распечатать газету</A>"
				if(src.securityCaster)
					var/wanted_already = 0
					if(news_network.wanted_issue)
						wanted_already = 1

					dat+="<HR><B>Настройки безопасности:</B><BR>"
					dat+="<BR><A href='?src=\ref[src];menu_wanted=1'>[(wanted_already) ? ("Изменить") : ("Объявить в")] розыск</A>"
					dat+="<BR><A href='?src=\ref[src];menu_censor_story=1'>Цензурировать Истории</A>"
					dat+="<BR><A href='?src=\ref[src];menu_censor_channel=1'>Отметить Новостной Канал ❌-меткой НаноТрейзен</A>"
				dat+="<BR><HR>Новостной модуль распознает вас, как: <FONT COLOR='green'>[src.scanned_user]</FONT>"
				dat+="<BR><A href='?src=\ref[src];refresh=1'>Сканировать пользователя</A>"
			if(1)
				dat+= "Новостные Каналы станции<HR>"
				if( isemptylist(news_network.network_channels) )
					dat+="<I>Активных Каналов не найдено...</I>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						if(CHANNEL.is_admin_channel)
							dat+="<B><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A></B><BR>"
						else
							dat+="<B><A href='?src=\ref[src];show_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<span class='red'>***</span>") : null]<BR></B>"
				dat+="<BR><HR><A href='?src=\ref[src];refresh=1'>Обновить</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Назад</A>"
			if(2)
				dat+="Создание Новостного Канала..."
				dat+="<HR><B><A href='?src=\ref[src];set_channel_name=1'>Название Канала</A>:</B> [src.channel_name]<BR>"
				dat+="<B>Автор Канала:</B> <FONT COLOR='green'>[src.scanned_user]</FONT><BR>"
				dat+="<B><A href='?src=\ref[src];set_channel_lock=1'>Истории других пользователей</A>:</B> [(src.c_locked) ? ("НЕТ") : ("ДА")]<BR><HR>"
				dat+="<BR><A href='?src=\ref[src];submit_new_channel=1'>Создать</A><BR><A href='?src=\ref[src];setScreen=[0]'>Отменить</A><BR>"
			if(3)
				dat+="Создание Истории..."
				dat+="<HR><B><A href='?src=\ref[src];set_channel_receiving=1'>Канал</A>:</B> [src.channel_name]<BR>" //MARK
				dat+="<B>Автор Истории:</B> <FONT COLOR='green'>[src.scanned_user]</FONT><BR>"
				dat+="<B><A href='?src=\ref[src];set_new_message=1'>Текст Истории</A>:</B> [src.msg] <BR>"
				dat+="<B><A href='?src=\ref[src];set_attachment=1'>Прикрепить снимок</A>:</B>  [(src.photo ? "Снимок прикреплен" : "Нет снимка")]<BR><HR>"
				dat+="<BR><A href='?src=\ref[src];submit_new_message=1'>Опубликовать</A><BR><A href='?src=\ref[src];setScreen=[0]'>Отменить</A><BR>"
			if(4)
				dat+="История успешно опубликованна в [src.channel_name].<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Вернуться</A><BR>"
			if(5)
				dat+="Канал \"[src.channel_name]\" успешно создан.<BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Вернуться</A><BR>"
			if(6)
				dat+="<B><FONT COLOR='maroon'>ОШИБКА: Не удалось опубликовать Историю.</B></FONT><HR><BR>"
				if(src.channel_name=="")
					dat+="<FONT COLOR='maroon'>Недопустимое имя Канала.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Автор канала неподтвержден.</FONT><BR>"
				if(src.msg == "" || src.msg == "\[██████\]")
					dat+="<FONT COLOR='maroon'>Недопустимый текст.</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[3]'>Вернуться</A><BR>"
			if(7)
				dat+="<B><FONT COLOR='maroon'>ОШИБКА: Не удалось создать Новостной Канал.</B></FONT><HR><BR>"
				//var/list/existing_channels = list()            //Let's get dem existing channels - OBSOLETE
				var/list/existing_authors = list()
				for(var/datum/feed_channel/FC in news_network.network_channels)
					//existing_channels += FC.channel_name       //OBSOLETE
					if(FC.author == "\[██████\]")
						existing_authors += FC.backup_author
					else
						existing_authors += FC.author
				if(src.scanned_user in existing_authors)
					dat+="<FONT COLOR='maroon'>Вы уже являетесь автором Новостного Канала.</FONT><BR>"
				if(src.channel_name=="" || src.channel_name == "\[██████\]")
					dat+="<FONT COLOR='maroon'>Недопустимое имя Канала.</FONT><BR>"
				var/check = 0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(FC.channel_name == src.channel_name)
						check = 1
						break
				if(check)
					dat+="<FONT COLOR='maroon'>Имя Канала уже используется.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Автор канала неподтвержден.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[2]'>Вернуться</A><BR>"
			if(8)
				var/total_num=length(news_network.network_channels)
				var/active_num=total_num
				var/message_num=0
				for(var/datum/feed_channel/FC in news_network.network_channels)
					if(!FC.censored)
						message_num += length(FC.messages)    //Dont forget, datum/feed_channel's var messages is a list of datum/feed_message
					else
						active_num--
				dat+="В настоящий момент существует [total_num] Новостных Каналов, [active_num] из которых активны. Всего было создано [message_num] Историй."
				dat+="<BR><BR><B>Количество жидкой бумаги:</B> [(src.paper_remaining) *100 ] см^3"
				dat+="<BR><BR><A href='?src=\ref[src];print_paper=[0]'>Распечатать газету</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Назад</A>"
			if(9)
				dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[создано: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT>\]</FONT><HR>"
				if(src.viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>ВНИМАНИЕ: </B></FONT>Этот Канал был признан угрозой благополучию станции, и был отмечен ❌-меткой НаноТрейзен.<BR>"
					dat+="Невозможно опубликовывать новые Истории, пока действует ❌-метка.<BR><BR>"
				else
					if( isemptylist(src.viewing_channel.messages) )
						dat+="<I>В этом Канале Истории не обнаружены...</I><BR>"
					else
						var/i = 0
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							i++
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								usr << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR><BR>"
							dat+="<FONT SIZE=1>\[Автор: <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
							//If a person has already voted, then the button will not be clickable
							dat+="<FONT SIZE=1>[((src.scanned_user in MESSAGE.voters) || (src.scanned_user == "Unknown")) ? ("<img src=like_clck.png>") : ("<A href='?src=\ref[src];setLike=\ref[MESSAGE]'><img src=like.png></A>")]: <FONT SIZE=2>[MESSAGE.likes]</FONT> \
											   [((src.scanned_user in MESSAGE.voters) || (src.scanned_user == "Unknown")) ? ("<img src=dislike_clck.png>") : ("<A href='?src=\ref[src];setDislike=\ref[MESSAGE]'><img src=dislike.png></A>")]: <FONT SIZE=2>[MESSAGE.dislikes]</FONT></FONT>"

							dat+="<BR><A href='?src=\ref[src];open_pages=\ref[MESSAGE]'><B>Открыть комментарии</B></A> - ([MESSAGE.count_comments])<HR>"

				dat+="<A href='?src=\ref[src];refresh=1'>Обновить</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[1]'>Назад</A>"
			if(10)
				dat+="<B>Инструмент цензурирования НаноТрейзен</B><BR>"
				dat+="<FONT SIZE=1>ПРИМЕЧАНИЕ: Из-за строения Новостных сетей полное удаление Историй невозможно.<BR>"
				dat+="Учитывайте, что пользователи которые пытаются посмотреть отредактированный канал, вместо текста увидят: \"\[██████\]\".</FONT>"
				dat+="<HR>Выбрать Канал:<BR>"
				if(isemptylist(news_network.network_channels))
					dat+="<I>Активных Каналов не найдено...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_censor_channel=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"
				dat+="<HR><BR><A href='?src=\ref[src];setScreen=[0]'>Назад</A>"
			if(11)
				dat+="<B>Обработчик ❌-метки НаноТрейзен</B><HR>"
				dat+="<FONT SIZE=1>❌-меткой должен быть отмечен канал, который служба безопасности сочтет Канал опасным для морального духа и дисциплины персонала станции."
				dat+="❌-метка не позволяет кому-либо обновлять, изменять или добавлять Истории в Канал, но при этом сохраняет всю информацию."
				dat+="Вы можете наложить или убрать ❌-метку в любое время, если у вас есть необходимый доступ.</FONT><HR>"
				if(isemptylist(news_network.network_channels))
					dat+="<I>Активных Каналов не найдено...</I><BR>"
				else
					for(var/datum/feed_channel/CHANNEL in news_network.network_channels)
						dat+="<A href='?src=\ref[src];pick_d_notice=\ref[CHANNEL]'>[CHANNEL.channel_name]</A> [(CHANNEL.censored) ? ("<FONT COLOR='red'>***</FONT>") : null]<BR>"

				dat+="<HR><BR><A href='?src=\ref[src];setScreen=[0]'>Назад</A>"
			if(12)
				dat+="<B>[src.viewing_channel.channel_name]: </B>"
				dat+="<FONT SIZE=1><A href='?src=\ref[src];censor_channel_author=\ref[src.viewing_channel]'>\[создано: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT></A><BR>"

				if( isemptylist(src.viewing_channel.messages) )
					dat+="<I>В этом Канале Истории не обнаружены...</I><BR>"
				else
					for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
						dat+="-<A href='?src=\ref[src];censor_channel_story_body=\ref[MESSAGE]'>[MESSAGE.body] </A><BR>"
						dat+="<FONT SIZE=1><A href='?src=\ref[src];censor_channel_story_author=\ref[MESSAGE]'>\[Story by <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT></A><BR>"
						dat+="<HR><A href='?src=\ref[src];open_censor_pages=\ref[MESSAGE]'><B>Открыть комментарии</B></A> - <B><FONT SIZE=2><A href='?src=\ref[src];locked_comments=1'>[(src.viewing_channel.lock_comments) ? ("Открыть") : ("Закрыть")]</A></B></FONT><BR><HR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[10]'>Назад</A>"
			if(13)
				dat+="<B>[src.viewing_channel.channel_name]: </B><FONT SIZE=1>\[создано: <FONT COLOR='maroon'>[src.viewing_channel.author]</FONT> \]</FONT><BR>"
				dat+="Если вы считаете содержание опасным для станции, вы можете <A href='?src=\ref[src];toggle_d_notice=\ref[src.viewing_channel]'>Наложить ❌-метку на Канал</A>.<HR>"
				if(src.viewing_channel.censored)
					dat+="<FONT COLOR='red'><B>ВНИМАНИЕ: </B></FONT>Этот Канал был признан угрозой благополучию станции, и был отмечен ❌-меткой НаноТрейзен.<BR>"
					dat+="Невозможно опубликовывать новые Истории, пока действует ❌-метка.</FONT><BR><BR>"
				else
					if( isemptylist(src.viewing_channel.messages) )
						dat+="<I>В этом Канале Истории не обнаружены...</I><BR>"
					else
						for(var/datum/feed_message/MESSAGE in src.viewing_channel.messages)
							dat+="-[MESSAGE.body] <BR><FONT SIZE=1>\[создано <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"

				dat+="<BR><A href='?src=\ref[src];setScreen=[11]'>Назад</A>"
			if(14)
				dat+="<B>Обработчик Розыска:</B>"
				var/wanted_already = 0
				var/end_param = 1
				if(news_network.wanted_issue)
					wanted_already = 1
					end_param = 2

				if(wanted_already)
					dat+="<FONT SIZE=2><BR><I>Запрос розыска уже существует. Вы можете отредактировать его ниже.</FONT></I>"
				dat+="<HR>"
				dat+="<A href='?src=\ref[src];set_wanted_name=1'>Имя</A>: [src.channel_name] <BR>"
				dat+="<A href='?src=\ref[src];set_wanted_desc=1'>Описание</A>: [src.msg] <BR>"
				dat+="<A href='?src=\ref[src];set_attachment=1'>Прикрепить снимок</A>: [(src.photo ? "Снимок прикреплен" : "Нет снимка")]</BR>"
				if(wanted_already)
					dat+="<B>Розыск создан:</B><FONT COLOR='green'> [news_network.wanted_issue.backup_author]</FONT><BR>"
				else
					dat+="<B>Розыск будет создан:</B><FONT COLOR='green'> [src.scanned_user]</FONT><BR>"
				dat+="<HR><BR><A href='?src=\ref[src];submit_wanted=[end_param]'>[(wanted_already) ? ("Редактировать") : ("Опубликовать")]</A>"
				if(wanted_already)
					dat+="<BR><A href='?src=\ref[src];cancel_wanted=1'>Удалить розыск</A>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Отменить</A>"
			if(15)
				dat+="<FONT COLOR='green'>[src.channel_name] был объявлен в розыск.</FONT><BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Вернуться</A><BR>"
			if(16)
				dat+="<B><FONT COLOR='maroon'>ОШИБКА: Не удалось создать розыск.</B></FONT><HR><BR>"
				if(src.channel_name=="" || src.channel_name == "\[██████\]")
					dat+="<FONT COLOR='maroon'>Недопустимое имя разыскиваемого.</FONT><BR>"
				if(src.scanned_user=="Unknown")
					dat+="<FONT COLOR='maroon'>Автор канала неподтвержден.</FONT><BR>"
				if(src.msg == "" || src.msg == "\[██████\]")
					dat+="<FONT COLOR='maroon'>Недопустимое описание.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Вернуться</A><BR>"
			if(17)
				dat+="<B>Розыск успешно удален.</B><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Вернуться</A><BR>"
			if(18)
				dat+="<B><FONT COLOR ='maroon'>-- ОСОБО ОПАСНЫ --</B></FONT><BR><FONT SIZE=2>\[Опубликованно: <FONT COLOR='green'>[news_network.wanted_issue.backup_author]</FONT>\]</FONT><HR>"
				dat+="<B>Имя</B>: [news_network.wanted_issue.author]<BR>"
				dat+="<B>Описани</B>: [news_network.wanted_issue.body]<BR>"
				dat+="<B>Снимок</B>: "
				if(news_network.wanted_issue.img)
					usr << browse_rsc(news_network.wanted_issue.img, "tmp_photow.png")
					dat+="<BR><img src='tmp_photow.png' width = '180'>"
				else
					dat+="Отсутствует"
				dat+="<BR><BR><A href='?src=\ref[src];setScreen=[0]'>Назад</A><BR>"
			if(19)
				dat+="<FONT COLOR='green'>Розыск в [src.channel_name] успешно изменен.</FONT><BR><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[0]'>Вернуться</A><BR>"
			if(20)
				dat+="<FONT COLOR='green'>Печать завершена. Пожалуйста, заберите вашу газету из нижней части Новостного Модуля</FONT><BR><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[0]'>Вернуться</A>"
			if(21)
				dat+="<FONT COLOR='maroon'>Ошибка печати. Недостаточно бумаги. Пожалуйста, уведомите обслуживающий персонал пополнить отсек для бумаги.</FONT><BR><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[0]'>Вернуться</A>"
			if(22)
				dat+="<B><FONT COLOR='maroon'>ОШИБКА: Не удалось опубликовать комментарий.</B></FONT><HR><BR>"
				if(src.comment_msg == "" || src.comment_msg == null)
					dat+="<FONT COLOR='maroon'>Недопустимая длина комментария.</FONT><BR>"
				if(src.scanned_user == "Unknown")
					dat+="<FONT COLOR='maroon'>Автор канала неподтвержден.</FONT><BR>"
				dat+="<BR><A href='?src=\ref[src];setScreen=[1]'>Вернуться</A><BR>"
			if(23)
				var/datum/feed_message/MESSAGE = src.viewing_message
				dat+="Количество комментариев - [MESSAGE.count_comments]<BR>"
				if(!src.viewing_channel.lock_comments)
					dat+="<B><A href='?src=\ref[src];leave_a_comment=\ref[MESSAGE]'>Оставить комментарий</A></B>"
				else
					dat+="<B><FONT SIZE=3>Комментарии закрыты!</FONT></B>"
				var/datum/comment_pages/PAGE = src.current_page
				if(PAGE.comments.len != 0) //perfecto
					dat+="<HR>"
				for(var/datum/message_comment/COMMENT in PAGE.comments)
					dat+="<FONT COLOR='ORANGE'>[COMMENT.author]</FONT> <FONT COLOR='RED'>[COMMENT.time]</FONT><BR>"
					dat+="-<FONT SIZE=3>[COMMENT.body]</FONT><BR>"
				var/i = 0
				dat+="<HR>"
				for(var/datum/comment_pages/PAGES in MESSAGE.pages)
					i++
					dat+="[(src.current_page != PAGES) ? ("<A href='?src=\ref[src];next_page=\ref[PAGES]'> [i]</A>") : (" [i]")]"
				dat+="<HR><A href='?src=\ref[src];refresh=1'>Обновить</A><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[9]'>Вернуться</A>"
			if(24)
				dat+="<B>Story ([src.viewing_message.body])</B><HR>"
				var/datum/feed_message/MESSAGE = src.viewing_message
				dat+="Количество комментариев - [MESSAGE.count_comments]<HR>"
				var/datum/comment_pages/PAGE = src.current_page
				for(var/datum/message_comment/COMMENT in PAGE.comments)
					dat+="<A href='?src=\ref[src];censor_author_comment=\ref[COMMENT]'><FONT COLOR='ORANGE'>[COMMENT.author]</FONT></A>"
					dat+=" <FONT COLOR='RED'>[COMMENT.time]</FONT><BR>"
					dat+="-<A href='?src=\ref[src];censor_body_comment=\ref[COMMENT]'><FONT SIZE=3>[COMMENT.body]</FONT></A><BR>"
				var/i = 0
				for(var/datum/comment_pages/PAGES in MESSAGE.pages)
					i++
					dat+="[(src.current_page != PAGES) ? ("<A href='?src=\ref[src];next_censor_page=\ref[PAGES]'> [i]</A>") : (" [i]")]"
				dat+="<HR><A href='?src=\ref[src];refresh=1'>Обновить</A><BR>"
				dat+="<A href='?src=\ref[src];setScreen=[10]'>Вернуться</A>"
			else
				dat+="Ошибка 404.<BR>[return_funny_title()]."

		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/newscaster)		//Sending pictures to the client
		assets.send(human_or_robot_user)

		var/datum/browser/popup = new(human_or_robot_user, "window=newscaster_main", src.name, 400, 600)
		popup.set_content(dat)
		popup.open()

	/*if(src.isbroken) //debugging shit
		return
	src.hitstaken++
	if(src.hitstaken==3)
		src.isbroken = 1
	update_icon()*/


/obj/machinery/newscaster/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["set_channel_name"])
		src.channel_name = sanitize_safe(input(usr, "Название Новостного Канала", "Обработчик Сети Новостей", input_default(channel_name)), MAX_LNAME_LEN)
		//update_icon()

	else if(href_list["set_channel_lock"])
		src.c_locked = !src.c_locked
		//update_icon()

	else if(href_list["submit_new_channel"])
		//var/list/existing_channels = list() //OBSOLETE
		var/list/existing_authors = list()
		for(var/datum/feed_channel/FC in news_network.network_channels)
			//existing_channels += FC.channel_name
			if(FC.author == "\[██████\]")
				existing_authors += FC.backup_author
			else
				existing_authors  +=FC.author
		var/check = 0
		for(var/datum/feed_channel/FC in news_network.network_channels)
			if(FC.channel_name == src.channel_name)
				check = 1
				break
		if(src.channel_name == "" || src.channel_name == "\[██████\]" || src.scanned_user == "Unknown" || check || (src.scanned_user in existing_authors) )
			src.screen = 7
		else
			var/choice = tgui_alert(usr,"Подтвердите создание Новостного Канала","Обработчик Сети Новостей", list("Подтвердить","Отменить"))
			if(choice=="Подтвердить")
				var/datum/feed_channel/newChannel = new /datum/feed_channel
				newChannel.channel_name = src.channel_name
				newChannel.author = src.scanned_user
				newChannel.locked = c_locked
				feedback_inc("newscaster_channels",1)
				/*for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)    //Let's add the new channel in all casters.
					NEWSCASTER.channel_list += newChannel*/                     //Now that it is sane, get it into the list. -OBSOLETE
				news_network.network_channels += newChannel                        //Adding channel to the global network
				src.screen = 5
		//update_icon()

	else if(href_list["set_channel_receiving"])
		//var/list/datum/feed_channel/available_channels = list()
		var/list/available_channels = list()
		for(var/datum/feed_channel/F in news_network.network_channels)
			if( (!F.locked || F.author == scanned_user) && !F.censored)
				available_channels += F.channel_name
		src.channel_name = input(usr, "Выберите Канал", "Обработчик Сети Новостей") in available_channels

	else if(href_list["set_new_message"])
		src.msg = sanitize(input(usr, "Напишите вашу Историю", "Обработчик Сети Новостей", input_default(src.msg)), extra = FALSE)

	else if(href_list["set_attachment"])
		AttachPhoto(usr)

	else if(href_list["submit_new_message"])
		if(src.msg == "" || src.msg == "\[██████\]" || src.scanned_user == "Unknown" || src.channel_name == "" )
			src.screen = 6
		else
			var/datum/feed_message/newMsg = new /datum/feed_message
			var/datum/comment_pages/CP = new /datum/comment_pages
			newMsg.author = src.scanned_user
			newMsg.body = src.msg
			if(photo)
				newMsg.img = photo.img
			feedback_inc("newscaster_stories",1)
			for(var/datum/feed_channel/FC in news_network.network_channels)
				if(FC.channel_name == src.channel_name)
					FC.messages += newMsg                  //Adding message to the network's appropriate feed_channel
					newMsg.pages += CP
					break
			src.screen = 4
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.newsAlert(src.channel_name)

	else if(href_list["create_channel"])
		src.screen = 2

	else if(href_list["create_feed_story"])
		src.screen = 3

	else if(href_list["menu_paper"])
		src.screen = 8
	else if(href_list["print_paper"])
		if(!src.paper_remaining)
			src.screen = 21
		else
			print_paper()
			src.screen = 20

	else if(href_list["menu_censor_story"])
		src.screen = 10

	else if(href_list["menu_censor_channel"])
		src.screen = 11

	else if(href_list["menu_wanted"])
		var/already_wanted = 0
		if(news_network.wanted_issue)
			already_wanted = 1

		if(already_wanted)
			src.channel_name = news_network.wanted_issue.author
			src.msg = news_network.wanted_issue.body
		src.screen = 14

	else if(href_list["set_wanted_name"])
		src.channel_name = sanitize(input(usr, "Укажите имя разыскиваемого лица", "Сетевой Обработчик Безопасности", input_default(channel_name)), MAX_LNAME_LEN)

	else if(href_list["set_wanted_desc"])
		src.msg = sanitize(input(usr, "Укажите описание разыскиваемого лица. Это могут быть любые детали, которые вы считаете важными.", "Сетевой Обработчик Безопасности", input_default(msg)), extra = FALSE)

	else if(href_list["submit_wanted"])
		var/input_param = text2num(href_list["submit_wanted"])
		if(src.msg == "" || src.channel_name == "" || src.scanned_user == "Unknown")
			src.screen = 16
		else
			var/choice = tgui_alert(usr,"Подтвердите [(input_param==1) ? ("создание") : ("редактирование")] объявления.","Сетевой Обработчик Безопасности", list("Подтвердить","Отменить"))
			if(choice == "Подтвердить")
				if(input_param == 1)          //If input_param == 1 we're submitting a new wanted issue. At 2 we're just editing an existing one. See the else below
					var/datum/feed_message/WANTED = new /datum/feed_message
					WANTED.author = src.channel_name
					WANTED.body = src.msg
					WANTED.backup_author = src.scanned_user //I know, a bit wacky
					if(photo)
						WANTED.img = photo.img
					news_network.wanted_issue = WANTED
					for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
						NEWSCASTER.newsAlert()
						NEWSCASTER.update_icon()
					src.screen = 15
				else
					if(news_network.wanted_issue.is_admin_message)
						to_chat(usr, "The wanted issue has been distributed by a Nanotrasen higherup. You cannot edit it.")
						return FALSE
					news_network.wanted_issue.author = src.channel_name
					news_network.wanted_issue.body = src.msg
					news_network.wanted_issue.backup_author = src.scanned_user
					if(photo)
						news_network.wanted_issue.img = photo.img
					src.screen = 19

	else if(href_list["cancel_wanted"])
		if(news_network.wanted_issue.is_admin_message)
			to_chat(usr, "The wanted issue has been distributed by a Nanotrasen higherup. You cannot take it down.")
			return FALSE
		var/choice = tgui_alert(usr, "Подтвердите удаление розыска.","Сетевой Обработчик Безопасности", list("Подтвердить","Отменить"))
		if(choice=="Подтвердить")
			news_network.wanted_issue = null
			for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
				NEWSCASTER.update_icon()
			src.screen = 17

	else if(href_list["view_wanted"])
		src.screen = 18
	else if(href_list["censor_channel_author"])
		var/datum/feed_channel/FC = locate(href_list["censor_channel_author"])
		if(FC.is_admin_channel)
			to_chat(usr, "This channel was created by a Nanotrasen Officer. You cannot censor it.")
			return FALSE
		if(FC.author != "<B>\[██████\]</B>")
			FC.backup_author = FC.author
			FC.author = "<B>\[██████\]</B>"
		else
			FC.author = FC.backup_author

	else if(href_list["censor_channel_story_author"])
		var/datum/feed_message/MSG = locate(href_list["censor_channel_story_author"])
		if(MSG.is_admin_message)
			to_chat(usr, "This message was created by a Nanotrasen Officer. You cannot censor its author.")
			return FALSE
		if(MSG.author != "<B>\[██████\]</B>")
			MSG.backup_author = MSG.author
			MSG.author = "<B>\[██████\]</B>"
		else
			MSG.author = MSG.backup_author

	else if(href_list["censor_channel_story_body"])
		var/datum/feed_message/MSG = locate(href_list["censor_channel_story_body"])
		if(MSG.is_admin_message)
			to_chat(usr, "This channel was created by a Nanotrasen Officer. You cannot censor it.")
			return FALSE
		if(MSG.img != null)
			MSG.backup_img = MSG.img
			MSG.img = null
		else
			MSG.img = MSG.backup_img
		if(MSG.body != "<B>\[██████\]</B>")
			MSG.backup_body = MSG.body
			MSG.body = "<B>\[██████\]</B>"
		else
			MSG.body = MSG.backup_body

	else if(href_list["censor_author_comment"])
		var/datum/message_comment/COMMENT = locate(href_list["censor_author_comment"])
		if(COMMENT.author != "<FONT SIZE=2><B>\[██████\]</B></FONT>")
			COMMENT.backup_author = COMMENT.author
			COMMENT.author = "<FONT SIZE=2><B>\[██████\]</B></FONT>"
		else
			COMMENT.author = COMMENT.backup_author

	else if(href_list["censor_body_comment"])
		var/datum/message_comment/COMMENT = locate(href_list["censor_body_comment"])
		if(COMMENT.body != "<FONT SIZE=2><B>\[██████\]</B></FONT>")
			COMMENT.backup_body = COMMENT.body
			COMMENT.body = "<FONT SIZE=2><B>\[██████\]</B></FONT>"
		else
			COMMENT.body = COMMENT.backup_body

	else if(href_list["pick_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["pick_d_notice"])
		src.viewing_channel = FC
		src.screen = 13

	else if(href_list["toggle_d_notice"])
		var/datum/feed_channel/FC = locate(href_list["toggle_d_notice"])
		if(FC.is_admin_channel)
			to_chat(usr, "This channel was created by a Nanotrasen Officer. You cannot place a D-Notice upon it.")
			return FALSE
		FC.censored = !FC.censored

	else if(href_list["view"])
		src.screen = 1

	else if(href_list["setScreen"]) //Brings us to the main menu and resets all fields~
		src.screen = text2num(href_list["setScreen"])
		if (src.screen == 0)
			src.scanned_user = "Unknown"
			msg = ""
			src.c_locked = 0
			channel_name = ""
			src.viewing_channel = null

	else if(href_list["show_channel"])
		var/datum/feed_channel/FC = locate(href_list["show_channel"])
		src.viewing_channel = FC
		src.screen = 9

	else if(href_list["pick_censor_channel"])
		var/datum/feed_channel/FC = locate(href_list["pick_censor_channel"])
		src.viewing_channel = FC
		src.screen = 12

	else if(href_list["setLike"])
		var/datum/feed_message/FM = locate(href_list["setLike"])
		FM.voters += src.scanned_user
		FM.likes += 1

	else if(href_list["setDislike"])
		var/datum/feed_message/FM = locate(href_list["setDislike"])
		FM.voters += src.scanned_user
		FM.dislikes += 1

	else if(href_list["open_pages"]) //page with comments for assistants
		var/datum/feed_message/FM = locate(href_list["open_pages"])
		src.viewing_message = FM
		src.current_page = FM.pages[1]
		src.screen = 23

	else if(href_list["open_censor_pages"]) //page with comments for security
		var/datum/feed_message/FM = locate(href_list["open_censor_pages"])
		src.viewing_message = FM
		src.current_page = FM.pages[1]
		src.screen = 24

	else if(href_list["next_page"])
		var/datum/comment_pages/CP = locate(href_list["next_page"])
		src.screen = 23
		src.current_page = CP

	else if(href_list["next_censor_page"])
		var/datum/comment_pages/CP = locate(href_list["next_censor_page"])
		src.screen = 24
		src.current_page = CP

	else if(href_list["leave_a_comment"])
		var/datum/feed_message/FM = locate(href_list["leave_a_comment"])
		src.comment_msg = sanitize(input(usr, "Напишите комментарий", "Обработчик Сети Новостей", input_default(src.comment_msg)), extra = FALSE)
		if(src.comment_msg == "" || src.comment_msg == null || src.scanned_user == "Unknown")
			src.screen = 22
		else
			var/datum/message_comment/COMMENT = new /datum/message_comment
			COMMENT.author = src.scanned_user
			COMMENT.body = src.comment_msg
			COMMENT.time = worldtime2text()

			var/length = FM.pages.len //find the last page
			var/size = FM.pages[length].comments.len

			if(size - COMMENTS_ON_PAGE != 0) //Create new page, if comments on the page are equal
				FM.pages[length].comments += COMMENT
			else
				var/datum/comment_pages/CP = new /datum/comment_pages
				FM.pages += CP
				CP.comments += COMMENT

			FM.count_comments += 1

			src.comment_msg = ""

	else if(href_list["locked_comments"])
		if(src.viewing_channel.lock_comments)
			src.viewing_channel.lock_comments = FALSE
		else
			src.viewing_channel.lock_comments = TRUE

	updateUsrDialog()

/obj/machinery/newscaster/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		if(user.is_busy())
			return
		to_chat(user, "<span class='notice'>Now [anchored ? "un" : ""]securing [name]</span>")
		if(I.use_tool(src, user, 60, volume = 50))
			new /obj/item/newscaster_frame(loc)
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			qdel(src)
		return

	if (src.isbroken)
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', VOL_EFFECTS_MASTER)
		user.visible_message("<EM>[user.name]</EM> further abuses the shattered [src.name].")
	else
		if(istype(I, /obj/item/weapon) )
			user.do_attack_animation(src)
			user.SetNextMove(CLICK_CD_MELEE)
			var/obj/item/weapon/W = I
			if(W.force <15)
				user.visible_message("[user.name] hits the [src.name] with the [W.name] with no visible effect.")
				playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
			else
				src.hitstaken++
				if(src.hitstaken==3)
					user.visible_message("[user.name] smashes the [src.name]!")
					src.isbroken=1
					playsound(src, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER)
				else
					user.visible_message("[user.name] forcefully slams the [src.name] with the [I.name]!")
					playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
		else
			to_chat(user, "<span class='info'>This does nothing.</span>")
	update_icon()

/obj/machinery/newscaster/attack_paw(mob/user)
	to_chat(user, "<span class='info'>The newscaster controls are far too complicated for your tiny brain!</span>")
	return

/obj/machinery/newscaster/proc/AttachPhoto(mob/user)
	if(photo)
		if(!issilicon(user))
			photo.loc = src.loc
			user.put_in_inactive_hand(photo)
		photo = null
	if(istype(user.get_active_hand(), /obj/item/weapon/photo))
		photo = user.get_active_hand()
		user.drop_from_inventory(photo, src)
	else if(istype(user,/mob/living/silicon))
		var/mob/living/silicon/tempAI = user
		var/obj/item/device/camera/siliconcam/camera = tempAI.aiCamera

		if(!camera)
			return
		var/datum/picture/selection = camera.selectpicture()
		if (!selection)
			return

		var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
		P.construct(selection)
		photo = P

/proc/return_funny_title()
	// Some copied from @neural_meduza with nanotrasen adaptation
	var/list/random_imortant_message = list(
		"В Еуране заблокировали социальные сети из-за твита Президента о гомосексуальных грузовиках",
		"В Слеирстине предложили наказывать за повышение зарплаты",
		"Закончились таинственные грибы у прокурора NanoTrasen в Крокандо",
		"Штальский снова позвонил в космос и изменил вообще всё. На карточках",
		"Патриарх Досифей назвал главной проблемой эволюцию",
		"Доказано отсутствие солдат синдиката на Юпитере",
		"Треть работников NanoTrasen высказалась против кибер-огурцов",
		"Таяране начали откладывать яйца",
		"В Ксокслэнсе из-за землетрясения на 10 дней приостановлены изнасилования",
		"Зрэимцам разрешили переезжать в NanotrasenHub",
		"Транспортная инспекция полетного движения предложила ввести штраф за покупку не летающих автомобилей",
		"В Свеузе будут штрафовать за отказ от наркотиков",
		"Николай II выйдет на работу в 2225 году",
		"Моисей — это мопс. Рассказываем, что нужно знать",
		"В Фрелпасу начали сбор подписей на памятник эчпочмаку",
		"Лепрастейнские гей-парады оказались неуязвимыми",
		"Только на майские праздники в Плаериэле построят мемориал жертвам космческих наркотиков",
		"Геофизики предрекли слияние борща и баклажанов",
		"Хескостен, город в Северном Ваезе, напомнил журналистам о своем гомосексуализме",
		"Баррингтон попросит вернуть у Кемалова три тысячи детей",
		"В Еспале из-за угрозы взрыва взорвали более 200 человек",
		"На Плутоне отказались от празднования Дня NanoTrasen",
		"Половина страпонианцев считает унатхов суперкомпьютерами",
		"Физики-исламисты стали плохо пить и задушили дождь",
		"Националисты пожаловались на нехватку сожженных детей в Уфрасе",
		"В Спауде снова зафиксированы бессмысленные жители",
		"Человек-слизень помог Буцулони стать унатхом",
		"Ученыe системы Тау Кита определили, что люди без мозгов живут дольше киборгов",
		"Университет высоких технологий имени Хутыйна выяснил опытным путем, что слепые люди реже голосуют, чем слабоумные и глухие",
		"Внимание! Доказано, что финансовые пирамиды платят больше, чем букмекеры",
		"Срочно! В Низком Кудмисте умер народный порноактер",
		"Во всем Дапако запретили заниматься сексом под Космо-Рок-Н-Ролл",
		)

	return pick(random_imortant_message)


//########################################################################################################################
//###################################### NEWSPAPER! ######################################################################
//########################################################################################################################

/obj/item/weapon/newspaper
	name = "Newspaper"
	desc = "An issue of The Griffon, the newspaper circulating aboard Nanotrasen Space Stations."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	w_class = ITEM_SIZE_SMALL	//Let's make it fit in trashbags!
	attack_verb = list("bapped")
	var/screen = 0
	var/pages = 0
	var/curr_page = 0
	var/list/datum/feed_channel/news_content = list()
	var/datum/feed_message/important_message = null
	var/scribble = ""
	var/scribble_page = null

/obj/item/weapon/newspaper/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		src.pages = 0
		switch(screen)
			if(0) //Cover
				dat+="<DIV ALIGN='center'><B><FONT SIZE=6>Грифон</FONT></B></div>"
				dat+="<DIV ALIGN='center'><FONT SIZE=2>Стандартная газета НаноТрейзен, предназначенная для использования на Космических Объектах НаноТрейзен©</FONT></div><HR>"
				if(isemptylist(src.news_content))
					if(src.important_message)
						dat+="Содержание:<BR><ul><B><FONT COLOR='red'>**</FONT>Важные объявление службы безопасности<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[стр. [src.pages+2]\]</FONT><BR></ul>"
					else
						dat+="<I>[return_funny_title()]</I>"
				else
					dat+="Содержание:<BR><ul>"
					for(var/datum/feed_channel/NP in src.news_content)
						src.pages++
					if(src.important_message)
						dat+="<B><FONT COLOR='red'>**</FONT>Важные объявление службы безопасности<FONT COLOR='red'>**</FONT></B> <FONT SIZE=2>\[стр. [src.pages+2]\]</FONT><BR>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in src.news_content)
						temp_page++
						dat+="<B>[NP.channel_name]</B> <FONT SIZE=2>\[стр. [temp_page+1]\]</FONT><BR>"
					dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>Маленькая надпись внизу страницы гласит: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>След. Страница</A></DIV> <div style='float:left;'></DIV>"
			if(1) // X channel pages inbetween.
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++ //Let's get it right again.
				var/datum/feed_channel/C = src.news_content[src.curr_page]
				dat+="<FONT SIZE=4><B>[C.channel_name]</B></FONT><FONT SIZE=1> \[создано: <FONT COLOR='maroon'>[C.author]</FONT>\]</FONT><BR><BR>"
				if(C.censored)
					dat+="Содержание данного Новостного Канала было отмечено как угроза благополучию станции и помечено <B><FONT COLOR='red'>❌-меткой</B></FONT>. Эта статья не была напечатана в газете."
				else
					if(isemptylist(C.messages))
						dat+="В этом Канале Истории не обнаружены..."
					else
						dat+="<ul>"
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							i++
							dat+="-[MESSAGE.body] <BR>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat+="<img src='tmp_photo[i].png' width = '180'><BR>"
							dat+="<FONT SIZE=1>\[Автор: <FONT COLOR='maroon'>[MESSAGE.author]</FONT>\]</FONT><BR>"
							dat+="<FONT SIZE=1>Лайки: [MESSAGE.likes] Дизлайки: [MESSAGE.dislikes]</FONT><BR><BR>"
						dat+="</ul>"
				if(scribble_page==curr_page)
					dat+="<BR><I>Маленькая надпись внизу страницы гласит: \"[src.scribble]\"</I>"
				dat+= "<BR><HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Пред. Страница</A></DIV> <DIV STYLE='float:right;'><A href='?src=\ref[src];next_page=1'>След. Страница</A></DIV>"
			if(2) //Last page
				for(var/datum/feed_channel/NP in src.news_content)
					src.pages++
				if(src.important_message != null)
					dat+="<DIV STYLE='float:center;'><FONT SIZE=4><B>Розыск:</B></FONT SIZE></DIV><BR><BR>"
					dat+="<B>Имя</B>: <FONT COLOR='maroon'>[important_message.author]</FONT><BR>"
					dat+="<B>Описание</B>: [important_message.body]<BR>"
					dat+="<B>Снимок:</B>: "
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat+="<BR><img src='tmp_photow.png' width = '180'>"
					else
						dat+="Отсутствует"
				else
					dat+="<I>[return_funny_title()]</I>"
				if(scribble_page==curr_page)
					dat+="<BR><I>Маленькая надпись внизу страницы гласит: \"[src.scribble]\"</I>"
				dat+= "<HR><DIV STYLE='float:left;'><A href='?src=\ref[src];prev_page=1'>Пред. Страница</A></DIV>"
			else
				dat+="[return_funny_title()]"

		dat+="<BR><HR><div align='center'>[src.curr_page+1]</div>"

		var/datum/browser/popup = new(human_user, "window=newspaper_main", src.name, 300, 400, ntheme = CSS_THEME_LIGHT)
		popup.set_content(dat)
		popup.open()
	else
		to_chat(user, "The paper is full of intelligible symbols!")


/obj/item/weapon/newspaper/Topic(href, href_list)
	var/mob/living/U = usr
	..()
	if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ))
		U.set_machine(src)
		if(href_list["next_page"])
			if(curr_page==src.pages+1)
				return //Don't need that at all, but anyway.
			if(src.curr_page == src.pages) //We're at the middle, get to the end
				src.screen = 2
			else
				if(curr_page == 0) //We're at the start, get to the middle
					src.screen=1
			src.curr_page++
			playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)

		else if(href_list["prev_page"])
			if(curr_page == 0)
				return
			if(curr_page == 1)
				src.screen = 0

			else
				if(curr_page == src.pages+1) //we're at the end, let's go back to the middle.
					src.screen = 1
			src.curr_page--
			playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)

		if (istype(src.loc, /mob))
			attack_self(src.loc)


/obj/item/weapon/newspaper/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen))
		if(src.scribble_page == src.curr_page)
			to_chat(user, "<FONT COLOR='blue'>There's already a scribble in this page... You wouldn't want to make things too cluttered, would you?</FONT>")
		else
			var/s = sanitize(input(user, "Write something", "Newspaper", ""))
			if (!s)
				return
			if (!in_range(src, usr) && src.loc != usr)
				return
			src.scribble_page = src.curr_page
			src.scribble = s
			attack_self(user)
		return
	return ..()


////////////////////////////////////helper procs


/obj/machinery/newscaster/proc/scan_user(mob/living/user)
	if(istype(user,/mob/living/carbon/human))                       //User is a human
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)                                      //Newscaster scans you
			if(istype(human_user.wear_id, /obj/item/device/pda) )	//autorecognition, woo!
				var/obj/item/device/pda/P = human_user.wear_id
				if(P.id)
					src.scanned_user = "[P.id.registered_name] ([P.id.assignment])"
				else
					src.scanned_user = "Unknown"
			else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = human_user.wear_id
				src.scanned_user ="[ID.registered_name] ([ID.assignment])"
			else
				src.scanned_user ="Unknown"
		else
			src.scanned_user ="Unknown"
	else
		var/mob/living/silicon/ai_user = user
		src.scanned_user = "[ai_user.name] ([ai_user.job])"


/obj/machinery/newscaster/proc/print_paper()
	feedback_inc("newscaster_newspapers_printed",1)
	var/obj/item/weapon/newspaper/NEWSPAPER = new /obj/item/weapon/newspaper
	for(var/datum/feed_channel/FC in news_network.network_channels)
		NEWSPAPER.news_content += FC
	if(news_network.wanted_issue)
		NEWSPAPER.important_message = news_network.wanted_issue
	NEWSPAPER.loc = get_turf(src)
	src.paper_remaining--
	return

//Removed for now so these aren't even checked every tick. Left this here in-case Agouri needs it later.
///obj/machinery/newscaster/process()       //Was thinking of doing the icon update through process, but multiple iterations per second does not
//	return                                  //bode well with a newscaster network of 10+ machines. Let's just return it, as it's added in the machines list.

/obj/machinery/newscaster/proc/newsAlert(channel)
	if(channel)
		audible_message("<span class='newscaster'><EM>[name]</EM> beeps, \"Breaking news from [channel]!\"</span>")
		alert = 1
		update_icon()
		spawn(300)
			alert = 0
			update_icon()
		playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
	else
		audible_message("<span class='newscaster'><EM>[name]</EM> beeps, \"Attention! Wanted issue distributed!\"</span>")
		playsound(src, 'sound/machines/warning-buzzer.ogg', VOL_EFFECTS_MASTER)
	return

#undef COMMENTS_ON_PAGE
