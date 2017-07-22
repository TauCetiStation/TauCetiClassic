//switch this out to use a database at some point
//list of ckey/ real_name and item paths
//gives item to specific people when they join if it can
//for multiple items just add mutliple entries, unless i change it to be a listlistlist
//yes, it has to be an item, you can't pick up nonitems

/var/list/custom_items = list()

/proc/EquipCustomItems(mob/living/carbon/human/M)
	for(var/line in custom_items)
		// split & clean up
		var/list/Entry = splittext(line, ":")
		for(var/i = 1 to Entry.len)
			Entry[i] = trim(Entry[i])

		if(Entry.len < 3)
			continue;

		if(Entry[1] == M.ckey && Entry[2] == M.real_name)
			var/list/Paths = splittext(Entry[3], ",")
			for(var/P in Paths)
				var/ok = 0  // 1 if the item was placed successfully
				P = trim(P)
				var/path = text2path(P)
				if(!path) continue

				var/obj/item/Item = new path()
				if(istype(Item,/obj/item/weapon/card/id))
					//id card needs to replace the original ID
					var/obj/item/weapon/card/id/I = Item
					for(var/obj/item/weapon/card/id/C in M)
						//default settings
						I.name = "[M.real_name]'s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
						I.registered_name = M.real_name
						I.access = C.access
						I.assignment = C.assignment
						I.blood_type = C.blood_type
						I.dna_hash = C.dna_hash
						I.fingerprint_hash = C.fingerprint_hash
						//I.pin = C.pin

						//replace old ID
						qdel(C)
						ok = M.equip_to_slot_if_possible(I, slot_wear_id, 0)	//if 1, last argument deletes on fail
						break
				else if(istype(Item,/obj/item/weapon/storage/belt))
					var/obj/item/weapon/storage/belt/medical/fluff/nashi_belt/I = Item
					if(istype(M.belt,/obj/item/weapon/storage/belt))
						for(var/obj/item/weapon/storage/belt/B in M)
							qdel(B)
							M.belt=null
						ok = M.equip_to_slot_if_possible(I, slot_belt, 0)
						break
					if(istype(M.belt,/obj/item/device/pda))
						for(var/obj/item/device/pda/Pda in M)
							M.belt=null
							M.equip_to_slot_if_possible(Pda, slot_l_store, 0)
						ok = M.equip_to_slot_if_possible(I, slot_belt, 0)
				else if(istype(M.back,/obj/item/weapon/storage) && M.back:contents.len < M.back:storage_slots) // Try to place it in something on the mob's back
					Item.loc = M.back
					ok = 1

				else
					for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
						if (S.contents.len < S.storage_slots)
							Item.loc = S
							ok = 1
							break

				if (ok == 0) // Finally, since everything else failed, place it on the ground
					Item.loc = get_turf(M.loc)
