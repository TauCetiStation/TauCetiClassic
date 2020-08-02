//gene sequence datum
/datum/genesequence
	var/spawned_type
	var/list/full_genome_sequence = list()



#define SCANFOSSIL_RETVAL_WRONGTYPE 1
#define SCANFOSSIL_RETVAL_NOMOREGENESEQ 2
#define SCANFOSSIL_RETVAL_SUCCESS 4

/obj/machinery/computer/reconstitutor
	name = "Flora reconstitution console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "dna"
	circuit = "/obj/item/weapon/circuitboard/reconstitutor"
	req_access = list(access_xenoarch) //Only used for record deletion right now. //xenoarch couldn't use it when it was access_heads
	var/obj/machinery/clonepod/pod1 = 1 //Linked cloning pod.
	var/last_used = 0 // We don't want seeds getting spammed
	var/temp = ""
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/list/undiscovered_genesequences = null
	var/list/discovered_genesequences = list()
	var/list/completed_genesequences = list()
	var/list/undiscovered_genomes = list()
	var/list/manually_placed_genomes = list()
	var/list/discovered_genomes = list("! Clear !")
	var/list/accepted_fossil_types = list(/obj/item/weapon/fossil/plant)

/obj/machinery/computer/reconstitutor/atom_init()
	. = ..()
	if(!undiscovered_genesequences)
		undiscovered_genesequences = SSxenoarch.all_plant_genesequences.Copy()

/obj/machinery/computer/reconstitutor/animal
	name = "Fauna reconstitution console"
	accepted_fossil_types = list(/obj/item/weapon/fossil/bone,/obj/item/weapon/fossil/shell,/obj/item/weapon/fossil/skull,/obj/item/weapon/fossil/skull/horned)
	pod1 = null
	circuit = /obj/item/weapon/circuitboard/reconstitutor/animal

/obj/machinery/computer/reconstitutor/animal/atom_init()
	undiscovered_genesequences = SSxenoarch.all_animal_genesequences.Copy()
	. = ..()

