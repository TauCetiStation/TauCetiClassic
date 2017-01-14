/proc/ext_python(script, args, scriptsprefix = 1)
	if(!config.python_path)
		return
	
	if(scriptsprefix) script = "scripts/" + script

	if(world.system_type == MS_WINDOWS)
		script = replacetext(script, "/", "\\")

	var/command = config.python_path + " " + script + " " + args
	
	return shell(command)
