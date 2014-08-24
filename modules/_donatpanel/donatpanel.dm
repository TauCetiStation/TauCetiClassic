/proc/donatinfo()


	var/percent = 0
	var/cost = 2000
	var/donate = 0
	var/month = "следующий мес&#1103;ц"

	var/list/Params = file2list("config/donatinfo.txt")

	for(var/t in Params)
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)
		if (!name)
			continue

		switch(name)
			if("hide")
				return	//как нибудь сделать это красивее, вынести в основной конфиг может
			if("cost")
				cost = text2num(value)
			if("donate")
				donate = text2num(value)
			if("month")
				month = value


	percent = round((100 * donate)/cost)
	var/di_width = min(percent, 100)
	//var/progressbar_width = percent * 3//1% = 3px
	//world << "progressbar_width [progressbar_width]"

	//TODO: "за этот месяц мы благодарны: ...", сделать ссылку через топик, ну и заодно переверстать табличку по человечески
	var/output = "<HEAD><TITLE>Важна&#1103; информаци&#1103;</TITLE></HEAD><BODY bgcolor='#373737' text='#DFE5EB'><div align='center'>\n"
	output += "<h2>Важна&#1103; информаци&#1103;!</h2>"
	output += "Аренда сервера дл&#1103; сообщества стоит денег, и мы очень надеемс&#1103; на вашу помощь.<br>"
	output += "Информаци&#1103; о том, как нам помочь: http://forums.tauceti.ru/talks/index.php?topic=1253.0<br><br>"
	output += "Сбор средств на [month]:<br>"
	output += "<div style='background-color: #DFDFDF; position: relative; width: 400px; height: 23px; border: 1px solid black; margin: 0px; padding: 0px;'>\n"//почему 23? да хз, хтмл отладчика тут нету а старые ослики славились своей одаренностью
	output += "<div style='position: absolute; left: 0px; background-color: #FF0D1E; width: [di_width]%; height: 20px; margin: 0px; padding: 0px; border: 1px solid white;'></div>"
	output += "<div style='color: 000000; position: absolute; left: 0; width: 400px; height: 22px; margin: 0px; padding: 0px; vertical-align: middle'>[percent]%</div>"
	output += "</div>"
	output += "<small>*состо&#1103;ние обновл&#1103;етс&#1103; раз в несколько дней,<br>собираема&#1103; сумма: [cost] рублей.</small>"
	//output += "<A href='?src=[ref];'>Принять к сведенью и закрыть</A>"
	output += "</div></BODY>"

	usr << browse(output, "window=donatinfo;size=620x250;can_resize=0;")