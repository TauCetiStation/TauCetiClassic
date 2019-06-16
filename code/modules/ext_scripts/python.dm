/world/proc/ext_python(script, args, scriptsprefix = 1)
	if(!config.python_path)
		info("Python path is undefined, see config.python_path")
		return

	if(scriptsprefix) script = "scripts/" + script

	var/command = "[config.python_path] [script] [args]"

	var/output = world.shelleo(command)

	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	if(!errorlevel)
		return stdout
	else
		ERROR("Python script execution error in [script]:\n [stderr]")
		return 0
