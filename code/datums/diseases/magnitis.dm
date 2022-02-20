/datum/disease/magnitis
	name = "Magnitis"
	max_stages = 4
	spread = "Airborne"
	cure = "Iron"
	cure_id = "iron"
	agent = "Fukkos Miracos"
	affected_species = list(HUMAN)
	curable = 0
	permeability_mod = 0.75
	desc = "This disease disrupts the magnetic field of your body, making it act as if a powerful magnet. Injections of iron help stabilize the field."
	severity = "Medium"

/datum/disease/magnitis/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете как слабый ток пробегает по вашему телу.</span>")
			if(prob(2))
				for(var/obj/M in orange(2,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(2,affected_mob))
					if(isAI(S)) continue
					step_towards(S,affected_mob)
						/*
						if(M.x > affected_mob.x)
							M.x--
						else if(M.x < affected_mob.x)
							M.x++
						if(M.y > affected_mob.y)
							M.y--
						else if(M.y < affected_mob.y)
							M.y++
						*/
		if(3)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете как сильный ток ударяет по вашему телу.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Вам кажется,что пришло время подурачиться.</span>")
			if(prob(4))
				for(var/obj/M in orange(4,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						var/i
						var/iter = rand(1,2)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(4,affected_mob))
					if(isAI(S)) continue
					var/i
					var/iter = rand(1,2)
					for(i=0,i<iter,i++)
						step_towards(S,affected_mob)
						/*
						if(M.x > affected_mob.x)
							M.x-=rand(1,min(3,M.x-affected_mob.x))
						else if(M.x < affected_mob.x)
							M.x+=rand(1,min(3,affected_mob.x-M.x))
						if(M.y > affected_mob.y)
							M.y-=rand(1,min(3,M.y-affected_mob.y))
						else if(M.y < affected_mob.y)
							M.y+=rand(1,min(3,affected_mob.y-M.y))
						*/
		if(4)
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Вы чувствуете как сильнейший ток ударяает по вашему телу.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='warning'>Вы возглашаете в природе чудес.</span>")
			if(prob(8))
				for(var/obj/M in orange(6,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						var/i
						var/iter = rand(1,3)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(6,affected_mob))
					if(isAI(S)) continue
					var/i
					var/iter = rand(1,3)
					for(i=0,i<iter,i++)
						step_towards(S,affected_mob)
						/*
						if(M.x > affected_mob.x)
							M.x-=rand(1,min(5,M.x-affected_mob.x))
						else if(M.x < affected_mob.x)
							M.x+=rand(1,min(5,affected_mob.x-M.x))
						if(M.y > affected_mob.y)
							M.y-=rand(1,min(5,M.y-affected_mob.y))
						else if(M.y < affected_mob.y)
							M.y+=rand(1,min(5,affected_mob.y-M.y))
						*/
	return
