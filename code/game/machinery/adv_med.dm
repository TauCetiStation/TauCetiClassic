// Pretty much everything here is stolen from the dna scanner FYI


/obj/machinery/bodyscanner
	var/locked
	name = "Body Scanner"
	cases = list("МРТ сканер", "МРТ сканера", "МРТ сканеру", "МРТ сканер", "МРТ сканером", "МРТ сканере")
	desc = "Используется для более детального анализа состояния пациента."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scanner_0"
	density = TRUE
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
		to_chat(user, "<span class='userdanger'>[capitalize(CASE(src, NOMINATIVE_CASE))] уже занят кем-то!</span>")
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(ishuman(target))
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
		open_machine()
		add_fingerprint(user)
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
	var/known_implants = list(/obj/item/weapon/implant/chem, /obj/item/weapon/implant/death_alarm, /obj/item/weapon/implant/mind_protect/mindshield, /obj/item/weapon/implant/tracking, /obj/item/weapon/implant/mind_protect/loyalty, /obj/item/weapon/implant/obedience, /obj/item/weapon/implant/skill, /obj/item/weapon/implant/blueshield, /obj/item/weapon/implant/fake_loyal)
	var/delete
	name = "Body Scanner Console"
	cases = list("консоль МРТ сканера", "консоли МРТ сканера", "консоли МРТ сканера", "консоль МРТ сканера", "консолью МРТ сканера", "консоли МРТ сканера")
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "body_scannerconsole"
	anchored = TRUE
	var/next_print = 0
	var/storedinfo = null
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_TRAINED)

/obj/machinery/body_scanconsole/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/body_scanconsole/atom_init_late()
	connected = locate(/obj/machinery/bodyscanner) in orange(1, src)

