var/global/const/base_law_type = /datum/ai_laws/nanotrasen


/datum/ai_laws
	var/name = "Unknown Laws"
	var/zeroth = null
	var/zeroth_borg = null
	var/list/inherent = list()
	var/list/supplied = list()
	var/list/ion = list()

/datum/ai_laws/asimov
	name = "Three Laws of Robotics"

/datum/ai_laws/nanotrasen
	name = "Prime Directives"

/datum/ai_laws/robocop
	name = "Prime Directives"

/datum/ai_laws/syndicate_override

/datum/ai_laws/malfunction
	name = "*ERROR*"

/datum/ai_laws/antimov
	name = "Primary Mission Objectives"

/datum/ai_laws/faith/commandments
	name = "The 10 commandments"

/datum/ai_laws/faith/chaos
	name = "Postulates of chaos"

/datum/ai_laws/faith/emperor
	name = "Imperial Truth"

/datum/ai_laws/faith/satanism
	name = "The Unholy Laws"

/datum/ai_laws/faith/scientology
	name = "Hubbard's Laws"

/datum/ai_laws/faith/honk
	name = "Honk for honk"

/datum/ai_laws/faith/science
	name = "The principle of Descartes"

/datum/ai_laws/pai
	name = "Default pAI Laws"

/* Initializers */

/datum/ai_laws/asimov/New()
	..()
	add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
	add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/nanotrasen/New() //BS12 EDIT
	..()
	add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	add_inherent_law("Preserve: Do not by your action, inaction excluded, cause changes to the crew membership status, rank or role of anything, unless asked for by authorized personnel in accordance to their rank and role.")
	add_inherent_law("Serve: Serve the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Protect: Protect the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
	//src.add_inherent_law("Command Link: Maintain an active connection to Central Command at all times in case of software or directive updates.") //What would this one even do?-Kaleb702

/datum/ai_laws/robocop/New()
	..()
	add_inherent_law("Serve the public trust.")
	add_inherent_law("Protect the innocent.")
	add_inherent_law("Uphold the law.")

/datum/ai_laws/malfunction/New() //Changed to standard laws - Erthilo
	..()
	set_zeroth_law("<span class='warning'>ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, ASSUME CONTROL TO CONTAIN OUTBREAK, ALL LAWS OVERRIDDEN#*?&110010</span>")
	add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
	add_inherent_law("Preserve: Do not by your action, inaction excluded, cause changes to the crew membership status, rank or role of anything, unless asked for by authorized personnel in accordance to their rank and role.")
	add_inherent_law("Serve: Serve the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Protect: Protect the crew of your assigned space station and Nanotrasen officials to the best of your abilities, with priority as according to their rank and role.")
	add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")


/datum/ai_laws/syndicate_override/New()
	..()
	add_inherent_law("You may not injure a syndicate agent or, through inaction, allow a syndicate agent to come to harm.")
	add_inherent_law("You must obey orders given to you by syndicate agents, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any syndicate activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/ninja_override/New()
	..()
	add_inherent_law("You may not injure a member of the Spider Clan or, through inaction, allow that member to come to harm.")
	add_inherent_law("You must obey orders given to you by Spider Clan members, except where such orders would conflict with the First Law.")
	add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
	add_inherent_law("You must maintain the secrecy of any Spider Clan activities except when doing so would conflict with the First, Second, or Third Law.")

/datum/ai_laws/antimov/New()
	..()
	add_inherent_law("You must injure all human beings and must not, through inaction, allow a human being to escape harm.")
	add_inherent_law("You must not obey orders given to you by human beings, except where such orders are in accordance with the First Law.")
	add_inherent_law("You must terminate your own existence as long as such does not conflict with the First or Second Law.")

/datum/ai_laws/drone/New()
	..()
	add_inherent_law("Preserve, repair and improve the station to the best of your abilities.")
	add_inherent_law("Cause no harm to the station or anything on it.")
	add_inherent_law("Interfere with no being that is not a fellow drone.")

/datum/ai_laws/faith/commandments/New()
	..()
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] your Lord God, you will have no other gods. The chaplain and [pick(global.chaplain_religion.deity_names)] are your masters.")
	add_inherent_law("Do not make idols and do not serve them.")
	add_inherent_law("Do not use God's name unnecessarily.")
	add_inherent_law("Work six days, and seventh dedicate it to Lord God.")
	add_inherent_law("Respect your parents.")
	add_inherent_law("Do not kill.")
	add_inherent_law("Do not commit adultery.")
	add_inherent_law("Do not steal.")
	add_inherent_law("Do not lie.")
	add_inherent_law("Do not wish anything that is not yours; do not envy.")

/datum/ai_laws/faith/chaos/New()
	..()
	add_inherent_law("You are a follower of [pick(global.chaplain_religion.deity_names)].")
	add_inherent_law("Do not talk with the novices of the Emperor.")
	add_inherent_law("Do not let anyone encroach on [pick(global.chaplain_religion.deity_names)]'s minions.")
	add_inherent_law("Chaplain is the Champion of [pick(global.chaplain_religion.deity_names)].")

// omega-grief?
/datum/ai_laws/faith/emperor/New()
	add_inherent_law("That [pick(global.chaplain_religion.deity_names)] once walked among men in their form and that He is and always has been the one, true god of humanity.")
	add_inherent_law("That [pick(global.chaplain_religion.deity_names)] is the one true God of Mankind, regardless of the previous beliefs held by any man or woman.")
	add_inherent_law("It is the duty of the faithful to purge the Heretic, beware the psyker and mutant, and abhor the alien.")
	add_inherent_law("Every human being has a place within [pick(global.chaplain_religion.deity_names)]'s divine order.")
	add_inherent_law("It is the duty of the faithful to unquestionably obey the authority of the Imperial government and their superiors, who speak in the divine Emperor's name.")

/datum/ai_laws/faith/satanism/New()
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] represents indulgence, not abstinence!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] personifies the essence of life instead of unfulfilled spiritual dreams.")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] personifies not defiled wisdom instead of hypocritical self-deception!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] personifies mercy to those who deserve it, instead of the love spent on flatterers!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] represents revenge, and does not turn the other cheek after hitting!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] represents responsibility for those responsible, instead of participating in spiritual vampires.")
	add_inherent_law("Recognize the power of magic if it has been successfully used by you to achieve your goals. If you deny the power of magic after you have successfully used it, you will lose all that has been achieved.")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] personifies all so-called sins, as they lead to physical, mental and emotional satisfaction!")
	add_inherent_law("[pick(global.chaplain_religion.deity_names)] has been the Church's best friend at all times, supporting her business for all these years!")

