/datum/controller/subsystem/economy/proc/generate_new_crew_mail()
	var/list/available_receivers = list()
	for(var/mob/living/carbon/human/H in player_list)
		var/datum/money_account/MA = get_account(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER))

		if(!MA)
			continue

		var/members = H.client.prefs.family_members
		if(members < 1)
			continue

		available_receivers += list(list(MA, members))

	if(!available_receivers.len)
		return

	var/mail_amount = rand(0, ceil(available_receivers.len * 0.3))

	if(!mail_amount)
		return

	for(var/i = 1 to mail_amount)
		var/list/receiver_info = pick(available_receivers)

		var/datum/money_account/MA = receiver_info[1]
		var/members = receiver_info[2]

		var/list/available_types = list()

		if(members & FAMILY_GRANDMOTHER)
			available_types += list(list("Бабушка", /obj/random/family/grandma))

		if(members & FAMILY_GRANDFATHER)
			available_types += list(list("Дедушка", /obj/random/family/grandpa))

		if(members & FAMILY_MOTHER)
			available_types += list(list("Мама", /obj/random/family/mother))

		if(members & FAMILY_FATHER)
			available_types += list(list("Папа", /obj/random/family/father))

		if(members & FAMILY_BROTHERS)
			available_types += list(list("Брат", /obj/random/family/brother))

		if(members & FAMILY_SISTERS)
			available_types += list(list("Сестра", /obj/random/family/sister))

		if(members & FAMILY_PARTNER)
			available_types += list(list("Партнер", /obj/random/family/partner))

		if(!available_types.len)
			continue

		var/list/picked_type = pick(available_types)

		SSshuttle.mail_orders += list(list("sender" = picked_type[1], "type" = PATH_OR_RANDOM_PATH(picked_type[2]), "receiver_account" = MA.account_number))

		available_receivers -= receiver_info