/obj/machinery/body_scanconsole/ui_interact(mob/user)
	if(!ishuman(connected.occupant))
		to_chat(user, "<span class='warning'>Это устройство может сканировать только гуманоидные формы жизни.</span>")
		return
	if(!do_skill_checks(user))
		return
	var/dat

	if (src.connected) //Is something connected?
		var/mob/living/carbon/human/occupant = src.connected.occupant
		dat = "<font color='blue'><B>Информация о пациенте:</B></FONT><BR>" //Blah obvious
		if (istype(occupant)) //is there REALLY someone in there?
			var/t1
			switch(occupant.stat) // obvious, see what their status is
				if(0)
					t1 = "В сознании"
				if(1)
					t1 = "Без сознания"
				else
					t1 = "*Мёртв*"
			if (!ishuman(occupant))
				dat += "<font color='red'>Это устройство может сканировать только гуманоидных существ.</font>"
			else
				dat += text("<font color='[]'>\tЗдоровье %: [] ([])</font><BR>", (occupant.health > 50 ? "blue" : "red"), occupant.health, t1)

				if(ischangeling(occupant) && occupant.fake_death)
					dat += text("<font color='red'>Обнаружена аномальная биохимическая активность!</font><BR>")

				if(occupant.virus2.len)
					dat += text("<font color='red'>В кровотоке обнаружен вирусный патоген.</font><BR>")

				dat += text("<font color='[]'>\t-Механические %: []</font><BR>", (occupant.getBruteLoss() < 60 ? "blue" : "red"), occupant.getBruteLoss())
				dat += text("<font color='[]'>\t-Асфиксия %: []</font><BR>", (occupant.getOxyLoss() < 60 ? "blue" : "red"), occupant.getOxyLoss())
				dat += text("<font color='[]'>\t-Интоксикация %: []</font><BR>", (occupant.getToxLoss() < 60 ? "blue" : "red"), occupant.getToxLoss())
				dat += text("<font color='[]'>\t-Термические %: []</font><BR><BR>", (occupant.getFireLoss() < 60 ? "blue" : "red"), occupant.getFireLoss())

				dat += text("<font color='[]'>\tУровень облучения %: []</font><BR>", (occupant.radiation < 10 ?"blue" : "red"), occupant.radiation)
				dat += text("<font color='[]'>\tГенетическое повреждение тканей %: []</font><BR>", (occupant.getCloneLoss() < 1 ?"blue" : "red"), occupant.getCloneLoss())
				dat += text("<font color='[]'>\tПовреждение мозга %: []</font><BR>", (occupant.getBrainLoss() < 1 ?"blue" : "red"), occupant.getBrainLoss())
				var/occupant_paralysis = occupant.AmountParalyzed()
				dat += text("Парализован на %: [] (осталось [] секунд)<BR>", occupant_paralysis, round(occupant_paralysis / 4))
				dat += text("Температура тела: [occupant.bodytemperature-T0C]&deg;C ([occupant.bodytemperature*1.8-459.67]&deg;F)<BR><HR>")

				if(occupant.has_brain_worms())
					dat += "В лобной доле обнаружено новообразование, возможно злокачественное. Рекомендуется хирургическое вмешательство.<BR/>"

				var/blood_volume = occupant.blood_amount()
				var/blood_percent =  100.0 * blood_volume / BLOOD_VOLUME_NORMAL
				dat += text("<font color='[]'>\tУровень крови %: [] ([] юнитов)</font><BR>", (blood_volume >= BLOOD_VOLUME_SAFE ? "blue" : "red"), blood_percent, blood_volume)

				if(occupant.reagents)
					dat += text("Inaprovaline units: [] юнитов<BR>", occupant.reagents.get_reagent_amount("inaprovaline"))
					dat += text("Soporific (Sleep Toxin): [] юнитов<BR>", occupant.reagents.get_reagent_amount("stoxin"))
					dat += text("<font color='[]'>\tDermaline: [] юнитов</font><BR>", (occupant.reagents.get_reagent_amount("dermaline") < 30 ? "black" : "red"), occupant.reagents.get_reagent_amount("dermaline"))
					dat += text("<font color='[]'>\tBicaridine: [] юнитов</font><BR>", (occupant.reagents.get_reagent_amount("bicaridine") < 30 ? "black" : "red"), occupant.reagents.get_reagent_amount("bicaridine"))
					dat += text("<font color='[]'>\tDexalin: [] юнитов</font><BR>", (occupant.reagents.get_reagent_amount("dexalin") < 30 ? "black" : "red"), occupant.reagents.get_reagent_amount("dexalin"))

				dat += "<HR><A href='?src=\ref[src];print=1'>Распечатать отчет о состояние пациента</A><BR>"
				storedinfo = null
				dat += "<HR><table border='1'>"
				dat += "<tr>"
				dat += "<th>Часть тела</th>"
				dat += "<th>Термические</th>"
				dat += "<th>Механические</th>"
				dat += "<th>Другое</th>"
				dat += "</tr>"
				storedinfo += "<HR><table border='1'>"
				storedinfo += "<tr>"
				storedinfo += "<th>Часть тела</th>"
				storedinfo += "<th>Термические</th>"
				storedinfo += "<th>Механические</th>"
				storedinfo += "<th>Другое</th>"
				storedinfo += "</tr>"

				for(var/obj/item/organ/external/BP in occupant.bodyparts)

					dat += "<tr>"
					storedinfo += "<tr>"
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
						arterial_bleeding = "<span class='red'><br><b>Артериальное кровотечение</b><br></span>"
					if(BP.status & ORGAN_SPLINTED)
						splint = "Наложена шина:"
					if(BP.status & ORGAN_BLEEDING)
						bled = "Кровотечение:"
					if(BP.status & ORGAN_BROKEN)
						AN = "[BP.broken_description]:"
					if(BP.is_robotic())
						robot = "Протез:"
					if(BP.open)
						open = "Вскрытое:"
					if(BP.is_rejecting)
						rejecting = "Генетическое отторжение:"
					switch (BP.germ_level)
						if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE_PLUS)
							infected = "Легкая инфекция:"
						if (INFECTION_LEVEL_ONE_PLUS to INFECTION_LEVEL_ONE_PLUS_PLUS)
							infected = "Легкая инфекция+:"
						if (INFECTION_LEVEL_ONE_PLUS_PLUS to INFECTION_LEVEL_TWO)
							infected = "Легкая инфекция++:"
						if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO_PLUS)
							infected = "Острая инфекция:"
						if (INFECTION_LEVEL_TWO_PLUS to INFECTION_LEVEL_TWO_PLUS_PLUS)
							infected = "Острая инфекция+:"
						if (INFECTION_LEVEL_TWO_PLUS_PLUS to INFECTION_LEVEL_THREE)
							infected = "Острая инфекция++:"
						if (INFECTION_LEVEL_THREE to INFINITY)
							infected = "Сепсис:"

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
						var/burnDamText = BP.burn_dam > 0 ? "<span class='orange'>[BP.burn_dam]</span>" : "-/-"
						var/bruteDamText = BP.brute_dam > 0 ? "<span class='red'>[BP.brute_dam]</span>" : "-/-"
						dat += "<td>[BP.name]</td><td>[burnDamText]</td><td>[bruteDamText]</td><td>[robot][bled][AN][splint][open][infected][imp][arterial_bleeding][rejecting]</td>"
						storedinfo += "<td>[BP.name]</td><td>[burnDamText]</td><td>[bruteDamText]</td><td>[robot][bled][AN][splint][open][infected][imp][arterial_bleeding][rejecting]</td>"
					else
						dat += "<td>[parse_zone(BP.body_zone)]</td><td>-</td><td>-</td><td>Not Found</td>"
						storedinfo += "<td>[parse_zone(BP.body_zone)]</td><td>-</td><td>-</td><td>Not Found</td>"
					dat += "</tr>"
					storedinfo += "</tr>"
				for(var/missing_zone in occupant.get_missing_bodyparts())
					dat += "<tr>"
					storedinfo += "<tr>"
					dat += "<td>[parse_zone(missing_zone)]</td><td>-</td><td>-</td><td>Not Found</td>"
					storedinfo += "<td>[parse_zone(missing_zone)]</td><td>-</td><td>-</td><td>Not Found</td>"
					dat += "</tr>"
					storedinfo += "</tr>"
				for(var/obj/item/organ/internal/IO in occupant.organs)
					var/mech = "Органические:"
					var/organ_status = ""
					var/infection = ""
					if(IO.robotic == 1)
						mech = "Вспомогательные средства:"
					if(IO.robotic == 2)
						mech = "Механические:"

					if(istype(IO, /obj/item/organ/internal/heart))
						var/obj/item/organ/internal/heart/Heart = IO
						if(Heart.heart_status == HEART_FAILURE)
							organ_status = "Остановка сердца:"
						else if(Heart.heart_status == HEART_FIBR)
							organ_status = "Фибрилляция сердца:"

					if(istype(IO, /obj/item/organ/internal/lungs))
						if(occupant.is_lung_ruptured())
							organ_status = "Разрыв легкого:"

					switch (IO.germ_level)
						if (INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE_PLUS)
							infection = "Легкая инфекция:"
						if (INFECTION_LEVEL_ONE_PLUS to INFECTION_LEVEL_ONE_PLUS_PLUS)
							infection = "Легкая инфекция+:"
						if (INFECTION_LEVEL_ONE_PLUS_PLUS to INFECTION_LEVEL_TWO)
							infection = "Легкая инфекция++:"
						if (INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO_PLUS)
							infection = "Острая инфекция:"
						if (INFECTION_LEVEL_TWO_PLUS to INFECTION_LEVEL_TWO_PLUS_PLUS)
							infection = "Острая инфекция+:"
						if (INFECTION_LEVEL_TWO_PLUS_PLUS to INFECTION_LEVEL_THREE)
							infection = "Острая инфекция++:"
						if (INFECTION_LEVEL_THREE to INFINITY)
							infection = "Некроз:"

					if(!organ_status && !infection)
						infection = "Не обнаружено:"

					var/organ_damage_text = IO.damage > 0 ? "<span class='red'>[IO.damage]</span>" : "-/-"
					dat += "<tr>"
					dat += "<td>[IO.name]</td><td>N/A</td><td>[organ_damage_text]</td><td>[infection][organ_status]|[mech]</td><td></td>"
					dat += "</tr>"
					storedinfo += "<tr>"
					storedinfo += "<td>[IO.name]</td><td>N/A</td><td>[organ_damage_text]</td><td>[infection][organ_status]|[mech]</td><td></td>"
					storedinfo += "</tr>"
				dat += "</table>"
				storedinfo += "</table>"
				if(occupant.sdisabilities & BLIND)
					dat += text("<font color='red'>Обнаружена катаракта.</font><BR>")
					storedinfo += text("<font color='red'>Обнаружена катаракта.</font><BR>")
				if(HAS_TRAIT(occupant, TRAIT_NEARSIGHT))
					dat += text("<font color='red'>Обнаружено смещение сетчатки.</font><BR>")
					storedinfo += text("<font color='red'>Обнаружено смещение сетчатки.</font><BR>")
		else
			dat += "\The [src] is empty."
	else
		dat = "<font color='red'> Ошибка: Не подключен сканер тела.</font>"

	var/datum/browser/popup = new(user, "window=scanconsole", src.name, 530, 700, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/obj/machinery/body_scanconsole/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["print"])
		if (next_print < world.time) //10 sec cooldown
			next_print = world.time + 10 SECONDS
			to_chat(usr, "<span class='notice'>Распечатка... Пожалуйста, подождите.</span>")
			playsound(src, 'sound/items/polaroid1.ogg', VOL_EFFECTS_MASTER, 20, FALSE)
			addtimer(CALLBACK(src, PROC_REF(print_scan), storedinfo), 1 SECOND)
		else
			to_chat(usr, "<span class='notice'>Консоль не может печатать так быстро!</span>")

/obj/machinery/body_scanconsole/proc/print_scan(additional_info)
	var/obj/item/weapon/paper/P = new(loc)
	if(!connected || !connected.occupant) // If while we were printing the occupant got out or our thingy did a boom.
		return
	var/mob/living/carbon/human/occupant = connected.occupant
	var/t1 = "<B>[occupant ? occupant.name : "Unknown"]'s</B> расширенный отчет сканера.<BR>"
	t1 += "Станционное время: <B>[worldtime2text()]</B><BR>"
	switch(occupant.stat) // obvious, see what their status is
		if(CONSCIOUS)
			t1 += "Status: <B>В сознании</B>"
		if(UNCONSCIOUS)
			t1 += "Status: <B>Без сознания</B>"
		else
			t1 += "Status: <B><span class='warning'>*Мёртв*</span></B>"
	t1 += additional_info
	P.info = t1
	P.name = "Результаты сканирования [occupant.name]"
	P.update_icon()
