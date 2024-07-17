// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/locked
	name = "Body Scanner"
	cases = list("медицинский сканер", "медицинского сканера", "медицинскому сканеру", "медицинский сканер", "медицинским сканером", "медицинском сканере")
	desc = "Используется для более детального анализа состояния пациента."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scanner_0"
	anchored = TRUE
	light_color = "#00ff00"
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_NOVICE)

/obj/machinery/bodyscanner/power_change()
	..()
	if(!(stat & (BROKEN|NOPOWER)))
		set_light(2)
	else
		set_light(0)

/obj/machinery/bodyscanner/relaymove(mob/user)
	if(!user.incapacitated())
		open_machine()

/obj/machinery/bodyscanner/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Body Scanner"

	if (usr.incapacitated())
		return
	if(!do_skill_checks(usr))
		return
	open_machine()
	add_fingerprint(usr)
	return

/obj/machinery/bodyscanner/verb/move_inside()
	set src in oview(1)
	set category = "Object"
	set name = "Enter Body Scanner"

	if (usr.incapacitated())
		return
	if(!move_inside_checks(usr, usr))
		return
	close_machine(usr, usr)

/obj/machinery/bodyscanner/proc/move_inside_checks(mob/target, mob/user)
	if(occupant)
		to_chat(user, "<span class='userdanger'>[C_CASE(src, NOMINATIVE_CASE)] уже занят кем-то!</span>")
		return FALSE
	if(!ishuman(target))
		to_chat(user, "<span class='userdanger'>Это устройство может сканировать только гуманоидные формы жизни.</span>")
		return FALSE
	var/mob/living/carbon/human/H = target
	if(H.species.flags[NO_MED_HEALTH_SCAN])
		to_chat(user, "<span class='userdanger'>Это существо нельзя сканировать</span>")
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='userdanger'>У пациента не должно быть чего-либо в руках.</span>")
		return FALSE
	if(!do_skill_checks(user))
		return
	return TRUE

/obj/machinery/bodyscanner/attackby(obj/item/weapon/grab/G, mob/user)
	if(!istype(G))
		return
	if(!move_inside_checks(G.affecting, user))
		return
	add_fingerprint(user)
	close_machine(G.affecting)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	qdel(G)

/obj/machinery/bodyscanner/update_icon()
	icon_state = "body_scanner_[occupant ? "1" : "0"]"

/obj/machinery/bodyscanner/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/bodyscanner/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>Вы не можете понять, что с этим делать.</span>")
		return
	if(occupant)
		eject()
		return
	var/mob/living/carbon/target = locate() in loc
	if(!target)
		return
	if(!move_inside_checks(target, user))
		return
	add_fingerprint(user)
	close_machine(target)
	playsound(src, 'sound/machines/analysis.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/bodyscanner/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
	for(var/atom/movable/A in src)
		A.forceMove(loc)
		ex_act(severity)
	qdel(src)

/obj/machinery/bodyscanner/deconstruct(disassembled)
	for(var/atom/movable/A in src)
		A.forceMove(loc)
	..()

/obj/machinery/body_scanconsole/power_change()
	if(stat & BROKEN)
		icon_state = "body_scannerconsole-p"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "body_scannerconsole-p"
			stat |= NOPOWER
			update_power_use()
	update_power_use()

/obj/machinery/body_scanconsole
	var/obj/machinery/bodyscanner/connected
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/tracking, /obj/item/weapon/implant/mind_protect/loyalty, /obj/item/weapon/implant/obedience, /obj/item/weapon/implant/skill, /obj/item/weapon/implant/blueshield, /obj/item/weapon/implant/fake_loyal, /obj/item/weapon/implant/bork)
	name = "Body Scanner Console"
	cases = list("консоль медицинского сканера", "консоли медицинского сканера", "консоли медицинского сканера", "консоль медицинского сканера", "консолью медицинского сканера", "консоли медицинского сканера")
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scannerconsole"
	anchored = TRUE
	COOLDOWN_DECLARE(next_print)
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/body_scanconsole/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/body_scanconsole/atom_init_late()
	connected = locate(/obj/machinery/bodyscanner) in orange(1, src)

