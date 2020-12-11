//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32
#define CULT_RUNES_LIMIT 26

var/list/cultwords = list() // associated english word = runeword
var/list/cultwords_reverse = list() // associated runeword = english word
var/list/cult_datums = list()

/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning."
	if(!cultwords["travel"])
		runerandom()
	for (var/word in cultwords)
		to_chat(usr, "[word] is [cultwords[word]]")

/proc/runerandom() //randomizes word meaning
	var/list/runewords = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri") ///"orkan" and "allaq" removed.
	var/list/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")
	for(var/word in engwords)
		cultwords[word] = pick_n_take(runewords)
		cultwords_reverse[cultwords[word]] = word

	for(var/type in subtypesof(/datum/cult))
		var/datum/cult/dat = type
		var/word1 = initial(dat.word1)
		var/word2 = initial(dat.word2)
		var/word3 = initial(dat.word3)
		cult_datums[word1 + word2 + word3] = type

/obj/effect/rune
	name = "blood"
	desc = ""
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER
	var/datum/cult/power

// travel self [word] - Teleport to random [rune with word destination matching]
// travel other [word] - Portal to rune with word destination matching - kinda doesnt work. At least the icon. No idea why.
// see blood Hell - Create a new tome
// join blood self - Incorporate person over the rune into the group
// Hell join self - Summon TERROR
// destroy see technology - EMP rune
// travel blood self - Drain blood
// see Hell join - See invisible
// blood join Hell - Raise dead

// hide see blood - Hide nearby runes
// blood see hide - Reveal nearby runes  - The point of this rune is that its reversed obscure rune. So you always know the words to reveal the rune once oyu have obscured it.

// Hell travel self - Leave your body and ghost around
// blood see travel - Manifest a ghost into a mortal body
// Hell tech join - Imbue a rune into a talisman
// Hell blood join - Sacrifice rune
// destroy travel self - Wall rune
// join other self - Summon cultist rune
// travel technology other - Freeing rune    //    other blood travel was freedom join other

// hide other see - Deafening rune     //     was destroy see hear
// destroy see other - Blinding rune
// destroy see blood - BLOOD BOIL

// self other technology - Communication rune  //was other hear blood
// join hide technology - stun rune. Rune color: bright pink.
/obj/effect/rune/atom_init()
	. = ..()
	cult_runes += src
	var/image/I = image('icons/effects/blood.dmi', src, "mfloor[rand(1, 7)]", 2)
	I.override = TRUE
	I.color = "#a10808"
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/update_icon()
	color = "#a10808"

/obj/effect/rune/Destroy()
	QDEL_NULL(power)
	cult_runes -= src
	return ..()

/obj/effect/rune/examine(mob/user)
	if(iscultist(user) || isobserver(user))
		to_chat(user, "[bicon(src)] That's <span class='cult'>cult rune!</span>")
		to_chat(user, "A spell circle drawn in blood. It reads: <i>[desc]</i>.")
		return
	to_chat(user, "[bicon(src)] That's some <span class='danger'>[name]</span>")
	if(issilicon(user))
		to_chat(user, "It's thick and gooey. Perhaps it's the chef's cooking?") // blood desc
	else
		to_chat(user, "A strange collection of symbols drawn in blood.")

