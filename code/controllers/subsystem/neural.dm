SUBSYSTEM_DEF(neural)
	name = "Neural"
	msg_lobby = "Настраиваем нейронные связи..."

	priority = SS_PRIORITY_LOW
	wait	 = SS_WAIT_DEFAULT

	flags = SS_NO_FIRE | SS_SHOW_IN_MC_TAB

	var/list/available_styles
	var/images_counter = 0

/datum/controller/subsystem/neural/Initialize(start_timeofday)
	. = ..()
	if(!config.use_kadinsky)
		return
	var/styles_json = get_webpage("https://cdn.fusionbrain.ai/static/styles/api")
	if(!styles_json)
		// fallback
		available_styles = list(
			"Кандинский" = "KANDINSKY",
			"Детальное фото" = "UHD",
			"Аниме" = "ANIME",
			"Свой стиль" = "DEFAULT",)
		return

	available_styles = list()
	for(var/list/style in json_decode(styles_json))
		available_styles[style["title"]] = style["name"]

/datum/controller/subsystem/neural/proc/get_available_styles()
	if(!config.use_kadinsky)
		return list()
	return get_list_of_primary_keys(available_styles)

/datum/controller/subsystem/neural/proc/get_full_path(postfix, prompt)
	var/hash = md5("[prompt]-[images_counter]-[round_id]")
	images_counter++
	return "cache/neuro/[postfix]/[hash].png"

/datum/controller/subsystem/neural/proc/release_cache(path)
	fdel(path)

/datum/controller/subsystem/neural/proc/generate_neural_image(datum/neural_query/query)
	if(!config.use_kadinsky)
		return

	if(!(query.style in available_styles))
		return

	query.prompt = sanitize(query.prompt)
	query.api_key = config.kadinsky_api_key
	query.secret_key = config.kadinsky_secret_key

	var/arguments = "--prompt \"[query.prompt]\""
	arguments += " --style \"[query.style]\""
	arguments += " --target_width [query.target_width]"
	arguments += " --target_height [query.target_height]"
	arguments += " --generate_width [query.generate_width]"
	arguments += " --generate_height [query.generate_height]"
	arguments += " --file_path \"[query.file_path]\""
	arguments += " --api_key \"[query.api_key]\""
	arguments += " --secret_key \"[query.secret_key]\""

	var/base64 = world.ext_python("kadinsky.py", arguments)
	return base64

/datum/neural_query
	var/prompt = ""
	var/style = ""
	// size of image for game
	var/target_width = 0
	var/target_height = 0
	// size of image to generate, image generation for small resolutions is terrible
	var/generate_width = 0
	var/generate_height = 0

	var/file_path = ""

	var/api_key = ""
	var/secret_key = ""
