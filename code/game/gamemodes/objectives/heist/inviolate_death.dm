#define MAX_VOX_KILLS 13 //Number of kills during the round before the Inviolate is broken.
						 //Would be nice to use vox-specific kills but is currently not feasible.
var/global/vox_kills = 0 //Used to check the Inviolate.

/datum/objective/heist/inviolate_death
	explanation_text = "Follow the Inviolate. Minimise death and loss of resources."

/datum/objective/heist/inviolate_death/check_completion()
	if(vox_kills > MAX_VOX_KILLS)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

#undef MAX_VOX_KILLS