/obj/effect/rune/attackby(I, mob/living/user)
	if(istype(I, /obj/item/weapon/book/tome) && iscultist(user))
		to_chat(user, "<span class='cult'>You retrace your steps, carefully undoing the lines of the rune.</span>")
		qdel(src)
	else if(istype(I, /obj/item/weapon/nullrod) && user.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		to_chat(user, "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>")
		qdel(src)
	else
		return ..()

/obj/effect/rune/attack_ghost(mob/dead/observer/user)
	if(!istype(power, /datum/cult/teleport) && !istype(power, /datum/cult/item_port))
		return ..()
	var/list/allrunes = list()
	for(var/obj/effect/rune/R in cult_runes)
		if(!istype(R.power, power.type) || R == src)
			continue
		if(R.power.word3 == power.word3 && !is_centcom_level(R.loc.z))
			allrunes += R
	if(length(allrunes) > 0)
		user.forceMove(get_turf(pick(allrunes)))

/obj/effect/rune/attack_hand(mob/living/user)
	user.SetNextMove(CLICK_CD_INTERACT)
	if(!iscultist(user))
		to_chat(user, "You can't mouth the arcane scratchings without fumbling over them.")
		return
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(user, "You are unable to speak the words of the rune.")
		return
	if(!power || prob(user.getBrainLoss()))
		user.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.",\
		"Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
		return
	power.action(user)

/obj/item/weapon/book/tome
	name = "book"
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	unique = 1
	var/unlocked = FALSE
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")

	tomedat = {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
				<style>
				h1 {font-size: 25px; margin: 15px 0px 5px;}
				h2 {font-size: 20px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>Писания Нар-Си, Того-Кто-Наблюдает, Геометра крови.</h1>

				<i>Книга написана на неизвестном диалекте. В ней много изображений разного рода комплексных, геометрических фигур. Вы находите некоторые похожие слова, благодаря чему можете прочитать большинство рун, описаных в книге. Также, вы можете прочесть слова, из которых состоят руны. Впрочем, вы все еще не можете начертить их, используя этот диалект.</i><br>
				<i>Список рун.</i> <br>

				<h2>Contents</h2>
				<p>
				<b>Телепортировать себя: </b>Travel Self (word)<br>
				<b>Телепортировать что-то: </b>Travel Other (word)<br>
				<b>Призыв нового тома: </b>See Blood Hell<br>
				<b>Обратить: </b>Join Blood Self<br>
				<b>Призыв Нар-Си: </b>Hell Join Self<br>
				<b>Отключить технологию: </b>Destroy See Technology<br>
				<b>Высосать кровь: </b>Travel Blood Self<br>
				<b>Поднять мертвеца: </b>Blood Join Hell<br>
				<b>Скрыть руны: </b>Hide See Blood<br>
				<b>Проявить руны: </b>Blood See Hide<br>
				<b>Покинуть тело: </b>Hell travel self<br>
				<b>Манифест призраков: </b>Blood See Travel<br>
				<b>Насытить талисман: </b>Hell Technology Join<br>
				<b>Жертвоприношение: </b>Hell Blood Join<br>
				<b>Создать стену: </b>Destroy Travel Self<br>
				<b>Призвать культиста: </b>Join Other Self<br>
				<b>Освободить культиста: </b>Travel technology other<br>
				<b>Оглушить: </b>Hide Other See<br>
				<b>Ослепить: </b>Destroy See Other<br>
				<b>Кипящая кровь: </b>Destroy See Blood<br>
				<b>Общение: </b>Self Other Technology<br>
				<b>Ошеломление: </b>Join Hide Technology<br>
				<b>Призыв брони: </b>Hell Destroy Other<br>
				<b>Увидеть невидимое: </b>See Hell Join<br>
				<b>Конструкт: </b>Technology Blood Travel<br>
				<b>Смена тел: </b>Travel Blood Other<br>
				</p>
				<h2>Описание рун</h2>
				<h3>Телепортировать себя</h3>
				Руна телепорта это специальная руна, которой нужны два слова как основа и третье как место назначения. Если у вас есть две руны с одинаковым местом назначения, то активация одной из них телепортирует вас к другой. Если рун больше, чем две, вас телепортирует на случайную. Руны с разными третьими словами создадут разную сеть телепортов. Вы можете перенести эту руну в талисман, который мог быть неплохим средством для побега.<br>
				<h3>Телепортировать что-то</h3>
				Эта руна позволяет переместить любой подвижный объект к другой руне, с таким же местом назначения. Вам понадобятся три культиста, произносящих руну, для активации.<br>
				<h3>Призыв нового тома</h3>
				Активируйте руну, чтобы призвать новый том.
				<h3>Обратить</h3>
				Руна показывает жертве измерение Нар-Си, что обычно приводит к вступлению в культ. Впрочем, некоторые люди (В частности, одержимые властью.) имеют достаточно сильную волю, чтобы оставаться преданными своим идеалам.<br>
				<h3>Призыв Нар-Си</h3>
				Ультимативная руна. Ее активация призывает в этот мир аватар самого Нар-Си, создавая огромную дыру в реальности. Призыв аватара финальная цель культа.<br>
				<h3>Отключить технологию</h3>
				Активация руны вызывает сильный электромагнитный импульс в небольшом радиусе, который аналогичен ЭМ-гранате. Вы можете перенести эту руну в талисман, что могло сделать его неплохим средством защиты.<br>
				<h3>Высосать кровь</h3>
				Руна мгновенно вылечит ваши порезы ценой урона существу, размещенному на ней. Когда вы активируете руну, все остальные руны высасывания также активируются, высасывая кровь из жертв. Вы - не исключение. Если вы встанете на руну и используете ее, ваша же кровь попадет обратно к вам. Это может помочь при поиске слов. Одна активация высасывает до 25HP каждой жертвы, но вы можете активировать руну повторно. Работает только с живыми людьми. Передозировка кровью может вызвать жажду крови.<br>
				<h3>Поднять мертвеца</h3>
				Позволяет воскрешать мертвецов. Вам понадобятся мертвое тело и жертвоприношение. Сделайте две руны. Положите живого, бодрствующего на одну и труп на другую. При активации руна перенесет жизненную силу из живого в мертвого, позволяя призраку, стоящему на руне, войти в исцеленное тело. Используйте другую руну для поиска призраков.<br>
				<h3>Скрыть руны</h3>
				Делает руны невидимыми. Они останутся на месте и будут работать, но вы не сможете активировать руны, если не видите их.<br>
				<h3>Проявить руны</h3>
				Эта руна, при активации, отображает другие руны, которые были скрыты с помощью руны сокрытия, в довольно большом радиусе.
				<h3>Покинуть тело</h3>
				Буквально вырывает вашу душу из тела. Вы можете свободно перемещаться как призрак и общаться с мертвыми. Ваше тело получает урон, пока вы находитесь в другом мире, так что лучше вам там не засиживаться, иначе вы можете оттуда и не вернуться.<br>
				<h3>Манифест призраков</h3>
				В отличие от руны поднятия мертвеца, эта не требует приготовлений или сосуда. Вместо поглощения жизненной силы из жертвы, она будет высасывать вашу. Встаньте на руну и активируйте ее. Если призрак будет стоять на руне, то он материализуется и будет жить до тех пор, пока вы стоите на ней или пока вы не умрете. Вы можете положить листок с именем на руну, чтобы новое тело выглядело как человек с этим именем.<br>
				<h3>Насытить талисман</h3>
				Руна позволяет насыщать магией рун бумажные талисманы. Начертите руну насыщения, положите на нее пустой лист бумаги и активируйте ее. Теперь у вас есть одноразовый талисман с силой целевой руны. Использование этого талисмана может высосать здоровье, так что осторожнее с ним. Вы можете насытить талисман этими рунами: Призыв тома, Проявить руны, Скрыть руны, Телепорт, Отключить технологию, Общение, Оглушить, Ослепить, Ошеломление, Конструкт и Призыв камня душ.<br>
				<h3>Жертвоприношение</h3>
				Позволяет принести в жертву Геометру Крови живое существо или тело. Мартышки и трупы - основа жертвоприношения, но этого может быть недостаточно, чтобы удовлетворить Его. Живой человек - то, что Ему нужно. Во всяком случае, вам понадобится три человека, чтобы прочитать и активировать руну с живым человеком на ней.
				<h3>Создать стену</h3>
				При активации делает воздух настолько твердым, что через него нельзя пройти. Чтобы убрать стену, активируйте руну снова.
				<h3>Призвать культиста</h3>
				Руна позволяет призвать вашего коллегу-культиста. Цель не должна быть закована в наручники и сидеть на чем-либо. Вам также понадобятся три человека, чтобы активировать руну. Ее активация производит сильную нагрузку на тела всех, участвующих в чтении руны.<br>
				<h3>Освободить культиста</h3>
				Позволяет снять наручники и отстегнуть от стула культиста, где бы он не находился. Вам понадобятся три человека, для проведения ритуала. Активация руны оказывает сильное воздействие на тела участников ритуала.<br>
				<h3>Оглушить</h3>
				Активация руны позволяет временно оглушить всех, кроме культистов, вокруг вас.<br>
				<h3>Ослепить</h3>
				Активация позволяет ослепить временно всех, кроме культистов, вокруг вас. Очень опасно. Использование вместе с руной Оглушить сделает ваших врагов беспомощными.<br>
				<h3>Кипящая кровь</h3>
				Руна заставляет кровь, в жилах не культистов, кипеть. Урона достаточно для нанесения критических повреждений человеку. Вам понадобятся три человека для активации руны. Ее действие может быть ненадежным и опасным даже для вас. Она также потребляет некоторое количество вашей крови и здоровья для успешной активации.<br>
				<h3>Общение</h3>
				Позволяет отправить сообщение всем культистам на станции.
				<h3>Ошеломление</h3>
				В отличие от прочих рун, эта предназначена для использования в форме талисмане. Если активировать напрямую - выпускает немного темной энергии и ошеломляет всех вокруг. Если ею насытить талисман, то вы сможете высвободить всю ее энергию и направить в одного человека, ошеломляя его так сильно, что тот даже не сможет говорить. Эффект временный и быстро пропадает.<br>
				<h3>Призыв брони</h3>
				При активации, в форме руны или талисмана, материализует броню последователей Нар-Си на теле призывающего. Чтобы использовать полный набор, убедитесь, что вы не носите головной убор, любую другую броню, перчатки и ботинки, а также не держите ничего в руках.<br>
				<h3>Увидеть невидимое</h3>
				При активации стоя на ней - позволяет видеть мир мертвых до тех пор, пока вы не двигаетесь.<br>
				<h3>Конструкт</h3>
				Может быть активирована только в качестве талисмана. Призывает оболочку конструкта. Для использования оболочки требуется заряженный камень душ.
				<h3>Призыв камня душ</h3>
				Может быть активирована только в качестве талисмана. Призывает пустой камень душ, который можно насыть лишь живой душой. Процесс поимки души довольно щепетильный и требует жертвоприношения. В момент последнего вздоха жертвы поднесите камень к телу, чтобы поймать его душу.
				<h3>Смена тел</h3>
				Для активации разместите живую, бодрствующую жертву на руне. Не работает ни с кем, кроме живых людей и наносит урон при переходе.
				</body>
				</html>
				"}

/obj/item/weapon/book/tome/atom_init()
	. = ..()
	if (icon_state == "book")
		icon_state = "book[pick(1,2,3,4,5,6)]"

/obj/item/weapon/book/tome/Topic(href, href_list[])
	if(loc != usr)
		usr << browse(null, "window=notes")
		return
	var/number = text2num(href_list["number"])
	if (usr.stat|| usr.restrained())
		return
	switch(href_list["action"])
		if("clear")
			words[words[number]] = words[number]
		if("change")
			words[words[number]] = input("Enter the translation for [words[number]]", "Word notes") in cultwords
			for (var/w in words)
				if ((words[w] == words[words[number]]) && (w != words[number]))
					words[w] = w
	notedat = {"
	<br><b>Word translation notes</b> <br>
	[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
	[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
	[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
	[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
	[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
	[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
	[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
	[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
	[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
	[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
	"}

	var/datum/browser/popup = new(usr, "window=notes", "Tome", 400, 600, ntheme=CSS_THEME_LIGHT)
	popup.set_content(notedat)
	popup.open()

/obj/item/weapon/book/tome/attack(mob/living/M, mob/living/user)
	M.log_combat(user, "beaten with [name]")

	if(istype(M, /mob/dead))
		M.invisibility = 0
		user.visible_message( \
			"<span class='userdanger'> [user] drags the ghost to our plan of reality!</span>", \
			"<span class='userdanger'>You drag the ghost to our plan of reality!</span>")
		return
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		return
	M.adjustBruteLoss(rand(5, 20)) //really lucky - 5 hits for a crit
	M.visible_message("<span class='danger'>[user] beats [M] with the arcane tome!</span>")
	to_chat(M, "<span class='danger'You feel searing heat inside!</span>")

/obj/item/weapon/book/tome/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(iscultist(user) && target.reagents && target.reagents.has_reagent("water"))
		var/water2convert = target.reagents.get_reagent_amount("water")
		target.reagents.del_reagent("water")
		to_chat(user, "<span class='warning'>You curse [target].</span>")
		target.reagents.add_reagent("unholywater",water2convert)

/obj/item/weapon/book/tome/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || user.incapacitated())
		return

	if(!cultwords["travel"])
		runerandom()
	if(!iscultist(user))
		to_chat(user, "This book is completely blank!")
		return
	if (!isturf(user.loc))
		to_chat(user, "<span class='userdanger'>You do not have enough space to write a proper rune.</span>")
		return
	for(var/obj/structure/obj_to_check in user.loc)
		if(obj_to_check.density)
			to_chat(user, "<span class='warning'>There is not enough space to write a proper rune.</span>")
			return
	if (length(cult_runes) >= CULT_RUNES_LIMIT + length(SSticker.mode.cult)) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
		alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
		return
	switch(alert("You open the tome",,"Read it","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
		if("Cancel")
			return
		if("Read it")
			if(usr.get_active_hand() != src)
				return
			var/datum/browser/popup = new(user, "window=Arcane Tome", "Tome", 400, 600, ntheme=CSS_THEME_LIGHT)
			popup.set_content(tomedat)
			popup.open()
			return
		if("Notes")
			if(usr.get_active_hand() != src)
				return
			notedat = {"
			<br><b>Word translation notes</b> <br>
			[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
			[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
			[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
			[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
			[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
			[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
			[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
			[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
			[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
			[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
			"}

			var/datum/browser/popup = new(user, "window=notes", "Tome", 400, 600, ntheme=CSS_THEME_LIGHT)
			popup.set_content(notedat)
			popup.open()
			return
	if(usr.get_active_hand() != src)
		return

	if(user.species.flags[NO_BLOOD])
		to_chat(user, "<span class='warning'>You don't have any blood, how do you suppose to write a blood rune?</span>")
		return

	var/w1
	var/w2
	var/w3
	var/list/english = list()
	for(var/w in words)
		english[words[w]] = w
	if(user)
		w1 = input("Write your first rune:", "Rune Scribing") as null|anything in english
		if(!w1)
			return
		if(w1 in cultwords)
			w1 = english[w1]
	if(user)
		w2 = input("Write your second rune:", "Rune Scribing") as null|anything in english
		if(!w2)
			return
		if(w2 in cultwords)
			w2 = english[w2]
	if(user)
		w3 = input("Write your third rune:", "Rune Scribing") as null|anything in english
		if(!w3)
			return
		if(w3 in cultwords)
			w3 = english[w3]


	if(user.get_active_hand() != src || user.is_busy())
		return
	user.visible_message("<span class='danger'> [user] slices open a finger and begins to chant and paint symbols on the floor.</span>",\
	"<span class='danger'> You hear chanting.</span>")
	to_chat(user, "<span class='danger'> You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the\
	ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>")
	user.take_overall_damage((rand(9) + 1) / 10) // 0.1 to 1.0 damage
	if((unlocked || do_after(user, 50, target = user)) && user.get_active_hand() == src)
		var/obj/effect/rune/R = new /obj/effect/rune(user.loc)
		if(w1 == cultwords["travel"])
			if(w2 == cultwords["self"])
				R.power = new /datum/cult/teleport(R, cultwords_reverse[w3])
			else if(w2 == cultwords["other"])
				R.power = new /datum/cult/item_port(R, cultwords_reverse[w3])
		to_chat(user, "<span class='userdanger'>You finish drawing the arcane markings of the Geometer.</span>")
		if(!R.power)
			var/type = cult_datums[cultwords_reverse[w1] + cultwords_reverse[w2] + cultwords_reverse[w3]]
			if(ispath(type))
				R.power = new type(R)
		R.desc = "[w1], [w2], [w3]" // for examine
		R.icon = get_uristrune_cult((R.power ? TRUE : FALSE), w1, w2, w3)
		R.blood_DNA = list()
		R.blood_DNA[user.dna.unique_enzymes] = user.dna.b_type


/obj/item/weapon/book/tome/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/book/tome))
		var/obj/item/weapon/book/tome/T = I
		switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
			if("Cancel")
				return
		for(var/w in words)
			words[w] = T.words[w]
		to_chat(user, "<span class='notice'>You copy the translation notes from [T].</span>")
		return
	return ..()

/obj/item/weapon/book/tome/examine(mob/user)
	..()
	if(iscultist(user))
		to_chat(user, "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of.\
		Most of these are useless, though.")

/obj/item/weapon/book/tome/imbued/atom_init()
	. = ..()
	unlocked = TRUE
	if(!cultwords["travel"])
		runerandom()
	for(var/word in cultwords)
		words[cultwords[word]] = word

/obj/item/weapon/book/tome/old
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister looking cover."
	icon = 'icons/obj/weapons.dmi'
	icon_state ="tome"
