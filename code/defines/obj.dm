/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = 1
	density = 1

/obj/structure/signpost/attackby(obj/item/weapon/W, mob/user)
	return attack_hand(user)

/obj/structure/signpost/attack_hand(mob/user)
	switch(alert("Travel back to ss13?",,"Yes","No"))
		if("Yes")
			if(user.z != src.z)
				return
			user.loc.loc.Exited(user)
			user.loc = pick(latejoin)
		if("No")
			return
	user.SetNextMove(CLICK_CD_INTERACT)

/obj/effect/mark
	var/mark = ""
	icon = 'icons/misc/mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0
	unacidable = 1//Just to be sure.

/obj/effect/beam
	name = "beam"
	unacidable = 1//Just to be sure.
	var/def_zone
	pass_flags = PASSTABLE


/obj/effect/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0
	unacidable = 1

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


/*
We can't just insert in HTML into the nanoUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /obj/effect/datacore/proc/manifest_inject( ), or manifest_insert( )
*/

var/global/list/PDA_Manifest = list()
var/global/ManifestJSON

/obj/effect/datacore/proc/get_manifest_json()
	if(PDA_Manifest.len)
		return PDA_Manifest
	var/heads[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/civ[0]
	var/bot[0]
	var/misc[0]
	for(var/datum/data/record/t in data_core.general)
		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]
		var/isactive = t.fields["p_stat"]
		var/account_number = t.fields["acc_number"]
		var/account_datum = t.fields["acc_datum"]
		var/department = 0
		var/depthead = 0 			// Department Heads will be placed at the top of their lists.
		if(real_rank in command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)
			department = 1
			depthead = 1
			if(rank=="Captain" && heads.len != 1)
				heads.Swap(1,heads.len)

		if(real_rank in security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)
			department = 1
			if(depthead && sec.len != 1)
				sec.Swap(1,sec.len)

		if(real_rank in engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)
			department = 1
			if(depthead && eng.len != 1)
				eng.Swap(1,eng.len)

		if(real_rank in medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)
			department = 1
			if(depthead && med.len != 1)
				med.Swap(1,med.len)

		if(real_rank in science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)
			department = 1
			if(depthead && sci.len != 1)
				sci.Swap(1,sci.len)

		if(real_rank in civilian_positions)
			civ[++civ.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)
			department = 1
			if(depthead && civ.len != 1)
				civ.Swap(1,civ.len)

		if(real_rank in nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive, "account" = account_number, "acc_datum" = account_datum)


	PDA_Manifest = list(\
		"heads" = heads,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"civ" = civ,\
		"bot" = bot,\
		"misc" = misc\
		)
	ManifestJSON = replacetext(json_encode(PDA_Manifest), "'", "`")
	return PDA_Manifest

// Using json manifest for html manifest. One proc for manifest generation
/obj/effect/datacore/proc/get_manifest(monochrome, OOC)
	if (PDA_Manifest.len < 1)
		get_manifest_json()
	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Activity</th></tr>
	"}
	var/even = 0
	// Formating keyword -> Description
	var/list/departments_list = list(\
		"heads" = "Heads",\
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
			if (M.real_name && M.job && M.client && M.client.inactivity > 10 * 60 * 10)
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
						dat += "<td>Active</td>"
				// Show record activity
				else
					dat += "<td>[person["active"]]</td>"
				dat +="</tr>"
				even = !even
		even = 0
	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")
	return dat


/obj/effect/list_container
	name = "list container"

/obj/effect/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/effect/projection
	name = "Projection"
	desc = "This looks like a projection of something."
	anchored = 1.0


/obj/effect/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1
	unacidable = 1//temporary until I decide whether the borg can be removed. -veyveyr

/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/weapon/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	item_state = "beachball"
	density = 0
	anchored = 0
	w_class = ITEM_SIZE_SMALL
	force = 0.0
	throwforce = 0.0
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT

/obj/item/weapon/beach_ball/afterattack(atom/target, mob/user, proximity, params)
	user.drop_item()
	src.throw_at(target, throw_range, throw_speed, user)

/obj/effect/spawner
	name = "object spawner"
