
var/list/ventcrawl_machinery = list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber)

//VENTCRAWLING

/mob/living/proc/handle_ventcrawl(atom/A)
	if(!ventcrawler || !Adjacent(A))
		return
	if(stat)
		to_chat(src, "You must be conscious to do this!")
		return
	if(lying)
		to_chat(src, "You can't vent crawl while you're stunned!")
		return
	if(restrained())
		to_chat(src, "You can't vent crawl while you're restrained!")
		return
	if(buckled_mob)
		to_chat(src, "You can't vent crawl with [buckled_mob] on you!")
		return

	var/obj/machinery/atmospherics/unary/vent_found


	if(A)
		vent_found = A
		if(!istype(vent_found) || !vent_found.can_crawl_through())
			vent_found = null

	if(!vent_found)
		for(var/obj/machinery/atmospherics/machine in range(1,src))
			if(is_type_in_list(machine, ventcrawl_machinery))
				vent_found = machine

			if(!vent_found.can_crawl_through())
				vent_found = null

			if(vent_found)
				break

	if(vent_found)
		//var/obj/machinery/atmospherics/unary/vent_found = vent_found
		//if(vent_found.node.parent && (vent_found.node.parent.members.len || vent_found.node.parent.normal_members))
		if(vent_found.network && (vent_found.node:parent.members.len || vent_found.network.normal_members))
			visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>" ,"<span class='notice'>You begin climbing into the ventilation system...</span>")

			if(!do_after(src, 25, target = usr))
				return

			if(!client)
				return

			if(iscarbon(src) && contents.len && ventcrawler < 2)//It must have atleast been 1 to get this far
				for(var/obj/item/I in contents)
					var/failed = 0
					if(istype(I, /obj/item/weapon/implant))
						continue
					else
						failed++

					if(failed)
						to_chat(src, "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>")
						return

			visible_message("<span class='notice'>[src] scrambles into the ventilation ducts!</span>","<span class='notice'>You climb into the ventilation ducts.</span>")
			loc = vent_found
			add_ventcrawl(vent_found)
	else
		to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/unary/starting_machine)
	if(!starting_machine)
		return
	//if(vent_found.network && (vent_found.network.normal_members.len || vent_found.network.normal_members))
	//var/list/temp0
	//var/list/temp1
	//var/list/temp2
	//for(temp0 in starting_machine.network.line_members)
	//	if(!temp1)
	//		temp1 = temp0
	//	else if(!temp2)
	//		temp2 = temp0
	//if(temp1 && temp2)
	//	temp1 += temp2
	var/list/totalMembers = starting_machine.node:parent.members + starting_machine.network.normal_members
	//var/list/totalMembers = temp1 + starting_machine.network.normal_members
	for(var/atom/A in totalMembers)
		var/image/new_image = image(A, A.loc, dir = A.dir, layer = ABOVE_HUD_PLANE)
		new_image.plane = ABOVE_HUD_PLANE
		pipes_shown += new_image
		if(client)
			client.images += new_image


/mob/living/proc/remove_ventcrawl()
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src
	pipes_shown.len = 0




//OOP
/atom/proc/update_pipe_vision()
	return

/mob/living/update_pipe_vision()
	if(pipes_shown.len)
		if(!istype(loc, /obj/machinery/atmospherics))
			remove_ventcrawl()
	else
		if(istype(loc, /obj/machinery/atmospherics))
			add_ventcrawl(loc)
