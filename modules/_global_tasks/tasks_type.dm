/datum/global_task

	var/name
	var/report_message		//will report in early rounds
	var/result_message		//results for the end of the round

	var/success
	var/type_id

/datum/global_task/proc/result()
	return

/*
 *RESOURSES*******************************************************************
 */

/datum/global_task/resourses
	//what we have?
	var/list/resources[0]
	//what we need?
	var/list/required_resources[0]

/datum/global_task/resourses/New()

	success = 1

	resources["glass"] = 0
	resources["metal"] = 0
	resources["plasteel"] = 0
	resources["reinforced glass"] = 0
	resources["wooden plank"] = 0
	resources["adamantine"] = 0
	resources["diamond"] = 0
	resources["gold"] = 0
	resources["mythril"] = 0
//	resources["plastic"] = 0
	resources["sandstone bricks"] = 0
	resources["silver"] = 0
	resources["uranium"] = 0
	resources["solid plasma"] = 0
	resources["bananium"] = 0	//yes, bananium too

	required_resources = resources.Copy()

	//generate required list
	required_resources[required_resources[rand(1, 5)]] += pick(50, 100, 150, 200)
	if(prob(60))
		required_resources[required_resources[rand(1, 5)]] += pick(50, 100, 150)
	if(prob(30))
		required_resources[required_resources[rand(1, 5)]] += pick(50, 100)
	//now minerals
	if(prob(50))
		required_resources[required_resources[rand(6, 14)]] += rand(1, 10)
		if(prob(60))
			required_resources[required_resources[rand(6, 14)]] += rand(1, 10)
		if(prob(30))
			required_resources[required_resources[rand(6, 14)]] += rand(1, 10)

	report_message = "Following resources are required:<br>"

	for(var/i in required_resources)
		if(required_resources[i])
			report_message += "*[i], [required_resources[i]]<br>"

/datum/global_task/resourses/result()

	result_message = "The following resources have been sent\\requested:<br>"

	for(var/i in required_resources)
		if(required_resources[i])
			if(required_resources[i] <= resources[i])
				result_message += "   *[i], <font color='green'>[resources[i]]\\[required_resources[i]]</font><br>"
			else
				result_message += "   *[i], <font color='red'>[resources[i]]\\[required_resources[i]]</font><br>"
				success = 0

/datum/global_task/resourses/centcomm

	name = "CentComm needs in resourses."

/datum/global_task/resourses/centcomm/New()
	..()

///datum/global_task/resourses/centcomm/proc/result()
//This in supplyshuttle.dm

/datum/global_task/resourses/vault

	name = "Need resources to restock the station vault."

/datum/global_task/resourses/vault/New()
	..()

//в работе
/datum/global_task/resourses/vault/result()
	world << "one"
	var/area/vault = locate(/area/security/nuke_storage)
	world << vault
	world << vault.contents
	world << vault.contents.len
	for(var/C in vault.contents)
		world << "zashlo"
		world << C

		if(istype(C,/obj/structure/closet/crate))
			world << "crate:"
			for(var/atom/A in C)
				world << A
				if(istype(A, /obj/item/stack/sheet))
					var/obj/item/stack/sheet/M = A
					world << M

					for(var/R in resources)
						if(M.name == R)
							resources[R] += M.amount
	..()

/*
 *RESEARCH********************************************************************
 */

 /datum/global_task/research/levels