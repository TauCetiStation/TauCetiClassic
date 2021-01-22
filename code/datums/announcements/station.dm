/* STATION */
/datum/announcement/station
	title = "Priority Announcement"
	sound = "announce"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND
/datum/announcement/station/play()
	..()
	add_communication_log(type = "station", title = title ? title : subtitle, author = announcer, content = message)

/datum/announcement/station/command/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/station/code
	title = null


/* Command */
/datum/announcement/station/command/department
	name = "Heads: Department"
/datum/announcement/station/command/department/play(department, message)
	if(department && message)
		title = "[department] Announcement"
	..(message)

/datum/announcement/station/command/ai
	name = "Heads: AI"
	title = "A.I. Announcement"
	sound = "aiannounce"
/datum/announcement/station/command/ai/play(mob/user, message)
	if(user && message)
		announcer = user.name
	..(message)

/* Alerts */
/datum/announcement/station/nuke
	name = "Alert: Nuke Activation"
	message = "Detected activation of a nuclear warhead somewhere on the station. Someone trying to blow up the station!"
	sound = "nuke"
/datum/announcement/station/nuke/play(area/A)
	if(A)
		message = "Detected activation of a nuclear warhead in [initial(A.name)]. Someone trying to blow up the station!"
	..()

/datum/announcement/station/maint_revoke
	name = "Alert: Maintenance Access Revoked"
	message = "The maintenance access requirement has been revoked on all airlocks."

/datum/announcement/station/maint_readd
	name = "Alert: Maintenance Access Readded"
	message = "The maintenance access requirement has been readded on all airlocks."

/datum/announcement/station/gravity_on
	name = "Secret: Gravity On"
	subtitle = "Station Fail-Safe System"
	message = "Gravity generators are again functioning within normal parameters. Sorry for any inconvenience."
	sound = "gravon"
/datum/announcement/station/gravity_on/play()
	subtitle = "[station_name()] Fail-Safe System"
	..()

/datum/announcement/station/gravity_off
	name = "Secret: Gravity Off"
	subtitle = "Station Fail-Safe System"
	message = "Feedback surge detected in mass-distributions systems. Artifical gravity has been disabled whilst the system reinitializes. " + \
			"Further failures may result in a gravitational collapse and formation of blackholes. Have a nice day."
	sound = "gravoff"
/datum/announcement/station/gravity_off/play()
	subtitle = "[station_name()] Fail-Safe System"
	..()

/* Shuttles */
/datum/announcement/station/shuttle/crew_called
	name = "Shuttle: Crew Called"
	message = "A crew transfer has been initiated. The shuttle has been called. It will arrive in a few minutes."
	sound = "crew_shut_called"
/datum/announcement/station/shuttle/crew_called/play()
	message = "A crew transfer has been initiated. The shuttle has been called. It will arrive in [shuttleminutes2text()] minutes."
	..()

/datum/announcement/station/shuttle/crew_recalled
	name = "Shuttle: Crew Recalled"
	message = "The shuttle has been recalled."
	sound = "crew_shut_recalled"

/datum/announcement/station/shuttle/crew_docked
	name = "Shuttle: Crew Docked"
	message = "The scheduled Crew Transfer Shuttle has docked with the station. It will depart in a few minutes."
	sound = "crew_shut_docked"
/datum/announcement/station/shuttle/crew_docked/play()
	message = "The scheduled Crew Transfer Shuttle has docked with the station. It will depart in approximately [shuttleminutes2text()] minutes."
	..()

/datum/announcement/station/shuttle/crew_left
	name = "Shuttle: Crew Left"
	message = "The Crew Transfer Shuttle has left the station. It will dock at Central Command in a few minutes."
	sound = "crew_shut_left"
/datum/announcement/station/shuttle/crew_left/play()
	message = "The Crew Transfer Shuttle has left the station. Estimate [shuttleminutes2text()] minutes until the shuttle docks at Central Command."
	..()


