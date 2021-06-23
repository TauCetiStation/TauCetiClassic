/**
  * NINJA STARS
  *  Shoots ninja stars at random people.
  *  This could be a lot better but I'm too tired atm.
  */
/obj/item/clothing/suit/space/space_ninja/proc/ninjastar()
	set name = "Energy Star (800E)"
	set desc = "Launches an energy star at a random living target."
	set category = "Ninja Ability"
	set popup_menu = 0

	var/C = 80
	if(!ninjacost(C,1))
		var/mob/living/carbon/human/U = affecting
		var/targets[] = list()//So yo can shoot while yo throw dawg
		for(var/mob/living/M in oview(loc))
			if(M.incapacitated())
				continue
			targets.Add(M)
		if(targets.len)
			var/mob/living/target=pick(targets)//The point here is to pick a random, living mob in oview to shoot stuff at.

			var/turf/curloc = U.loc
			var/atom/targloc = get_turf(target)
			if (!targloc || !istype(targloc, /turf) || !curloc)
				return
			if (targloc == curloc)
				return
			var/obj/item/projectile/energy/dart/A = new(curloc)
			A.starting = get_turf(affecting)
			A.current = curloc
			A.original = targloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			cell.use(C*10)
			A.process()
		else
			to_chat(U, "<span class='warning'>There are no targets in view.</span>")
	return
