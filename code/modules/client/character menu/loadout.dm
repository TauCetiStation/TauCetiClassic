/datum/preferences/proc/ShowCustomLoadout(mob/user)
	var/total_cost = 0
	var/list/type_blacklist = list()
	if(gear && gear.len)
		for(var/i = 1 to gear.len)
			var/datum/gear/G = gear_datums[gear[i]]
			if(G)
				if(!G.subtype_cost_overlap)
					if(G.subtype_path in type_blacklist)
						continue
					type_blacklist += G.subtype_path
				total_cost += G.cost

	var/fcolor =  "#3366cc"
	var/max_cost = user.client.supporter ? MAX_GEAR_COST_SUPPORTER : MAX_GEAR_COST
	if(total_cost < max_cost)
		fcolor = "#e67300"
	. += "<table align='center' width='570px'>"
	. += "<tr><td colspan=3><center><b><font color='[fcolor]'>[total_cost]/[max_cost]</font> loadout points spent.</b> \[<a href='?_src_=prefs;preference=loadout;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
	. += "<tr><td colspan=3><center><b>"

	var/firstcat = 1
	for(var/category in loadout_categories + list("Custom items"))
		if(firstcat)
			firstcat = 0
		else
			. += " |"
		if(category == gear_tab)
			. += " <b>[category]</b> "
		else
			. += " <a href='?_src_=prefs;preference=loadout;select_category=[category]'>[category]</a> "
	. += "</b></center></td></tr>"
	if(gear_tab == "Custom items")
		. += FluffLoadout(user)
		return .

	var/datum/loadout_category/LC = loadout_categories[gear_tab]
	. += "<tr><td colspan=3><hr></td></tr>"
	. += "<tr><td colspan=3><b><center>[LC.category]</center></b></td></tr>"
	. += "<tr><td colspan=3><hr></td></tr>"
	for(var/gear_name in LC.gear)
		var/datum/gear/G = LC.gear[gear_name]
		var/ticked = (G.display_name in gear)
		. += "<tr style='vertical-align:top;'><td width=15%><a style='white-space:normal;' [ticked ? "style='font-weight:bold' " : ""]href='?_src_=prefs;preference=loadout;toggle_gear=[G.display_name]'>[G.display_name]</a></td>"
		. += "<td width = 5% style='vertical-align:top'>[G.cost]</td>"
		. += "<td><font size=2><i>[G.description]</i></font></td>"
		. += "</tr>"
		if(G.allowed_roles)
			. += "<tr><td colspan=3><font size=2>Restrictions: "
			var/aroles
			for(var/role in G.allowed_roles)
				if(!aroles)
					aroles = "[role]"
				else
					aroles +=  ", [role]"
			. += aroles
			. += "</font></td></tr>"

		if(ticked)
			. += "<tr><td colspan=3>"
			for(var/datum/gear_tweak/tweak in G.gear_tweaks)
				. += " <a href='?_src_=prefs;preference=loadout;gear=[G.display_name];tweak=\ref[tweak]'>[tweak.get_contents(get_tweak_metadata(G, tweak))]</a>"
			. += "</td></tr>"
	. += "</table>"

/datum/preferences/proc/process_link_loadout(mob/user, list/href_list)
	if(href_list["toggle_gear"])
		var/datum/gear/TG = gear_datums[href_list["toggle_gear"]]
		if(TG.display_name in gear)
			gear -= TG.display_name
		else
			var/total_cost = 0
			var/list/type_blacklist = list()
			for(var/gear_name in gear)
				var/datum/gear/G = gear_datums[gear_name]
				if(istype(G))
					if(!G.subtype_cost_overlap)
						if(G.subtype_path in type_blacklist)
							continue
						type_blacklist += G.subtype_path
					total_cost += G.cost

			if((total_cost + TG.cost) <= (user.client.supporter ? MAX_GEAR_COST_SUPPORTER : MAX_GEAR_COST))
				gear += TG.display_name
	else if(href_list["toggle_custom_gear"])
		toggle_custom_item(user, href_list["toggle_custom_gear"])

	else if(href_list["gear"] && href_list["tweak"])
		var/datum/gear/G = gear_datums[href_list["gear"]]
		var/datum/gear_tweak/tweak = locate(href_list["tweak"])
		if(!tweak || !istype(G) || !(tweak in G.gear_tweaks))
			return
		var/metadata = tweak.get_metadata(user, get_tweak_metadata(G, tweak))
		if(!metadata)
			return
		set_tweak_metadata(G, tweak, metadata)
	else if(href_list["select_category"])
		gear_tab = href_list["select_category"]
	else if(href_list["clear_loadout"])
		gear.Cut()

	ShowChoices(user)
	return


