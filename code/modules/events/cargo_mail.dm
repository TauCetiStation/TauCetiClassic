/datum/event/cargo_mail
	var/list/citizenship_to_type = list(
		"Mars" = /obj/random/mail/mars,
		"Venus" = /obj/random/mail/venus,
		"Earth" = /obj/random/mail/earth,
		"Bimna" = /obj/random/mail/bimna,
		"Luthien" = /obj/random/mail/luthien,
		"New Gibson" = /obj/random/mail/newgibson,
		"Reed" = /obj/random/mail/reed,
		"Argelius" = /obj/random/mail/argelius,
		"Ahdomai" = /obj/random/mail/ahdomai,
		"Moghes" = /obj/random/mail/moghes,
		"Qerrbalak" = /obj/random/mail/qerrbalak,
	)

	/*var/bible_by_name = list(
		"Church of Christ" = /datum/bible_info/chaplain/bible,
		"Church of Satan" = /datum/bible_info/chaplain/satanism,
		"Church of Yog'Sotherie" = /datum/bible_info/chaplain/necronomicon,
		"Church of Chaos" = /datum/bible_info/chaplain/book_of_lorgar,
		"Church of Imperium" = /datum/bible_info/chaplain/book_of_lorgar/imperial_truth,
		"Toolboxia" = /datum/bible_info/chaplain/toolbox,
		"MG1M0" = /datum/bible_info/chaplain/science,
		"F1ZTEH" = /datum/bible_info/chaplain/techno,
		"Honkers" = /datum/bible_info/chaplain/scrapbook,
		"Dialectic materialism group of Venera" = /datum/bible_info/chaplain/atheist,
	)*/

	var/list/job_to_mail = list(
		JOB_VIROLOGIST = list("Венерианский Институт Вирусологии и Микологии", /obj/item/weapon/virusdish/random),
		JOB_GENETICIST = list("Ассоциация Свободных Генетиков", /obj/random/meds/dna_injector),
		JOB_ENGINEER = list("Профсоюз Инженеров и Атмостехов", /obj/random/tools/bettertool),
		JOB_ATMOS = list("Профсоюз Инженеров и Атмостехов", /obj/random/tools/bettertool),
		JOB_DOCTOR = list("Фонд поддержки людей с ограниченными возможностями" , /obj/structure/stool/bed/chair/wheelchair),
		JOB_PSYCHIATRIST = list("Коллегия Психиатрии и Маркетологии" , /obj/item/clothing/suit/straight_jacket),
		JOB_MINER = list("Профсоюз работников отрасли добычи", /obj/item/weapon/gun/energy/laser/cutter),
		JOB_RECYCLER = list("Профсоюз работников отрасли добычи", /obj/item/weapon/shovel/experimental),
		JOB_HYDRO = list("Фонд развития ГМО", /obj/item/weapon/gun/energy/floragun),
		JOB_JANITOR = list("САНМИНСОЛГОВ", /obj/item/weapon/holosign_creator),
	)

/datum/event/cargo_mail/start()
	var/list/available_receivers = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/datum/data/record/R = find_general_record("id", find_record_by_name(null, H.real_name))
		if(!R)
			continue

		var/datum/money_account/MA = get_account(R.fields["insurance_account_number"])
		if(!MA)
			continue

		available_receivers += list(list(H, MA))

	if(!available_receivers.len)
		return


	var/mail_amount = rand(1, ceil(available_receivers.len * 0.3))

	for(var/i in 1 to mail_amount)
		if(!available_receivers.len)
			break

		var/list/receiversData = pick_n_take(available_receivers)
		var/mob/living/carbon/human/H = receiversData[1]
		var/datum/money_account/MA = receiversData[2]

		var/itemType
		var/senderInfo

		var/list/variants = list("FromHome", "NTSocial", "WrongMail", "WannaKnowMore?", "Love", "Prank")
		if(H.mind.assigned_role in job_to_mail)
			variants += "JobItem"

		switch(pick(variants))
			if("FromHome") //From Home with Love
				senderInfo = H.client.prefs.citizenship
				var/citizenshipType = citizenship_to_type[senderInfo]
				if(!citizenshipType)
					citizenshipType = /obj/random/mail/home
				itemType = PATH_OR_RANDOM_PATH(citizenshipType)

			/*if(2) //Religious spam
				senderInfo = pick(bible_by_name)
				itemType = bible_by_name[senderInfo]*/

			if("NTSocial") //NT Support
				senderInfo = "Отдел социальной поддержки персонала НаноТрейзен"
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/ntsupport)

			if("WrongMail") //Wrong Receiver
				senderInfo = pick(citizenship_to_type)
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/wrongreceiver)

			if("WannaKnowMore?") //Wanna know more?
				senderInfo = "Хочешь знать больше?"
				itemType = PATH_OR_RANDOM_PATH(/obj/random/misc/book)

			if("Love") //Lover
				senderInfo = "<3"
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/love)

			if("JobItem") //Job related
				var/list/data = job_to_mail[H.mind.assigned_role]
				senderInfo = data[1]
				itemType = PATH_OR_RANDOM_PATH(data[2])

			if("Prank") //Prank
				senderInfo = pick(citizenship_to_type)
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/prank)


		SSshuttle.add_mail(senderInfo, MA.account_number, itemType)
