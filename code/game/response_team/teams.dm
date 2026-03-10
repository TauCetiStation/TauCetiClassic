/datum/response_team/nt_ert
	name = "NT ERT"
	spawner = /datum/spawner/responders/nt_ert
	spawners_amount = 6
	probability = 40
	faction = /datum/faction/responders/nt_ert

/datum/response_team/nt_ert/New()
	if(security_level == SEC_LEVEL_DELTA)
		probability = 80

/datum/response_team/gorlex
	name = "Gorlex Marauders"
	spawner = /datum/spawner/responders/gorlex
	spawners_amount = 3
	probability = 10
	faction = /datum/faction/responders/gorlex
	fixed_objective = /datum/objective/nuclear

/datum/response_team/deathsquad
	name = "Death Esquadron"
	spawner = /datum/spawner/responders/deathsquad
	spawners_amount = 6
	probability = 1
	faction = /datum/faction/responders/deathsquad

/datum/response_team/pirates
	name = "Pirates"
	spawner = /datum/spawner/responders/pirates
	spawners_amount = 4
	probability = 20
	faction = /datum/faction/responders/pirates
	fixed_objective = /datum/objective/plunder

/datum/response_team/engineering
	name = "NT ECT (Engineers)"
	spawner = /datum/spawner/responders/engineering
	spawners_amount = 6
	probability = 10
	faction = /datum/faction/responders

/datum/response_team/medical
	name = "NT EMT (Medics)"
	spawner = /datum/spawner/responders/medical
	spawners_amount = 6
	probability = 10
	faction = /datum/faction/responders

/datum/response_team/soviet
	name = "USSP Squad"
	spawner = /datum/spawner/responders/soviet
	spawners_amount = 9
	probability = 20
	faction = /datum/faction/responders/soviet
	fixed_objective = /datum/objective/target/assassinate_heads

/datum/response_team/soviet/New()
	if(SSticker.mode.name == "Revolution")
		var/heads = 0
		var/just_heads = 1
		for(var/mob/living/carbon/human/player as anything in human_list)
			if(player.mind && (player.mind.assigned_role in SSjob.heads_positions))
				if(player.stat == DEAD)
					just_heads++
				heads++
			probability = 20 * ((heads / just_heads) - 1) //More head alive - more chances to get rev squad

/datum/response_team/security
	name = "Security Team"
	spawner = /datum/spawner/responders/security
	spawners_amount = 6
	probability = 20
	faction = /datum/faction/responders/security

/datum/response_team/marines
	name = "Marine Squad"
	spawner = /datum/spawner/responders/marines
	spawners_amount = 7
	probability = 20
	faction = /datum/faction/responders/marines

/datum/response_team/marines/New()
	if(SSticker.mode.name == "Infestation")
		probability = 60

/datum/response_team/clowns
	name = "Space Circus"
	spawner = /datum/spawner/responders/clowns
	spawners_amount = 5
	probability = 20
	faction = /datum/faction/responders/clowns
	fixed_objective = /datum/objective/custom/clowns

//Semi-deathsquad
/datum/response_team/inquisition
	name = "Holy inquisitors"
	spawner = /datum/spawner/responders/inquisition
	spawners_amount = 7
	probability = 5
	faction = /datum/faction/responders/inquisition
	//fixed_objective = /datum/objective/custom/clowns
