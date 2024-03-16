/obj/machinery/computer/cloning
	name = "Cloning console"
	cases = list("консоль капсулы клонирования", "консоли капсулы клонирования", "консоли капсулы клонирования", "консоль капсулы клонирования", "консолью капсулы клонирования", "консоли капсулы клонирования")
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	state_broken_preset = "crewb"
	state_nopower_preset = "crew0"
	light_color = "#315ab4"
	circuit = /obj/item/weapon/circuitboard/cloning
	req_access = list(access_heads) //Only used for record deletion right now.
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/temp = ""
	var/scantemp = "Сканер пуст"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/autoprocess = 0
	required_skills = list(/datum/skill/medical = SKILL_LEVEL_PRO, /datum/skill/research = SKILL_LEVEL_TRAINED)
	fumbling_time = 3 SECONDS

/obj/machinery/computer/cloning/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/cloning/atom_init_late()
	updatemodules()

/obj/machinery/computer/cloning/process()
	if(!(scanner && pod1 && autoprocess))
		return

	if(scanner.occupant && (scanner.scan_level > 2))
		scan_mob(scanner.occupant)

	if(!(pod1.occupant || pod1.mess) && (pod1.efficiency > 5))
		for(var/datum/data/record/R in records)
			if(!(pod1.occupant || pod1.mess))
				if(pod1.growclone(R.fields["ckey"], R.fields["name"], R.fields["UI"], R.fields["SE"], R.fields["mind"], R.fields["mrace"]))
					records -= R

/obj/machinery/computer/cloning/proc/updatemodules()
	src.scanner = findscanner()
	src.pod1 = findcloner()

	if (!isnull(src.pod1))
		src.pod1.connected = src // Some variable the pod needs

