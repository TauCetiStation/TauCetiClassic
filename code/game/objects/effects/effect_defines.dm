/obj/effect
	flags = ABSTRACT



/obj/effect/particles_holder
	name = "particles holder"

	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	plane = GAME_PLANE
	layer = INFRONT_MOB_LAYER

	anchored = TRUE

	var/atom/movable/parent

/obj/effect/particles_holder/atom_init(mapload, particlesPath)
	. = ..()

	if(!loc || !particlesPath)
		return INITIALIZE_HINT_QDEL

	//Уводим генератор партиклов в нуллспесс чтобы оно валялось в нигде.
	parent = loc
	loc = null

	particles = new particlesPath()

	parent.vis_contents += src
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(parent_deleted))

/obj/effect/particles_holder/Destroy()
	QDEL_NULL(particles)
	parent = null
	return ..()

/obj/effect/particles_holder/proc/parent_deleted()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/proc/add_particles(pathOrPaths)//Возможность закинуть лист партиклов для сложных эффектов на несколько партиклов разом.
	var/list/allPaths = list()
	allPaths += pathOrPaths

	var/list/allParticles = list()
	for(var/particlesPath in allPaths)
		var/obj/effect/particles_holder/Holder = new(src, particlesPath)
		allParticles += Holder

	return allParticles

/atom/movable/proc/cut_particles(holderOrHolders)
	var/list/allHolders = list()
	allHolders += holderOrHolders

	for(var/obj/effect/particles_holder/Holder in allHolders)
		qdel(Holder)

/obj/effect/shared_particles_holder
	name = "particles holder"

	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	plane = GAME_PLANE
	layer = INFRONT_MOB_LAYER

	anchored = TRUE

/obj/effect/shared_particles_holder/atom_init(mapload, particlesPath)
	. = ..()

	if(!particlesPath)
		return INITIALIZE_HINT_QDEL

	//Уводим генератор партиклов в нуллспесс чтобы оно валялось в нигде.
	loc = null

	particles = new particlesPath()

/obj/effect/shared_particles_holder/Destroy()
	QDEL_NULL(particles)
	return ..()

var/global/list/shared_particles = list()

/atom/movable/proc/add_shared_particles(pathOrPaths)//Возможность закинуть лист партиклов для сложных эффектов на несколько партиклов разом.
	var/list/allPaths = list()
	allPaths += pathOrPaths

	for(var/particlesPath in allPaths)

