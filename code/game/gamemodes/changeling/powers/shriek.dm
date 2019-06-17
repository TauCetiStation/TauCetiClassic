/obj/effect/proc_holder/changeling/resonant_shriek
	name = "Resonant Shriek"
	desc = "Our lungs and vocal chords shift, allowing us to briefly emit a noise that deafens and confuses the weak-minded."
	helptext = "Emits a high-frequency sound that confuses and deafens humans, blows out nearby lights and overloads cyborg sensors."
	chemical_cost = 25
	genomecost = 3
	req_human = 1

//A flashy ability, good for crowd control and sewing chaos.
/obj/effect/proc_holder/changeling/resonant_shriek/sting_action(mob/user)
	for(var/mob/living/M in hearers(4, user))
		if(iscarbon(M))
			if(!M.mind || !M.mind.changeling)
				M.ear_deaf += 30
				M.confused += 20
				M.make_jittery(500)
			else
				M.playsound_local(null, 'sound/effects/screech.ogg', VOL_EFFECTS_MASTER, null, FALSE)

		if(issilicon(M))
			M.playsound_local(null, 'sound/weapons/flash.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			M.Weaken(rand(5,10))

	for(var/obj/machinery/light/L in range(4, user))
		L.on = 1
		L.broken()

	feedback_add_details("changeling_powers","RES")
	return 1
