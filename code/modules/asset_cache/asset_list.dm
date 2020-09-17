//These datums are used to populate the asset cache, the proc "register()" does this.
//Place any asset datums you create in asset_list_items.dm

//all of our asset datums, used for referring to these later
var/global/list/asset_datums = list()

//get an assetdatum or make a new one
/proc/get_asset_datum(type)
	return global.asset_datums[type] || new type()

/datum/asset
	var/_abstract = /datum/asset	//assets with this variable will not be loaded into the cache automatically when the game starts

/datum/asset/New()
	global.asset_datums[type] = src
	register()

/datum/asset/proc/get_url_mappings()
	return list()

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return


//If you don't need anything complicated.
/datum/asset/simple
	_abstract = /datum/asset/simple
	var/assets = list()

/datum/asset/simple/register()
	for(var/asset_name in assets)
		assets[asset_name] = register_asset(asset_name, assets[asset_name])

/datum/asset/simple/send(client)
	. = send_asset_list(client, assets)

/datum/asset/simple/get_url_mappings()
	. = list()
	for (var/asset_name in assets)
		var/datum/asset_cache_item/ACI = assets[asset_name]
		if (!ACI)
			continue
		.[asset_name] = ACI.url

// For registering or sending multiple others at once
/datum/asset/group
	_abstract = /datum/asset/group
	var/list/children

/datum/asset/group/register()
	for(var/type in children)
		get_asset_datum(type)

/datum/asset/group/send(client/C)
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		. = A.send(C) || .

/datum/asset/group/get_url_mappings()
	. = list()
	for(var/type in children)
		var/datum/asset/A = get_asset_datum(type)
		. += A.get_url_mappings()

/*
 * Spritesheet implementation - coalesces various icons into a single .png file
 * and uses CSS to select icons out of that file - saves on transferring some
 * 1400-odd individual PNG files. (this is the port from tgstation)
 */
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
	if(!name)
		CRASH("spritesheet [type] cannot register without a name")
	ensure_stripped()
	for(var/size_id in sizes)
		var/size = sizes[size_id]
		register_asset("[name]_[size_id].png", size[SPRSZ_STRIPPED])
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"
	fdel(fname)
	text2file(generate_css(), fname)
	register_asset(res_name, fcopy_rsc(fname))
	fdel(fname)


/datum/asset/spritesheet/proc/ensure_stripped(sizes_to_strip = sizes)
	for(var/size_id in sizes_to_strip)
		var/size = sizes[size_id]
		if(size[SPRSZ_STRIPPED])
			continue

		// save flattened version
		var/fname = "data/spritesheets/[name]_[size_id].png"
		fcopy(size[SPRSZ_ICON], fname)
		world.ext_python("strip_metadata.py", "[fname]")
		size[SPRSZ_STRIPPED] = icon(fname)
		fdel(fname)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()

	for(var/size_id in sizes)
		var/size = sizes[size_id]
		var/icon/tiny = size[SPRSZ_ICON]
		out += ".[name][size_id]{display:inline-block;width:[tiny.Width()]px;height:[tiny.Height()]px;background:url('[get_asset_url("[name]_[size_id].png")]') no-repeat;}"

	for(var/sprite_id in sprites)
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
	if(!I || !length(icon_states(I)))  // that direction or state doesn't exist
		return
	var/size_id = "[I.Width()]x[I.Height()]"
	var/size = sizes[size_id]

	if(sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if(size)
		var/position = size[SPRSZ_COUNT]++
		var/icon/sheet = size[SPRSZ_ICON]
		size[SPRSZ_STRIPPED] = null
		sheet.Insert(I, icon_state=sprite_name)
		sprites[sprite_name] = list(size_id, position)
	else
		sizes[size_id] = size = list(1, I, null)
		sprites[sprite_name] = list(size_id, 0)

/datum/asset/spritesheet/get_url_mappings()
	if (!name)
		return
	. = list("spritesheet_[name].css" = get_asset_url("spritesheet_[name].css"))
	for(var/size_id in sizes)
		.["[name]_[size_id].png"] = get_asset_url("[name]_[size_id].png")


/datum/asset/spritesheet/proc/css_tag()
	return {"<link rel="stylesheet" href="[css_filename()]" />"}

/datum/asset/spritesheet/proc/css_filename()
	return get_asset_url("spritesheet_[name].css")

#undef SPR_SIZE
#undef SPR_IDX
#undef SPRSZ_COUNT
#undef SPRSZ_ICON
#undef SPRSZ_STRIPPED


/datum/asset/spritesheet/simple
	_abstract = /datum/asset/spritesheet/simple
	var/list/assets

/datum/asset/spritesheet/simple/register()
	for(var/key in assets)
		insert_icon_in_list(key, assets[key])
	..()
