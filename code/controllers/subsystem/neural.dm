#define COMSIG_NEURAL_IMAGE_GENERATED "neural_image_generated"

SUBSYSTEM_DEF(neural)
	name = "Neural"
	msg_lobby = "Настраиваем нейронные связи..."

	init_order = SS_INIT_NEURO
	priority = SS_PRIORITY_LOW
	wait	 = SS_WAIT_DEFAULT

	flags = SS_TICKER

	/// fallback
	var/list/available_styles = list(
			"Кандинский" = "KANDINSKY",
			"Детальное фото" = "UHD",
			"Аниме" = "ANIME",
			"Свой стиль" = "DEFAULT",)
	var/images_counter = 0

	// avoid spamming to the api
	var/list/currentrun = list()
	var/const/max_requests = 5
	var/current_requests = 0

/datum/controller/subsystem/neural/Initialize(start_timeofday)
	. = ..()
	if(!config.use_kadinsky)
		return
	var/styles_json = get_webpage("https://cdn.fusionbrain.ai/static/styles/api")
	available_styles = list()
	for(var/list/style in json_decode(styles_json))
		available_styles[style["title"]] = style["name"]

/datum/controller/subsystem/neural/fire()
	if(current_requests == max_requests)
		return

	var/list/currentrun = src.currentrun

	while(currentrun.len && current_requests != max_requests)
		var/datum/neural_query/query = currentrun[currentrun.len]
		currentrun.len--

		INVOKE_ASYNC(src, PROC_REF(generate_neural_image), query)

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/neural/proc/start_generation_request(datum/neural_query/query)
	currentrun += query

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
	var/file_path = SSneural.get_full_path(query.file_postfix, query.prompt)

	var/arguments = "--prompt \"[query.prompt]\""
	arguments += " --style \"[query.style]\""
	arguments += " --target_width [query.target_width]"
	arguments += " --target_height [query.target_height]"
	arguments += " --generate_width [query.generate_width]"
	arguments += " --generate_height [query.generate_height]"
	arguments += " --file_path \"[file_path]\""
	arguments += " --api_key \"[query.api_key]\""
	arguments += " --secret_key \"[query.secret_key]\""

	current_requests++
	var/base64 = world.ext_python("kadinsky.py", arguments)
	current_requests--

	SEND_SIGNAL(query.source, COMSIG_NEURAL_IMAGE_GENERATED, base64, file_path)

/datum/neural_query
	// ref to source
	var/atom/source

	var/prompt = ""
	var/style = ""
	// size of image for game
	var/target_width = 0
	var/target_height = 0
	// size of image to generate, image generation for small resolutions is terrible
	var/generate_width = 0
	var/generate_height = 0

	var/file_postfix = ""

	var/api_key = ""
	var/secret_key = ""
