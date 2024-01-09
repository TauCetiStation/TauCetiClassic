/datum/faction/gang
	name = "Super Duper Gang" // Its name will be cnhanged
	ID = F_FAMILIES
	required_pref = ROLE_FAMILIES

	initroletype = /datum/role/gangster/leader
	roletype = /datum/role/gangster

	min_roles = 1
	max_roles = 2

	/// The number of family members more that a family may have over other active families. Can be set externally; used internally.
	var/gang_balance_cap = 5
	/// The abbreviation of this family.
	var/gang_id = "LLJK"
	/// Contains all graffiti created by gang
	var/list/gang_tags = list()
	/// The list of clothes that are acceptable to show allegiance to this family.
	var/list/acceptable_clothes = list()
	/// The list of clothes that are given to family members upon induction into the family.
	var/list/free_clothes = list()
	/// Each gang has its own type of objective
	var/gang_objective_type
	/// Used for gun dealers
	var/help_sent = FALSE

/datum/faction/gang/New()
	logo_state = gang_id
	..()

/datum/faction/gang/forgeObjectives()
	. = ..()
	AppendObjective(/datum/objective/gang/points)
	AppendObjective(gang_objective_type)
	AppendObjective(/datum/objective/gang/steal_lowrisk)

/datum/faction/gang/custom_result()
	var/alive_gangsters = 0
	var/alive_cops = 0
	for(var/datum/role/gangster/G in members)
		if(!ishuman(G.antag.current))
			continue
		var/mob/living/carbon/human/H = G.antag.current
		if(H.stat != CONSCIOUS)
			continue
		alive_gangsters++
	var/datum/faction/cops/C = find_faction_by_type(/datum/faction/cops)
	for(var/datum/role/cop/cop in C.members)
		if(!ishuman(cop.antag.current)) // always returns false
			continue
		var/mob/living/carbon/human/H = cop.antag.current
		if(H.stat != CONSCIOUS)
			continue
		alive_cops++
	if(alive_gangsters > alive_cops)
		return "<span class='green'>Банда смогла выжить</span>"
	return "<span class='red'>НаноТрейзен уничтожила банду</span>"

/datum/faction/gang/GetScoreboard()
	. = ..()
	. += "Очки: [round(points)]"

/datum/faction/gang/AdminPanelEntry()
	. = ..()
	. += "<br>Очки: [points]"
	. += "<br>Граффити: [gang_tags.len]"

/// Adds points to the points var.
/datum/faction/gang/proc/adjust_points(points_to_adjust)
	points += points_to_adjust

