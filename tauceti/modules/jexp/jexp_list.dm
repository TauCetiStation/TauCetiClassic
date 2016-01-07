//List of titles and alt-titles for each job
//Format: "title_name" = list("department_name", points per time)
var/list/jexp_jobs_xptable = list(
	"Captain"					= list("command", 1),
	"Head of Personnel"			= list("command", 1),
	"Chief Engineer"			= list("command", 1),
	"Chief Medical Officer"		= list("command", 1),
	"Research Director"			= list("command", 1),
	"Head of Security"			= list("command", 1),
	"Security Cadet"			= list("security", 1),
	"Warden"					= list("security", 1),
	"Detective"					= list("security", 1),
	"Security Officer"			= list("security", 1),
	"Forensic Technician"		= list("security", 1),
	"Bartender"					= list("civilian", 1),
	"Chef"						= list("civilian", 1),
	"Botanist"					= list("civilian", 1),
	"Hydroponicist"				= list("civilian", 1),
	"Janitor"					= list("civilian", 1),
	"Librarian"					= list("civilian", 1),
	"Internal Affairs Agent"	= list("civilian", 1),
	"Clown"						= list("civilian", 1),
	"Mime"						= list("civilian", 1),
	"Chaplain"					= list("civilian", 1),
	"Counselor"					= list("civilian", 1),
	"Lawyer"					= list("civilian", 1),
	"Private Eye"				= list("civilian", 1),
	"Reporter"					= list("civilian", 1),
	"Waiter"					= list("civilian", 1),
	"Paranormal Investigator"	= list("civilian", 1),
	"Vice Officer"				= list("civilian", 1),
	"Quartermaster"				= list("cargo", 1),
	"Cargo Technician"			= list("cargo", 1),
	"Shaft Miner"				= list("cargo", 1),
	"Medical Intern"			= list("medical", 1),
	"Medical Doctor"			= list("medical", 1),
	"Surgeon"					= list("medical", 1),
	"Emergency Physician"		= list("medical", 1),
	"Nurse"						= list("medical", 1),
	"Chemist"					= list("medical", 1),
	"Pharmacist"				= list("medical", 1),
	"Virologist"				= list("medical", 1),
	"Pathologist"				= list("medical", 1),
	"Microbiologist"			= list("medical", 1),
	"Psychiatrist"				= list("medical", 1),
	"Psychologist"				= list("medical", 1),
	"Research Assistant"		= list("science", 1),
	"Mecha Operator"			= list("science", 1),
	"Test Subject"				= list("science", 1),
	"Geneticist"				= list("science", 1),
	"Scientist"					= list("science", 1),
	"Xenoarcheologist"			= list("science", 1),
	"Anomalist"					= list("science", 1),
	"Phoron Researcher"			= list("science", 1),
	"Xenobiologist"				= list("science", 1),
	"Roboticist"				= list("science", 1),
	"Biomechanical Engineer"	= list("science", 1),
	"Mechatronic Engineer"		= list("science", 1),
	"Technical Assistant"		= list("engineering", 1),
	"Station Engineer"			= list("engineering", 1),
	"Maintenance Technician"	= list("engineering", 1),
	"Engine Technician"			= list("engineering", 1),
	"Electrician"				= list("engineering", 1),
	"Atmospheric Technician"	= list("engineering", 1),
	"AI"						= list("silicon", 1),
	"Cyborg"					= list("silicon", 1),
	"Android"					= list("silicon", 1),
	"Robot"						= list("silicon", 1),
	"Drone"						= list("silicon", 1)
	)

//list of departments
var/list/jexp_departments = list(
	"command",
	"security",
	"civilian",
	"cargo",
	"medical",
	"science",
	"engineering",
	"silicon"
)

/*
/mob/verb/test_1()
	set category = "Test"
	set name = "1"

	//world << jd_engineering["Technical Assistant"]

	var/list/test_list = jexp_jobs_xptable["Technical Assistant"]
	for(var/X in test_list)
		world << X
	world << jexp_jobs_xptable["Technical Assistant"][1]
	world << jexp_jobs_xptable["Technical Assistant"][2]

	//world << jd_engineering["Technical Assistant"]

	//world << get_job_department("Technical Assistant")

	//var/list/returned_list = get_job_department("Technical Assistant")
	//world << "[returned_list] : [returned_list[1]] : [returned_list[2]]"

/mob/verb/test_2()
	set category = "Test"
	set name = "save"

	src.client.jexp.save(usr)*/