/obj/machinery/computer/cloning/proc/findscanner()
	// Try to find a scanner
	var/obj/machinery/dna_scannernew/scannerf = locate(/obj/machinery/dna_scannernew) in range(4, src)
	// If found, then return the scanner
	if(!isnull(scannerf))
		return scannerf

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = locate(/obj/machinery/clonepod) in range(4, src)

	if(!isnull(podf))
		return podf

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user)
	if (istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			user.drop_from_inventory(W, src)
			src.diskette = W
			to_chat(user, "You insert [W].")
			updateUsrDialog()
			return
	else
		..()
	return

/obj/machinery/computer/cloning/ui_interact(mob/user)
	updatemodules()
	var/dat = ""
	dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Обновить</a></font><br>"
	if(scanner && pod1 && ((scanner.scan_level > 2) || (pod1.efficiency > 5)))
		if(!autoprocess)
			dat += "<a href='byond://?src=\ref[src];task=autoprocess'>Автопроцесс</a>"
		else
			dat += "<a href='byond://?src=\ref[src];task=stopautoprocess'>Остановить автопроцесс</a>"
	else
		dat += "<span class='disabled'>Автопроцесс</span>"
	dat += "<br><tt>[temp]</tt><br>"

	switch(src.menu)
		if(1)
			// Modules
			dat += "<h4>Модули</h4>"
			//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
			if (isnull(src.scanner))
				dat += " <span class='red'>Сканер - не обнаружен!</span><br>"
			else
				dat += " <span class='green'>Сканер - обнаружен!</span><br>"
			if (isnull(src.pod1))
				dat += " <span class='red'>Капсула - не обнаружена!</span><br>"
			else
				dat += " <span class='green'>Капсула - обнаружена!</span><br>"

			// Scanner
			dat += "<h4>Функции сканера</h4>"

			if(loading)
				dat += "<b>Сканирование...</b><br>"
			else
				dat += "<b>[scantemp]</b><br>"

			if (isnull(src.scanner))
				dat += "Сканер не подключён!<br>"
			else
				if (src.scanner.occupant)
					if(scantemp == "Сканер пуст") scantemp = "" // Stupid check to remove the text

					dat += "<a href='byond://?src=\ref[src];scan=1'>Просканировать - [src.scanner.occupant]</a><br>"
				else
					scantemp = "Сканер пуст"

				dat += "Статус блокировки: <a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Заблокирован" : "Разблокирован"]</a><br>"

			if (!isnull(src.pod1))
				dat += "Биомасса: <i>[src.pod1.biomass].</i><br>"

			// Database
			dat += "<h4>Функции для управления базой данных</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>Просмотреть записи</a><br>"
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Извлечь диск</a>"


		if(2)
			dat += "<h4>Текущие записи</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=1'>Вернуться</a><br><br>"
			for(var/datum/dna2/record/R in src.records)
				dat += "<li><a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.dna.real_name]</a><li>"

		if(3)
			dat += "<h4>Выбранная запись</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>Вернуться</a><br>"

			if (!src.active_record)
				dat += "<span class='red'>Ошибка: запись не обнаружена.</span>"
			else
				dat += {"<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Удалить запись</a></font><br>
					<b>Name:</b> [src.active_record.dna.real_name]<br>"}
				var/obj/item/weapon/implant/health/H = null
				if(src.active_record.implant)
					H=locate(src.active_record.implant)

				if ((H) && (istype(H)))
					dat += "<b>Health:</b> [H.sensehealth()] | АСФ-ОЖОГ-ТОКС-МЕХАН<br>"
				else
					dat += "<span class='red'>Невозможно обнаружить имплант.</span><br>"

				if (!isnull(src.diskette))
					dat += "<a href='byond://?src=\ref[src];disk=load'>Загрузить информацию с диска.</a>"

					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ue'>UI + UE</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ui'>UI</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=se'>SE</a>"
					dat += "<br>"
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				dat += {"<b>UI:</b> [src.active_record.dna.uni_identity]<br>
				<b>SE:</b> [src.active_record.dna.struc_enzymes]<br><br>"}

				if(pod1 && pod1.biomass >= CLONE_BIOMASS)
					dat += {"<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Клонировать</a><br>"}
				else
					dat += {"<b>Недостаточно биомассы</b><br>"}

		if(4)
			if (!src.active_record)
				src.menu = 2
			dat = "[src.temp]<br>"
			dat += "<h4>Подтвердить удаление записи</h4>"

			dat += "<b><a href='byond://?src=\ref[src];del_rec=1'>Приложите ID-карту для подтверждения.</a></b><br>"
			dat += "<b><a href='byond://?src=\ref[src];menu=3'>Отмена</a></b>"

	var/datum/browser/popup = new(user, "cloning", "Управление системой клонирования")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(loading)
		return

	if(href_list["task"])
		switch(href_list["task"])
			if("autoprocess")
				autoprocess = 1
			if("stopautoprocess")
				autoprocess = 0

	else if ((href_list["scan"]) && (!isnull(src.scanner)))
		scantemp = ""

		loading = 1
		updateUsrDialog()

		spawn(20)
			scan_mob(src.scanner.occupant)

			loading = 0
			updateUsrDialog()


		//No locking an open scanner.
	else if ((href_list["lock"]) && (!isnull(src.scanner)))
		if ((!src.scanner.locked) && (src.scanner.occupant))
			src.scanner.locked = 1
		else
			src.scanner.locked = 0

	else if (href_list["view_rec"])
		src.active_record = locate(href_list["view_rec"])
		if(istype(src.active_record,/datum/dna2/record))
			if ((isnull(src.active_record.ckey)))
				qdel(src.active_record)
				src.temp = "Ошибка: запись повреждена"
			else
				src.menu = 3
		else
			src.active_record = null
			src.temp = "Запись стёрта."

	else if (href_list["del_rec"])
		if ((!src.active_record) || (src.menu < 3))
			return
		if (src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Удалить запись?"
			src.menu = 4

		else if (src.menu == 4)
			var/obj/item/weapon/card/id/C = usr.get_active_hand()
			if (istype(C)||istype(C, /obj/item/device/pda))
				if(check_access(C))
					records.Remove(src.active_record)
					qdel(src.active_record)
					src.temp = "Запись удалена."
					src.menu = 2
				else
					src.temp = "Отказано в доступе."

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(src.diskette)) || isnull(src.diskette.buf))
					src.temp = "Ошибка загрузки."
					updateUsrDialog()
					return
				if (isnull(src.active_record))
					src.temp = "Ошибка записи."
					src.menu = 1
					updateUsrDialog()
					return

				src.active_record = src.diskette.buf

				src.temp = "Загрузка прошла успешно."
			if("eject")
				if (!isnull(src.diskette))
					src.diskette.loc = src.loc
					src.diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if ((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(src.active_record)))
			src.temp = "Ошибка сохранения."
			updateUsrDialog()
			return

		// DNA2 makes things a little simpler.
		src.diskette.buf=src.active_record
		src.diskette.buf.types=0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				src.diskette.buf.types=DNA2_BUF_UI
			if("ue")
				src.diskette.buf.types=DNA2_BUF_UI|DNA2_BUF_UE
			if("se")
				src.diskette.buf.types=DNA2_BUF_SE
		src.diskette.name = "data disk - '[src.active_record.dna.real_name]'"
		src.temp = "Сохранение \[[href_list["save_disk"]]\] произведено успешно."

	else if (href_list["refresh"])
		updateUsrDialog()

	else if (href_list["clone"])
		var/datum/dna2/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!pod1)
				temp = "Ошибка: не обнаружено капсулы клонирования."
			else if(pod1.occupant)
				temp = "Ошибка: капсула клонирования уже занята."
			else if(pod1.biomass < CLONE_BIOMASS)
				temp = "Ошибка: недостаточно биомассы."
			else if(pod1.mess)
				temp = "Ошибка: повреждение капсулы клонирования."
			else if(!config.revival_cloning)
				temp = "Ошибка: невозможно начать процесс клонирования."

			else if(pod1.growclone(C))
				temp = "<span class='good'>Проводится процесс клонирования...</span>"
				records.Remove(C)
				qdel(C)
				menu = 1
			else
				var/mob/selected = find_dead_player("[C.ckey]")
				if(selected)
					selected.playsound_local(null, 'sound/machines/chime.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)	//probably not the best sound but I think it's reasonable
					var/answer = tgui_alert(selected,"Вы желаете вернуться к жизни?","Cloning", list("Да","Нет"))
					if(answer != "Нет" && pod1.growclone(C))
						temp = "Начинаем процесс клонирования..."
						records.Remove(C)
						qdel(C)
						menu = 1
					else
						temp = "Начинаем процесс клонирования...<br>Ошибка: пост-инициализация не удалась. Процесс клонирования отменён."
				else
					temp = "Начинаем процесс клонирования...<br>Ошибка: пост-инициализация не удалась. Процесс клонирования отменён."

		else
			temp = "Ошибка: повреждение данных."

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])

	updateUsrDialog()

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/subject)
	if(ishuman(subject))
		var/mob/living/carbon/human/Hsubject = subject
		if(!Hsubject.has_brain() || Hsubject.species.flags[NO_SCAN])
			scantemp = "Ошибка: не обнаружено следов разума."
			return
	else if(!isbrain(subject))
		scantemp = "Ошибка: структура тела пациента не поддерживается."
		return
	if(!subject.dna)
		scantemp = "Ошибка: невозможно получить ДНК пациента."
		return
	if(subject.suiciding)
		scantemp = "Ошибка: мозг пациента мёртв."
		return
	if((!subject.ckey) || (!subject.client))
		scantemp = "Ошибка: сканирование не удалось."
		return
	if((NOCLONE in subject.mutations && src.scanner.scan_level < 4) || HAS_TRAIT(subject, TRAIT_NO_CLONE))
		scantemp = "<span class='bad'>Геном пациента повреждён и не пригоден для клонирования.</span>"
		return
	if(!isnull(find_record(subject.ckey)))
		scantemp = "Пациент уже находится в базе данных."
		return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.dna=subject.dna
	R.ckey = subject.ckey
	R.id= copytext(md5(subject.real_name), 2, 6)
	R.name=R.dna.real_name
	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages=subject.languages

	R.quirks = list()
	for(var/V in subject.roundstart_quirks)
		var/datum/quirk/T = V
		R.quirks += T.type
	R.quirks += /datum/quirk/genetic_degradation // clones cannot be cloned

	//Add an implant if needed
	var/obj/item/weapon/implant/health/imp = locate(/obj/item/weapon/implant/health, subject)
	if (isnull(imp))
		imp = new /obj/item/weapon/implant/health(subject)
		imp.implanted = subject
		subject.sec_hud_set_implants()
		R.implant = "\ref[imp]"
	//Update it if needed
	else
		R.implant = "\ref[imp]"

	if (!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	src.records += R
	scantemp = "Пациент успешно просканирован."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in src.records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/update_icon()

	if(stat & BROKEN)
		icon_state = "crewb"
	else
		if(stat & NOPOWER)
			src.icon_state = "crew0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
