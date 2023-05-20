/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table_surgey_idle"
	icon_state_active = "table_surgey_active"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null

/obj/machinery/optable/atom_init()
	. = ..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break
	AddComponent(/datum/component/clickplace)
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/operating_table(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 2)
	RefreshParts()


/obj/machinery/optable/attack_paw(mob/user)
	if ((HULK in usr.mutations))
		user.SetNextMove(CLICK_CD_MELEE)
		to_chat(usr, text("<span class='notice'>You destroy the operating table.</span>"))
		visible_message("<span class='danger'>[usr] destroys the operating table!</span>")
		src.density = FALSE
		qdel(src)
	return

/obj/machinery/optable/attack_hand(mob/user)
	if (HULK in usr.mutations)
		user.SetNextMove(CLICK_CD_MELEE)
		to_chat(usr, text("<span class='notice'>You destroy the table.</span>"))
		visible_message("<span class='danger'>[usr] destroys the operating table!</span>")
		src.density = FALSE
		qdel(src)
	else
		return ..() // for fun, for braindamage and fingerprints.

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(atom/A, mob/user)
	if(user.incapacitated())
		return
	if (iscarbon(A) && isturf(user.loc) && user.IsAdvancedToolUser())
		var/mob/living/carbon/M = A
		if (M.buckled)
			M.buckled.user_unbuckle_mob(user)
		take_victim(M, user)
		return
	return ..()

/obj/machinery/optable/proc/check_victim()
	if(panel_open)
		src.victim = null
		icon_state = "table_surgey_open"
		return 0
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, src.loc)
		if(!panel_open && M.crawling)
			src.victim = M
			icon_state = M.pulse ? icon_state_active : initial(icon_state)
			return 1
	src.victim = null
	icon_state = initial(icon_state)
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user)
	if (C == user)
		user.visible_message("<span class='rose'>[user] climbs on [src].</span>","<span class='notice'>You climb on [src].</span>")
	else
		visible_message("<span class='notice'>[C] has been laid on [src] by [user].</span>")
	if (C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src
	C.SetCrawling(TRUE)
	C.loc = src.loc

	add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		src.victim = H
		icon_state = H.pulse ? icon_state_active : initial(icon_state)
	else
		icon_state = initial(icon_state)

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated() || !ishuman(usr) || !usr.canmove)
		return

	if(src.victim)
		to_chat(usr, "<span class='rose'>The table is already occupied!</span>")
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/weapon/W, mob/living/carbon/user)
	if (istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(iscarbon(G.affecting))
			take_victim(G.affecting, usr)
			user.SetNextMove(CLICK_CD_MELEE)
			qdel(G)
			return

	if(default_deconstruction_screwdriver(user, "table_surgey_open", initial(icon_state), W))
		update_icon()
		return

	var/turf/T = get_turf(src)
	if(default_deconstruction_crowbar(W))
		message_admins("[src] has been deconstructed by [key_name_admin(user)] [ADMIN_QUE(user)] [ADMIN_FLW(user)] in [COORD(T)] - [ADMIN_JMP(T)]")
		log_game("[src] has been deconstructed by [key_name(user)]")
		log_investigate("[src] deconstructed by [key_name(user)]", INVESTIGATE_SINGULO)

	return ..()
