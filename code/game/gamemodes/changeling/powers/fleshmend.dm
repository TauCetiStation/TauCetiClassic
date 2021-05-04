/obj/effect/proc_holder/changeling/fleshmend
	name = "Заживление Плоти"
	desc = "Наша плоть быстро восстанавливается, залечивая раны."
	helptext = "Позволяет быстро залечить некритические раны. Можно использовать в бессознательном состоянии."
	chemical_cost = 25
	genomecost = 4
	req_stat = UNCONSCIOUS

//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/obj/effect/proc_holder/changeling/fleshmend/sting_action(mob/living/user)
	to_chat(user, "<span class='notice'>We begin to heal rapidly.</span>")
	spawn(0)
		for(var/i = 0, i<10,i++)
			user.adjustBruteLoss(-10)
			user.adjustOxyLoss(-10)
			user.adjustFireLoss(-10)
			sleep(10)

	feedback_add_details("changeling_powers","RR")
	return 1