var/list/loadout_categories = list()
var/list/gear_datums = list()

/datum/loadout_category
	var/category = ""
	var/list/gear = list()

/datum/loadout_category/New(cat)
	category = cat
	..()

/proc/populate_gear_list()
	//create a list of gear datums to sort
	for(var/geartype in subtypesof(/datum/gear))
		var/datum/gear/G = geartype

		var/use_name = initial(G.display_name)
		var/use_category = initial(G.sort_category)

		if(G == initial(G.subtype_path))
			continue

		if(!use_name)
			error("Loadout - Missing display name: [G]")
			continue
		if(!initial(G.cost))
			error("Loadout - Missing cost: [G]")
			continue
		if(!initial(G.path))
			error("Loadout - Missing path definition: [G]")
			continue

		if(!loadout_categories[use_category])
			loadout_categories[use_category] = new /datum/loadout_category(use_category)
		var/datum/loadout_category/LC = loadout_categories[use_category]
		gear_datums[use_name] = new geartype
		LC.gear[use_name] = gear_datums[use_name]

	loadout_categories = sortAssoc(loadout_categories)
	for(var/loadout_category in loadout_categories)
		var/datum/loadout_category/LC = loadout_categories[loadout_category]
		LC.gear = sortAssoc(LC.gear)
	return 1


/datum/gear
	var/display_name       //Name/index. Must be unique.
	var/description        //Description of this gear. If left blank will default to the description of the pathed item.
	var/path               //Path to item.
	var/cost = 1           //Number of points used. Items in general cost 1 point, storage/armor/gloves/special use costs 2 points.
	var/slot               //Slot to equip to.
	var/list/allowed_roles //Roles that can spawn with this item.
	var/whitelisted        //Term to check the whitelist for..
	var/sort_category = "General"
	var/list/gear_tweaks = list() //List of datums which will alter the item after it has been spawned.
	var/subtype_path = /datum/gear //for skipping organizational subtypes (optional)
	var/subtype_cost_overlap = TRUE //if subtypes can take points at the same time

/datum/gear/New()
	..()
	if(!description)
		var/obj/O = path
		description = initial(O.desc)

/datum/gear_data
	var/path
	var/location

/datum/gear_data/New(npath, nlocation)
	path = npath
	location = nlocation

/datum/gear/proc/spawn_item(location, metadata)
	var/datum/gear_data/gd = new(path, location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_gear_data(metadata["[gt]"], gd)
	var/item = new gd.path(gd.location)
	for(var/datum/gear_tweak/gt in gear_tweaks)
		gt.tweak_item(item, metadata["[gt]"])
	return item

/datum/preferences/proc/get_gear_metadata(datum/gear/G)
	. = gear[G.display_name]
	if(!.)
		. = list()
		gear[G.display_name] = .

/datum/preferences/proc/get_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak)
	var/list/metadata = get_gear_metadata(G)
	. = metadata["[tweak]"]
	if(!.)
		. = tweak.get_default()
		metadata["[tweak]"] = .

/datum/preferences/proc/set_tweak_metadata(datum/gear/G, datum/gear_tweak/tweak, new_metadata)
	var/list/metadata = get_gear_metadata(G)
	metadata["[tweak]"] = new_metadata
