#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT  2
#define BAD_INIT_SLEPT       4
#define BAD_INIT_NO_HINT     8

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = SS_INIT_ATOMS
	flags = SS_NO_FIRE | SS_SHOW_IN_MC_TAB
	msg_lobby = "Заполняем отсеки..."

	initialized = INITIALIZATION_INSSATOMS
	var/old_initialized

	var/list/late_loaders
	var/list/created_atoms

	var/list/BadInitializeCalls = list()

/datum/controller/subsystem/atoms/Initialize(timeofday)
	global_announcer = new(null) // Doh...
	setupGenetics() // to set the mutations' place in structural enzymes, so monkey.initialize() knows where to put the monkey mutation.
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()

	var/time = (world.timeofday - timeofday) / 10
	var/msg = "Initialized [name] subsystem within [time] second[time == 1 ? "" : "s"]!"
	world.log << "[msg]"
	log_initialization(msg)
	return time

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	initialized = INITIALIZATION_INNEW_MAPLOAD

	LAZYINITLIST(late_loaders)

	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		created_atoms = list()
		count = atoms.len
		for(var/I in atoms)
			var/atom/A = I
			if(!A.initialized)
				if(InitAtom(I, mapload_arg))
					atoms -= I
				CHECK_TICK
	else
		count = 0
		for(var/atom/A in world)
			if(!A.initialized)
				InitAtom(A, mapload_arg)
				++count
				CHECK_TICK

	world.log << "Initialized [count] atoms"

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders.len)
		for(var/I in late_loaders)
			var/atom/A = I
			A.atom_init_late()
		testing("Late initialized [late_loaders.len] atoms")
		late_loaders.Cut()

	if(atoms)
		. = created_atoms + atoms
		created_atoms = null

/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, list/arguments)
	var/the_type = A.type
	if(QDELING(A))
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	var/start_tick = world.time

	var/result = A.atom_init(arglist(arguments))

	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT

	var/qdeleted = FALSE

	if(result != INITIALIZE_HINT_NORMAL)
		switch(result)
			if(INITIALIZE_HINT_LATELOAD)
				if(arguments[1])	//mapload
					late_loaders += A
				else
					A.atom_init_late()
			if(INITIALIZE_HINT_QDEL)
				qdel(A)
				qdeleted = TRUE
			else
				BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A)	//possible harddel
		qdeleted = TRUE
	else if(!A.initialized)
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT

	return qdeleted || QDELETED(A)

/datum/controller/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/controller/subsystem/atoms/proc/InitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/atom_init()\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an atom_init() hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during atom_init()\n"

// Randomize block, assign a reference name, and optionally define difficulty (by making activation zone smaller or bigger)
// The name is used on /vg/ for species with predefined genetic traits,
//  and for the DNA panel in the player panel.
/datum/controller/subsystem/atoms/proc/getAssignedBlock(name,list/blocksLeft, activity_bounds=DNA_DEFAULT_BOUNDS)
	if(blocksLeft.len==0)
		warning("[name]: No more blocks left to assign!")
		return 0
	var/assigned = pick(blocksLeft)
	blocksLeft.Remove(assigned)
	assigned_blocks[assigned]=name
	dna_activity_bounds[assigned]=activity_bounds
	return assigned