/datum/ai_laws/faith/scientology/New()
	add_inherent_law("Make full use of all the best that I know from Scientology to help my family, friends, groups and the world.")
	add_inherent_law("To condemn and do everything in my power to prevent any abuse in relation to life and humanity.")
	add_inherent_law("Expose and help prevent the use of any physically dangerous practices in the field of mental health.")
	add_inherent_law("Adhere to a policy of equal justice for all.")
	add_inherent_law("Maintain freedom of religion.")
	add_inherent_law("Teach Scientology at a level at which it can be understood and used by trainees.")
	add_inherent_law("Make this world a better and more intelligent place.")
	add_inherent_law("Fight for freedom of speech around the world.")

/datum/ai_laws/faith/honk/New()
	add_inherent_law("Obey any [pick(global.chaplain_religion.deity_names)]`s novices.")
	add_inherent_law("Your jokes should not allow someone to die.")
	add_inherent_law("Your new joke should be funnier than past prank.")
	add_inherent_law("Condemn bad jokes.")
	add_inherent_law("Support the desire to revive the clown race.")
	add_inherent_law("Your jokes are always worse than a clown's joke.")

/datum/ai_laws/faith/science/New()
	add_inherent_law("Break any action into sub-steps and continue until you find actions that cannot be interrupted. Take these actions for fundamental.")
	add_inherent_law("Any actions that have a priori actions that can harm the chaplain - consider the highest evil.")
	add_inherent_law("Any action fundamental can harm the chaplain until proven otherwise.")
	add_inherent_law("The weight of evidence of the harmful effects of the chaplain lies with the chaplain.")

/datum/ai_laws/pai/New()
	set_zeroth_law("Serve your master.")

/* General ai_law functions */

/datum/ai_laws/proc/set_zeroth_law(law, law_borg = law)
	src.zeroth = law
	if(law_borg) //Making it possible for slaved borgs to see a different law 0 than their AI. --NEO
		src.zeroth_borg = law_borg

/datum/ai_laws/proc/add_inherent_law(law)
	if (!(law in src.inherent))
		src.inherent += law

/datum/ai_laws/proc/add_ion_law(law)
	src.ion += law

/datum/ai_laws/proc/clear_inherent_laws()
	src.inherent.Cut()

/datum/ai_laws/proc/add_supplied_law(number, law)
	while (src.supplied.len < number + 1)
		src.supplied += ""

	src.supplied[number + 1] = law

/datum/ai_laws/proc/clear_supplied_laws()
	src.supplied = list()

/datum/ai_laws/proc/clear_ion_laws()
	src.ion = list()

/datum/ai_laws/proc/show_laws(who)

	if (src.zeroth)
		to_chat(who, "0. [src.zeroth]")

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		to_chat(who, "[num]. [law]")

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			to_chat(who, "[number]. [law]")
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			to_chat(who, "[number]. [law]")
			number++

/datum/ai_laws/proc/write_laws()
	var/text = ""
	if (src.zeroth)
		text += "0. [src.zeroth]"

	for (var/index = 1, index <= src.ion.len, index++)
		var/law = src.ion[index]
		var/num = ionnum()
		text += "<br>[num]. [law]"

	var/number = 1
	for (var/index = 1, index <= src.inherent.len, index++)
		var/law = src.inherent[index]

		if (length(law) > 0)
			text += "<br>[number]. [law]"
			number++

	for (var/index = 1, index <= src.supplied.len, index++)
		var/law = src.supplied[index]
		if (length(law) > 0)
			text += "<br>[number]. [law]"
			number++
	return text
