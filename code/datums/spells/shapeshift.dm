/obj/effect/proc_holder/spell/no_target/shapeshift
	name = "Перевёртыш"
	desc = "Примите облик какого-либо существа на время, чтобы использовать его силы. Как только вы выбрали существо, его уже нельзя будет изменить."
	clothes_req = FALSE
	charge_max = 200
	range = -1
	invocation = "RAC'WA NO!"
	invocation_type = "shout"
	action_icon_state = "shapeshift"

	/// Whether we revert to our human form on death.
	var/revert_on_death = TRUE
	/// Whether we die when our shapeshifted form is killed
	var/die_with_shapeshifted_form = TRUE
	/// Whether we convert our health from one form to another
	var/convert_damage = TRUE
	/// If convert damage is true, the damage type we deal when converting damage back and forth
	var/convert_damage_type = BURN //Since simplemobs don't have advanced damagetypes, what to convert damage back into.

	/// Our chosen type.
	var/mob/living/shapeshift_type
	/// All possible types we can become.
	/// This should be implemented even if there is only one choice.
	var/list/possible_shapes = list(
		/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/corgi,\
		/mob/living/simple_animal/hostile/carp,\
		/mob/living/simple_animal/hostile/giant_spider/hunter,\
		/mob/living/simple_animal/hostile/blob/blobbernaut/independent,)

/obj/effect/proc_holder/spell/no_target/shapeshift/cast(list/targets, mob/living/user = usr)
	if(user.buckled)
		user.buckled.unbuckle_mob()
	if(!shapeshift_type)
		var/list/animal_list = list()
		var/list/display_animals = list()
		for(var/path in possible_shapes)
			var/mob/living/simple_animal/animal = path
			animal_list[initial(animal.name)] = path
			var/image/animal_image = image(icon = initial(animal.icon), icon_state = initial(animal.icon_state))
			display_animals += list(initial(animal.name) = animal_image)
		sortList(display_animals)
		var/new_shapeshift_type = show_radial_menu(user, user, display_animals, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 38, require_near = TRUE)
		if(!new_shapeshift_type)
			return
		shapeshift_type = animal_list[new_shapeshift_type]

	var/obj/shapeshift_holder/S = locate() in user
	if(S)
		user = Restore(user)
	else
		user = Shapeshift(user)

	// Are we currently ventcrawling?
	if(!user.is_ventcrawling)
		return
	// Can our new form support ventcrawling?
	var/ventcrawler = user.ventcrawler
	if(ventcrawler)
		return

	// Shapeshifting into something that can't fit into a vent
	var/obj/machinery/atmospherics/pipeyoudiein = user.loc
	var/datum/pipeline/ourpipeline
	var/pipenets = pipeyoudiein.returnPipenets()

	if(islist(pipenets))
		ourpipeline = pipenets[1]
	else
		ourpipeline = pipenets

	to_chat(user, "<span class='userdanger'>Использование Перевёртыша внутри трубы расплющивает тебя в кровавое мессиво, которое вытекает из близжайшей вентиляции!</span>")
	var/gibtype = /obj/effect/gibspawner/generic
	if(isalien(user))
		gibtype = /obj/effect/gibspawner/xeno
	for(var/obj/machinery/atmospherics/components/unary/possiblevent in range(10, get_turf(user))) //Funny thing
		if(possiblevent.parents.len && possiblevent.parents[1] == ourpipeline)
			new gibtype(get_turf(possiblevent))
			playsound(possiblevent, 'sound/effects/reee.ogg', VOL_EFFECTS_MASTER)
	user.death() //One will try, the other one will get a warning
	qdel(user)

/**
 * check_menu: Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The mob interacting with a menu
 */
/obj/effect/proc_holder/spell/no_target/shapeshift/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/no_target/shapeshift/proc/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, "<span class='userdanger'>Вы уже приняли форму существа!</span>")
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	H = new(shape, src, caster)

	clothes_req = FALSE
	return shape

/obj/effect/proc_holder/spell/no_target/shapeshift/proc/Restore(mob/living/shape)
	var/obj/shapeshift_holder/H = locate() in shape
	if(!H)
		return

	. =  H.stored
	H.restore()

	clothes_req = initial(clothes_req)

