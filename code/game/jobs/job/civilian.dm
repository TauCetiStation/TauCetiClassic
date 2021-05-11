// Это не по-настоящему, а всего-лишь тест агрессивного сбора фидбека по карго. Пожалуйста делайте вид что всерьёз
// ревьювите этот ПР, и что это не шутка, спасибо. ~Luduk

//Food
/datum/job/bartender
	title = "Bartender"
	flag = BARTENDER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_bar)
	salary = 40
	minimal_player_ingame_minutes = 240
	outfit = /datum/outfit/job/bartender
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(TAJARAN)


/datum/job/chef
	title = "Chef"
	flag = CHEF
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_kitchen)
	salary = 40
	alt_titles = list("Cook")
	minimal_player_ingame_minutes = 240
	outfit = /datum/outfit/job/chef
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(TAJARAN)


/datum/job/hydro
	title = "Botanist"
	flag = BOTANIST
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_hydroponics) // Removed tox and chem access because STOP PISSING OFF THE CHEMIST GUYS // //Removed medical access because WHAT THE FUCK YOU AREN'T A DOCTOR YOU GROW WHEAT //Given Morgue access because they have a viable means of cloning.
	salary = 60
	alt_titles = list("Hydroponicist")
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/hydro


/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_janitor, access_maint_tunnels, access_sec_doors, access_research, access_mailsorting, access_medical, access_engineering_lobby)
	salary = 50
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/janitor


//More or less assistants
/datum/job/barber
	title = "Barber"
	flag = BARBER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_barber)
	salary = 40
	alt_titles = list("Stylist" = /datum/outfit/job/stylist)
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/barber


/datum/job/librarian
	title = "Librarian"
	flag = LIBRARIAN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/civ
	access = list(access_library)
	salary = 40
	alt_titles = list("Journalist")
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/librarian


//var/global/lawyer = 0//Checks for another lawyer //This changed clothes on 2nd lawyer, both IA get the same dreds.
/datum/job/lawyer
	title = "Internal Affairs Agent"
	flag = LAWYER
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "The Central Command"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/int
	access = list(access_lawyer, access_sec_doors, access_medical, access_research, access_mailsorting, access_engine, access_engineering_lobby)
	salary = 200
	minimal_player_ingame_minutes = 1560
	outfit = /datum/outfit/job/lawyer
	/*
		HEY YOU!
		ANY TIME YOU TOUCH THIS, PLEASE CONSIDER GOING TO preferences_savefile.dm
		AND BUMPING UP THE SAVEFILE_VERSION_MAX, AND ALSO LOCATING THE "job_loop:" THINGY AND CHANGING
		THE VERSION THERE. CURRENTLY THE VERSION THERE IS 26.
		~Luduk
	*/
	restricted_species = list(SKRELL, UNATHI, TAJARAN, DIONA, VOX)


/datum/job/clown
	title = "Clown"
	flag = CLOWN
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/clown
	access = list(access_clown, access_theatre)
	salary = 20
	minimal_player_ingame_minutes = 120
	outfit = /datum/outfit/job/clown

/datum/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		H.mutations.Add(CLUMSY)

/datum/job/mime
	title = "Mime"
	flag = MIME
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/mime
	access = list(access_mime, access_theatre)
	salary = 20
	outfit = /datum/outfit/job/mime

/datum/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(!visualsOnly)
		H.verbs += /client/proc/mimespeak
		H.verbs += /client/proc/mimewall
		H.mind.special_verbs += /client/proc/mimespeak
		H.mind.special_verbs += /client/proc/mimewall
		H.miming = 1
