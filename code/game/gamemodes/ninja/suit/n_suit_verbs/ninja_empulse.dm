/** 
  * EM PULSE
  *  Disables nearby tech equipment.
  */
/obj/item/clothing/suit/space/space_ninja/proc/ninjapulse()
	set name = "EM Burst (2,000E)"
	set desc = "Disable any nearby technology with a electro-magnetic pulse."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/C = 200
	if(!ninjacost(C,0)) // EMP's now cost 1,000Energy about 30%
		var/mob/living/carbon/human/U = affecting
		playsound(U, 'sound/effects/EMPulse.ogg', VOL_EFFECTS_MASTER)
		empulse(U, 2, 3) //Procs sure are nice. Slightly weaker than wizard's disable tch.
		s_coold = 2
		cell.use(C*10)
	return
