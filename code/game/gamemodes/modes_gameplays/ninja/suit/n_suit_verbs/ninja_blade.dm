// ENERGY BLADE
//Summons a blade of energy in active hand.
/obj/item/clothing/suit/space/space_ninja/proc/ninjablade()
	set name = "Energy Blade (500E)"
	set desc = "Create a focused beam of energy in your active hand."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/C = 50
	if(!ninjacost(C,0)) //Same spawn cost but higher upkeep cost
		var/mob/living/carbon/human/U = affecting
		if(!kamikaze)
			cancel_stealth()
			if(!U.get_active_hand()&&!istype(U.get_inactive_hand(), /obj/item/weapon/melee/energy/blade))
				var/obj/item/weapon/melee/energy/blade/W = new()
				spark_system.start()
				playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
				U.put_in_hands(W)
				cell.use(C*10)
			else
				to_chat(U, "<span class='warning'>You can only summon one blade. Try dropping an item first.</span>")
		else//Else you can run around with TWO energy blades. I don't know why you'd want to but cool factor remains.
			if(!U.get_active_hand())
				var/obj/item/weapon/melee/energy/blade/W = new()
				U.put_in_hands(W)
			if(!U.get_inactive_hand())
				var/obj/item/weapon/melee/energy/blade/W = new()
				U.put_in_inactive_hand(W)
			spark_system.start()
			playsound(U, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			s_coold = 1
	return