/obj/machinery/computer/reconstitutor/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/fossil))
		user.drop_item()
		W.loc = src.loc
		switch(scan_fossil(W))
			if(1)
				src.visible_message("<span class='red'> [bicon(src)] [src] scans the fossil and rejects it.</span>")
			if(2)
				visible_message("<span class='red'> [bicon(src)] [src] can not extract any more genetic data from new fossils.</span>")
			if(4)
				src.visible_message("<span class='notice'>[bicon(src)] [user] inserts [W] into [src], the fossil is consumed as [src] extracts genetic data from it.</span>")
				qdel(W)
				updateDialog()
	else if (istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		var/numaccepted = 0
		var/numrejected = 0
		var/full = 0
		for(var/obj/item/weapon/fossil/F in S.contents)
			switch(scan_fossil(F))
				if(SCANFOSSIL_RETVAL_WRONGTYPE)
					numrejected += 1
				if(SCANFOSSIL_RETVAL_NOMOREGENESEQ)
					full = 1
				if(SCANFOSSIL_RETVAL_SUCCESS)
					numaccepted += 1
					S.remove_from_storage(F, src) //This will move the item to this item's contents
					qdel(F)
					updateDialog()
		var/outmsg = "<span class='notice'>You empty all the fossils from [S] into [src].</span>"
		if(numaccepted)
			outmsg += " <span class='notice'>[numaccepted] fossils were accepted and consumed as [src] extracts genetic data from them.</span>"
		if(numrejected)
			outmsg += " <span class='red'>[numrejected] fossils were rejected.</span>"
		if(full)
			outmsg += " <span class='red'>[src] can not extract any more genetic data from new fossils.</span>"
		visible_message(outmsg)

	else
		..()

/obj/machinery/computer/reconstitutor/ui_interact(mob/user)
	if(stat & (NOPOWER|BROKEN) || get_dist(src, user) > 1 && !issilicon(user) && !isobserver(user))
		user.unset_machine(src)
		return

	var/dat = "<B>Garland Corp genetic reconstitutor</B><BR>"
	dat += "<HR>"
	if(!pod1)
		pod1 = locate() in orange(1, src)

	if(!pod1)
		dat += "<b><font color=red>Unable to locate cloning pod.</font></b><br>"
	else if(istype(pod1))
		dat += "<b><font color=green>Cloning pod connected.</font></b><br>"

	dat += "<table border=1>"
	dat += "<tr>"
	dat += "<td><b>GENE1</b></td>"
	dat += "<td><b>GENE2</b></td>"
	dat += "<td><b>GENE3</b></td>"
	dat += "<td><b>GENE4</b></td>"
	dat += "<td><b>GENE5</b></td>"
	dat += "<td></td>"
	dat += "<td></td>"
	dat += "</tr>"

	//WIP gene sequences
	for(var/sequence_num = 1, sequence_num <= discovered_genesequences.len, sequence_num += 1)
		var/datum/genesequence/cur_genesequence = discovered_genesequences[sequence_num]
		dat += "<tr>"
		var/num_correct = 0
		for(var/curindex = 1, curindex <= 5, curindex++)
			var/bgcolour = "#ffffff"//white ffffff, red ff0000

			//background colour hints at correct positioning
			if(manually_placed_genomes[sequence_num][curindex])
				//green background if slot is correctly filled
				if(manually_placed_genomes[sequence_num][curindex] == cur_genesequence.full_genome_sequence[curindex])
					bgcolour = "#008000"
					num_correct += 1
					if(num_correct == 5)
						discovered_genesequences -= cur_genesequence
						completed_genesequences += cur_genesequence
						manually_placed_genomes[sequence_num] = new/list(5)
						updateDialog()
						return
				//yellow background if adjacent to correct slot
				if(curindex > 1 && manually_placed_genomes[sequence_num][curindex] == cur_genesequence.full_genome_sequence[curindex - 1])
					bgcolour = "#ffff00"
				else if(curindex < 5 && manually_placed_genomes[sequence_num][curindex] == cur_genesequence.full_genome_sequence[curindex + 1])
					bgcolour = "#ffff00"

			var/this_genome_slot = manually_placed_genomes[sequence_num][curindex]
			if(!this_genome_slot)
				this_genome_slot = "- - - - -"
			dat += "<td><a href='?src=\ref[src];sequence_num=[sequence_num];insertpos=[curindex]' style='background-color:[bgcolour]'>[this_genome_slot]</a></td>"
		dat += "<td><a href='?src=\ref[src];reset=1;sequence_num=[sequence_num]'>Reset</a></td>"
		//dat += "<td><a href='?src=\ref[src];clone=1;sequence_num=[sequence_num]'>Clone</a></td>"
		dat += "</tr>"

	//completed gene sequences
	for(var/sequence_num = 1, sequence_num <= completed_genesequences.len, sequence_num += 1)
		var/datum/genesequence/cur_genesequence = completed_genesequences[sequence_num]
		dat += "<tr>"
		for(var/curindex = 1, curindex <= 5, curindex++)
			var/this_genome_slot = cur_genesequence.full_genome_sequence[curindex]
			dat += "<td style='background-color:#008000'>[this_genome_slot]</td>"
		dat += "<td><a href='?src=\ref[src];wipe=1;sequence_num=[sequence_num]'>Wipe</a></td>"
		dat += "<td><a href='?src=\ref[src];clone=1;sequence_num=[sequence_num]'>Clone</a></td>"
		dat += "</tr>"

	dat += "</table>"

	dat += "<br>"
	dat += "<hr>"
	dat += "<a href='?src=\ref[src];close=1'>Close</a>"
	user << browse(dat, "window=reconstitutor;size=600x500")
	onclose(user, "reconstitutor")

/obj/machinery/computer/reconstitutor/Topic(href, href_list)
	if(href_list["close"])
		usr.unset_machine(src)
		usr << browse(null, "window=reconstitutor")
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["insertpos"])
		//world << "inserting gene for genesequence [href_list["insertgenome"]] at pos [text2num(href_list["insertpos"])]"
		var/sequence_num = text2num(href_list["sequence_num"])
		var/insertpos = text2num(href_list["insertpos"])

		var/old_genome = manually_placed_genomes[sequence_num][insertpos]
		discovered_genomes = sortList(discovered_genomes)
		var/new_genome = input(usr, "Which genome do you want to insert here?") as null|anything in discovered_genomes
		if(new_genome == "! Clear !")
			manually_placed_genomes[sequence_num][insertpos] = null
		else if(new_genome)
			manually_placed_genomes[sequence_num][insertpos] = new_genome
			discovered_genomes.Remove(new_genome)
		if(old_genome)
			discovered_genomes.Add(old_genome)

	else if(href_list["reset"])
		var/sequence_num = text2num(href_list["sequence_num"])
		for(var/curindex = 1, curindex <= 5, curindex++)
			var/old_genome = manually_placed_genomes[sequence_num][curindex]
			manually_placed_genomes[sequence_num][curindex] = null
			if(old_genome)
				discovered_genomes.Add(old_genome)

	else if(href_list["wipe"])
		var/sequence_num = text2num(href_list["sequence_num"])
		var/datum/genesequence/wiped_genesequence = completed_genesequences[sequence_num]
		completed_genesequences.Remove(wiped_genesequence)
		discovered_genesequences.Add(wiped_genesequence)
		discovered_genomes.Add(wiped_genesequence.full_genome_sequence)
		discovered_genomes = sortList(discovered_genomes)

	else if(href_list["clone"])
		reconstruct(text2num(href_list["sequence_num"]))

	updateDialog()

/obj/machinery/computer/reconstitutor/proc/reconstruct(sequence_num)
	if(world.time > src.last_used + 150)
		var/datum/genesequence/cloned_genesequence = completed_genesequences[sequence_num]
		visible_message("<span class='notice'>[bicon(src)] [src] clones a packet of seeds from a reconstituted gene sequence!</span>")
		playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, null, -3)
		new cloned_genesequence.spawned_type(src.loc)
		src.last_used = world.time
	else
		visible_message("<span class='notice'>[bicon(src)] [src] is recharging.</span>")

