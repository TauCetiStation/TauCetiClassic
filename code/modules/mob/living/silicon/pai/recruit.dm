// Recruiting observers to play as pAIs

var/global/datum/paiController/paiController			// Global handler for pAI candidates

/datum/paiCandidate
	var/name
	var/key
	var/description
	var/role
	var/comments
	var/ready = 0

/datum/paiController
	var/list/pai_candidates = list()

/datum/paiController/Topic(href, href_list[])
	if(href_list["download"])
		var/datum/paiCandidate/candidate = locate(href_list["candidate"])
		var/obj/item/device/paicard/card = locate(href_list["device"])
		if(card.pai)
			return
		if(istype(card,/obj/item/device/paicard) && istype(candidate,/datum/paiCandidate))
			var/mob/living/silicon/pai/pai = new(card)
			if(!candidate.name)
				pai.name = pick(ninja_names)
			else
				pai.name = candidate.name
			pai.real_name = pai.name
			pai.key = candidate.key

			card.setPersonality(pai)
			card.looking_for_personality = 0


			pai_candidates -= candidate
			usr << browse(null, "window=findPai")

	if(href_list["new"])
		var/datum/paiCandidate/candidate = locate(href_list["candidate"])
		var/option = href_list["option"]
		var/t = ""

		switch(option)
			if("name")
				t = sanitize_safe(input("Enter a name for your pAI", "pAI Name", input_default(candidate.name)) as text)
				if(t)
					candidate.name = t
			if("desc")
				t = sanitize(input("Enter a description for your pAI", "pAI Description", input_default(candidate.description)) as message)
				if(t)
					candidate.description = t
			if("role")
				t = sanitize(input("Enter a role for your pAI", "pAI Role", input_default(candidate.role)) as text)
				if(t)
					candidate.role = t
			if("ooc")
				t = sanitize(input("Enter any OOC comments", "pAI OOC Comments", input_default(candidate.comments)) as message)
				if(t)
					candidate.comments = t
			if("save")
				candidate.savefile_save(usr)
			if("load")
				candidate.savefile_load(usr)
				//In case people have saved unsanitized stuff.
				if(candidate.name)
					candidate.name = sanitize_safe(candidate.name, MAX_NAME_LEN)
				if(candidate.description)
					candidate.description = sanitize(candidate.description, MAX_MESSAGE_LEN)
				if(candidate.role)
					candidate.role = sanitize(candidate.role, MAX_MESSAGE_LEN)
				if(candidate.comments)
					candidate.comments = sanitize(candidate.comments, MAX_MESSAGE_LEN)

			if("submit")
				if(candidate)
					candidate.ready = 1
					for(var/obj/item/device/paicard/p in paicard_list)
						if(p.looking_for_personality == 1)
							p.alertUpdate()
				usr << browse(null, "window=paiRecruit")
				return
		recruitWindow(usr)

