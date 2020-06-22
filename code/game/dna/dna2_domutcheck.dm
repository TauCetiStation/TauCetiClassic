//#Z2 A whole new system
// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
/proc/domutcheck(mob/living/M, connected=null, flags=0, forced=1)
	if(!M || !M.dna)
		return
	var/datum/species/S = all_species[M.get_species()]
	if(S && S.flags[NO_DNA])
		return
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		domutation(gene, M, connected, flags, forced)
		// To prevent needless copy pasting of code i put this commented out section
		// into domutation so domutcheck and genemutcheck can both use it.
		/*
		// Sanity checks, don't skip.
		if(!gene.can_activate(M,flags))
			//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
			continue

		// Current state
		var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
		if(!gene_active)
			gene_active = M.dna.GetSEState(gene.block)

		// Prior state
		var/gene_prior_status = (gene.type in M.active_genes)
		var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

		// If gene state has changed:
		if(changed)
			// Gene active (or ALWAYS ACTIVATE)
			if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
//				testing("[gene.name] activated!")
				gene.activate(M,connected,flags)
				if(M)
					M.active_genes |= gene.type
					M.update_icon = 1
			// If Gene is NOT active:
			else
//				testing("[gene.name] deactivated!")
				gene.deactivate(M,connected,flags)
				if(M)
					M.active_genes -= gene.type
					M.update_icon = 1
		*/

// Use this to force a mut check on a single gene!
/proc/genemutcheck(mob/living/M, block, connected=null, flags=0)
	if(!M)
		return
	if(block < 0)
		return
	var/datum/species/S = all_species[M.get_species()]
	if(S && S.flags[NO_DNA])
		return

	var/datum/dna/gene/gene = assigned_gene_blocks[block]
	domutation(gene, M, connected, flags)


// This proc is highly unsafe. It contains nochecks concerning whether M can have a gene activated. Please don't use directly.
/proc/domutation(datum/dna/gene/gene, mob/living/M, connected=null, flags=0, forced=1)
	if(!gene || !istype(gene))
		return FALSE

	// Sanity checks, don't skip.
	if(!gene.can_activate(M,flags))
		//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
		return FALSE

	// Current state
	var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
	if(!gene_active)
		gene_active = M.dna.GetSEState(gene.block)

	// Prior state
	var/gene_prior_status = (gene.type in M.active_genes)
	var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

	// If gene state has changed:
	if(changed)
		// Gene active (or ALWAYS ACTIVATE)
		if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
			if( (!forced && !prob(gene.activation_prob)) || (gene.flags & GENE_ALWAYS_ACTIVATE)) //#Z2
				//testing("We failed for [gene] [gene.activation_prob] percent chance activation!")
				return
			/*if(forced)
				testing("[gene.name] percent chance was [gene.activation_prob], but gene mutation was forced!")
			else
				testing("[gene.name] percent chance was [gene.activation_prob] and passed!") //##Z2
			*/
			//testing("[gene.name] activated!")
			gene.activate(M,connected,flags)
			if(M)
				M.active_genes |= gene.type
				M.update_icon = 1
		// If Gene is NOT active:
		else
			//testing("[gene.name] deactivated!")
			gene.deactivate(M,connected,flags)
			if(M)
				M.active_genes -= gene.type
				M.update_icon = 1
