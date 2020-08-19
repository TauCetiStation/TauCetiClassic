/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	universal_speak = 1
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches the"
	melee_damage = 10
	attacktext = "drain"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = -1
	stop_automated_movement = 1
	status_flags = 0
	faction = "cult"
	status_flags = CANPUSH

	animalistic = FALSE
	has_head = TRUE
	has_arm = TRUE

/mob/living/simple_animal/shade/Life()
	..()
	if(stat == DEAD)
		new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(loc)
		visible_message("<span class='warning'>[src] lets out a contented sigh as their form unwinds.</span>")
		ghostize(bancheck = TRUE)
		qdel(src)
		return


/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user)  //Marker -Agouri
	if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("SHADE", src, user)
	else
		if(O.force)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			health -= damage
			visible_message("<span class='warning'><b>[src] has been attacked with the [O] by [user].</b></span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			visible_message("<span class='warning'>[user] gently taps [src] with the [O].</span>")
	return

/mob/living/simple_animal/shade/god
	name = "Unbelievable God"
	real_name = "Unbelievable God"
	desc = "Strange looking hologram."
	icon_state = "shade_god"
	icon_living = "shade_god"
	stat = CONSCIOUS
	maxHealth = 5000
	health = 5000
	melee_damage = 0
	faction = "Station"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	universal_understand = TRUE
	density = FALSE

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	unsuitable_atoms_damage = 0

	var/obj/item/weapon/nullrod/staff/container

	var/datum/religion/my_religion

/mob/living/simple_animal/shade/god/Stat()
	..()
	if(statpanel("Status"))
		if(global.chaplain_religion)
			stat(null, "Favor: [round(global.chaplain_religion.favor)]/[global.chaplain_religion.max_favor]")

/mob/living/simple_animal/shade/god/incapacitated(restrained_type = ARMS)
	// So the god can't use verbs and stuff like that.
	return TRUE

/mob/living/simple_animal/shade/god/atom_init()
	. = ..()
	gods_list += src

/mob/living/simple_animal/shade/god/Destroy()
	gods_list -= src
	if(container)
		container.brainmob = null
		QDEL_NULL(container.god_image)
		container = null

	if(my_religion)
		my_religion.remove_deity(src)

	return ..()

/mob/living/simple_animal/shade/god/Login()
	..()
	stat = CONSCIOUS
	blinded = FALSE

/mob/living/simple_animal/shade/god/Life()
	..()
	if(global.chaplain_religion)
		global.chaplain_religion.favor += 0.2

/mob/living/simple_animal/shade/god/proc/god_attack(atom/A)
	if(ismob(A))
		var/mob/M = A
		var/obj/item/weapon/nullrod/staff/S = M.is_in_hands(/obj/item/weapon/nullrod/staff)
		if(S && S.brainmob == src)
			if(a_intent != INTENT_HARM)
				// Pull them in closer...
				step_towards(A, src)
				SetNextMove(CLICK_CD_RAPID)
			else
				M.drop_item()
	else if(istype(A, /obj/item/weapon/nullrod/staff))
		var/obj/item/weapon/nullrod/staff/S = A
		if(S.brainmob == src)
			step_towards(A, src)
			SetNextMove(CLICK_CD_RAPID)
	else
		A.attack_ghost(src)
		SetNextMove(CLICK_CD_MELEE)

/mob/living/simple_animal/shade/god/UnarmedAttack(atom/A)
	god_attack(A)

/mob/living/simple_animal/shade/god/RangedAttack(atom/A, params)
	god_attack(A)

/mob/living/simple_animal/shade/god/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return TRUE

/mob/living/simple_animal/shade/god/Move(atom/NewLoc, direct)
	. = TRUE

	var/oldLoc = loc

	dir = direct
	if(NewLoc)
		if (SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, NewLoc, direct) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
			return

		forceMove(NewLoc)
		return

	forceMove(get_turf(src)) //Get out of closets and such as a ghostly being.
	var/new_x = x
	var/new_y = y
	if((direct & NORTH) && y < world.maxy)
		new_y++
	else if((direct & SOUTH) && y > 1)
		new_y--
	if((direct & EAST) && x < world.maxx)
		new_x++
	else if((direct & WEST) && x > 1)
		new_x--

	if (SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, locate(new_x, new_y,  z), direct) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return

	x = new_x
	y = new_y

	Moved(oldLoc, 0)

/mob/living/simple_animal/shade/god/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/shade/god/verb/view_manfiest()
	set name = "View Crew Manifest"
	set category = "Deity"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

/mob/living/simple_animal/shade/god/resist()
	. = ..()
	if(. && container)
		var/mob/M = container.loc
		if(istype(M))
			M.drop_from_inventory(container)
			to_chat(M, "<span class='notice'>[container] wriggles out of your grip!</span>")
			to_chat(src, "<span class='notice'>You wriggle out of [M]'s grip!</span>")
		else if(istype(container.loc, /obj/item))
			to_chat(src, "<span class='notice'>You struggle free of [container.loc].</span>")
			container.forceMove(get_turf(container.loc))

/mob/living/simple_animal/shade/god/update_canmove(no_transform = FALSE)
	if(paralysis || stunned || weakened || buckled || pinned.len)
		canmove = FALSE
	else
		canmove = TRUE
	return canmove
