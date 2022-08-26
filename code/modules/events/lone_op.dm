/datum/role/operative/lone
	name = LONE_OP
	id = LONE_OP
	nuclear_outfit = /datum/outfit/nuclear/solo
	TC_num = 15

/datum/role/operative/lone/forgeObjectives()
	if(!..())
		return FALSE
	switch(rand(1,100))
		if(1 to 50)
			AppendObjective(/datum/objective/hijack)

		if(51 to 100)
			AppendObjective(/datum/objective/nuclear)


/datum/event/lone_op
	announceWhen	= 12
	endWhen			= 120

/datum/event/lone_op/start()
	if(!global.loneopstart.len)
		kill()
		return

	create_spawner(/datum/spawner/lone_op_event)


