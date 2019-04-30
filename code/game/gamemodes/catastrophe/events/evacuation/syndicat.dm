/datum/catastrophe_event/syndicat_evacuation
	name = "Syndicat evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

	manual_stop = TRUE

/datum/catastrophe_event/syndicat_evacuation/on_step()
	switch(step)
		if(1)
			announce("Èñõîä, ìû íè÷¸ì íå ìîæåì âàì ïîìî÷ü, ñòàíöè[JA_PLACEHOLDER] ÖÊ ïðàêòè÷åñêè ïîëíîñòüþ óíè÷òîæåíà, ñâ[JA_PLACEHOLDER]çü ñ Èêàðîì ïîòåð[JA_PLACEHOLDER]íà, òðàíçèòíà[JA_PLACEHOLDER] ñòàíöè[JA_PLACEHOLDER] Âåëîñèòè ïîòåð[JA_PLACEHOLDER]íà, êîíòðîëü íàä âñåé ñèñòåìîé óòåð[JA_PLACEHOLDER]í, ó íàñ íåò ñâîáîäíûõ øàòëîâ ýâàêóàöèè äë[JA_PLACEHOLDER] âàñ, ïðîñòèòå. Ïîïûòàéòåñü ÷òî-íèáóäü ïðèäóìàòü. È äà õðàíèò âàñ áîã, êîíåö ñâ[JA_PLACEHOLDER]çè")

			addtimer(CALLBACK(src, .proc/syndicat_evacuation_real), 5 MINUTES)

/datum/catastrophe_event/syndicat_evacuation/proc/syndicat_evacuation_real()
	announce("Õà-à-à, êòî ýòî ó ìåí[JA_PLACEHOLDER] òóò íà ðàäàðå. Íåóæåëè ýòî ïîëóðàçðóøåííûé Èñõîä? Íåóæåëè âàøå õâàëåííîå Íàíîòðåéçåí ðåøèëà çàáèòü íà âàñ? Êàê æå ìíå âàñ æàëü, ÷åðò ïîáåðè, õà. À òåïåðü ñåðü¸çíî. ß äàþ âàì âñåãî ëèøü îäèí âàðèàíò ñïàñòè âàøè æàëêèå çàäíèöû, âû îòäà¸òå ìíå âñ¸ öåííîå, ÷òî èìååò âàøà ñòàíöè[JA_PLACEHOLDER], âêëþ÷à[JA_PLACEHOLDER] òåõíîëîãèè è êîðïîðàòèâíûå ñåêðåòèêè, à [JA_PLACEHOLDER] îáåùàþ ÷òî, ìîæåò áûòü, íå äàì âàøèì äóøàì áåññëåäíî ïðîïàñòü â áåçäíå, èä¸ò? Êîíå÷íî èä¸ò, ó âàñ òóïî íåò äðóãîãî âûáîðà, õà. È íå îáðàùàéòå âíèìàíè[JA_PLACEHOLDER] íà êðàñíûé öâåò øàòëà è îãðîìíûå áóêâû “Ñèíäèêàò” íà îáøèâêå, [JA_PLACEHOLDER] òåïåðü âàø åäèíñòâåííûé äðóã")

	var/list/shuttle_turfs = get_area_turfs(locate(/area/shuttle/escape/centcom))
	for(var/turf/simulated/shuttle/wall/W in shuttle_turfs)
		W.color = "#aa0000"
	for(var/turf/simulated/shuttle/floor/F in shuttle_turfs)
		F.color = "#550000"

	var/list/shuttle_atoms = get_area_all_atoms(locate(/area/shuttle/escape/centcom))
	for(var/obj/structure/window/reinforced/shuttle/default/W in shuttle_atoms)
		W.color = "#222222"
	for(var/obj/machinery/door/unpowered/shuttle/D in shuttle_atoms)
		D.color = "#333333"

	if(SSshuttle)
		SSshuttle.always_fake_recall = FALSE
		SSshuttle.fake_recall = 0

		SSshuttle.incall()
	stop()