/obj/effect/proc_holder/spell/no_target/shapeshift/abductor
	name = "True form"
	desc = "Reveal your true form!"
	convert_damage = FALSE

/obj/effect/proc_holder/spell/no_target/shapeshift/abductor/atom_init()
	. = ..()
	var/form = pick("slime", "corgi", "mouse")
	switch(form)
		if("slime")
			invocation = "BLORP-BLORP. BLOOORP"
			shapeshift_type = /mob/living/carbon/slime/adult
		if("corgi")
			invocation = "WOOF. WAF! BARK!"
			shapeshift_type = /mob/living/simple_animal/corgi
		if("mouse")
			invocation = "Squeeeeeek!"
			shapeshift_type = /mob/living/simple_animal/mouse

/obj/shapeshift_holder
	name = "Shapeshift holder"
	resistance_flags = INDESTRUCTIBLE
	flags = ABSTRACT
	var/mob/living/stored
	var/mob/living/shape
	var/restoring = FALSE
	var/obj/effect/proc_holder/spell/no_target/shapeshift/source

/obj/shapeshift_holder/atom_init(mapload, obj/effect/proc_holder/spell/no_target/shapeshift/_source, mob/living/caster)
	. = ..()
	source = _source
	shape = loc
	if(!istype(shape))
		stack_trace("shapeshift holder created outside /mob/living")
		return INITIALIZE_HINT_QDEL
	stored = caster
	if(stored.mind)
		stored.mind.transfer_to(shape)
		shape.spell_list = stored.spell_list
	stored.forceMove(src)
	stored.notransform = TRUE
	if(source.convert_damage)
		var/damage_percent = (stored.maxHealth - stored.health)/stored.maxHealth;
		var/damapply = damage_percent * shape.maxHealth;
		shape.apply_damage(damapply, source.convert_damage_type)

	RegisterSignal(shape, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DIED), PROC_REF(shape_death))
	RegisterSignal(stored, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DIED), PROC_REF(caster_death))

/obj/shapeshift_holder/Destroy()
	// Restore manages signal unregistering. If restoring is TRUE, we've already unregistered the signals and we're here
	// because restore() qdel'd src.
	if(!restoring)
		restore()
	stored = null
	shape = null
	return ..()

/obj/shapeshift_holder/Moved() //Somehow it is outside
	. = ..()
	if(!restoring || QDELETED(src))
		restore()

/obj/shapeshift_holder/handle_atom_del(atom/A) //Don't let our body be deleted
	if(A == stored && !restoring)
		restore()

/obj/shapeshift_holder/Exited(atom/movable/gone, direction) //Somehow it is outside
	if(stored == gone && !restoring)
		restore()

/obj/shapeshift_holder/proc/caster_death()
	SIGNAL_HANDLER
	//Something kills the stored caster through direct damage.
	if(source.revert_on_death)
		restore(death=TRUE)
	else
		shape.death()

/obj/shapeshift_holder/proc/shape_death()
	SIGNAL_HANDLER
	//Shape dies
	if(source.die_with_shapeshifted_form)
		if(source.revert_on_death)
			restore(death=TRUE)
	else
		restore()

/obj/shapeshift_holder/proc/restore(death=FALSE)
	// Destroy() calls this proc if it hasn't been called. Unregistering here prevents multiple qdel loops
	// when caster and shape both die at the same time.
	UnregisterSignal(shape, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DIED))
	UnregisterSignal(stored, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DIED))
	restoring = TRUE
	stored.forceMove(shape.loc)
	stored.notransform = FALSE
	if(shape.mind)
		shape.mind.transfer_to(stored)

	if(death)
		stored.death()
	else if(source.convert_damage)
		var/damage_percent = (shape.maxHealth - shape.health)/shape.maxHealth;
		var/damapply = stored.maxHealth * damage_percent
		stored.apply_damage(damapply, source.convert_damage_type)

	stored.is_ventcrawling = shape.is_ventcrawling // Dramatic

	// This guard is important because restore() can also be called on COMSIG_PARENT_QDELETING for shape, as well as on death.
	// This can happen in, for example, [/proc/wabbajack] where the mob hit is qdel'd.
	if(!QDELETED(shape))
		QDEL_NULL(shape)

	qdel(src)
