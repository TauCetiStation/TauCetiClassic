
var/const/ENGSEC			=(1<<0)

var/const/CAPTAIN			=(1<<0)
var/const/HOS				=(1<<1)
var/const/WARDEN			=(1<<2)
var/const/DETECTIVE			=(1<<3)
var/const/OFFICER			=(1<<4)
var/const/CHIEF				=(1<<5)
var/const/ENGINEER			=(1<<6)
var/const/ATMOSTECH			=(1<<7)
var/const/AI				=(1<<8)
var/const/CYBORG			=(1<<9)
var/const/FORENSIC			=(1<<10)
var/const/CADET             =(1<<11)
var/const/TECHNICASSISTANT	=(1<<12)

var/const/MEDSCI			=(1<<1)

var/const/RD				=(1<<0)
var/const/SCIENTIST			=(1<<1)
var/const/CHEMIST			=(1<<2)
var/const/CMO				=(1<<3)
var/const/DOCTOR			=(1<<4)
var/const/GENETICIST		=(1<<5)
var/const/VIROLOGIST		=(1<<6)
var/const/PSYCHIATRIST		=(1<<7)
var/const/ROBOTICIST		=(1<<8)
var/const/XENOBIOLOGIST		=(1<<9)
var/const/PARAMEDIC			=(1<<10)
var/const/XENOARCHAEOLOGIST	=(1<<11)
var/const/INTERN			=(1<<12)
var/const/RESEARCHASSISTANT	=(1<<13)


var/const/CIVILIAN			=(1<<2)

var/const/HOP				=(1<<0)
var/const/BARTENDER			=(1<<1)
var/const/BOTANIST			=(1<<2)
var/const/CHEF				=(1<<3)
var/const/JANITOR			=(1<<4)
var/const/LIBRARIAN			=(1<<5)
var/const/QUARTERMASTER		=(1<<6)
var/const/CARGOTECH			=(1<<7)
var/const/MINER				=(1<<8)
var/const/LAWYER			=(1<<9)
var/const/CHAPLAIN			=(1<<10)
var/const/CLOWN				=(1<<11)
var/const/MIME				=(1<<12)
var/const/ASSISTANT			=(1<<13)
var/const/RECYCLER			=(1<<14)
var/const/BARBER			=(1<<15)

var/list/assistant_occupations = list(
)


var/list/command_positions = list(
	"Captain",
	"Head of Personnel",
	"Head of Security",
	"Chief Engineer",
	"Research Director",
	"Chief Medical Officer"
)


var/list/engineering_positions = list(
	"Chief Engineer",
	"Station Engineer",
	"Atmospheric Technician",
	"Technical Assistant"
)


var/list/medical_positions = list(
	"Chief Medical Officer",
	"Medical Doctor",
	"Geneticist",
	"Psychiatrist",
	"Chemist",
	"Virologist",
	"Paramedic",
	"Medical Intern"
)


var/list/science_positions = list(
	"Research Director",
	"Scientist",
	"Geneticist",	//Part of both medical and science
	"Roboticist",
	"Xenobiologist",
	"Xenoarchaeologist",
	"Research Assistant"
)

//BS12 EDIT
var/list/civilian_positions = list(
	"Head of Personnel",
	"Barber",
	"Bartender",
	"Botanist",
	"Chef",
	"Janitor",
	"Librarian",
	"Quartermaster",
	"Cargo Technician",
	"Shaft Miner",
	"Recycler",
	"Internal Affairs Agent",
	"Chaplain",
	"Test Subject",
	"Clown",
	"Mime"
)

var/list/security_positions = list(
	"Head of Security",
	"Warden",
	"Detective",
	"Security Officer",
	"Forensic Technician",
	"Security Cadet"
)


var/list/nonhuman_positions = list(
	"AI",
	"Cyborg",
	"pAI"
)


/proc/guest_jobbans(job)
	return job in command_positions

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
	
	var/all_staff = data_core.get_manifest_json()	//crew manifest
	var/list/data = list()	//it will be returned
	var/list/own_department = list()
	var/list/QM_staff = list("Cargo Technician", "Shaft Miner", "Recycler")	//QM's boys

	switch(head_rank)	//What departments do we manage?
		if("Admin")
			own_department = list("heads", "sec", "eng", "med", "sci", "civ", "misc")	//all except bots
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
				if(head_rank == "Quartermaster" && !QM_staff.Find(person["rank"]))	//QM only rules his boys
					continue
			var/datum/money_account/account = person["acc_datum"]
			data[++data.len] = list("name" = person["name"], "rank" = person["rank"], "salary" = account.owner_salary, "acc_datum" = person["acc_datum"], "acc_number" = person["account"])

	return data	// --> list(real_name, assignment, salary, /datum/money_account/, account_number)
