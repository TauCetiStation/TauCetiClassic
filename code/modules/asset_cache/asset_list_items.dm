//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	assets = list(
		"jquery.min.js" = 'code/modules/goonchat/browserassets/js/jquery.min.js'
	)

/datum/asset/simple/goonchat
	assets = list(
		"jquery.mark.min.js" = 'code/modules/goonchat/browserassets/js/jquery.mark.min.js',
		"json2.min.js" = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js" = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"error_handler.js" = 'code/modules/error_handler_js/error_handler.js',
		"emojib64.css" = 'code/modules/goonchat/browserassets/css/emojib64.css',
		"browserOutput.css" = 'code/modules/goonchat/browserassets/css/browserOutput.css'
	)

/datum/asset/simple/fontawesome
	assets = list(
		"fontawesome-webfont.eot" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'code/modules/goonchat/browserassets/css/fonts/fontawesome-webfont.woff',
		"font-awesome.css" = 'code/modules/goonchat/browserassets/css/font-awesome.css'
	)

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
		"paper_dickbutt.png" = 'icons/paper_icons/dickbutt.png',
		"bluentlogo.png" = 'icons/paper_icons/bluentlogo.png'
	)

/datum/asset/simple/newscaster
	assets = list(
		"like.png" = 'icons/newscaster_icons/like.png',
		"like_clck.png" = 'icons/newscaster_icons/like_clck.png',
		"dislike.png" = 'icons/newscaster_icons/dislike.png',
		"dislike_clck.png" = 'icons/newscaster_icons/dislike_clck.png'
	)

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
