/obj/effect/proc_holder/spell/targeted/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "GAR YOK"
	invocation_type = "whisper"
	range = -1
	include_user = 1
	var/obj/item/marked_item
	action_icon_state = "summons"

/obj/effect/proc_holder/spell/targeted/summonitem/cast(list/targets, mob/user = usr)
	if(!iscarbon(user))
		to_chat(user,"<span class='userdanger'>Where is your hands?</span>")
	var/list/hand_items = list(user.get_active_hand(), user.get_inactive_hand())
	if(!marked_item) //linking item to the spell
		for(var/obj/item in hand_items)
			if(item && item.flags & ABSTRACT)
				continue
			marked_item = item
			to_chat(user, "<span class='notice'>You mark [item] for recall.</span>")
			name = "Recall [item]"
			break
		if(!marked_item)
			if(hand_items)
				to_chat(user, "<span class='caution'>You aren't holding anything that can be marked for recall.</span>")
			else
				to_chat(user, "<span class='notice'>You must hold the desired item in your hands to mark it for recall.</span>")
		return

	else if(marked_item in hand_items) //unlinking item to the spell
		to_chat(user, "<span class='notice'>You remove the mark on [marked_item] to use elsewhere.</span>")
		name = initial(name)
		marked_item = null
	else if(marked_item && (QDELETED(marked_item) || !marked_item.loc)) //the item was destroyed at some point
		to_chat(user, "<span class='warning'>You sense your marked item has been destroyed!</span>")
		name = initial(name)
		marked_item = null
	else	//Getting previously marked item
		// Preventing a nasty exlpoit where wizard traps himself in the hat with the hat.
		// Note: probably should've been in area/custom/tophat/Entered(), but it gets called before Moved()
		// And so the hat is put into wizard's hands *after* it teleports somewhere
		// which leads to whole bunch of other problems
		// so it resides here.

		if(istype(marked_item, /obj/item/clothing/head/wizard/tophat) && istype(get_area(user), /area/custom/tophat))
			var/obj/item/clothing/head/wizard/tophat/TP = marked_item
			TP.jump_out()
			var/area/new_area = teleportlocs[pick(teleportlocs)]
			user.visible_message("<span class='danger'>[TP] becomes unstable as it enters itself, and now resides somewhere in [new_area]!</span>")

			var/list/all_turfs = get_area_turfs(new_area.type)
			var/turf/T = pick(all_turfs)

			TP.forceMove(T)
			return

		var/obj/item_to_retrieve = marked_item
		while(isobj(item_to_retrieve.loc))
			item_to_retrieve = item_to_retrieve.loc
		if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
			var/mob/M = item_to_retrieve.loc
			if(issilicon(M)) //Items in silicons warp the whole silicon
				M.visible_message("<span class='warning'>[M] suddenly disappears!</span>")
				M.forceMove(user.loc)
				M.visible_message("<span class='caution'>[M] suddenly appears!</span>")
				item_to_retrieve = null
				return
			M.remove_from_mob(item_to_retrieve)
		if(item_to_retrieve.anchored)
			to_chat(user, "<span class='userdanger'>[item_to_retrieve] prevents summoning [marked_item]. It's located in [get_area(item_to_retrieve)]!</span>")
			item_to_retrieve.SpinAnimation(5, 1)
			playsound(item_to_retrieve, 'sound/magic/SummonItems_generic.ogg', VOL_EFFECTS_MASTER)
			if(alert("Do you want to unlink the [marked_item]?",,"Yes","No") == "Yes")
				name = initial(name)
				marked_item = null
		else
			item_to_retrieve.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly disappears!</span>")
			if(item_to_retrieve != marked_item)
				item_to_retrieve.forceMove(user.loc)
				item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears!</span>")
			else
				item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears in [user]'s hand!</span>")
				user.put_in_hands(item_to_retrieve)
			playsound(user, 'sound/magic/SummonItems_generic.ogg', VOL_EFFECTS_MASTER)
