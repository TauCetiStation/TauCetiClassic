/mob/living/blob
	name = "blob fragment"
	real_name = "blob fragment"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_spore_temp"
	pass_flags = PASSBLOB
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	var/ghost_name = "Unknown"
	var/creating_blob = 0
	faction = "blob"
	me_verb_allowed = FALSE //Blobs can't emote


/mob/living/blob/atom_init()
	real_name += " [pick(rand(1, 99))]"
	name = real_name
	. = ..()


/mob/living/blob/say(var/message)
	return//No talking for you


/mob/living/blob/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	return


/mob/living/blob/Life()
	set invisibility = 0
	//set background = 1

	clamp_values()
	UpdateDamage()
	if(health < 0)
		src.dust()


/mob/living/blob/proc/clamp_values()
	AdjustStunned(0)
	AdjustParalysis(0)
	AdjustWeakened(0)
	SetSleeping(0)
	if(stat)
		stat = CONSCIOUS
	return


/mob/living/blob/proc/UpdateDamage()
	health = 60 - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())
	return


/mob/living/blob/death(gibbed)
	if(key)
		var/mob/dead/observer/ghost = new(src)
		ghost.name = ghost_name
		ghost.real_name = ghost_name
		ghost.key = key
		if (ghost.client)
			ghost.client.eye = ghost
		return ..(gibbed)


/mob/living/blob/blob_act()
	to_chat(src, "The blob attempts to reabsorb you.")
	adjustToxLoss(20)
	return


/mob/living/blob/Process_Spacemove()
	if(locate(/obj/effect/blob) in oview(1,src))
		return 1
	return (..())


/mob/living/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node"
	set desc = "Create a Node."
	if(creating_blob)	return
	var/turf/T = get_turf(src)
	creating_blob = 1
	if(!T)
		creating_blob = 0
		return
	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(!B)//We are on a blob
		to_chat(usr, "There is no blob here!")
		creating_blob = 0
		return
	if(istype(B,/obj/effect/blob/node)||istype(B,/obj/effect/blob/core)||istype(B,/obj/effect/blob/factory))
		to_chat(usr, "Unable to use this blob, find a normal one.")
		creating_blob = 0
		return
	for(var/obj/effect/blob/node/blob in orange(5))
		to_chat(usr, "There is another node nearby, move more than 5 tiles  away from it!")
		creating_blob = 0
		return
	for(var/obj/effect/blob/factory/blob in orange(2))
		to_chat(usr, "There is a porus blob nearby, move more than 2 tiles away from it!")
		creating_blob = 0
	B.change_to("Node")
	src.dust()
	return


/mob/living/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Defense"
	set desc = "Create a Spore producing blob."
	if(creating_blob)	return
	var/turf/T = get_turf(src)
	creating_blob = 1
	if(!T)
		creating_blob = 0
		return
	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(!B)
		to_chat(usr, "You must be on a blob!")
		creating_blob = 0
		return
	if(istype(B,/obj/effect/blob/node)||istype(B,/obj/effect/blob/core)||istype(B,/obj/effect/blob/factory))
		to_chat(usr, "Unable to use this blob, find a normal one.")
		creating_blob = 0
		return
	for(var/obj/effect/blob/blob in orange(2))//Not right next to nodes/cores
		if(istype(B,/obj/effect/blob/node))
			to_chat(usr, "There is a node nearby, move away from it!")
			creating_blob = 0
			return
		if(istype(B,/obj/effect/blob/core))
			to_chat(usr, "There is a core nearby, move away from it!")
			creating_blob = 0
			return
		if(istype(B,/obj/effect/blob/factory))
			to_chat(usr, "There is another porous blob nearby, move away from it!")
			creating_blob = 0
			return
	B.change_to("Factory")
	src.dust()
	return


/mob/living/blob/verb/revert()
	set category = "Blob"
	set name = "Purge Defense"
	set desc = "Removes a porous blob."
	if(creating_blob)	return
	var/turf/T = get_turf(src)
	creating_blob = 1
	if(!T)
		creating_blob = 0
		return
	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(!B)
		to_chat(usr, "You must be on a blob!")
		creating_blob = 0
		return
	if(!istype(B,/obj/effect/blob/factory))
		to_chat(usr, "Unable to use this blob, find another one.")
		creating_blob = 0
		return
	B.change_to("Normal")
	src.dust()
	return


/mob/living/blob/verb/spawn_blob()
	set category = "Blob"
	set name = "Create new blob"
	set desc = "Attempts to create a new blob in this tile."
	if(creating_blob)	return
	var/turf/T = get_turf(src)
	creating_blob = 1
	if(!T)
		creating_blob = 0
		return
	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(B)
		to_chat(usr, "There is a blob here!")
		creating_blob = 0
		return
	new/obj/effect/blob(src.loc)
	src.dust()
	return


///mob/proc/Blobize()
/client/proc/Blobcount()
	set category = "Debug"
	set name = "blobreport"
	set desc = "blob report."
	set hidden = 1

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(SSticker && SSticker.mode)
		to_chat(src, "blobs: [blobs.len]")
		to_chat(src, "cores: [blob_cores.len]")
		to_chat(src, "nodes: [blob_nodes.len]")
	return


/client/proc/Blobize()//Mostly stolen from the respawn command
	set category = "Debug"
	set name = "Ghostblob"
	set desc = "Ghost into blobthing."
	set hidden = 1

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = ckey(input(src, "Please specify which key will be turned into a bloby.", "Key", ""))

	var/mob/dead/observer/G_found
	if(!input)
		var/list/ghosts = list()
		for(var/mob/dead/observer/G in player_list)
			ghosts += G
		if(ghosts.len)
			G_found = pick(ghosts)

	else
		for(var/mob/dead/observer/G in player_list)
			if(G.client&&ckey(G.key)==input)
				G_found = G
				break

	if(!G_found)//If a ghost was not found.
		alert("There is no active key like that in the game or the person is not currently a ghost. Aborting command.")
		return

	if(G_found.client)
		G_found.client.screen.len = null
	var/mob/living/blob/B = new/mob/living/blob(locate(0,0,1))//temp area also just in case should do this better but tired
	if(blob_cores.len > 0)
		var/obj/effect/blob/core/core = pick(blob_cores)
		if(core)
			B.loc = core.loc
	B.ghost_name = G_found.real_name
	if (G_found.client)
		G_found.client.mob = B
	B.verbs += /mob/living/blob/verb/create_node
	B.verbs += /mob/living/blob/verb/create_factory
	to_chat(B, "<B>You are now a blob fragment.</B>")
	to_chat(B, "You are a weak bit that has temporarily broken off of the blob.")
	to_chat(B, "If you stay on the blob for too long you will likely be reabsorbed.")
	to_chat(B, "If you stray from the blob you will likely be killed by other organisms.")
	to_chat(B, "You have the power to create a new blob node that will help expand the blob.")
	to_chat(B, "To create this node you will have to be on a normal blob tile and far enough away from any other node.")
	to_chat(B, "Check your Blob verbs and hit Create Node to build a node.")
	spawn(10)
		qdel(G_found)