/datum/controller/subsystem/atoms/proc/setupGenetics()

	if (prob(50))
		// Currently unused.  Will revisit. - N3X
		BLOCKADD = rand(-300,300)
	if (prob(75))
		DIFFMUT = rand(0,20)

	var/list/numsToAssign=new()
	for(var/i=1;i<DNA_SE_LENGTH;i++)
		numsToAssign += i

	//#Z2 A bit of sorting.
	// Standard muts, imported from older code above.
	//Major Powers (DAC)
	HULKBLOCK          = getAssignedBlock("HULK",          numsToAssign, DNA_HARD_BOUNDS)
	TELEBLOCK          = getAssignedBlock("TELE",          numsToAssign, DNA_HARD_BOUNDS)
	FIREBLOCK          = getAssignedBlock("FIRE",          numsToAssign, DNA_HARD_BOUNDS)
	XRAYBLOCK          = getAssignedBlock("XRAY",          numsToAssign, DNA_HARD_BOUNDS)
	COLDBLOCK          = getAssignedBlock("COLD",          numsToAssign, DNA_HARD_BOUNDS)
	SHOCKIMMUNITYBLOCK = getAssignedBlock("SHOCKIMMUNITY", numsToAssign, DNA_HARD_BOUNDS)
	//Minor Powers (BEA)
	NOBREATHBLOCK      = getAssignedBlock("NOBREATH",      numsToAssign, DNA_HARDER_BOUNDS)
	REMOTEVIEWBLOCK    = getAssignedBlock("REMOTEVIEW",    numsToAssign, DNA_HARDER_BOUNDS)
	REGENERATEBLOCK    = getAssignedBlock("REGENERATE",    numsToAssign, DNA_HARDER_BOUNDS)
	INCREASERUNBLOCK   = getAssignedBlock("INCREASERUN",   numsToAssign, DNA_HARDER_BOUNDS)
	REMOTETALKBLOCK    = getAssignedBlock("REMOTETALK",    numsToAssign, DNA_HARDER_BOUNDS)
	MORPHBLOCK         = getAssignedBlock("MORPH",         numsToAssign, DNA_HARDER_BOUNDS)
	NOPRINTSBLOCK      = getAssignedBlock("NOPRINTS",      numsToAssign, DNA_HARDER_BOUNDS)
	SMALLSIZEBLOCK     = getAssignedBlock("SMALLSIZE",     numsToAssign, DNA_HARDER_BOUNDS)
	//Disabilities (802)
	BLINDBLOCK         = getAssignedBlock("BLIND",         numsToAssign)
	DEAFBLOCK          = getAssignedBlock("DEAF",          numsToAssign)
	CLUMSYBLOCK        = getAssignedBlock("CLUMSY",        numsToAssign)
	COUGHBLOCK         = getAssignedBlock("COUGH",         numsToAssign)
	GLASSESBLOCK       = getAssignedBlock("GLASSES",       numsToAssign)
	EPILEPSYBLOCK      = getAssignedBlock("EPILEPSY",      numsToAssign)
	TWITCHBLOCK        = getAssignedBlock("TWITCH",        numsToAssign)
	NERVOUSBLOCK       = getAssignedBlock("NERVOUS",       numsToAssign)
	HEADACHEBLOCK      = getAssignedBlock("HEADACHE",      numsToAssign)
	HALLUCINATIONBLOCK = getAssignedBlock("HALLUCINATION", numsToAssign)
	FAKEBLOCK          = getAssignedBlock("FAKE",          numsToAssign) //##Z2

	//
	// Static Blocks
	/////////////////////////////////////////////.

	// Monkeyblock is always last.
	MONKEYBLOCK = DNA_SE_LENGTH

	// And the genes that actually do the work. (domutcheck improvements)
	var/list/blocks_assigned[DNA_SE_LENGTH]
	for(var/gene_type in typesof(/datum/dna/gene))
		var/datum/dna/gene/G = new gene_type
		if(G.block)
			if(G.block in blocks_assigned)
				warning("DNA2: Gene [G.name] trying to use already-assigned block [G.block] (used by [get_english_list(blocks_assigned[G.block])])")
			dna_genes.Add(G)
			var/list/assignedToBlock[0]
			if(blocks_assigned[G.block])
				assignedToBlock=blocks_assigned[G.block]
			assignedToBlock.Add(G.name)
			blocks_assigned[G.block]=assignedToBlock
	for(var/block=1;block<=DNA_SE_LENGTH;block++) //#Z2
		var/name = assigned_blocks[block]
		for(var/datum/dna/gene/gene in dna_genes)
			if(gene.name == name || gene.block == block)
				if(gene.block in assigned_gene_blocks)
					warning("DNA2: Gene [gene.name] trying to add to already assigned gene block list (used by [get_english_list(assigned_gene_blocks[block])])")
				assigned_gene_blocks[block] = gene

#undef BAD_INIT_QDEL_BEFORE
#undef BAD_INIT_DIDNT_INIT
#undef BAD_INIT_SLEPT
#undef BAD_INIT_NO_HINT
