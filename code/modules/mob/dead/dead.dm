//Dead mobs can exist whenever. This is needful

INITIALIZE_IMMEDIATE(/mob/dead)

/mob/dead
	sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	var/datum/spawners_menu/spawners_menu
	var/global/list/datum/spawner/registred_spawners = list()

/mob/dead/Logout()
	..()
	if(length(registred_spawners))
		for(var/datum/spawner/S in registred_spawners)
			S.cancel_registration(src)

/**
  * Doesn't call parent, see [/atom/proc/atom_init]
  */
/mob/dead/atom_init()
	SHOULD_CALL_PARENT(FALSE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	mob_list += src
	prepare_huds()

	return INITIALIZE_HINT_NORMAL

/mob/dead/dust()	//ghosts can't be vaporised.
	return

/mob/dead/gib()		//ghosts can't be gibbed.
	return

/mob/dead/incapacitated(restrained_type = ARMS)
	return !IsAdminGhost(src)

/mob/dead/me_emote(message, message_type = SHOWMSG_VISUAL, intentional=FALSE)
	to_chat(src, "<span class='notice'>You can not emote.</span>")
