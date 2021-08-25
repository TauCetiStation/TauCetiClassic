
/client/proc/open_outfit_editor(datum/outfit/target)
	var/datum/outfit_editor/ui = new(usr, target)
	ui.tgui_interact(usr)

#define OUTFIT_EDITOR_NAME "Outfit-O-Tron 9000"
/datum/outfit_editor
	var/client/owner

	var/dummy_key

	var/datum/outfit/drip

/datum/outfit_editor/New(user, datum/outfit/target)
	owner = CLIENT_FROM_VAR(user)

	if(ispath(target))
		drip = new /datum/outfit
		drip.copy_from(new target)
	else if(istype(target))
		drip = target
	else
		drip = new /datum/outfit
		drip.name = "New Outfit"

/datum/outfit_editor/tgui_state(mob/user)
	return global.admin_state

/datum/outfit_editor/tgui_status(mob/user, datum/tgui_state/state)
	if(QDELETED(drip))
		return UI_CLOSE
	return ..()

/datum/outfit_editor/tgui_close(mob/user)
	clear_human_dummy(dummy_key)
	qdel(src)

/datum/outfit_editor/proc/init_dummy()
	dummy_key = "outfit_editor_[owner]"
	generate_or_wait_for_human_dummy(dummy_key)
	unset_busy_human_dummy(dummy_key)

/datum/outfit_editor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OutfitEditor", OUTFIT_EDITOR_NAME)
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/outfit_editor/proc/entry(data)
	if(ispath(data, /obj/item))
		var/obj/item/item = data
		var/icon/I = new(initial(item.icon))
		var/sprite = (initial(item.icon_state) in I.IconStates()) ? icon2base64(icon(initial(item.icon), initial(item.icon_state), dir = SOUTH, frame = 1)) : null
		return list(
			"path" = item,
			"name" = initial(item.name),
			"desc" = initial(item.desc),
			// at this point initializing the item is probably faster tbh
			"sprite" = sprite,
		)

	return data

/datum/outfit_editor/proc/serialize_outfit()
	var/list/outfit_slots = drip.get_json_data()
	. = list()
	for(var/key in outfit_slots)
		var/val = outfit_slots[key]
		. += list("[key]" = entry(val))

/datum/outfit_editor/tgui_data(mob/user)
	var/list/data = list()

	data["outfit"] = serialize_outfit()
	data["saveable"] = !global.custom_outfits.Find(drip)

	if(!dummy_key)
		init_dummy()
	var/icon/dummysprite = get_flat_human_icon(null, dummy_key = dummy_key, outfit_override = drip)
	data["dummy64"] = icon2base64(dummysprite)

	return data


/datum/outfit_editor/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)
	if(..())
		return
	. = TRUE

	var/slot = params["slot"]
	switch(action)
		if("click")
			choose_item(slot)
		if("ctrlClick")
			choose_any_item(slot)
		if("clear")
			if(drip.vars.Find(slot))
				drip.vars[slot] = null

		if("rename")
			var/newname = sanitize_text(input(owner, "What do you want to name this outfit?", OUTFIT_EDITOR_NAME))
			if(newname)
				drip.name = newname
		if("save")
			global.custom_outfits |= drip
			SStgui.update_user_uis(owner.mob)
		if("delete")
			global.custom_outfits -= drip
			SStgui.update_user_uis(owner.mob)
		if("vv")
			owner.debug_variables(drip)
		if("random")
			random_equip()

/datum/outfit_editor/proc/set_item(slot, obj/item/choice, show_warnings = TRUE)
	if(!choice)
		return
	if(!ispath(choice))
		if(show_warnings)
			tgui_alert(owner, "Invalid item", OUTFIT_EDITOR_NAME, list("oh no"))
		return
	if(initial(choice.icon_state) == null) //hacky check copied from experimentor code
		var/msg = "Warning: This item's icon_state is null, indicating it is very probably not actually a usable item."
		if(!show_warnings || tgui_alert(owner, msg, OUTFIT_EDITOR_NAME, list("Use it anyway", "Cancel")) != "Use it anyway")
			return

	if(drip.vars.Find(slot))
		drip.vars[slot] = choice

/datum/outfit_editor/proc/choose_any_item(slot)
	var/obj/item/choice = pick_closest_path(FALSE)

	if(!choice)
		return

	set_item(slot, choice)

/datum/outfit_editor/proc/random_equip()
	for(var/slotname in list(
			"head",
			"glasses",
			"l_ear",
			"r_ear",
			"accessory",
			"mask",
			"uniform",
			"suit",
			"gloves",
			"suit_store",
			"belt",
			"id",
			"l_hand",
			"back",
			"r_hand",
			"l_pocket",
			"shoes",
			"r_pocket",
		))
		choose_item(slotname, random = TRUE)

//this proc will try to give a good selection of items that the user can choose from
//it does *not* give a selection of all items that can fit in a slot because lag;
//most notably the hand and pocket slots because they accept pretty much anything
//also stuff that fits in the belt and back slots are scattered pretty much all over the place
/datum/outfit_editor/proc/choose_item(slot, random = FALSE)
	var/list/options = list()

	switch(slot)
		if("head")
			options = typesof(/obj/item/clothing/head)
		if("glasses")
			options = typesof(/obj/item/clothing/glasses)
		if("l_ear")
			options = typesof(/obj/item/device/radio/headset)
		if("r_ear")
			options = typesof(/obj/item/device/radio/headset)
		if("accessory")
			options = typesof(/obj/item/clothing/accessory)
		if("mask")
			options = typesof(/obj/item/clothing/mask)

		if("uniform")
			options = typesof(/obj/item/clothing/under)
		if("suit")
			options = typesof(/obj/item/clothing/suit)
		if("gloves")
			options = typesof(/obj/item/clothing/gloves)

		if("suit_store")
			var/obj/item/clothing/suit/suit = drip.suit
			if(suit)
				suit = new suit //initial() doesn't like lists
				options = suit.allowed
			if(!options.len) //nothing will happen, but don't let the user think it's broken
				to_chat(owner, "<span class='warning'>No options available for the current suit.</span>")

		if("belt")
			options = typesof(/obj/item/weapon/storage/belt)
		if("id")
			options = typesof(/obj/item/weapon/card/id)

		if("l_hand")
			if(random)
				return
			choose_any_item(slot)
		if("back")
			options = typesof(/obj/item/weapon/storage/backpack)
		if("r_hand")
			if(random)
				return
			choose_any_item(slot)

		if("l_pocket")
			if(random)
				return
			choose_any_item(slot)
		if("shoes")
			options = typesof(/obj/item/clothing/shoes)
		if("r_pocket")
			if(random)
				return
			choose_any_item(slot)

	if(length(options))
		if(!random)
			set_item(slot, tgui_input_list(owner, "Choose an item", OUTFIT_EDITOR_NAME, options))
		else
			set_item(slot, pick(options), show_warnings = FALSE)

#undef OUTFIT_EDITOR_NAME
