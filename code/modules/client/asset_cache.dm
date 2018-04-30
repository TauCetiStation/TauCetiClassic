/*
Asset cache quick users guide:
Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.
You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8


/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client
			else
				return 0
		else
			return 0

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(SSasset.cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += asset_name
		return 1
	if (!client)
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client
			else
				return 0
		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	if(unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "<span class='info'><b>Sending Resources, please wait...</b></span>")
	for(var/asset in unreceived)
		if (asset in SSasset.cache)
			client << browse_rsc(SSasset.cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if (client)
			client.cache += unreceived
		return 1
	if (!client)
		return 0
	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file,files[file])
		send_asset(client,file)
		sleep(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSasset.cache[asset_name] = asset

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
/var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)

/datum/asset/simple/goonchat
	assets = list(
		"jquery.min.js" = 'code/modules/goonchat/browserassets/js/jquery.min.js',
		"jquery.mark.min.js" = 'code/modules/goonchat/browserassets/js/jquery.mark.min.js',
		"json2.min.js" = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js" = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"fontawesome-webfont.eot" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.woff',
		"font-awesome.css" = 'code/modules/goonchat/browserassets/css/font-awesome.css',
		"emojib64.css" = 'code/modules/goonchat/browserassets/css/emojib64.css',
		"browserOutput.css" = 'code/modules/goonchat/browserassets/css/browserOutput.css'
	)

//DEFINITIONS FOR ASSET DATUMS START HERE.
/datum/asset/simple/spider_os
	assets = list(
		"sos_1.png" = 'icons/spideros_icons/sos_1.png',
		"sos_2.png" = 'icons/spideros_icons/sos_2.png',
		"sos_3.png" = 'icons/spideros_icons/sos_3.png',
		"sos_4.png" = 'icons/spideros_icons/sos_4.png',
		"sos_5.png" = 'icons/spideros_icons/sos_5.png',
		"sos_6.png" = 'icons/spideros_icons/sos_6.png',
		"sos_7.png" = 'icons/spideros_icons/sos_7.png',
		"sos_8.png" = 'icons/spideros_icons/sos_8.png',
		"sos_9.png" = 'icons/spideros_icons/sos_9.png',
		"sos_10.png" = 'icons/spideros_icons/sos_10.png',
		"sos_11.png" = 'icons/spideros_icons/sos_11.png',
		"sos_12.png" = 'icons/spideros_icons/sos_12.png',
		"sos_13.png" = 'icons/spideros_icons/sos_13.png',
		"sos_14.png" = 'icons/spideros_icons/sos_14.png'
	)

/datum/asset/simple/paper
	assets = list(
		"paper_dickbutt.png" = 'icons/paper_icons/dickbutt.png'
	)

/datum/asset/simple/halop_cards
	assets = list(
		"sofa_ninja_1.png" = 'icons/obj/halop_cards/sofa_ninja_1.png',
		"shrub_2.png" = 'icons/obj/halop_cards/shrub_2.png',
		"space_carp_3.png" = 'icons/obj/halop_cards/space_carp_3.png',
		"assistant_4.png" = 'icons/obj/halop_cards/assistant_4.png',
		"assistant_in_space_suit_5.png" = 'icons/obj/halop_cards/assistant_in_space_suit_5.png',
		"cakehead_6.png" = 'icons/obj/halop_cards/cakehead_6.png',
		"space_law_7.png" = 'icons/obj/halop_cards/space_law_7.png',
		"clown_8.png" = 'icons/obj/halop_cards/clown_8.png',
		"light_sources_9.png" = 'icons/obj/halop_cards/light_sources_9.png',
		"experienced_assistant_10.png" = 'icons/obj/halop_cards/experienced_assistant_10.png',
		"the_false_wizard_11.png" = 'icons/obj/halop_cards/the_false_wizard_11.png',
		"vending_machines_12.png" = 'icons/obj/halop_cards/vending_machines_12.png',
		"arcade_13.png" = 'icons/obj/halop_cards/arcade_13.png',
		"unwanted_clone_14.png" = 'icons/obj/halop_cards/unwanted_clone_14.png',
		"mattress_ninja_22.png" = 'icons/obj/halop_cards/mattress_ninja_22.png',
		"winged_soldier_23.png" = 'icons/obj/halop_cards/winged_soldier_23.png',
		"bronze_helmet_24.png" = 'icons/obj/halop_cards/bronze_helmet_24.png',
		"bumblebee_25.png" = 'icons/obj/halop_cards/bumblebee_25.png')

/datum/asset/simple/chess
	assets = list(
		"BR.png" = 'icons/obj/chess/board_BR.png',
		"BN.png" = 'icons/obj/chess/board_BN.png',
		"BI.png" = 'icons/obj/chess/board_BI.png',
		"BQ.png" = 'icons/obj/chess/board_BQ.png',
		"BK.png" = 'icons/obj/chess/board_BK.png',
		"BP.png" = 'icons/obj/chess/board_BP.png',
		"WR.png" = 'icons/obj/chess/board_WR.png',
		"WN.png" = 'icons/obj/chess/board_WN.png',
		"WI.png" = 'icons/obj/chess/board_WI.png',
		"WQ.png" = 'icons/obj/chess/board_WQ.png',
		"WK.png" = 'icons/obj/chess/board_WK.png',
		"WP.png" = 'icons/obj/chess/board_WP.png',
		"CB.png" = 'icons/obj/chess/board_CB.png',
		"CR.png" = 'icons/obj/chess/board_CR.png',
		"none.png" = 'icons/obj/chess/board_none.png'
	)

/datum/asset/nanoui
	var/list/common = list()

	var/list/common_dirs = list(
		"nano/css/",
		"nano/js/",
		"nano/images/",
		"nano/layouts/"
	)
	var/list/uncommon_dirs = list(
		"nano/templates/"
	)



/datum/asset/nanoui/register()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])
	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset(filename, fcopy_rsc(path + filename))

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon)
	send_asset_list(client, common)