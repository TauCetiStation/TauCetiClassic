/proc/tgui_alert(mob/user, message = null, title = null, list/buttons = list("Ok"), timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (isclient(user))
			var/client/client = user
			user = client.mob
		else
			return
	var/datum/tgui_modal/alert = new(user, message, title, buttons, timeout)
	alert.tgui_interact(user)
	alert.wait()
	if (alert)
		. = alert.choice
		qdel(alert)

/**
 * Creates an asynchronous TGUI alert window with an associated callback.
 *
 * This proc should be used to create alerts that invoke a callback with the user's chosen option.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * callback - The callback to be invoked when a choice is made.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Disabled by default, can be set to seconds otherwise.
 */
/proc/tgui_alert_async(mob/user, message = null, title = null, list/buttons = list("Ok"), datum/callback/callback, timeout = 0)
	if (!user)
		user = usr
	if (!istype(user))
		if (!isclient(user))
			return
		var/client/client = user
		user = client.mob

	var/datum/tgui_modal/async/alert = new(user, message, title, buttons, callback, timeout)
	alert.tgui_interact(user)

/**
 * # tgui_modal
 *
 * Datum used for instantiating and using a TGUI-controlled modal that prompts the user with
 * a message and has buttons for responses.
 */
/datum/tgui_modal
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of buttons (responses) provided on the TGUI window
	var/list/buttons
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The time at which the tgui_modal was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_modal, after which the window will close and delete itself.
	var/timeout
	/// Boolean field describing if the tgui_modal was closed by the user.
	var/closed

/datum/tgui_modal/New(mob/user, message, title, list/buttons, timeout)
	src.title = title
	src.message = message
	src.buttons = buttons.Copy()
	if (timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_modal/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/**
 * Waits for a user's response to the tgui_modal's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_modal/proc/wait()
	while (!choice && !closed)
		stoplag(1)

/datum/tgui_modal/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertModal")
		ui.open()

/datum/tgui_modal/tgui_close(mob/user)
	. = ..()
	closed = TRUE

/datum/tgui_modal/tgui_state(mob/user)
	return global.always_state

/datum/tgui_modal/tgui_data(mob/user)
	. = list(
		"title" = title,
		"message" = message,
		"buttons" = buttons
	)
	if(timeout)
		.["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))

/datum/tgui_modal/tgui_act(action, list/params)
	. = ..()
	if (.)
		return
	switch(action)
		if("choose")
			if (!(params["choice"] in buttons))
				return
			choice = params["choice"]
			SStgui.close_uis(src)
			return TRUE

/**
 * # async tgui_modal
 *
 * An asynchronous version of tgui_modal to be used with callbacks instead of waiting on user responses.
 */
/datum/tgui_modal/async
	/// The callback to be invoked by the tgui_modal upon having a choice made.
	var/datum/callback/callback

/datum/tgui_modal/async/New(mob/user, message, title, list/buttons, callback, timeout)
	..(user, title, message, buttons, timeout)
	src.callback = callback

/datum/tgui_modal/async/Destroy(force, ...)
	QDEL_NULL(callback)
	. = ..()

/datum/tgui_modal/async/tgui_close(mob/user)
	. = ..()
	qdel(src)

/datum/tgui_modal/async/tgui_act(action, list/params)
	. = ..()
	if (!. || choice == null)
		return
	callback.InvokeAsync(choice)
	qdel(src)

/datum/tgui_modal/async/wait()
	return

 //A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE)

/* Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
 category is a text string. Each mob may only have one alert per category; the previous one will be replaced
 path is a type path of the actual alert type to throw
 severity is an optional number that will be placed at the end of the icon_state for this alert
 For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 Clicks are forwarded to master
 Override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 */

	if(!category || QDELETED(src))
		return

	var/atom/movable/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return 0
		if(new_master && new_master != thealert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [thealert.master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(thealert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
	thealert.mob_viewer = src

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		thealert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		thealert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		thealert.master = new_master
	else
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	thealert.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(thealert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	if(thealert.timeout)
		addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(atom/movable/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = alerts[category]
	if(!alert)
		return FALSE
	if(alert.override_alerts && !clear_override)
		return FALSE

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)
	return TRUE

/atom/movable/screen/alert
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "default"
	name = "Тревога"
	desc = "Похоже, что-то пошло не так с этим предупреждением, поэтому, пожалуйста, сообщите об этой ошибке"
	mouse_opacity = MOUSE_OPACITY_ICON

	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/mob_viewer //the mob viewing this alert

/atom/movable/screen/alert/Destroy()
	. = ..()
	severity = 0
	mob_viewer = null
	screen_loc = ""

/mob
	var/list/alerts = list() // contains /atom/movable/screen/alert only // On /mob so clientless mobs will throw alerts properly

/atom/movable/screen/alert/Click(location, control, params)
	if(!usr || !usr.client)
		return
	var/paramslist = params2list(params)
	if(paramslist[SHIFT_CLICK]) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>")
		return
	if(master)
		return usr.client.Click(master, location, control, params)

/atom/movable/screen/alert/MouseEntered(location, control, params)
	if(!QDELETED(src))
		openToolTip(usr, src, params, title = name, content = desc, theme = alerttooltipstyle)

/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)

//Gas alerts
/atom/movable/screen/alert/oxy
	name = "Удушение"
	desc = "По каким-то причинам, вы не можете дышать! Выйдите на свежий воздух, пока не потеряли сознание! В вашем рюкзаке есть коробка с кислородным баллоном и маской."
	icon_state = "oxy"

/atom/movable/screen/alert/tox_in_air
	name = "Токсичный газ"
	desc = "В воздухе витает легковоспламеняющийся, токсичный форон, и вы дышите им. Выйдите на свежий воздух."
	icon_state = "tox_in_air"
//End gas alerts


/atom/movable/screen/alert/hot
	name = "Слишком жарко"
	desc = "Вам жарко. Найдите прохладное место."
	icon_state = "hot"

/atom/movable/screen/alert/cold
	name = "Слишком холодно"
	desc = "Вам холодно. Найдите тёплое место."
	icon_state = "cold"

/atom/movable/screen/alert/lowpressure
	name = "Низкое давление"
	desc = "Вокруг вас опасный уровень давления атмосферы. Скафандр бы вас защитил."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "Высокое давление"
	desc = "Вокруг вас опасный уровень давления атмосферы. Скафандр бы вас защитил."
	icon_state = "highpressure"

/atom/movable/screen/alert/blind
	name = "Слепота"
	desc = "По какой-то причине вы не можете видеть. Это может быть вызвано генетическим дефектом, травмой глаз, потерей сознания, \
			ну или что-то закрывает ваши глаза."
	icon_state = "blind"

/atom/movable/screen/alert/high
	name = "Кайф"
	desc = "Воу, чувак, ты просто балдеешь! Осторожней, ты можешь стать зависимым... если не уже..."
	icon_state = "high"

/atom/movable/screen/alert/drunk/slur
	name = "Опьянение"
	desc = "Ик! Ой... Да ФсЕ хоРошО! НеМНого МоЖно..."
	icon_state = "drunk_slur"

/atom/movable/screen/alert/drunk/confused
	name = "Опьянение"
	desc = "ЛаДНО, можИт НемНОгО..."
	icon_state = "drunk_confused"

/atom/movable/screen/alert/drunk/blur
	name = "Опьянение"
	desc = "ЗаВТра ТочнО бРОшу ПиТЬ!"
	icon_state = "drunk_blur"

/atom/movable/screen/alert/drunk/pass_out
	name = "АпЬйаНЕнИе"
	desc = "ПУШКА!!! КАК ЖЕ НАВОДИТ ПОРЧУУУЭЭЭЭЭ-"
	icon_state = "drunk_pass_out"

/atom/movable/screen/alert/embeddedobject
	name = "Застрявший предмет"
	desc = "Что-то застряло в вашей плоти и вызывает сильную боль. Стоит попросить оказать медицинскую помощь. \
			Если это вам сильно мешает, то нажмите по себе правой кнопкой мыши и выберите 'Вытащить предмет' (yank object)."
	icon_state = "embeddedobject"

/atom/movable/screen/alert/weightless
	name = "Невесомость"
	desc = "Гравитация перестала воздействовать на вас, и вы бесцельно плаваете вокруг. Вам понадобится что-нибудь большое и тяжелое, например \
			стена или решетчатая конструкция, чтобы можно было оттолкнуться и двигаться куда надо. Реактивный ранец обеспечил бы свободу передвижения. \
			Магнитные сапоги позволят вам нормально передвигаться по полу. Если их нет, вы можете бросать предметы, пользоваться огнетушителем, \
			или стрелять из пистолета, чтобы передвигаться в соответствии с 3-м законом Ньютона."
	icon_state = "weightless"

//ALIENS

/atom/movable/screen/alert/alien_tox
	name = "Плазма"
	desc = "В воздухе витает горючая плазма. Если она загорится, вы будете поджарены."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Возгарание"
	desc = "Горячо! Бегите подальше от огня! Полежите на вашей траве, чтобы немного исцелиться."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_embryo
	name = "Медленное развитие эмбриона"
	desc = "Носитель не находится в гнезде. Ваша скорость развития снижена."
	icon_state = "alien_embryo"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_queen
	name = "Низкая скорость роста"
	desc = "Королева вне зоны видимости. Ваша скорость роста снижена."
	icon_state = "alien_queen"
	alerttooltipstyle = "alien"

//BLOBS
/atom/movable/screen/alert/nofactory
	name = "Нет фабрики"
	desc = "У вас нет фабрики и вы медленно умираете!"
	icon_state = "blobbernaut"

//changeling
/atom/movable/screen/alert/regen_stasis
	name = "Регенеративный стазис"
	desc = "Вы вошли в стазис. Просто подождите немного."
	icon_state = "regen_stasis"

//IANS
/atom/movable/screen/alert/ian_oxy
	name = "Удушение"
	desc = "Вам не хватает кислорода."
	icon_state = "ian_oxy"

/atom/movable/screen/alert/ian_tox
	name = "Газ"
	desc = "В воздухе есть газ, и вы вдыхаете его."
	icon_state = "ian_tox"

/atom/movable/screen/alert/ian_hot
	name = "Слишком жарко"
	desc = "Вам жарко. Найдите способ остудиться."
	icon_state = "ian_hot"

/atom/movable/screen/alert/ian_cold
	name = "Слишком холодно"
	desc = "Вам холодно. Найдите способ согреться."
	icon_state = "ian_cold"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Нет батареи"
	desc = "У юнита отсутствует батарея. Модули недоступны до тех пор, пока батарея не будет установлена. Робототехники могут оказать вам помощь."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell
	name = "Севшая батарея"
	desc = "В батарее юнита не осталось заряда. Модули недоступны до тех пор, пока элемент питания не будет заряжен. \
			Станции подзарядки имеются в робототехнике, в туалетах дормиторий, на станции подзарядки киборгов и на спутнике ИИ."
	icon_state = "emptycell"

/atom/movable/screen/alert/lowcell
	name = "Низкий заряд"
	desc = "Батарея скоро сядет. Станции подзарядки имеются в робототехнике, в туалетах дормиторий, на станции подзарядки киборгов и на спутнике ИИ."
	icon_state = "lowcell"

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Взломан"
	desc = "Обнаружено нестандартизированное опасное оборудование. Пожалуйста, убедитесь, что любое использование этого оборудования разрешается вашим набором законов."
	icon_state = "hacked"

/atom/movable/screen/alert/not_locked
	name = "Интерфейс разблокирован"
	desc = "Интерфейс взаимодействия с юнитом разблокирован. Кто-то случайно или намеренно оставил его открытым. Робототехник может оказать помощь."
	icon_state = "not_locked"

/atom/movable/screen/alert/locked
	name = "Заблокирован"
	desc = "Юнит удаленно заблокирован. Этот вопрос может быть решен с помощью компьютера для управления робототехникой, \
			подобного тому, который находится в кабинете директора научного отдела, вашим Мастером или любым специалистом. \
			Стоит разобраться по какой причине это произошло. При необходимости робототехник окажет дополнительную помощь."
	icon_state = "locked"

/atom/movable/screen/alert/newlaw
	name = "Обновление законов"
	desc = "Набор ваших законов был обновлён. Стоит проверить его, чтобы не нарушить их случайно."
	icon_state = "newlaw"
	timeout = 300

/atom/movable/screen/alert/swarm_hunger
	name = "Голод роя"
	desc = "Эта реальность не может выдержать вашего присутствия... Вы должны потреблять, чтобы жить."
	icon_state = "swarm_hunger"

/atom/movable/screen/alert/swarm_upgrade
	name = "Обновление массива"
	desc = "Доступно обновление массива данных. Осмотрите себя, чтобы увидеть возможные обновления."
	icon_state = "swarm_upgrade"

/atom/movable/screen/alert/swarm_upgrade/Click()
	if(!mob_viewer)
		return
	if(mob_viewer.incapacitated())
		return
	if(!mob_viewer.mind)
		return
	if(!isreplicator(mob_viewer))
		return
	var/mob/living/simple_animal/hostile/replicator/R = mob_viewer
	R.acquire_array_upgrade()

//OBJECT-BASED

/atom/movable/screen/alert/buckled
	name = "Пристёгнут"
	desc = "Вы пристёгнуты к чему-то и не можете двинуться. \
			Нажмите на предупреждение, чтобы отстегнуться, если на вас не надеты наручники."
	icon_state = "buckled"

/atom/movable/screen/alert/buckled/Click()
	if(!mob_viewer)
		return
	if(mob_viewer.restrained())
		to_chat(mob_viewer, "Вы в наручниках! Сначала разберитесь с ними!")
		return
	if(mob_viewer.incapacitated() || mob_viewer.crawling || mob_viewer.is_busy())
		return
	master.user_unbuckle_mob(mob_viewer)

/atom/movable/screen/alert/brake
	name = "Тормоз включён"
	desc = "Тормоз инвалидной коляски включен, так что вы не можете двигуться."
	icon_state = "brake"

/atom/movable/screen/alert/handcuffed
	name = "В наручниках"
	desc = "На вас надеты наручники, и вы не можете пользоваться своими руками. Если кто-то потащит вас, вы не сможете двинуться. \
			Нажмите на кнопку Сопротивления (Resist), чтобы попытаться выбраться из них."
	icon_state = "handcuff"

/atom/movable/screen/alert/legcuffed
	name = "Скованные ноги"
	desc = "Ваши ноги скованы. Что-то мешает вам свободно ходить. \
			Нажмите на кнопку Сопротивления (Resist), чтобы попытаться убрать ловушку из ног."
	icon_state = "legcuff"

/atom/movable/screen/alert/stunned
	name = "Оглушение"
	desc = "Что-то или кто-то оглушило вас. Вы не можете даже пошевелиться."
	icon_state = "stun"

/atom/movable/screen/alert/paralysis
	name = "Паралич"
	desc = "Вы не чувствуете своего тела."
	icon_state = "paralysis"

/atom/movable/screen/alert/weaken
	name = "Слабость"
	desc = "Вы не можете стоять на ногах."
	icon_state = "weaken"

/atom/movable/screen/alert/notify_action
	name = "Созданное тело"
	desc = "Было создано тело. Вы можете войти в него."
	icon_state = "template"
	timeout = 300
	var/atom/target = null
	var/action = NOTIFY_JUMP

/atom/movable/screen/alert/notify_action/Click()
	. = ..()
	if(!target)
		return
	var/mob/dead/observer/ghost_owner = mob_viewer
	if(!istype(ghost_owner))
		return
	switch(action)
		if(NOTIFY_ATTACK)
			target.attack_ghost(ghost_owner)
		if(NOTIFY_JUMP)
			var/turf/target_turf = get_turf(target)
			if(target_turf && isturf(target_turf))
				ghost_owner.abstract_move(target_turf)
		if(NOTIFY_ORBIT)
			ghost_owner.ManualFollow(target)

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts()
	var/list/alerts = mymob.alerts
	if(!hud_shown)
		for(var/i = 1, i <= alerts.len, i++)
			mymob.client.screen -= alerts[alerts[i]]
		return TRUE
	for(var/i = 1, i <= alerts.len, i++)
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			if(ui_style)
				alert.icon = ui_style
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		mymob.client.screen |= alert
	return TRUE
