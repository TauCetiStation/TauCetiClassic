/obj/machinery/computer/card
	name = "Identification Computer"
	desc = "Terminal for programming NanoTrasen employee ID cards to access parts of the station."
	icon_state = "id"
	light_color = "#0099ff"
	req_access = list(access_change_ids)
	circuit = /obj/item/weapon/circuitboard/card
	allowed_checks = ALLOWED_CHECK_NONE
	var/obj/item/weapon/card/id/scan = null		//card that gives access to this console
	var/obj/item/weapon/card/id/modify = null	//the card we will change
	var/mode = 0.0
	var/printing = null
	var/datum/money_account/datum_account = null	//if money account is tied to the card and the card is inserted into the console, the account is stored here
	required_skills = list(/datum/skill/command = SKILL_LEVEL_PRO)
	fumbling_time = SKILL_TASK_TOUGH

/obj/machinery/computer/card/proc/is_centcom()
	return istype(src, /obj/machinery/computer/card/centcom)

/obj/machinery/computer/card/proc/is_authenticated()
	return scan ? check_access(scan) : 0

/obj/machinery/computer/card/proc/get_target_rank()
	return modify && modify.assignment ? modify.assignment : "Unassigned"

/obj/machinery/computer/card/proc/format_jobs(list/jobs)
	var/list/formatted = list()
	for(var/job in jobs)
		formatted.Add(list(list(
			"display_name" = replacetext(job, " ", "&nbsp"),
			"target_rank" = get_target_rank(),
				"job" = job)))

	return formatted

