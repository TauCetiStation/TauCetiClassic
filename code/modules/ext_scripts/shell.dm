//Runs the command in the system's shell, returns a list of (error code, stdout, stderr)

#define SHELLEO_NAME "data/shelleo."
#define SHELLEO_ERR ".err"
#define SHELLEO_OUT ".out"
/world/proc/shelleo(command)
	var/static/list/shelleo_ids = list()
	var/stdout = ""
	var/stderr = ""
	var/errorcode = 1
	var/shelleo_id
	var/out_file = ""
	var/err_file = ""
	for(var/seo_id in shelleo_ids)
		if(!shelleo_ids[seo_id])
			shelleo_ids[seo_id] = TRUE
			shelleo_id = "[seo_id]"
			break
	if(!shelleo_id)
		shelleo_id = "[shelleo_ids.len + 1]"
		shelleo_ids += shelleo_id
		shelleo_ids[shelleo_id] = TRUE
	out_file = "[SHELLEO_NAME][shelleo_id][SHELLEO_OUT]"
	err_file = "[SHELLEO_NAME][shelleo_id][SHELLEO_ERR]"
	if(world.system_type == UNIX)
		errorcode = shell("[command] > [out_file] 2> [err_file]")
	else
		errorcode = shell("cmd /c \"[command]\" > [out_file] 2> [err_file]")
	if(fexists(out_file))
		stdout = file2text(out_file)
		fdel(out_file)
	if(fexists(err_file))
		stderr = file2text(err_file)
		fdel(err_file)
	shelleo_ids[shelleo_id] = FALSE
	. = list(errorcode, stdout, stderr)
#undef SHELLEO_NAME
#undef SHELLEO_ERR
#undef SHELLEO_OUT
