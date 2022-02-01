/datum/role/vox_raider
	name = VOXRAIDER
	id = VOXRAIDER
	required_pref = ROLE_RAIDER
	disallow_job = TRUE

	logo_state = "raider-logo"
	skills_type = /datum/skills/traitor

/datum/role/vox_raider/Greet(greeting, custom)
	. = ..()

	to_chat(antag.current, "<span class='notice'><B>You are a Vox Raider, fresh from the Shoal!</b></span>")
	to_chat(antag.current, "<span class='notice'>The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to [system_name()] and much of the unexplored galaxy. You and the crew have come to the Exodus for plunder, trade or both.</span>")
	to_chat(antag.current, "<span class='notice'>Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.</span>")
	to_chat(antag.current, "<span class='notice'>Use :V to voxtalk, :H to talk on your encrypted channel, and don't forget to turn on your nitrogen internals!</span>")
	if(config && config.wikiurl)
		to_chat(antag.current, "<span class='warning'>IF YOU HAVE NOT PLAYED A VOX BEFORE, REVIEW THIS THREAD: [config.wikiurl]/Vox_Raider</span>")

	var/wikilink = ""

	if(config && config.wikiurl)
		wikilink = "<font color='red'>Крайне рекомендуется ознакомиться вот с этой статьей или найти аналог - [config.wikiurl]/Vox_Raider</font><BR>"

	var/output_text = {"<font color='red'>============Ограбление - краткий курс============</font><BR>[wikilink]
	[sanitize("- Запомните! Воксы никогда не бросают своих! Скорее пойдут на верную гибель вызволяя собрата. К примеру: начали миссию в 4-ом, значит в 4-ом и должны закончить, живыми или мертвыми (даже тела нужно забрать, если остались)!")]<BR>
	[sanitize("- Вы - не пираты (режим). Вам не надо тащить все что не прибито к полу, старайтесь придерживаться ваших целей. Чем дольше вы задержитесь в раунде, тем выше шансы того, что кто-нибудь из вас вляпается в неприятности. Но если решите забить на цели и устроить чай, дело ваше (но только если вы решили это командой, а не кто-то один очень умный, ну и на всякий случай согласуйте \"чай\" с администрацией, в остальных случаях идите просто по заданиям).")]<BR>
	[sanitize("- Могут ли воксы убивать? Могут. Однако они никогда не будут это делать специально и целенаправленно, выкашивая всех на своем пути. Все боевые действия должны быть сведены к минимуму, желательно не у всех на глазах и только для защиты своей команды, не больше и не меньше. Если враг перед вами не представляет никакой опасности и даже скорее хочет убежать с ваших глаз - вероятно стоит проигнорировать, однако в плен взять вам никто не запрещает, и если уж калечить, то так, чтобы это не кончилось летальным исходом. Но помните о последствиях к которым могут привести те или иные действия.")]<BR>
	<font color='red'>============Прочие полезности============</font><BR>
	[sanitize("- Вероятно не все воксы говорят на Соле, но все его понимают. Код для языка :1 - а умение говорить можно посмотреть в \"IC > check known languages\"")]<BR>
	[sanitize("- cloaking field terminal консоль позволит вам выбрать между тихим прилетом - когда не будет никакого глобального объявления и маскировкой под торговое судно. Выбор за вами.")]<BR>
	[sanitize("- Шипометы (spike thrower) имеют бесконечный заряд, однако восполнение \"шипов\" происходит раз в 10 секунд и как любое оружие такого типа - способно откинуть космонавта на 5 квадратов и даже пристрелить к бочке, двери, стене что как минимум обездвижит вашу цель пока она не вытащит застрявший шип.")]<BR>
	[sanitize("- В левом крыле вы найдете два хактула \"debugger\". С помощью них можно \"емагать\" двери и apc. Учтите, что двери после этого перестают работать и их невозможно будет закрыть (опасайтесь разгерметизаций которые могут в связи с этими действиями возникнуть).")]<BR>
	[sanitize("- Два человеческих космических скафандра и баллоны с кислородом которые вы найдете у себя на корабле, в первую очередь предназначены для более удобного выполнения задания на похищение человека (они должны без проблем помещаться в сумку), а уж потом как средство торговли (на случай дипломатического подхода).")]<BR>
	[sanitize("- Черные стелс-съюты имеют функцию стелса (дает серьезную невидимость), однако зоркий глаз может вас заметить в движении. Ко всему прочему стелс перестает работать если риг серьезно поврежден.")]<BR>
	[sanitize("- У вас есть способность \"Leap\" и вы можете использовать ее даже для решения проблем с мобильностью когда рядом нет врагов. При столкновении с человеком, вы повалите его с ног и сразу возьмете в агрессивный \"граб\". Помните о перезарядке равной 10-ти секундам и старайтесь не прыгать на плотные объекты, стены или людей у которых в руках щит, а еще про дальность в 4 квадрата.")]<BR>
	[sanitize("- Избегайте боевых действий в открытом космосе не имея для этого спец. средств (например джетпака). Ваше преимущество земля и пристреленные враги к стенам (если нет другого оружия), а способность \"Leap\" может резко поменять ход боя.")]<BR>
	[sanitize("- И последнее - старайтесь играть командой, не соло! Если вам все воксы кричат чтобы вы возвращались на корабль - вероятно стоит бросить текущие дела и прислушаться к команде.")]<BR>
	"}

	var/datum/browser/popup = new(antag.current, "window=vxrd", nwidth = 600, nheight = 300)
	popup.set_content(output_text)
	popup.open()

/datum/role/vox_raider/OnPostSetup(laterole)
	. = ..()

	var/sounds = rand(2, 8)
	var/i = 0
	var/newname = ""

	while(i <= sounds)
		i++
		newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah"))

	var/mob/living/carbon/human/vox = antag.current

	vox.real_name = capitalize(newname)
	vox.name = vox.real_name
	antag.name = vox.name
	vox.age = rand(5, 15) // its fucking lore
	vox.dna.mutantrace = "vox"
	vox.set_species(VOX)
	vox.languages = list() // Removing language from chargen.
	vox.flavor_text = ""
	vox.add_language("Vox-pidgin")
	if(faction.members.len % 2 == 0 || prob(33)) // first vox always gets Sol, everyone else by random.
		vox.add_language("Sol Common")
	vox.h_style = "Short Vox Quills"
	vox.f_style = "Shaved"
	vox.grad_style = "none"
	for(var/obj/item/organ/external/BP in vox.bodyparts)
		BP.status = 0 // rejuvenate() saves prostethic limbs, so we tell it NO.
		BP.rejuvenate()

	//Now apply cortical stack.
	var/obj/item/organ/external/BP = vox.bodyparts_by_name[BP_HEAD]

	var/obj/item/weapon/implant/cortical/I = new(vox)
	I.imp_in = vox
	I.implanted = TRUE
	BP.implants += I
	vox.sec_hud_set_implants()
	I.part = BP

	vox.equip_vox_raider()
	vox.regenerate_icons()