/datum/faction/gang/red
	name = "San Fierro Triad"
	gang_id = "SFT"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/mask/scarf/red,
							/obj/item/clothing/suit/jacket/letterman_red,
							/obj/item/clothing/under/color/red,
							/obj/item/clothing/mask/bandana/red,
							/obj/item/clothing/under/suit_jacket/red)
	free_clothes = list(/obj/item/clothing/suit/jacket/letterman_red,
						/obj/item/clothing/under/color/red,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/kill_undercover_cops

/datum/faction/gang/purple
	name = "Ballas"
	gang_id = "B"
	acceptable_clothes = list(/obj/item/clothing/head/soft/purple,
							/obj/item/clothing/under/lightpurple,
							/obj/item/clothing/mask/scarf/violet,
							/obj/item/clothing/gloves/purple,
							/obj/item/clothing/mask/bandana/skull,
							/obj/item/clothing/under/color/pink)

	free_clothes = list(/obj/item/clothing/under/lightpurple,
						/obj/item/clothing/gloves/purple,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/protect_security

/datum/faction/gang/green
	name = "Grove Street Families"
	gang_id = "GSF"
	acceptable_clothes = list(/obj/item/clothing/head/soft/green,
							/obj/item/clothing/under/lightgreen,
							/obj/item/clothing/mask/scarf/green,
							/obj/item/clothing/suit/poncho/green,
							/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/mask/bandana/green,
						/obj/item/clothing/under/lightgreen,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/capture_station

/datum/faction/gang/russian_mafia
	name = "Russian Mafia"
	gang_id = "RM"
	acceptable_clothes = list(/obj/item/clothing/head/soft/red,
							/obj/item/clothing/mask/scarf/red,
							/obj/item/clothing/suit/jacket,
							/obj/item/clothing/under/suit_jacket/rouge,
							/obj/item/clothing/head/ushanka)
	free_clothes = list(/obj/item/clothing/head/ushanka,
						/obj/item/clothing/suit/jacket,
						/obj/item/clothing/under/suit_jacket/rouge,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/save_bottle

/datum/faction/gang/italian_mob
	name = "Italian Mob"
	gang_id = "IM"
	acceptable_clothes = list(/obj/item/clothing/under/mafia,
							/obj/item/clothing/head/fedora,
							/obj/item/clothing/mask/scarf/green,
							/obj/item/clothing/mask/bandana/green)
	free_clothes = list(/obj/item/clothing/head/fedora,
						/obj/item/clothing/under/mafia,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/church_tradition

/datum/faction/gang/tunnel_snakes
	name = "Tunnel Snakes"
	gang_id = "TS"
	acceptable_clothes = list(/obj/item/clothing/under/pants/classicjeans,
							/obj/item/clothing/suit/jacket,
							/obj/item/clothing/mask/bandana/skull)
	free_clothes = list(/obj/item/clothing/suit/jacket,
						/obj/item/clothing/under/pants/classicjeans,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/tunnel_snake

/datum/faction/gang/vagos
	name = "Los Santos Vagos"
	gang_id = "LSV"
	acceptable_clothes = list(/obj/item/clothing/head/soft/yellow,
							/obj/item/clothing/under/color/yellow,
							/obj/item/clothing/mask/scarf/yellow,
							/obj/item/clothing/mask/bandana/gold)
	free_clothes = list(/obj/item/clothing/mask/bandana/gold,
						/obj/item/clothing/under/color/yellow,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/rob_nt

/datum/faction/gang/henchmen
	name = "Monarch Crew"
	gang_id = "HENCH"
	acceptable_clothes = list(/obj/item/clothing/head/soft/yellow,
							/obj/item/clothing/under/henchmen,
							/obj/item/clothing/mask/scarf/yellow,
							/obj/item/clothing/mask/bandana/gold,
							/obj/item/weapon/storage/backpack/henchmen)
	free_clothes = list(/obj/item/weapon/storage/backpack/henchmen,
						/obj/item/clothing/under/henchmen,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/target/assassinate/kill_head

/datum/faction/gang/yakuza
	name = "Tojo Clan"
	gang_id = "YAK"
	acceptable_clothes = list(/obj/item/clothing/head/soft/yellow,
							/obj/item/clothing/under/yakuza,
							/obj/item/clothing/shoes/yakuza,
							/obj/item/clothing/mask/scarf/yellow,
							/obj/item/clothing/mask/bandana/gold,
							/obj/item/clothing/suit/jacket/leather)
	free_clothes = list(/obj/item/clothing/under/yakuza,
						/obj/item/clothing/shoes/yakuza,
						/obj/item/clothing/suit/jacket/leather,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/save_station

/datum/faction/gang/jackbros
	name = "Jack Bros"
	gang_id = "JB"
	acceptable_clothes = list(/obj/item/clothing/head/soft/blue,
							/obj/item/clothing/under/jackbros,
							/obj/item/clothing/shoes/jackbros,
							/obj/item/clothing/head/jackbros,
							/obj/item/clothing/mask/bandana/blue)
	free_clothes = list(/obj/item/clothing/under/jackbros,
						/obj/item/clothing/shoes/jackbros,
						/obj/item/clothing/head/jackbros,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/become_captain

/datum/faction/gang/dutch
	name = "Dutch van der Linde's Gang"
	gang_id = "VDL"
	acceptable_clothes = list(/obj/item/clothing/head/soft/sec/corp,
							/obj/item/clothing/under/dutch,
							/obj/item/clothing/suit/dutch,
							/obj/item/clothing/head/bowler,
							/obj/item/clothing/mask/bandana/black)
	free_clothes = list(/obj/item/clothing/under/dutch,
						/obj/item/clothing/head/bowler,
						/obj/item/clothing/suit/dutch,
						/obj/item/toy/crayon/spraycan)
	gang_objective_type = /datum/objective/gang/steal_gold
