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

/datum/event/cargo_mail/start()
	var/list/available_receivers = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/datum/money_account/MA = get_account(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER))
		if(!MA)
			continue

		available_receivers += H

	if(!available_receivers.len)
		return


	var/mail_amount = rand(1, ceil(available_receivers.len * 0.3))

	for(var/i = 1 to mail_amount)
		var/mob/living/carbon/human/H = pick_n_take(available_receivers)
		var/datum/money_account/MA = get_account(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER))
		var/itemType
		var/senderInfo

		switch(pick(1, 3, 4, 5, 6))
			if(1) //From Home with Love
				senderInfo = H.client.prefs.citizenship
				var/citizenshipType = citizenship_to_type[senderInfo]
				if(!citizenshipType)
					citizenshipType = citizenship_to_type[pick(citizenship_to_type)]
				itemType = PATH_OR_RANDOM_PATH(citizenshipType)

			/*if(2) //Religious spam
				senderInfo = pick(bible_by_name)
				itemType = bible_by_name[senderInfo]*/

			if(3) //NT Support
				senderInfo = "Отдел социальной поддержки персонала НаноТрейзен"
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/ntsupport)

			if(4) //Wrong Receiver
				senderInfo = pick(citizenship_to_type)
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/wrongreceiver)

			if(5) //Wanna know more?
				senderInfo = "Хочешь знать больше?"
				itemType = PATH_OR_RANDOM_PATH(/obj/random/misc/book)

			if(6) //Lover
				senderInfo = "<3"
				itemType = PATH_OR_RANDOM_PATH(/obj/random/mail/love)

		SSshuttle.add_mail(senderInfo, MA.account_number, itemType)