/datum/announcement/station/shuttle/emer_called
	name = "Shuttle: Emergency Called"
	message = "The emergency shuttle has been called. It will arrive as soon as possible."
	sound = "emer_shut_called"
/datum/announcement/station/shuttle/emer_called/play()
	message = "The emergency shuttle has been called. It will arrive in [shuttleminutes2text()] minutes."
	..()

/datum/announcement/station/shuttle/emer_recalled
	name = "Shuttle: Emergency Recalled"
	message = "The emergency shuttle has been recalled."
	sound = "emer_shut_recalled"

/datum/announcement/station/shuttle/emer_docked
	name = "Shuttle: Emergency Docked"
	message = "The Emergency Shuttle has docked with the station. You have a few minutes to board the Emergency Shuttle."
	sound = "emer_shut_docked"
/datum/announcement/station/shuttle/emer_docked/play()
	message = "The Emergency Shuttle has docked with the station. You have [shuttleminutes2text()] minutes to board the Emergency Shuttle."
	..()

/datum/announcement/station/shuttle/emer_left
	name = "Shuttle: Emergency Left"
	message = "The Emergency Shuttle has left the station. It will dock at Central Command in a few minutes."
	sound = "emer_shut_left"
/datum/announcement/station/shuttle/emer_left/play()
	message = "The Emergency Shuttle has left the station. Estimate [shuttleminutes2text()] minutes until the shuttle docks at Central Command."
	..()

/* Security codes */
/datum/announcement/station/code/downtogreen
	name = "Code: Down to Green"
	subtitle = "Attention! Security level lowered to green."
	message = "Непосредственные или явные угрозы для станции отсутствуют. " + \
			"Служба безопасности обязана спрятать оружие, а также уважать личное право и пространство персонала, несанкционированные обыски запрещены."
	sound = "downtogreen"

/datum/announcement/station/code/uptoblue
	name = "Code: Up to Blue"
	subtitle = "Attention! Security level elevated to blue."
	message = "Командование получило надежную информацию о возможной враждебной активности на борту станции. " + \
			"Служба безопасности может носить оружие на виду, однако, не следует вынимать его без необходимости. " + \
			"Разрешается личный обыск персонала и отсеков станции без предварительных санкций."
	sound = "blue"

/datum/announcement/station/code/downtoblue
	name = "Code: Down to Blue"
	subtitle = "Attention! Security level lowered to blue."
	message = "Непосредственная угроза станции отсутсвует. " + \
			"Служба безопасности не имеет права вынимать оружие, однако может носить его на виду. " + \
			"Спонтанные обыски всё еще разрешены."
	sound = "downtoblue"

/datum/announcement/station/code/uptored
	name = "Code: Up to Red"
	subtitle = "Attention! Code red!"
	message = "Существует прямая угроза станции или возможно причинение значительного ущерба. " + \
			"Боевое положение! Служба безопасности имеет право носить оружие на готове по собственному усмотрению. " + \
			"Рекомендуются спонтанные обыски персонала и отсеков. Весь персонал станции обязан оставаться в своих отделах. " + \
			"Весь персонал станции обязан повиноваться требованиям СБ и выше стоящих офицеров."
	sound = "red"

/datum/announcement/station/code/downtored
	name = "Code: Down to Red"
	subtitle = "Attention! Code red!"
	message = "Механизм самоунитожения деактивирован и над ситуацией был вернут частичный контроль. " + \
			"Тем не менее существует прямая угроза станции. Служба безопасности имеет право носить оружие наготове по собственному усмотрению. " + \
			"Рекомендуются спонтанные обыски персонала и отсеков."
	sound = "downtored"

/datum/announcement/station/code/delta
	name = "Code: Up to Delta"
	subtitle = "Attention! Delta security level reached!"
	message = "Внимание, активирован механизм самоуничтожения или ситуация вышла полностью из под контроля! " + \
			"Все приказы глав станции должны выполняться беспрекословно, любое неповиновение карается смертью! " + \
			"Всему персоналу перевести датчики костюмов в третий режим! Это не учебная тревога!"
	sound = "delta"
