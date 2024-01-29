/obj/item/device/healthanalyzer
	name = "Health Analyzer"
	cases = list("анализатор здоровья", "анализатора здоровья", "анализатору здоровья", "анализатор здоровья", "анализатором здоровья", "анализаторе здоровья")
	icon_state = "health"
	item_state = "healthanalyzer"
	desc = "Способен просканировать жизненные показатели пациента."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = SIZE_TINY
	throw_speed = 4
	throw_range = 10
	m_amt = 200
	origin_tech = "magnets=1;biotech=1"
	var/mode = TRUE
	var/output_to_chat = TRUE
	var/last_scan = ""
	var/last_scan_name = ""
	var/scan_hallucination = FALSE
	var/advanced = FALSE

/obj/item/device/healthanalyzer/attack(mob/living/M, mob/living/user)
	add_fingerprint(user)
	if(!ishuman(M))
		to_chat(user, "<span class = 'warning'>Результаты анализа не завершены. Обнаружена неизвестная анатомия.</span>")
		return
	var/mob/living/carbon/human/H = M
	if(H.species.flags[NO_MED_HEALTH_SCAN])
		to_chat(user, "<span class='userdanger'>Это существо нельзя сканировать</span>")
		return
	if(H.species.flags[IS_SYNTHETIC] || H.species.flags[IS_PLANT])
		var/message = ""
		message += "<span class = 'notice'>Результаты сканирования: ОШИБКА\n&emsp; Общее состояние: ОШИБКА</span><br>"
		message += "&emsp; Key: <font color='blue'>Асфиксия</font>/<font color='green'>Интоксикация</font>/<font color='#FFA500'>Термические</font>/<font color='red'>Механические</font><br>"
		message += "&emsp; Специфика повреждений: <font color='blue'>?</font> - <font color='green'>?</font> - <font color='#FFA500'>?</font> - <font color='red'>?</font><br>"
		message += "<span class = 'notice'>Температура тела: [H.bodytemperature-T0C]&deg;C ([H.bodytemperature*1.8-459.67]&deg;F)</span><br>"
		message += "<span class = 'warning bold'>Внимание: Уровень крови ОШИБКА: --% --сл.</span> <span class = 'notice bold'>Группа крови: ОШИБКА</span><br>"
		message += "<span class = 'notice'>Пульс пациента:</span><font color='red'>-- уд/мин.</font><br>"

		last_scan = message
		last_scan_name = M.name
		if(output_to_chat)
			to_chat(user, message)
			return
		var/datum/browser/popup = new(user, "[M.name]_scan_report", "Результаты сканирования [M.name]", 400, 400, ntheme = CSS_THEME_LIGHT)
		popup.set_content(message)
		popup.open()
		return
	var/dat = health_analyze(M, user, mode, output_to_chat, null, scan_hallucination, advanced)
	last_scan = dat
	last_scan_name = M.name
	if(output_to_chat)
		to_chat(user, dat)
		return
	var/datum/browser/popup = new(user, "[M.name]_scan_report", "Результаты сканирования [M.name]", 400, 400, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/item/device/healthanalyzer/examine(mob/user)
	. = ..()
	if(advanced)
		to_chat(user, "[capitalize(CASE(src, NOMINATIVE_CASE))] имеет модуль анализатора реагентов и может показывать находящиеся в пациенте реагенты!")
	else
		to_chat(user, "[capitalize(CASE(src, NOMINATIVE_CASE))] может быть улучшен с помощью анализатора реагентов!")

/obj/item/device/healthanalyzer/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/device/mass_spectrometer) && !advanced)
		advanced = TRUE
		icon_state = "health_adv"
		to_chat(user, "Вы подсоединяете анализатор реагентов в пазы [CASE(src, GENITIVE_CASE)].")
		qdel(I)

