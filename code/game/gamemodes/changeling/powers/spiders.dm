/obj/effect/proc_holder/changeling/spiders
	name = "Паучье Заражение"
	desc = "Наши железы вырабатывают паучьи личинки, со временем превращающиеся в смертоносных монстров."
	helptext = "Пауки - существа безрассудные, поэтому могут атаковать своих создателей, когда вырастут. Требуется поглотить минимум 4 ДНК."
	chemical_cost = 30
	genomecost = 3
	req_dna = 4

//Makes some spiderlings. Good for setting traps and causing general trouble.
/obj/effect/proc_holder/changeling/spiders/sting_action(mob/user)
	var/turf = get_turf(user)
	for(var/I in 1 to 2)
		var/obj/effect/spider/spiderling/Sp = new(turf)
		Sp.amount_grown = 1

	feedback_add_details("changeling_powers","SI")
	return 1