/datum/paiController/proc/recruitWindow(mob/M)
	var/datum/paiCandidate/candidate
	for(var/datum/paiCandidate/c in pai_candidates)
		if(!istype(c) || !istype(M))
			break
		if(c.key == M.key)
			candidate = c
	if(!candidate)
		candidate = new /datum/paiCandidate()
		candidate.key = M.key
		pai_candidates.Add(candidate)


	var/dat = ""
	dat += {"
		<head>
			<style type="text/css">
				body {
					margin-top:5px;
					font-family:Verdana;
					color:white;
					font-size:13px;
					background-image:url('uiBackground.png');
					background-repeat:repeat-x;
					background-color:#272727;
					background-position:center top;
				}
				table {
					border-collapse:collapse;
					font-size:13px;
				}
				th, td {
					border: 1px solid #333333;
				}
				p.top {
					background-color: none;
					color: white;
				}
				tr.d0 td {
					background-color: #c0c0c0;
					color: black;
					border:0px;
					border: 1px solid #333333;
				}
				tr.d0 th {
					background-color: none;
					color: #4477E0;
					text-align:right;
					vertical-align:top;
					width:120px;
					border:0px;
				}
				tr.d1 td {
					background-color: #555555;
					color: white;
				}
				td.button {
					border: 1px solid #161616;
					background-color: #40628a;
				}
				td.desc {
					font-weight:bold;
				}
				a {
					color:#4477E0;
				}
				a.button {
					color:white;
					text-decoration: none;
				}
			</style>
			[get_browse_zoom_style(M.client)]
		</head>
		"}

	dat += {"
	<body>
		<b><font size="3px">pAI Personality Configuration</font></b>
		<p class="top">Please configure your pAI personality's options. Remember, what you enter here could determine whether or not the user requesting a personality chooses you!</p>

		<table>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=\ref[src];option=name;new=1;candidate=\ref[candidate]'>Name</a>:</th>
				<td class="desc">[candidate.name]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>What you plan to call yourself. Suggestions: Any character name you would choose for a station character OR an AI.</td>
			</tr>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=\ref[src];option=desc;new=1;candidate=\ref[candidate]'>Description</a>:</th>
				<td class="desc">[candidate.description]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>What sort of pAI you typically play; your mannerisms, your quirks, etc. This can be as sparse or as detailed as you like.</td>
			</tr>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=\ref[src];option=role;new=1;candidate=\ref[candidate]'>Preferred Role</a>:</th>
				<td class="desc">[candidate.role]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>Do you like to partner with sneaky social ninjas? Like to help security hunt down thugs? Enjoy watching an engineer's back while he saves the station yet again? This doesn't have to be limited to just station jobs. Pretty much any general descriptor for what you'd like to be doing works here.</td>
			</tr>
			<tr class="d0">
				<th rowspan="2"><a href='byond://?src=\ref[src];option=ooc;new=1;candidate=\ref[candidate]'>OOC Comments</a>:</th>
				<td class="desc">[candidate.comments]&nbsp;</td>
			</tr>
			<tr class="d1">
				<td>Anything you'd like to address specifically to the player reading this in an OOC manner. \"I prefer more serious RP.\", \"I'm still learning the interface!\", etc. Feel free to leave this blank if you want.</td>
			</tr>
		</table>
		<br>
		<table>
			<tr>
				<td class="button">
					<a href='byond://?src=\ref[src];option=save;new=1;candidate=\ref[candidate]' class="button">Save Personality</a>
				</td>
			</tr>
			<tr>
				<td class="button">
					<a href='byond://?src=\ref[src];option=load;new=1;candidate=\ref[candidate]' class="button">Load Personality</a>
				</td>
			</tr>
		</table><br>
		<table>
			<td class="button"><a href='byond://?src=\ref[src];option=submit;new=1;candidate=\ref[candidate]' class="button"><b><font size="4px">Submit Personality</font></b></a></td>
		</table><br>

	<body>
	"}

	M << browse(dat, "window=paiRecruit;[get_browse_size_parameter(M.client, 580, 580)];")

/datum/paiController/proc/findPAI(obj/item/device/paicard/p, mob/user)
	if(!p.searching)
		p.searching = TRUE
		addtimer(CALLBACK(p, TYPE_PROC_REF(/obj/item/device/paicard, reset_searching)), 3 MINUTES)
		requestRecruits()
	var/list/available = list()
	for(var/datum/paiCandidate/c in paiController.pai_candidates)
		if(c.ready)
			var/found = 0
			for(var/mob/dead/observer/o in player_list)
				if(o.key == c.key)
					found = 1
			if(found)
				available.Add(c)
	var/dat = ""

	dat += {"
		<!DOCTYPE html>
		<html>
			<head>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
				<style>
					body {
						margin-top:5px;
						font-family:Verdana;
						color:white;
						font-size:13px;
						background-image:url('uiBackground.png');
						background-repeat:repeat-x;
						background-color:#272727;
						background-position:center top;
					}
					table {
						font-size:13px;
					}
					table.desc {
						border-collapse:collapse;
						font-size:13px;
						border: 1px solid #161616;
						width:100%;
					}
					table.download {
						border-collapse:collapse;
						font-size:13px;
						border: 1px solid #161616;
						width:100%;
					}
					tr.d0 td, tr.d0 th {
						background-color: #506070;
						color: white;
					}
					tr.d1 td, tr.d1 th {
						background-color: #708090;
						color: white;
					}
					tr.d2 td {
						background-color: #00FF00;
						color: white;
						text-align:center;
					}
					td.button {
						border: 1px solid #161616;
						background-color: #40628a;
						text-align: center;
					}
					td.download {
						border: 1px solid #161616;
						background-color: #40628a;
						text-align: center;
					}
					th {
						text-align:left;
						width:125px;
						vertical-align:top;
					}
					a.button {
						color:white;
						text-decoration: none;
					}
				</style>
			</head>
			<body>
				<b><font size='3px'>pAI Availability List</font></b><br><br>
	"}
	dat += "<p>Displaying available AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>"

	for(var/datum/paiCandidate/c in available)
		dat += {"
				<table class="desc">
					<tr class="d0">
						<th>Name:</th>
						<td>[c.name]</td>
					</tr>
					<tr class="d1">
						<th>Description:</th>
						<td>[c.description]</td>
					</tr>
					<tr class="d0">
						<th>Preferred Role:</th>
						<td>[c.role]</td>
					</tr>
					<tr class="d1">
						<th>OOC Comments:</th>
						<td>[c.comments]</td>
					</tr>
				</table>
				<table class="download">
					<td class="download"><a href='byond://?src=\ref[src];download=1;candidate=\ref[c];device=\ref[p]' class="button"><b>Download [c.name]</b></a>
					</td>
				</table>
				<br>
		"}

	dat += {"
			</body>
		</html>
	"}

	user << browse(dat, "window=findPai")

/datum/paiController/proc/requestRecruits()
	var/list/candidates = pollGhostCandidates("Someone is requesting a pAI personality. Would you like to play as a personal AI?", ROLE_GHOSTLY, IGNORE_PAI, 100, TRUE)
	for(var/mob/M in candidates)
		recruitWindow(M)
