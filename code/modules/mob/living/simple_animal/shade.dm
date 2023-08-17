/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "Связанный дух."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	universal_speak = 1
	speak_emote = list("шипит")
	emote_hear = list("стонет", "визжит")
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
	stop_automated_movement = TRUE
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
		var/obj/item/device/soulstone/S = O
		S.transfer_soul(SOULSTONE_SHADE, src, user)
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
	desc = "Странная голограмма..."
	icon_state = "shade_god"
	icon_living = "shade_god"
	stat = CONSCIOUS
	maxHealth = 5000
	health = 5000
	melee_damage = 0
	faction = "Station"
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_OBSERVER
	invisibility = INVISIBILITY_OBSERVER
	universal_understand = TRUE
	universal_speak = FALSE
	density = FALSE

	min_oxy = 0
	max_tox = 0
	max_co2 = 0
	unsuitable_atoms_damage = 0

	typing_indicator_type = null

	var/obj/item/weapon/nullrod/staff/container

/mob/living/simple_animal/shade/god/Stat()
	..()
	if(statpanel("Status"))
		if(my_religion)
			stat(null, "Favor: [round(my_religion.favor)]/[my_religion.max_favor]")

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

/mob/living/simple_animal/shade/god/Life()
	..()
	if(my_religion)
		my_religion.adjust_favor(0.2)

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

/mob/living/simple_animal/shade/god/CanPass(atom/movable/mover, turf/target, height=0)
	return TRUE

/mob/living/simple_animal/shade/god/Move(atom/NewLoc, direct)
	. = TRUE

	var/oldLoc = loc

	set_dir(direct)
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

	var/dat = data_core.html_manifest()

	var/datum/browser/popup = new(src, "manifest", "Crew Manifest", 370, 420, ntheme = CSS_THEME_LIGHT)
	popup.set_content(dat)
	popup.open()

/mob/living/simple_animal/shade/god/verb/check_area()
	set name = "Check influence in this area"
	set category = "Deity"

	var/area/A = get_area(usr)
	if(A.religion == usr.my_religion)
		to_chat(usr, "Эта зона под вашим контролем.")
	else if(isnull(A.religion))
		to_chat(usr, "Нейтральная зона.")
	else if(A.religion != usr.my_religion)
		to_chat(usr, "Зона захвачена кем-то другим.")

/mob/living/simple_animal/shade/god/resist()
	. = ..()
	if(. && container)
		if(ismob(container.loc))
			var/mob/M = container.loc
			M.drop_from_inventory(container)
			to_chat(M, "<span class='notice'>[container] wriggles out of your grip!</span>")
			to_chat(src, "<span class='notice'>You wriggle out of [M]'s grip!</span>")
		else if(isitem(container.loc) || istype(container.loc, /obj/machinery/pipedispenser/disposal))
			to_chat(src, "<span class='notice'>You struggle free of [container.loc].</span>")
			container.forceMove(get_turf(container.loc))
		else if(istype(container.loc, /obj/structure/closet))
			var/obj/structure/closet/C = container.loc
			if(!C.opened)
				to_chat(src, "<span class='notice'>You struggle free of [container.loc].</span>")
				container.forceMove(get_turf(container.loc))

/mob/living/simple_animal/shade/god/update_canmove(no_transform = FALSE)
	canmove = !buckled

/mob/living/simple_animal/shade/evil_shade
	layer = TURF_LAYER
	melee_damage = 2
	incorporeal_move = 1
	maxHealth = 15
	health = 15
	icon_state = "ghost2"
	icon_living = "ghost2"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/mob/living/simple_animal/shade/atom_init()
	. = ..()
	global.wizard_shades_count++

/mob/living/simple_animal/shade/Destroy()
	global.wizard_shades_count--
	return ..()

