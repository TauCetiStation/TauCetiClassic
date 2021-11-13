/*
		name
		key
		description
		role
		comments
		ready = 0
*/

/datum/paiCandidate/proc/savefile_path(mob/user)
	return "data/player_saves/[user.ckey[1]]/[user.ckey]/pai.sav"

/datum/paiCandidate/proc/savefile_save(mob/user)
	if(IsGuestKey(user.key))
		return 0

	var/savefile/F = new /savefile(savefile_path(user))


	F["name"] << src.name
	F["description"] << src.description
	F["role"] << src.role
	F["comments"] << src.comments

	F["version"] << 1

	return TRUE

// loads the savefile corresponding to the mob's ckey
// if silent = TRUE, report incompatible savefiles
// returns TRUE if loaded (or file was incompatible)
// returns FALSE if savefile did not exist

/datum/paiCandidate/proc/savefile_load(mob/user, silent = TRUE)
	if (IsGuestKey(user.key))
		return FALSE

	var/path = savefile_path(user)

	if (!fexists(path))
		return FALSE

	var/savefile/F = new /savefile(path)

	if(!F) return //Not everyone has a pai savefile.

	var/version = null
	F["version"] >> version

	if (isnull(version) || version != 1)
		fdel(path)
		if (!silent)
			tgui_alert(user, "Your savefile was incompatible with this version and was deleted.")
		return FALSE

	F["name"] >> src.name
	F["description"] >> src.description
	F["role"] >> src.role
	F["comments"] >> src.comments
	return TRUE
