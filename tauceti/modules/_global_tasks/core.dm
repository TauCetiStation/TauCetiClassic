var/global/list/gtTaskIDs = new/list()
var/global/list/gtCurrentTasks = new/list()

//task ID's
//#define %NAME% 0
#define RESOURSES_FOR_CC 1
#define RESOURSES_FOR_VAULT 2
#define RESEARCH_LEVEL 3
#define BUILD_BAY 4
#define NO_CREW_DEATHS 5
#define NO_ONE_ASSISTENT 6

/proc/gtInit()

	//sleep(300)

	gtGenerateTasks()

	//create CentComm report
	var/message = "<big><b>Command updated crew objectives.</b></big><br><br>"

	for(var/datum/global_task/T in gtCurrentTasks)
		message += "<u><b>" + T.name + "</u></b><br>"
		message += T.report_message

	var/effective_phrase = pick("Are you still an effective crew?","Are you an effective crew?")

	message +="<br><small>P.S. [effective_phrase]</small>"

	//now send it
	for (var/obj/machinery/computer/communications/comm in machines)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper - 'Cent. Com. Objectives Update'"
			intercept.info = message

			comm.messagetitle.Add("Cent. Com. Objectives Update")
			comm.messagetext.Add(message)
	world << sound('sound/AI/commandreport.ogg')

/proc/gtGenerateTasks()

	var/list/active_with_role = gtActiveWithRole()

	var/count = 2
	//rand(1, 2)

	while(count)
		if(prob(5 + active_with_role["Cargo"]*5 + active_with_role["Assistant"]*2 + active_with_role["Badass"]) > (RESOURSES_FOR_CC in gtTaskIDs))
			gtAddTask(RESOURSES_FOR_CC)
			count--
			continue
		if(prob(5 + active_with_role["Cargo"]*5 + active_with_role["Assistant"]*2 + active_with_role["Badass"] + active_with_role["Senior head"]*5) > (RESOURSES_FOR_VAULT in gtTaskIDs))
			gtAddTask(RESOURSES_FOR_VAULT)
			count--
			continue

/proc/gtAddTask(var/task_type)
	var/datum/global_task/new_task

	if(!task_type)
		return

	switch(task_type)
		if(RESOURSES_FOR_CC)
			new_task = new /datum/global_task/resourses/centcomm
		if(RESOURSES_FOR_VAULT)
			new_task = new /datum/global_task/resourses/vault
		else
			return

	new_task.type_id = task_type
	gtCurrentTasks += new_task
	gtTaskIDs += task_type


/*
	//we can use it as a condition for some task
	//var/list/active_with_role = number_active_with_role()	//from event_dynamic.dm
	//example: active_with_role["Atmospheric Technician"]

	//временное решение для теста, потом проставить зависимость от проф и шансы
	//if(!task)
	//	task = pick(RESOURSES_FOR_CC, RESOURSES_FOR_VAULT, RESEARCH_LEVEL, BUILD_BAY, NO_CREW_DEATHS, NO_ONE_ASSISTENT)

	//if(task in gtTaskIDs)
	//	return
	// сделать вычитанием листов между текущими и возможными

	task = RESOURSES_FOR_CC

	//switch(task)
		//if(RESOURSES_FOR_CC)
	var/datum/global_task/resourses/centcomm/new_task = new /datum/global_task/resourses/centcomm
	gtCurrentTasks.Add(new_task)
	gtTaskIDs.Add(new_task.type_id)

	world << new_task.desc
*/
/proc/gtDeclareCompletion()

	var/message = "<big><b>Crew objectives were:</b></big><br><br>"
	var/number = 1

	for(var/datum/global_task/T in gtCurrentTasks)

		T.result()

		message += "<b>Objective #[number]</b>: [T.name] "
		if(T.success)
			message += "<font color='green'><b>Success!</b></font>"
		else
			message += " <font color='red'><b>Fail.</b></font>"

		message += "<br>"
		message += T.result_message
		number++

	world << message