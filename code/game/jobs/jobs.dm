
var/global/const/ENGSEC             =(1<<0)

var/global/const/CAPTAIN            =(1<<0)
var/global/const/HOS                =(1<<1)
var/global/const/WARDEN             =(1<<2)
var/global/const/DETECTIVE          =(1<<3)
var/global/const/OFFICER            =(1<<4)
var/global/const/CHIEF              =(1<<5)
var/global/const/ENGINEER           =(1<<6)
var/global/const/ATMOSTECH          =(1<<7)
var/global/const/AI                 =(1<<8)
var/global/const/CYBORG             =(1<<9)
var/global/const/FORENSIC           =(1<<10)
var/global/const/CADET              =(1<<11)
var/global/const/TECHNICASSISTANT   =(1<<12)

var/global/const/CENTCOMREPRESENT   =(1<<1)

var/global/const/LAWYER             =(1<<0)
var/global/const/BLUESHIELD  		=(1<<1)

var/global/const/MEDSCI             =(1<<2)

var/global/const/RD                 =(1<<0)
var/global/const/SCIENTIST          =(1<<1)
var/global/const/CHEMIST            =(1<<2)
var/global/const/CMO                =(1<<3)
var/global/const/DOCTOR             =(1<<4)
var/global/const/GENETICIST         =(1<<5)
var/global/const/VIROLOGIST         =(1<<6)
var/global/const/PSYCHIATRIST       =(1<<7)
var/global/const/ROBOTICIST         =(1<<8)
var/global/const/XENOBIOLOGIST      =(1<<9)
var/global/const/PARAMEDIC          =(1<<10)
var/global/const/XENOARCHAEOLOGIST  =(1<<11)
var/global/const/INTERN             =(1<<12)
var/global/const/RESEARCHASSISTANT  =(1<<13)

var/global/const/CIVILIAN           =(1<<3)

var/global/const/HOP                =(1<<0)
var/global/const/BARTENDER          =(1<<1)
var/global/const/BOTANIST           =(1<<2)
var/global/const/CHEF               =(1<<3)
var/global/const/JANITOR            =(1<<4)
var/global/const/LIBRARIAN          =(1<<5)
var/global/const/QUARTERMASTER      =(1<<6)
var/global/const/CARGOTECH          =(1<<7)
var/global/const/MINER              =(1<<8)
var/global/const/CHAPLAIN           =(1<<9)
var/global/const/CLOWN              =(1<<10)
var/global/const/MIME               =(1<<11)
var/global/const/ASSISTANT          =(1<<12)
var/global/const/RECYCLER           =(1<<13)
var/global/const/BARBER             =(1<<14)


var/global/list/assistant_occupations = list(
)


/*
Attention!
Order of ranks in *_positions lists below is used to sort crew manifest by such ranks
*/

var/global/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)

var/global/list/centcom_positions = list(
	"Blueshield Officer",
	"Internal Affairs Agent"
)

var/global/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Forensic Technician",
	"Security Officer",
	"Security Cadet"
)

var/global/list/engineering_positions = list(
	"Chief Engineer",
	"Station Engineer",
	"Atmospheric Technician",
	"Technical Assistant"
)

var/global/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Paramedic",
	"Chemist",
	"Geneticist", //Part of both medical and science
	"Virologist",
	"Psychiatrist",
	"Medical Intern"
)

var/global/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Roboticist",
	"Geneticist", //Part of both medical and science
	"Xenobiologist",
	"Xenoarchaeologist",
	"Research Assistant"
)

var/global/list/civilian_positions = list(
	"Head of Personnel",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Recycler",
	"Chef",
	"Bartender",
	"Botanist",
	"Clown",
	"Mime",
	"Chaplain",
	"Janitor",
	"Barber",
	"Librarian",
	"Assistant"
)

var/global/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI"
)

var/global/list/heads_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
)

var/global/list/protected_by_blueshield_list = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer",
	"Internal Affairs Agent"
)



/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			titles = J.alt_titles

	return titles

/proc/my_subordinate_staff(head_rank)	//the function takes a rank, returns a list of subordinate personnel

	var/all_staff = data_core.get_manifest()	//crew manifest
	var/list/data = list()	//it will be returned
	var/list/own_department = list()
	var/list/QM_staff = list("Cargo Technician", "Shaft Miner", "Recycler")	//QM's boys

	switch(head_rank)	//What departments do we manage?
		if("Admin")
			own_department = list("heads", "centcom", "sec", "eng", "med", "sci", "civ", "misc")	//all except bots
		if("Captain")
			own_department = list("sec", "eng", "med", "sci", "civ", "misc")	//exept "heads", repetitions we don't need
		if("Head of Personnel")
			own_department = list("civ", "misc")
		if("Head of Security")
			own_department = list("sec")
		if("Chief Engineer")
			own_department = list("eng")
		if("Research Director")
			own_department = list("sci")
		if("Chief Medical Officer")
			own_department = list("med")
		if("Quartermaster")
			own_department = list("civ")

	for(var/department in own_department)
		for(var/person in all_staff[department])
			if(head_rank == person["rank"])	//we will not change the salary for yourself
				continue
			if(department == "med" && (head_rank == "Admin" || head_rank == "Captain") && person["rank"] == "Geneticist")	//so that the geneticist would not repeat twice
				continue	//there is a geneticist in "sci"
			if(department == "heads" && person["rank"] != "Captain")	//in "heads" we need only Captain
				continue
			if(department == "civ")
				if(head_rank != "Admin" && person["rank"] == "Internal Affairs Agent")	//only CentCom can change IAA's salary
					continue
				if(head_rank != "Admin" && person["rank"] == "Blueshield Officer")
					continue
				if(head_rank == "Quartermaster" && !QM_staff.Find(person["rank"]))	//QM only rules his boys
					continue

			var/datum/money_account/MA = get_account(person["account"])
			if(!MA)
				continue

			data[++data.len] = list("name" = person["name"], "rank" = person["rank"], "salary" = MA.owner_salary, "account" = person["account"])

	return data	// --> list(real_name, assignment, salary, account_number)