/obj/machinery/computer/card/AltClick(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	if(Adjacent(user))
		eject_id()

/obj/machinery/computer/card/verb/eject_id()
	set category = "Object"
	set name = "Eject ID Card"
	set src in oview(1)

	if(!usr || usr.incapacitated() || issilicon(usr))	return

	if(modify)
		if(!do_skill_checks(usr))
			return
		to_chat(usr, "You remove \the [modify] from \the [src].")
		modify.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(modify)
		modify = null
		playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else if(scan)
		if(!do_skill_checks(usr))
			return
		to_chat(usr, "You remove \the [scan] from \the [src].")
		scan.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(scan)
		scan = null
		playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	else
		to_chat(usr, "There is nothing to remove from the console.")
	return

/obj/machinery/computer/card/attackby(obj/item/weapon/card/id/id_card, mob/user)
	if(!istype(id_card))
		return ..()

	if(!scan && (access_change_ids in id_card.access))
		user.drop_from_inventory(id_card, src)
		scan = id_card
	else if(!modify)
		user.drop_from_inventory(id_card, src)
		modify = id_card
		if(id_card.associated_account_number)
			datum_account = get_account(id_card.associated_account_number)
		else
			datum_account = null	//delete information if there is something in the variable

	playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	nanomanager.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/card/ui_interact(mob/user, ui_key="main", datum/nanoui/ui=null)
	var/data[0]
	data["src"] = "\ref[src]"
	data["station_name"] = station_name()
	data["mode"] = mode
	data["printing"] = printing
	data["manifest"] = data_core ? data_core.html_manifest(monochrome=0) : null
	data["target_name"] = modify ? modify.name : "-----"
	data["target_owner"] = modify && modify.registered_name ? modify.registered_name : "-----"
	data["target_rank"] = get_target_rank()
	data["scan_name"] = scan ? scan.name : "-----"
	data["authenticated"] = is_authenticated()
	data["has_modify"] = !!modify
	data["account_number"] = modify ? modify.associated_account_number : null
	data["salary"] = datum_account ? datum_account.owner_salary : "not_found"
	data["centcom_access"] = is_centcom()
	data["all_centcom_access"] = null
	data["regions"] = null

	data["engineering_jobs"] = format_jobs(SSjob.departments_occupations[DEP_ENGINEERING])
	data["medical_jobs"] = format_jobs(SSjob.departments_occupations[DEP_MEDICAL])
	data["science_jobs"] = format_jobs(SSjob.departments_occupations[DEP_SCIENCE])
	data["security_jobs"] = format_jobs(SSjob.departments_occupations[DEP_SECURITY])
	data["civilian_jobs"] = format_jobs(SSjob.departments_occupations[DEP_CIVILIAN])
	data["representative_jobs"] = format_jobs(SSjob.departments_occupations[DEP_SPECIAL])

	data["fast_modify_region"] = is_skill_competent(user, list(/datum/skill/command = SKILL_LEVEL_PRO))
	data["fast_full_access"] = is_skill_competent(user, list(/datum/skill/command = SKILL_LEVEL_MASTER))

	if(mode == 2)
		var/list/jobsCategories = list(
			list(title = "Command", jobs = SSjob.departments_occupations[DEP_COMMAND], color = "#aac1ee"),
			list(title = "NT Representatives", jobs = SSjob.departments_occupations[DEP_SPECIAL], color = "#6c7391"),
			list(title = "Engineering", jobs = SSjob.departments_occupations[DEP_ENGINEERING], color = "#ffd699"),
			list(title = "Security", jobs = SSjob.departments_occupations[DEP_SECURITY], color = "#ff9999"),
			list(title = "Synthetic", jobs = SSjob.departments_occupations[DEP_SILICON], color = "#ccffcc"),
			list(title = "Service", jobs = SSjob.departments_occupations[DEP_CIVILIAN], color = "#cccccc"),
			list(title = "Medical", jobs = SSjob.departments_occupations[DEP_MEDICAL], color = "#99ffe6"),
			list(title = "Science", jobs = SSjob.departments_occupations[DEP_SCIENCE], color = "#e6b3e6"),
		)

		for(var/jobCategory in jobsCategories)
			var/list/jobsList = jobCategory["jobs"]
			var/list/newJobsList = list()

			for(var/jobTitle in jobsList)
				var/datum/job/job = SSjob.name_occupations[jobTitle]
				if(!job)
					continue
				newJobsList += list(list("name" = jobTitle, "quota" = job.quota))

			jobCategory["jobs"] = newJobsList

		data["all_jobs"] = jobsCategories

	if (modify && is_centcom())
		var/list/all_centcom_access = list()
		for(var/access in get_all_centcom_access())
			all_centcom_access.Add(list(list(
				"desc" = replacetext(get_centcom_access_desc(access), " ", "&nbsp"),
				"ref" = access,
				"allowed" = (access in modify.access) ? 1 : 0)))

		data["all_centcom_access"] = all_centcom_access
	else if (modify)
		var/list/regions = list()
		for(var/i = 1; i <= 7; i++)
			var/list/accesses = list()
			var/region_allowed = 0
			for(var/access in get_region_accesses(i))
				if (get_access_desc(access))
					region_allowed += (access in modify.access) ? 1 : 0
					accesses.Add(list(list(
						"desc" = replacetext(get_access_desc(access), " ", "&nbsp"),
						"ref" = access,
						"allowed" = (access in modify.access) ? 1 : 0)))

			regions.Add(list(list(
				"name" = get_region_accesses_name(i),
				"accesses" = accesses,
				"id" = i,
				"region_allowed" =  (region_allowed == length(get_region_accesses(i)) ? 1 : 0))))

		data["regions"] = regions

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "identification_computer.tmpl", src.name, 600, 700)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/card/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	switch(href_list["choice"])
		if ("modify")
			if (modify)
				data_core.manifest_modify(modify.registered_name, modify.assignment)
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				if(ishuman(usr))
					modify.loc = usr.loc
					playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
					if(!usr.get_active_hand())
						usr.put_in_hands(modify)
					modify = null
				else
					modify.loc = loc
					modify = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_from_inventory(I, src)
					modify = I
					var/obj/item/weapon/card/id/id_card = I
					if(id_card.associated_account_number)
						datum_account = get_account(id_card.associated_account_number)
					else
						datum_account = null	//delete information if there is something in the variable
					playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.sec_hud_set_ID()

		if ("scan")
			if (scan)
				if(ishuman(usr))
					scan.loc = usr.loc
					playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
					if(!usr.get_active_hand())
						usr.put_in_hands(scan)
					scan = null
				else
					scan.loc = src.loc
					scan = null
			else
				var/obj/item/I = usr.get_active_hand()
				if (istype(I, /obj/item/weapon/card/id))
					usr.drop_from_inventory(I, src)
					scan = I
					playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.sec_hud_set_ID()

		if("access")
			if(href_list["allowed"])
				if(is_authenticated())
					var/access_type = text2num(href_list["access_target"])
					var/access_allowed = text2num(href_list["allowed"])
					if(access_type in (is_centcom() ? get_all_centcom_access() : get_all_accesses()))
						modify.access -= access_type
						if(!access_allowed)
							modify.access += access_type
		if("access_region")
			if(is_authenticated())
				var/region_id = text2num(href_list["region_id"])
				var/region_accesses = get_region_accesses(region_id)
				var/region_allowed = text2num(href_list["region_allowed"])
				modify.access -= region_accesses
				if(!region_allowed)
					modify.access += region_accesses
		if("access_full")
			if(is_authenticated())
				modify.access += get_all_accesses()
		if ("assign")
			if (is_authenticated() && modify)
				var/t1 = sanitize(href_list["assign_target"] , 45)
				var/new_salary = 0
				var/datum/job/jobdatum
				if(t1 == "Custom")
					var/temp_t = sanitize(input("Enter a custom job assignment.","Assignment"), 45)
					//let custom jobs function as an impromptu alt title, mainly for sechuds
					if(temp_t && modify)
						modify.assignment = temp_t
				else
					var/list/access = list()
					for(var/datum/job/J as anything in SSjob.active_occupations)
						if(ckey(J.title) == ckey(t1))
							jobdatum = J
							break
					if(!jobdatum)
						to_chat(usr, "<span class='warning'>No log exists for this job: [t1]</span>")
						return

					access = jobdatum.get_access()
					new_salary = jobdatum.salary

					modify.access = access
					modify.assignment = t1
					modify.rank = t1

					if(datum_account)
						datum_account.set_salary(new_salary, jobdatum.salary_ratio)	//set the new salary equal to job

		if ("reg")
			if (is_authenticated())
				if (Adjacent(usr) || issilicon(usr))
					var/temp_name = sanitize_name(href_list["reg"])
					if(temp_name)
						modify.registered_name = temp_name
					else
						visible_message("<span class='notice'>[src] buzzes rudely.</span>")
			nanomanager.update_uis(src)

		if ("account")
			if (is_authenticated())
				if (Adjacent(usr) || issilicon(usr))
					var/datum/money_account/account = get_account(text2num(href_list["account"]))
					if(account)
						modify.associated_account_number = account.account_number
					else
						to_chat(usr, "<span class='warning'> Account with such number does not exist!</span>")
			nanomanager.update_uis(src)

		if ("mode")
			mode = text2num(href_list["mode_target"])

		if ("print")
			if (!printing)
				printing = 1
				spawn(50)
					printing = null
					nanomanager.update_uis(src)

					var/obj/item/weapon/paper/P = new(loc)
					if (mode)
						P.name = text("crew manifest ([])", worldtime2text())
						P.info = {"<h4>Crew Manifest</h4>
							<br>
							[data_core ? data_core.html_manifest(monochrome=0) : ""]
						"}
						P.update_icon()
					else if (modify)
						P.name = "access report"
						P.info = {"<h4>Access Report</h4>
							<u>Prepared By:</u> [scan?.registered_name ? scan.registered_name : "Unknown"]<br>
							<u>For:</u> [modify.registered_name ? modify.registered_name : "Unregistered"]<br>
							<hr>
							<u>Assignment:</u> [modify.assignment]<br>
							<u>Account Number:</u> #[modify.associated_account_number]<br>
							<u>Blood Type:</u> [modify.blood_type]<br><br>
							<u>Access:</u><br>
						"}
						P.update_icon()

						for(var/A in modify.access)
							P.info += "  [get_access_desc(A)]"

		if ("terminate")
			if (is_authenticated())
				modify.assignment = "Terminated"
				modify.access = list()
				if(datum_account)
					datum_account.set_salary(0)		//no salary

		if ("up_quota")
			var/job_name = sanitize(href_list["quotajob_name"], 50)
			var/datum/job/Job = SSjob.name_occupations[job_name]
			if(Job)
				if(Job.quota == QUOTA_WANTED)
					Job.quota = QUOTA_NEUTRAL
				else
					Job.quota = QUOTA_WANTED

		if ("down_quota")
			var/job_name = sanitize(href_list["quotajob_name"], 50)
			var/datum/job/Job = SSjob.name_occupations[job_name]
			if(Job)
				if(Job.quota == QUOTA_UNWANTED)
					Job.quota = QUOTA_NEUTRAL
				else
					Job.quota = QUOTA_UNWANTED

	if (modify)
		modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")

	return 1

/obj/machinery/computer/card/centcom
	name = "CentCom Identification Computer"
	circuit = /obj/item/weapon/circuitboard/card/centcom
	req_access = list(access_cent_captain)
