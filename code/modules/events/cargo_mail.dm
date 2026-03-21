/datum/event/cargo_mail
	var/list/citizenship_to_mail_type = list(
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

	var/list/job_to_mail_type = list(
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

	for(var/datum/data/record/R in data_core.general)
		if(!R.fields["auto_created"])
			continue

		var/datum/money_account/MA = get_account(R.fields["acc_number"])
		if(!MA)
			continue

		available_receivers += R

	if(!available_receivers.len)
		return

	var/mail_amount = rand(1, ceil(available_receivers.len * 0.3))

	for(var/i in 1 to mail_amount)
		if(!available_receivers.len)
			break

		generate_mail_for_record(pick_n_take(available_receivers))

/datum/event/cargo_mail/proc/generate_mail_for_record(datum/data/record/record)
	var/receiver_name = record.fields["name"]
	var/citizenship = record.fields["citizenship"]
	var/receiver_rank = record.fields["rank"]
	var/receiver_account = record.fields["acc_number"]

	var/item_type
	var/sender_info

	var/list/variants = list("FromHome", "NTSocial", "WrongMail", "WannaKnowMore?", "Love", "Prank")
	if(receiver_rank in job_to_mail_type)
		variants += "JobItem"

	switch(pick(variants))
		if("FromHome") //From Home with Love
			sender_info = citizenship
			var/citizenship_mail_type = citizenship_to_mail_type[sender_info]
			if(!citizenship_mail_type)
				citizenship_mail_type = /obj/random/mail/home
			item_type = PATH_OR_RANDOM_PATH(citizenship_mail_type)

		if("NTSocial") //NT Support
			sender_info = "Отдел социальной поддержки персонала НаноТрейзен"
			item_type = PATH_OR_RANDOM_PATH(/obj/random/mail/ntsupport)

		if("WrongMail") //Wrong Receiver
			sender_info = pick(citizenship_to_mail_type)
			item_type = PATH_OR_RANDOM_PATH(/obj/random/mail/wrongreceiver)

		if("WannaKnowMore?") //Wanna know more?
			sender_info = "Хочешь знать больше?"
			item_type = PATH_OR_RANDOM_PATH(/obj/random/misc/book)

		if("Love") //Lover
			sender_info = "<3"
			item_type = PATH_OR_RANDOM_PATH(/obj/random/mail/love)

		if("JobItem") //Job related
			var/list/data = job_to_mail_type[receiver_rank]
			sender_info = data[1]
			item_type = PATH_OR_RANDOM_PATH(data[2])

		if("Prank") //Prank
			sender_info = pick(citizenship_to_mail_type)
			item_type = PATH_OR_RANDOM_PATH(/obj/random/mail/prank)


	SSshuttle.add_mail(sender_info, receiver_name, receiver_account, item_type)