/obj/machinery/computer/reconstitutor/animal/reconstruct(sequence_num)
	var/datum/genesequence/cloned_genesequence = completed_genesequences[sequence_num]
	if(pod1)
		if(pod1.occupant)
			visible_message("<span class='red'>[bicon(src)] The cloning pod is currently occupied.</span>")
		else if(pod1.biomass < CLONE_BIOMASS)
			visible_message("<span class='red'>[bicon(src)] Not enough biomass in the cloning pod.</span>")
		else if(pod1.mess)
			visible_message("<span class='red'>[bicon(src)] Error: clonepod malfunction.</span>")
		else
			visible_message("<span class='notice'>[bicon(src)] [src] clones something from a reconstituted gene sequence!</span>")
			playsound(src, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, null, -3)
			pod1.occupant = new cloned_genesequence.spawned_type(pod1)
			pod1.locked = 1
			pod1.icon_state = "pod_1"
			//pod1.occupant.name = "[pod1.occupant.name] ([rand(0,999)])"
			pod1.biomass -= CLONE_BIOMASS
	else
		to_chat(usr, "<span class='red'>[bicon(src)] Unable to locate cloning pod!</span>")

/obj/machinery/computer/reconstitutor/proc/scan_fossil(obj/item/weapon/fossil/scan_fossil)
	// see whether we accept these kind of fossils
	if(accepted_fossil_types.len && !accepted_fossil_types.Find(scan_fossil.type))
		return SCANFOSSIL_RETVAL_WRONGTYPE

	if(undiscovered_genesequences.len)

		// calculate a chance to discover a new gensequence (the more unfinished gensequences we got - the less chance to get another one)
		var/new_gensequence_prob = 100 / max(1, discovered_genesequences.len * 5)

		if(!undiscovered_genomes.len || prob(new_gensequence_prob))
			// discover new gene sequence
			var/datum/genesequence/newly_discovered_genesequence = pick(undiscovered_genesequences)
			undiscovered_genesequences -= newly_discovered_genesequence
			discovered_genesequences += newly_discovered_genesequence

			// add genomes for new gene sequence to pool of discoverable genomes
			undiscovered_genomes.Add(newly_discovered_genesequence.full_genome_sequence)
			manually_placed_genomes.Add(null)
			manually_placed_genomes[manually_placed_genomes.len] = new/list(5)


		// add new genomes (we can get from 1 to 3 genomes for each time)
		if(undiscovered_genomes.len)

			// create a new genome for an existing gene sequence
			var/newly_discovered_genome = pick(undiscovered_genomes)
			undiscovered_genomes -= newly_discovered_genome
			discovered_genomes.Add(newly_discovered_genome)

			// chance to discover a second genome
			if(prob(75) && undiscovered_genomes.len)
				newly_discovered_genome = pick(undiscovered_genomes)
				undiscovered_genomes -= newly_discovered_genome
				discovered_genomes.Add(newly_discovered_genome)

				// chance to discover a third genome
				if(prob(50) && undiscovered_genomes.len)
					newly_discovered_genome = pick(undiscovered_genomes)
					undiscovered_genomes -= newly_discovered_genome
					discovered_genomes.Add(newly_discovered_genome)

	else
		// there's no point scanning any more fossils, we've already discovered everything
		return SCANFOSSIL_RETVAL_NOMOREGENESEQ

	return SCANFOSSIL_RETVAL_SUCCESS

#undef SCANFOSSIL_RETVAL_WRONGTYPE
#undef SCANFOSSIL_RETVAL_NOMOREGENESEQ
#undef SCANFOSSIL_RETVAL_SUCCESS


/obj/item/weapon/circuitboard/reconstitutor
	name = "Circuit board (Flora Reconstitution Console)"
	build_path = /obj/machinery/computer/reconstitutor
	origin_tech = "programming=2;biotech=4;materials=6"
	frame_desc = "Requires 2 Advanced Scanning Module, 1 Nano Manipulator, 1 Matter Bin and 1 Advanced Capacitor."
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module/adv = 2,
							/obj/item/weapon/stock_parts/manipulator/nano = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/capacitor/adv = 1)

/obj/item/weapon/circuitboard/reconstitutor/animal
	name = "Circuit board (Fauna Reconstitution Console)"
	build_path = /obj/machinery/computer/reconstitutor/animal
	origin_tech = "programming=2;biotech=4;materials=6"
	frame_desc = "Requires 2 Advanced Scanning Module, 1 Nano Manipulator, 1 Matter Bin and 1 Advanced Capacitor."
	req_components = list(
							/obj/item/weapon/stock_parts/scanning_module/adv = 2,
							/obj/item/weapon/stock_parts/manipulator/nano = 1,
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/capacitor/adv = 1)