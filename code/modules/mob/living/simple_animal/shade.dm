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
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
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
	speak_emote = list("hisses", "bless")
	maxHealth = 5000
	health = 5000
	melee_damage_lower = 0
	melee_damage_upper = 0
	faction = "Station"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	universal_understand = TRUE
	density = FALSE

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	unsuitable_atoms_damage = 0

	var/islam = FALSE
	var/obj/item/weapon/nullrod/staff/container

/mob/living/simple_animal/shade/god/incapacitated()
	// So the god can't use procs and stuff like that.
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
	return ..()

/mob/living/simple_animal/shade/god/Login()
	..()
	stat = CONSCIOUS
	blinded = FALSE

/mob/living/simple_animal/shade/god/proc/god_attack(atom/A)
	if(ismob(A))
		var/mob/M = A
		var/obj/item/weapon/nullrod/staff/S = M.is_in_hands(/obj/item/weapon/nullrod/staff)
		if(S && S.brainmob == src)
			// Pull them in closer...
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
