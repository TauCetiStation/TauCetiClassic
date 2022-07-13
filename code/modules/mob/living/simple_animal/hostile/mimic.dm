//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	response_help = "touches the"
	response_disarm = "pushes the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 150
	health = 150

	harm_intent_damage = 5
	melee_damage = 10
	attacktext = "attack"
	attack_sound = list('sound/weapons/bite.ogg')

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "mimic"
	move_to_delay = 8

	animalistic = FALSE
	has_head = TRUE

/mob/living/simple_animal/hostile/mimic/FindTarget()
	. = ..()
	if(.)
		me_emote("growls at [.]")



//
// Crate Mimic
//


// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate

	attacktext = "bites"

	stop_automated_movement = TRUE
	wander = FALSE
	var/attempt_open = 0

// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/atom_init()
	. = ..()
	for(var/obj/item/I in loc)
		I.loc = src

/mob/living/simple_animal/hostile/mimic/crate/DestroySurroundings()
	..()
	if(prob(90))
		icon_state = "[initial(icon_state)]open"
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return ..()
	return view(src, 1)

/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = 1

/mob/living/simple_animal/hostile/mimic/crate/adjustBruteLoss(damage)
	trigger()
	..(damage)

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/LostTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/death()

	var/obj/structure/closet/crate/C = new(get_turf(src))
	// Put loot in crate
	for(var/obj/O in src)
		O.loc = C

	visible_message("<span class='warning'><b>[src]</b> stops moving!</span>")
	qdel(src)
	..()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Stun(1)
			L.Weaken(2)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

//
// Copy Mimic
//

var/global/list/protected_objects = list(/obj/structure/table, /obj/structure/cable, /obj/structure/window, /obj/item/projectile/magic/animate)

/mob/living/simple_animal/hostile/mimic/copy

	health = 100
	maxHealth = 100
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0

/mob/living/simple_animal/hostile/mimic/copy/atom_init(mapload, obj/copy, mob/living/creator)
	. = ..()
	CopyObject(copy, creator)

/mob/living/simple_animal/hostile/mimic/copy/death()

	for(var/atom/movable/M in src)
		M.loc = get_turf(src)

	visible_message("<span class='warning'><b>[src]</b> stops moving!</span>")
	qdel(src)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(obj/O, mob/living/creator)

	if((isitem(O) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))

		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state

		if(istype(O, /obj/structure))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage *= 2
		else if(isitem(O))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage = 2 + I.force
			move_to_delay = 2 * I.w_class

		maxHealth = health
		if(creator)
			src.creator = creator
			faction = "\ref[creator]" // very unique
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. = ..()
	if(knockdown_people)
		var/mob/living/L = .
		if(istype(L))
			if(prob(15))
				L.Stun(1)
				L.Weaken(1)
				L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(mob/owner)
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction = "\ref[owner]"

/mob/living/simple_animal/hostile/mimic/copy/religion
	response_help = "pets the"
	attacktext = "hugs"
	a_intent = INTENT_HELP

/mob/living/simple_animal/hostile/mimic/copy/flora/atom_init(mapload)
	var/obj/structure/flora/copy = locate() in loc
	if (!copy)
		return INITIALIZE_HINT_QDEL
	return ..(mapload, copy)

/mob/living/simple_animal/hostile/mimic/prophunt
	name = "mimic"
	real_name = "mimic"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon = 'icons/mob/animal.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"

	maxHealth = 100
	health = 100
	speed = 2
	harm_intent_damage = 5
	melee_damage = 5

	universal_understand = TRUE
	universal_speak = TRUE

	var/next_transform = 0
	var/transform_cd = 30 SECONDS

	var/atom/my_prototype

/mob/living/simple_animal/hostile/mimic/prophunt/Destroy()
	my_prototype = null
	return ..()

/mob/living/simple_animal/hostile/mimic/prophunt/death()
	icon = initial(icon)
	..()

/mob/living/simple_animal/hostile/mimic/prophunt/MouseEntered()
	. = ..()
	if(isitem(my_prototype))
		apply_outline()

/mob/living/simple_animal/hostile/mimic/prophunt/MouseExited()
	. = ..()
	if(isitem(my_prototype))
		remove_outline()

/mob/living/simple_animal/hostile/mimic/prophunt/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(src != over && isitem(my_prototype))
		remove_outline()

/mob/living/simple_animal/hostile/mimic/prophunt/RangedAttack(atom/A, params)
	mimic_attack(A)

/mob/living/simple_animal/hostile/mimic/prophunt/UnarmedAttack(atom/A)
	if(a_intent == INTENT_HELP)
		mimic_attack(A)
		return
	return ..()

/mob/living/simple_animal/hostile/mimic/prophunt/examine(mob/user)
	if(!my_prototype)
		return ..()
	return my_prototype.examine(user)

/mob/living/simple_animal/hostile/mimic/prophunt/proc/CopyObject(atom/A)
	my_prototype = A

	name = A.name
	real_name = A.name
	desc = A.desc
	icon = A.icon
	icon_state = A.icon_state
	icon_living = icon_state
	appearance = A.appearance
	set_dir(A.dir)
	layer = initial(A.layer)
	plane = initial(A.plane)
	density = A.density

/mob/living/simple_animal/hostile/mimic/prophunt/proc/mimic_attack(atom/A)
	var/list/black_types = list(/turf, /mob/living/carbon/human, /obj/structure/table, /obj/structure/cable, /obj/structure/disposalpipe, /obj/machinery/atmospherics/pipe)
	if(next_transform > world.time)
		to_chat(src, "До следующего превращения: [round((next_transform - world.time) / 10)] секунд.")
		return
	if(is_type_in_list(A, black_types) || !A.has_valid_appearance())
		to_chat(src, "Вы не можете превратиться в [A.name].")
		return

	CopyObject(A)
	next_transform = world.time + transform_cd

/mob/living/simple_animal/hostile/mimic/prophunt/med_hud_set_health()
	return

/mob/living/simple_animal/hostile/mimic/prophunt/med_hud_set_status()
	return
