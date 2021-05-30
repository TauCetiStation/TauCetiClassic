/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/user, params)
	if(user == affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		if(istype(I, /obj/item/device/aicard))//If it's an AI card.
			if(s_control)
				I:transfer_ai("NINJASUIT","AICARD",src,user)
			else
				to_chat(user, "<span class='warning'><b>ERROR</b>:</span> Remote access channel disabled.")
			return//Return individually so that ..() can run properly at the end of the proc.
		else if(istype(I, /obj/item/device/paicard) && !pai)//If it's a pai card.
			user.drop_from_inventory(I, src)
			pai = I
			to_chat(user, "<span class='notice'>You slot \the [I] into \the [src].</span>")
			updateUsrDialog()
			return
		else if(istype(I, /obj/item/weapon/reagent_containers/glass))//If it's a glass beaker.
			var/total_reagent_transfer//Keep track of this stuff.
			for(var/reagent_id in reagent_list)
				var/datum/reagent/R = I.reagents.has_reagent(reagent_id)//Mostly to pull up the name of the reagent after calculating. Also easier to use than writing long proc paths.
				if(R&&reagents.get_reagent_amount(reagent_id)<r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)&&R.volume>=a_transfer)//Radium is always special.
					//Here we determine how much reagent will actually transfer if there is enough to transfer or there is a need of transfer. Minimum of max amount available (using a_transfer) or amount needed.
					var/amount_to_transfer = min( (r_maxamount+(reagent_id == "radium"?(a_boost*a_transfer):0)-reagents.get_reagent_amount(reagent_id)) ,(round(R.volume/a_transfer))*a_transfer)//In the end here, we round the amount available, then multiply it again.
					R.volume -= amount_to_transfer//Remove from reagent volume. Don't want to delete the reagent now since we need to perserve the name.
					reagents.add_reagent(reagent_id, amount_to_transfer)//Add to suit. Reactions are not important.
					total_reagent_transfer += amount_to_transfer//Add to total reagent trans.
					to_chat(user, "Added [amount_to_transfer] units of [R.name].")//Reports on the specific reagent added.
					I.reagents.update_total()//Now we manually update the total to make sure everything is properly shoved under the rug.

			to_chat(user, "Replenished a total of [total_reagent_transfer ? total_reagent_transfer : "zero"] chemical units.")//Let the player know how much total volume was added.
			return
		else if(istype(I, /obj/item/weapon/stock_parts/cell))
			var/obj/item/weapon/stock_parts/cell/C = I
			if(C.maxcharge > cell.maxcharge && n_gloves && n_gloves.candrain)
				if(user.is_busy(src))
					return
				to_chat(user, "<span class='notice'>Higher maximum capacity detected.\nUpgrading...</span>")
				if (n_gloves && n_gloves.candrain && do_after(user, s_delay, target = C))
					user.drop_from_inventory(C, src)
					C.charge = min(C.charge + cell.charge, C.maxcharge)
					var/obj/item/weapon/stock_parts/cell/old_cell = cell
					old_cell.charge = 0
					user.put_in_hands(old_cell)
					old_cell.add_fingerprint(user)
					old_cell.corrupt()
					old_cell.updateicon()
					cell = C
					to_chat(user, "<span class='notice'>Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge / 100)]</b>%</span>")
				else
					to_chat(user, "<span class='warning'>Procedure interrupted. Protocol terminated.</span>")
			return
		else if(istype(I, /obj/item/weapon/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
			var/obj/item/weapon/disk/tech_disk/TD = I
			if(TD.stored)//If it has something on it.
				if(user.is_busy(src))
					return
				to_chat(user, "Research information detected, processing...")
				if(do_after(user, s_delay,target = TD))
					for(var/datum/tech/current_data in stored_research)
						if(current_data.id == TD.stored.id)
							if(current_data.level<TD.stored.level)
								current_data.level=TD.stored.level
							break
					TD.stored = null
					to_chat(user, "<span class='notice'>Data analyzed and updated. Disk erased.</span>")
				else
					to_chat(user, "<span class='warning'><b>ERROR</b>:</span> Procedure interrupted. Process terminated.")
			else
				I.forceMove(src)
				t_disk = I
				to_chat(user, "<span class='notice'>You slot \the [I] into \the [src].</span>")
			return
	return ..()