/obj/item/device/healthanalyzer/attack_self(mob/user)
	var/datum/browser/popup = new(user, "[last_scan_name]_scan_report", "Результаты сканирования [last_scan_name]", 400, 400, ntheme = CSS_THEME_LIGHT)
	popup.set_content(last_scan)
	popup.open()

/obj/item/device/healthanalyzer/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "Теперь сканер выводит данные в чат.")
	else
		to_chat(usr, "Теперь сканер выводит данные в отдельном окне.")

/obj/item/device/healthanalyzer/verb/toggle_mode()
	set name = "Switch Verbosity"
	set category = "Object"

	mode = !mode
	if(mode)
		to_chat(usr, "Сканер теперь показывает конкретные повреждения конечностей.")
	else
		to_chat(usr, "Сканер больше не показывает повреждения конечностей.")

/obj/item/device/healthanalyzer/rad_laser
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;biotech=5;syndicate=3"
	var/irradiate = 1
	var/intensity = 10 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?

/obj/item/device/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	..()
	if(!irradiate)
		return
	if(!used)
		var/cooldown = round(max(10, (intensity*5 - wavelength/4))) * 10
		used = 1
		icon_state = "health1"
		spawn(cooldown) // splits off to handle the cooldown while handling wavelength
			used = 0
			icon_state = "health"
		to_chat(user,"<span class='warning'>Успешное облучение [M].</span>")
		M.log_combat(user, "irradiated with [name]")
		spawn((wavelength+(intensity*4))*5)
			if(M)
				if(intensity >= 5)
					M.apply_effect(round(intensity/1.5), PARALYZE)
				irradiate_one_mob(M, intensity * 10)
	else
		to_chat(user,"<span class='warning'>Радиоактивный микролазер все еще перезаряжается.</span>")

/obj/item/device/healthanalyzer/rad_laser/attack_self(mob/user)
	interact(user)

/obj/item/device/healthanalyzer/rad_laser/interact(mob/user)
	user.set_machine(src)
	var/cooldown = round(max(10, (intensity*5 - wavelength/4)))
	var/dat = "Облучение: <A href='?src=\ref[src];rad=1'>[irradiate ? "Вкл" : "Выкл"]</A><br>"

	dat += {"
	Интенсивность излучения:
	<A href='?src=\ref[src];radint=-5'>-</A><A href='?src=\ref[src];radint=-1'>-</A>
	[intensity]
	<A href='?src=\ref[src];radint=1'>+</A><A href='?src=\ref[src];radint=5'>+</A><BR>

	Длина волны излучения:
	<A href='?src=\ref[src];radwav=-5'>-</A><A href='?src=\ref[src];radwav=-1'>-</A>
	[(wavelength+(intensity*4))]
	<A href='?src=\ref[src];radwav=1'>+</A><A href='?src=\ref[src];radwav=5'>+</A><BR>
	Перезарядка лазера: [cooldown] секунд<BR>
	"}

	var/datum/browser/popup = new(user, "radlaser", "Radioactive Microlaser Interface", 400, 240)
	popup.set_content(dat)
	popup.open()

/obj/item/device/healthanalyzer/rad_laser/Topic(href, href_list)

	usr.set_machine(src)
	if(href_list["rad"])
		irradiate = !irradiate

	else if(href_list["radint"])
		var/amount = text2num(href_list["radint"])
		amount += intensity
		intensity = max(1,(min(20,amount)))

	else if(href_list["radwav"])
		var/amount = text2num(href_list["radwav"])
		amount += wavelength
		wavelength = max(0,(min(120,amount)))

	attack_self(usr)
	add_fingerprint(usr)
	return

/obj/item/device/healthanalyzer/psychology
	name = "Health and Mental Analyzer"
	cases = list("анализатор здоровья и психики", "анализатора здоровья и психики", "анализатору здоровья и психики", "анализатор здоровья психики", "анализатором здоровья и психики", "анализаторе здоровья и психики")
	desc = "Анализатор здоровья и психики, способный просканировать жизненные и психические показатели пациента."
	scan_hallucination = TRUE
