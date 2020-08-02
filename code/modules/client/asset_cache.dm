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

	client << browse_rsc(SSassets.cache[asset_name], asset_name)
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
		stoplag(1) // Lock up the caller until this is received.
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
		if (asset in SSassets.cache)
			client << browse_rsc(SSassets.cache[asset], asset)

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
		stoplag(1) // Lock up the caller until this is received.
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
		stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSassets.cache[asset_name] = asset

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
/var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset
	var/_abstract = /datum/asset	//assets with this variable will not be loaded into the cache automatically when the game starts

/datum/asset/New()
	asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	_abstract = /datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)

/datum/asset/simple/goonchat
	_abstract = /datum/asset/simple/goonchat
	assets = list(
		"jquery.min.js" = 'code/modules/goonchat/browserassets/js/jquery.min.js',
		"jquery.mark.min.js" = 'code/modules/goonchat/browserassets/js/jquery.mark.min.js',
		"json2.min.js" = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js" = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"error_handler.js" = 'code/modules/error_handler_js/error_handler.js',
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
	_abstract = /datum/asset/simple/spider_os
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
	_abstract = /datum/asset/simple/paper
	assets = list(
		"paper_dickbutt.png" = 'icons/paper_icons/dickbutt.png',
		"bluentlogo.png" = 'icons/paper_icons/bluentlogo.png'
	)

/datum/asset/simple/newscaster
	_abstract = /datum/asset/simple/newscaster
	assets = list(
		"like.png" = 'icons/newscaster_icons/like.png',
		"like_clck.png" = 'icons/newscaster_icons/like_clck.png',
		"dislike.png" = 'icons/newscaster_icons/dislike.png',
		"dislike_clck.png" = 'icons/newscaster_icons/dislike_clck.png'
	)

/datum/asset/simple/chess
	_abstract = /datum/asset/simple/chess
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

	var/assets = list(
		"error_handler.js" = 'code/modules/error_handler_js/error_handler.js',
	)

/datum/asset/nanoui/register()
	// Crawl the directories to find files.
	for (var/path in common_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					common[filename] = fcopy_rsc(path + filename)
					register_asset(filename, common[filename])
	for (var/path in uncommon_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, -1) != "/") // Ignore directories.
				if(fexists(path + filename))
					register_asset(filename, fcopy_rsc(path + filename))
	
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/nanoui/send(client, uncommon)
	if(!islist(uncommon))
		uncommon = list(uncommon)

	send_asset_list(client, uncommon)
	send_asset_list(client, common)
	send_asset_list(client, assets)

/*Spritesheet implementation - coalesces various icons into a single .png file
 and uses CSS to select icons out of that file - saves on transferring some
1400-odd individual PNG files. (this is the port from tgstation)*/
#define SPR_SIZE 1 //sprite size in list/sprites
#define SPR_IDX 2 //sprite index in list/sprites
#define SPRSZ_COUNT 1 //sprite size count in list/sizes
#define SPRSZ_ICON 2 //sprite size icon in list/sizes
#define SPRSZ_STRIPPED 3 //sprite size stripped in list/sizes

/datum/asset/spritesheet
	_abstract = /datum/asset/spritesheet
	var/name
	var/list/sizes = list()    // "32x32" -> list(sprite count, icon/normal, icon/stripped)
	var/list/sprites = list()  // "foo_bar" -> list("32x32", sprite index)

/datum/asset/spritesheet/register()
	if (!name)
		CRASH("spritesheet [type] cannot register without a name")
	ensure_stripped()
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"
	fdel(fname)
	text2file(generate_css(), fname)
	register_asset(res_name, fcopy_rsc(fname))
	fdel(fname)

	for(var/size_id in sizes)
		var/size = sizes[size_id]
		register_asset("[name]_[size_id].png", size[SPRSZ_STRIPPED])

/datum/asset/spritesheet/proc/ensure_stripped(sizes_to_strip = sizes)
	for(var/size_id in sizes_to_strip)
		var/size = sizes[size_id]
		if (size[SPRSZ_STRIPPED])
			continue

		// save flattened version
		var/fname = "data/spritesheets/[name]_[size_id].png"
		fcopy(size[SPRSZ_ICON], fname)
		world.ext_python("strip_metadata.py", "[fname]")
		size[SPRSZ_STRIPPED] = icon(fname)
		fdel(fname)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()

	for (var/size_id in sizes)
		var/size = sizes[size_id]
		var/icon/tiny = size[SPRSZ_ICON]
		out += ".[name][size_id]{display:inline-block;width:[tiny.Width()]px;height:[tiny.Height()]px;background:url('[name]_[size_id].png') no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]
		var/size = sizes[size_id]

		var/icon/tiny = size[SPRSZ_ICON]
		var/icon/big = size[SPRSZ_STRIPPED]
		var/per_line = big.Width() / tiny.Width()
		var/x = (idx % per_line) * tiny.Width()
		var/y = round(idx / per_line) * tiny.Height()

		out += ".[name][size_id].[sprite_id]{background-position:-[x]px -[y]px;}"

	return out.Join("\n")

/datum/asset/spritesheet/proc/insert_icon_in_list(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE)
	I = icon(I, icon_state=icon_state, dir=dir, frame=frame, moving=moving)
	if (!I || !length(icon_states(I)))  // that direction or state doesn't exist
		return
	var/size_id = "[I.Width()]x[I.Height()]"
	var/size = sizes[size_id]

	if (sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if (size)
		var/position = size[SPRSZ_COUNT]++
		var/icon/sheet = size[SPRSZ_ICON]
		size[SPRSZ_STRIPPED] = null
		sheet.Insert(I, icon_state=sprite_name)
		sprites[sprite_name] = list(size_id, position)
	else
		sizes[size_id] = size = list(1, I, null)
		sprites[sprite_name] = list(size_id, 0)

#undef SPR_SIZE
#undef SPR_IDX
#undef SPRSZ_COUNT
#undef SPRSZ_ICON
#undef SPRSZ_STRIPPED

/datum/asset/spritesheet/vending
	name = "vending"

/datum/asset/spritesheet/vending/register()
	for (var/k in global.vending_products)
		var/atom/item = k
		if (!ispath(item, /atom))
			continue
		var/obj/product = new item
		var/icon/I = getFlatIcon(product)
		var/imgid = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")
		insert_icon_in_list(imgid, I)
	return ..()

/datum/asset/spritesheet/autolathe
	name = "autolathe"

/datum/asset/spritesheet/autolathe/register()
	var/list/recipes = global.autolathe_recipes + global.autolathe_recipes_hidden
	for (var/obj/item in recipes)
		var/icon/I = icon(item.icon, item.icon_state) //for some reason, the getFlatIcon(item) function does not create images of objects such as /obj/item/ammo_casing
		var/imgid = replacetext(replacetext("[item.type]", "/obj/item/", ""), "/", "-")
		insert_icon_in_list(imgid, I)
	return ..()

/datum/asset/spritesheet/cargo
	name = "cargo"

/datum/asset/spritesheet/cargo/register()
	var/all_objects = list()
	for(var/supply_name in SSshuttle.supply_packs)
		var/datum/supply_pack/N = SSshuttle.supply_packs[supply_name]
		for(var/supp in N.contains)
			if(supp in all_objects)
				continue
			all_objects += supp
		if(N.crate_type in all_objects)
			continue
		all_objects += N.crate_type
		if(ispath(N.crate_type, /obj/structure/closet/critter))
			var/obj/structure/closet/critter/C = N.crate_type
			all_objects += initial(C.content_mob)
	for(var/content in all_objects)
		var/imgid = null
		var/icon/sprite = null
		if(ispath(content, /mob))
			var/mob/M = content
			sprite = icon(initial(M.icon), initial(M.icon_state))
			imgid = replacetext(replacetext("[content]", "/mob/", ""), "/", "-")
		else
			var/obj/supply = new content
			sprite = getFlatIcon(supply)
			imgid = replacetext(replacetext("[content]", "/obj/", ""), "/", "-")
		insert_icon_in_list(imgid, sprite)
	return ..()