/obj/machinery/body_scanconsole/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/body_scanconsole/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BodyScanner", C_CASE(src, NOMINATIVE_CASE), 690, 600)
		ui.open()

/obj/machinery/body_scanconsole/tgui_data(mob/user)
	var/list/data = list()
	var/list/occupantData = list()
	var/mob/living/carbon/human/occupant = connected.occupant

	data["occupied"] = occupant
	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth

		occupantData["hasVirus"] = occupant.virus2.len

		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()

		occupantData["radLoss"] = occupant.radiation
		occupantData["cloneLoss"] = occupant.getCloneLoss()
		occupantData["brainLoss"] = occupant.getBrainLoss()
		occupantData["drunkenness"] = (occupant.drunkenness / 6) // 600 - maximum stage
		occupantData["bodyTempC"] = occupant.bodytemperature-T0C
		occupantData["bodyTempF"] = (((occupant.bodytemperature-T0C) * 1.8) + 32)

		occupantData["hasBorer"] = !!occupant.has_brain_worms()

		var/list/bloodData = list()
		bloodData["hasBlood"] = FALSE
		if(!occupant.species.flags[NO_BLOOD])
			bloodData["hasBlood"] = TRUE
			bloodData["percent"] = round(((occupant.blood_amount() / BLOOD_VOLUME_NORMAL)*100))
			bloodData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			bloodData["bloodLevel"] = occupant.blood_amount()
			bloodData["bloodNormal"] = BLOOD_VOLUME_NORMAL
		occupantData["blood"] = bloodData

		var/list/extOrganData = list()
		for(var/obj/item/organ/external/E in occupant.bodyparts)
			var/list/organData = list()

			organData["name"] = C_CASE(E, NOMINATIVE_CASE)
			if(E.is_stump)
				organData["name"] = capitalize(parse_zone_ru(E.body_zone))

			organData["open"] = E.open
			organData["germ_level"] = get_germ_level_name(E.germ_level)
			organData["bruteLoss"] = E.brute_dam
			organData["fireLoss"] = E.burn_dam
			organData["totalLoss"] = E.brute_dam + E.burn_dam
			organData["maxHealth"] = E.max_damage
			organData["broken"] = E.min_broken_damage
			organData["stump"] = E.is_stump

			var/list/implantData = list()
			var/has_unknown_implant = FALSE
			for(var/obj/I in E.implants)
				var/list/implantSubData = list()
				implantSubData["name"] = C_CASE(I, NOMINATIVE_CASE)

				if(!is_type_in_list(I, known_implants))
					has_unknown_implant = TRUE
					implantSubData["name"] = null

				implantData.Add(list(implantSubData))

			organData["implant"] = implantData
			organData["unknown_implant"] = has_unknown_implant

			var/list/organStatus = list()
			if(E.status & ORGAN_BROKEN)
				organStatus["broken"] = capitalize(E.broken_description)
			if(E.is_robotic())
				organStatus["robotic"] = TRUE
			if(E.status & ORGAN_SPLINTED)
				organStatus["splinted"] = TRUE
			if(E.status & ORGAN_DEAD)
				organStatus["dead"] = TRUE

			organData["status"] = organStatus

			if(istype(E, /obj/item/organ/external/chest) && occupant.is_lung_ruptured())
				organData["lungRuptured"] = TRUE

			if(E.status & ORGAN_ARTERY_CUT)
				organData["internalBleeding"] = TRUE

			extOrganData.Add(list(organData))

		for(var/bp_type in occupant.get_missing_bodyparts())
			var/list/organData = list()
			var/list/organStatus = list()

			organData["name"] = capitalize(parse_zone_ru(bp_type))
			organData["missing"] = TRUE
			organData["totalLoss"] = 0

			organData["status"] = organStatus

			extOrganData.Add(list(organData))

		occupantData["extOrgan"] = extOrganData

		var/list/intOrganData = list()
		for(var/obj/item/organ/internal/I in occupant.organs)
			var/list/organData = list()
			organData["name"] = C_CASE(I, NOMINATIVE_CASE)
			organData["germ_level"] = get_germ_level_name(I.germ_level)
			organData["damage"] = I.damage
			organData["maxHealth"] = I.min_broken_damage
			organData["bruised"] = I.is_bruised()
			organData["broken"] = I.is_broken()
			organData["assisted"] = I.robotic == 1
			organData["robotic"] = I.robotic == 2
			organData["dead"] = (I.status & ORGAN_DEAD)

			intOrganData.Add(list(organData))

		occupantData["intOrgan"] = intOrganData

		occupantData["blind"] = occupant.sdisabilities & BLIND
		occupantData["nearsighted"] = HAS_TRAIT(occupant, TRAIT_NEARSIGHT)

	data["occupant"] = occupantData

	return data

