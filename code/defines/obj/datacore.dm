var/global/list/PDA_Manifest = list()
var/global/list/Silicon_Manifest = list()
var/global/ManifestJSON

/*
 * This item is completely unused, but removing it will break something in R&D and Radio code causing PDA and Ninja code to fail on compile
 */

/obj/effect/datacore
	name = "datacore"
	var/medical[] = list()
	var/general[] = list()
	var/security[] = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/locked[] = list()


/obj/effect/datacore/proc/remove_priority_field(list/L)
	for(var/list/R in L)
		R.Remove("priority")


/*
We can't just insert in HTML into the nanoUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /obj/effect/datacore/proc/manifest_inject( )
*/

/obj/effect/datacore/proc/load_manifest()
	if (PDA_Manifest.len)
		return

	var/heads[0]
	var/centcom[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/civ[0]
	var/bot[0]
	var/misc[0]

	for(var/datum/data/record/t in general)
		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]
		var/isactive = t.fields["p_stat"]

		var/account_number = t.fields["acc_number"]
		var/in_department = FALSE

		if(real_rank in command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = command_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in centcom_positions)
			centcom[++centcom.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = centcom_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = security_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = engineering_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = medical_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = science_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in civilian_positions)
			civ[++civ.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "priority" = civilian_positions.Find(real_rank))
			in_department = TRUE

		if(real_rank in nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive, "priority" = nonhuman_positions.Find(real_rank))
			in_department = TRUE

		if(!in_department)
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number)

	sortTim(heads, GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(centcom, GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(sec,   GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(eng,   GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(med,   GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(sci,   GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(civ,   GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	sortTim(bot,   GLOBAL_PROC_REF(cmp_job_titles), FALSE)

	remove_priority_field(heads)
	remove_priority_field(centcom)
	remove_priority_field(sec)
	remove_priority_field(eng)
	remove_priority_field(med)
	remove_priority_field(sci)
	remove_priority_field(civ)
	remove_priority_field(bot)

	PDA_Manifest = list(\
		"heads" = heads,\
		"centcom" = centcom,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"civ" = civ,\
		"bot" = bot,\
		"misc" = misc\
		)
	ManifestJSON = replacetext(json_encode(PDA_Manifest), "'", "`")

/obj/effect/datacore/proc/load_silicon_manifest()
	if(Silicon_Manifest.len)
		return

	for(var/mob/living/silicon/M as anything in silicon_list)
		var/name = "Unknown"
		var/is_active = "Inactive"
		var/rank = "Unknown"
		var/net = null
		var/prio = 99
		if((!isAI(M) && !isrobot(M)) || isdrone(M) || istype(M, /mob/living/silicon/robot/syndicate))
			continue
		name = sanitize(M.name)

		if(M.mind && M.mind.active && !M.is_dead())
			is_active = "Active"
		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			rank = sanitize("[R.modtype] [R.braintype]")
			// use tag as network ID for limit few AI crossview
			net = R.connected_ai ? ref(R.connected_ai) : ref(R)
			prio = 2
		if(isAI(M))
			rank = "AI"
			net = ref(M)
			prio = 1
		Silicon_Manifest[++Silicon_Manifest.len] = list("name" = name, "rank" = rank, "active" = is_active, "net" = net, "priority" = prio)

	sortTim(Silicon_Manifest, GLOBAL_PROC_REF(cmp_job_titles), FALSE)
	remove_priority_field(Silicon_Manifest)

/obj/effect/datacore/proc/get_manifest()
	load_manifest()
	return PDA_Manifest

// Using json manifest for html manifest. One proc for manifest generation
/obj/effect/datacore/proc/html_manifest(monochrome, OOC, silicon)
	// monochrome - render without color
	// OOC - use OOC active status and show all station silicon
	// silicon - use src to limit manifest AI network
	load_manifest()
	if (OOC || silicon)
		load_silicon_manifest()
	var/dat = {"
	<head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Status</th></tr>
	"}
	var/even = 0
	// Formating keyword -> Description
	var/list/departments_list = list(\
		"heads" = "Heads",\
		"centcom" = "NanoTrasen representatives",\
		"sec" = "Security",\
		"eng" = "Engineering",\
		"med" = "Medical",\
		"sci" = "Science",\
		"civ" = "Civilian",\
		"bot" = "Silicon",\
		"misc" = "Miscellaneous"\
	)
	var/list/inactive_players_namejob = new()
	// Collect inactive players-jobs if OOC
	if (OOC)
		for (var/mob/M in player_list)
			if (M.real_name && M.job && M.client && M.client.inactivity > 10 MINUTES)
				inactive_players_namejob.Add("[M.real_name]/[M.job]")
	// render crew manifest
	var/list/person = new() // buffer for employ record
	for (var/dep in departments_list)
		if((dep in PDA_Manifest) && length(PDA_Manifest[dep]))
			dat += "<tr><th colspan=3>[departments_list[dep]]</th></tr>"
			for(person in PDA_Manifest[dep])
				dat += "<tr[even ? " class='alt'" : ""]>"
				dat += "<td>[person["name"]]</td>"
				dat += "<td>[person["rank"]]</td>"
				// Show real activity player
				if (OOC)
					var/namejob = "[person["name"]]/[person["rank"]]"
					if(namejob in inactive_players_namejob)
						dat += "<td>Inactive</td>"
					else
						dat += "<td>[person["active"]]</td>"
				// Show record activity
				else
					dat += "<td>[person["active"]]</td>"
				dat +="</tr>"
				even = !even
		even = 0
	if ((OOC || silicon) && Silicon_Manifest.len)
		dat += "<tr><th colspan=3>Silicon</th></tr>"
		for (var/list/D in Silicon_Manifest)
			if (!istype(D))
				continue
			// limit view to connected AI and borgs
			if (silicon)
				if (!D["net"])
					continue
				var/usr_net
				if (isrobot(usr))
					var/mob/living/silicon/robot/R = usr
					usr_net = R.connected_ai ? ref(R.connected_ai) : ref(R)
				if (isAI(usr))
					usr_net = ref(usr)
				if (!usr_net || (usr_net != D["net"]))
					continue
			dat += "<tr[even ? " class='alt'" : ""]>"
			dat += "<td>[D["name"]]</td><td>[D["rank"]]</td><td>[D["active"]]</td>"
			dat += "</tr>"
			even = !even
	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat

/obj/effect/datacore/proc/manifest()
	set waitfor = FALSE
	for(var/mob/living/carbon/human/H in player_list)
		manifest_inject(H, H.client)

		CHECK_TICK

/obj/effect/datacore/proc/manifest_modify(name, assignment)
	PDA_Manifest.Cut()
	var/datum/data/record/foundrecord
	var/real_title = assignment

	for(var/datum/data/record/t in general)
		if (t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	var/list/all_jobs = get_job_datums()

	for(var/datum/job/J in all_jobs)
		var/list/alttitles = get_alternate_titles(J.title)
		if(!J)
			continue
		if(assignment in alttitles)
			real_title = J.title
			break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["real_rank"] = real_title

/obj/effect/datacore/proc/manifest_inject(mob/living/carbon/human/H, client/C)
	set waitfor = FALSE
	PDA_Manifest.Cut()

	if(H.mind && (H.mind.assigned_role != "MODE"))
		var/assignment
		if(H.mind.role_alt_title)
			assignment = H.mind.role_alt_title
		else if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		var/static/record_id_num = 1001
		var/id = num2hex(record_id_num++, 6)
		if(!C)
			C = H.client

		//General Record
		//Creating photo
		var/icon/ticon = get_id_photo(H, C, cardinal)
		var/icon/photo_front = new(ticon, dir = SOUTH)
		var/icon/photo_side = new(ticon, dir = WEST)
		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["real_rank"]	= H.mind.assigned_role
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		G.fields["fingerprint"]	= md5(H.dna.uni_identity)
		G.fields["insurance_account_number"] = H.mind.get_key_memory(MEM_ACCOUNT_NUMBER)
		G.fields["insurance_type"] = H.roundstart_insurance
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= H.gender
		G.fields["species"]		= H.get_species()
		G.fields["home_system"]	= H.home_system
		G.fields["citizenship"]	= H.citizenship
		G.fields["faction"]		= H.personal_faction
		G.fields["religion"]	= H.religion
		G.fields["photo_f"]		= photo_front
		G.fields["photo_s"]		= photo_side
		if(H.gen_record && !jobban_isbanned(H, "Records"))
			G.fields["notes"] = H.gen_record
		else
			G.fields["notes"] = "No notes found."

		var/acc_number = H.mind.get_key_memory(MEM_ACCOUNT_NUMBER)
		if(!acc_number)
			acc_number = 0
		G.fields["acc_number"] = acc_number

		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["b_type"]		= H.dna.b_type
		M.fields["b_dna"]		= H.dna.unique_enzymes ? H.dna.unique_enzymes : "None"
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		if(H.med_record && !jobban_isbanned(H, "Records"))
			M.fields["notes"] = H.med_record
		else
			M.fields["notes"] = "No notes found."
		medical += M

		//Security Record
		var/datum/data/record/S = new()
		S.fields["id"]			= id
		S.fields["name"]		= H.real_name
		S.fields["criminal"]	= "None"
		S.fields["mi_crim"]		= "None"
		S.fields["mi_crim_d"]	= "No minor crime convictions."
		S.fields["ma_crim"]		= "None"
		S.fields["ma_crim_d"]	= "No major crime convictions."
		S.fields["notes"]		= "No notes."
		if(H.sec_record && !jobban_isbanned(H, "Records"))
			S.fields["notes"] = H.sec_record
		else
			S.fields["notes"] = "No notes."
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= H.gender
		L.fields["b_type"]		= H.dna.b_type
		L.fields["b_dna"]		= H.dna.unique_enzymes ? H.dna.unique_enzymes : "None"
		L.fields["enzymes"]		= H.dna.SE // Used in respawning
		L.fields["home_system"]	= H.home_system
		L.fields["citizenship"]	= H.citizenship
		L.fields["faction"]		= H.personal_faction
		L.fields["religion"]	= H.religion
		L.fields["identity"]	= H.dna.UI
		L.fields["image"]		= ticon
		locked += L

		SSStatistics.score.crew_total++