/obj/machinery/body_scanconsole/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("ejectify")
			connected.eject()
		if("print_p")
			print_scan()

	return TRUE

/obj/machinery/body_scanconsole/proc/print_scan()
	if(!do_skill_checks(usr))
		return

	if(!connected || !connected.occupant)
		return

	if(!COOLDOWN_FINISHED(src, next_print)) //10 sec cooldown
		to_chat(usr, "<span class='notice'>Консоль не может печатать так быстро!</span>")
		return

	COOLDOWN_START(src, next_print, 10 SECONDS)
	playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER, 20, FALSE)

	var/obj/item/weapon/paper/P = new(loc)
	var/mob/living/carbon/human/occupant = connected.occupant
	P.info = get_scan_info()
	P.name = "Результаты сканирования [occupant.name]"
	P.update_icon()

/obj/machinery/body_scanconsole/proc/get_scan_info()
	var/dat
	var/mob/living/carbon/human/occupant = connected.occupant

	dat = "<B>Информация о пациенте:</B><BR>"
	dat += "Станционное время: <B>[worldtime2text()]</B><BR>"

	var/t1
	switch(occupant.stat)
		if(0)
			t1 = "В сознании"
		if(1)
			t1 = "Без сознания"
		else
			t1 = "<B>Мёртв</B>"
	dat += "<BR>"

	if(ischangeling(occupant) && occupant.fake_death)
		dat += ">Обнаружена аномальная биохимическая активность!<BR>"

	if(occupant.virus2.len)
		dat += "В кровотоке обнаружен вирусный патоген.<BR>"

	dat += "\tЗдоровье %: [occupant.health] ([t1])<BR>"
	dat += "\t-Механические %: [occupant.getBruteLoss()]<BR>"
	dat += "\t-Асфиксия %: [occupant.getOxyLoss()]<BR>"
	dat += "\t-Интоксикация %: [occupant.getToxLoss()]<BR>"
	dat += "\t-Термические %: [occupant.getFireLoss()]<BR><BR>"

	dat += "\tУровень облучения %: [occupant.radiation]<BR>"
	dat += "\tГенетическое повреждение тканей %: [occupant.getCloneLoss()]<BR>"
	dat += "\tПовреждение мозга %: [occupant.getBrainLoss()]<BR>"

	var/occupant_paralysis = occupant.AmountParalyzed()
	dat += "Парализован на %: [occupant_paralysis] ([round(occupant_paralysis / 4)] [PLUR_SECONDS_LEFT(round(occupant_paralysis / 4))])<BR>"

	dat += "Температура тела: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<BR><HR>"

	if(occupant.has_brain_worms())
		dat += "В лобной доле обнаружено новообразование, возможно злокачественное. Рекомендуется хирургическое вмешательство.<BR/>"

	var/blood_volume = occupant.blood_amount()
	var/blood_percent =  (blood_volume / BLOOD_VOLUME_NORMAL) * 100
	dat += "\tУровень крови %: [blood_percent] ([blood_volume] [PLUR_UNITS(blood_volume)])<BR>"

	dat += "<HR><table border='1'>"
	dat += "<tr>"
	dat += "<th>Часть тела</th>"
	dat += "<th>Термические</th>"
	dat += "<th>Механические</th>"
	dat += "<th>Другое</th>"
	dat += "</tr>"
	for(var/obj/item/organ/external/BP in occupant.bodyparts)
		dat += "<tr>"
		var/AN = ""
		var/open = ""
		var/infected = ""
		var/imp = ""
		var/bled = ""
		var/robot = ""
		var/splint = ""
		var/arterial_bleeding = ""
		var/rejecting = ""
		if(BP.status & ORGAN_ARTERY_CUT)
			arterial_bleeding = "<br><b>Артериальное кровотечение</b></br>"
		if(BP.status & ORGAN_SPLINTED)
			splint = "Наложена шина:"
		if(BP.status & ORGAN_BLEEDING)
			bled = "Кровотечение:"
		if(BP.status & ORGAN_BROKEN)
			AN = "[capitalize(BP.broken_description)]:"
		if(BP.is_robotic())
			robot = "Протез:"
		if(BP.open)
			open = "Вскрытое:"
		if(BP.is_rejecting)
			rejecting = "Генетическое отторжение:"
		if(BP.germ_level >= INFECTION_LEVEL_ONE)
			infected = "[get_germ_level_name(BP.germ_level)]:"

		var/unknown_body = 0
		for(var/I in BP.implants)
			if(is_type_in_list(I,known_implants))
				imp += "[I] имплантирован:"
			else
				unknown_body++
		if(unknown_body || BP.hidden)
			imp += "Обнаружен инородный предмет:"

		if(!AN && !open && !infected && !imp)
			AN = "Не обнаружено:"

		if(!(BP.is_stump))
			dat += "<td>[C_CASE(BP, NOMINATIVE_CASE)]</td><td>[BP.burn_dam]</td><td>[BP.brute_dam]</td><td>[robot][bled][AN][splint][open][infected][imp][arterial_bleeding][rejecting]</td>"
		else
			dat += "<td>[capitalize(parse_zone_ru(BP.body_zone))]</td><td>-</td><td>-</td><td>Отсутствует</td>"
		dat += "</tr>"

	for(var/missing_zone in occupant.get_missing_bodyparts())
		dat += "<tr>"
		dat += "<td>[capitalize(parse_zone_ru(missing_zone))]</td><td>-</td><td>-</td><td>Отсутствует</td>"
		dat += "</tr>"

	for(var/obj/item/organ/internal/IO in occupant.organs)
		var/mech = "Органическое:"
		var/organ_status = ""
		var/infection = ""
		if(IO.robotic == 1)
			mech = "Со вспомогательными средствами:" // sounds weird
		if(IO.robotic == 2)
			mech = "Механическое:"

		if(istype(IO, /obj/item/organ/internal/heart))
			var/obj/item/organ/internal/heart/Heart = IO
			if(Heart.heart_status == HEART_FAILURE)
				organ_status = "Остановка сердца:"
			else if(Heart.heart_status == HEART_FIBR)
				organ_status = "Фибрилляция сердца:"

		if(istype(IO, /obj/item/organ/internal/lungs))
			if(occupant.is_lung_ruptured())
				organ_status = "Разрыв легкого:"

		if(IO.germ_level >= INFECTION_LEVEL_ONE)
			infection = "[get_germ_level_name(IO.germ_level)]:"
		if(!organ_status && !infection)
			infection = "Не обнаружено:"

		dat += "<tr>"
		dat += "<td>[C_CASE(IO, NOMINATIVE_CASE)]</td><td>N/A</td><td>[IO.damage]</td><td>[infection][organ_status]|[mech]</td><td></td>"
		dat += "</tr>"

	dat += "</table>"

	if(occupant.sdisabilities & BLIND)
		dat += "Обнаружена катаракта.<BR>"
	if(HAS_TRAIT(occupant, TRAIT_NEARSIGHT))
		dat += "Обнаружено смещение сетчатки.<BR>"

	return dat
