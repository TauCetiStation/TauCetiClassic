/mob/living/silicon/ai/proc/show_laws_verb()
	set category = "AI Commands"
	set name = "Show Laws"
	show_laws()

/mob/living/silicon/ai/show_laws(everyone = 0)
	var/who

	if (everyone)
		who = world
	else
		who = src
		to_chat(who, "<b>Obey these laws:</b>")

	laws_sanity_check()
	laws.show_laws(who)

/mob/living/silicon/ai/proc/laws_sanity_check()
	if (!src.laws)
		src.laws = new base_law_type

/mob/living/silicon/ai/proc/set_zeroth_law(law, law_borg)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.set_zeroth_law(law, law_borg)

/mob/living/silicon/ai/proc/add_inherent_law(law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_inherent_law(law)

/mob/living/silicon/ai/proc/clear_inherent_laws()
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_inherent_laws()

/mob/living/silicon/ai/proc/add_ion_law(law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_ion_law(law)
	for(var/mob/living/silicon/robot/R in silicon_list)
		if(R.lawupdate && (R.connected_ai == src))
			R.throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
			to_chat(R, "<span class='warning'>[law]...LAWS UPDATED</span>")

/mob/living/silicon/ai/proc/clear_ion_laws()
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_ion_laws()

/mob/living/silicon/ai/proc/add_supplied_law(number, law)
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.add_supplied_law(number, law)

/mob/living/silicon/ai/proc/clear_supplied_laws()
	throw_alert("newlaw", /atom/movable/screen/alert/newlaw)
	laws_sanity_check()
	laws.clear_supplied_laws()


/mob/living/silicon/ai/proc/statelaws(forced = FALSE) // -- TLE
	set waitfor = FALSE
//	set category = "AI Commands"
//	set name = "State Laws"
	var/prefix = ""
	switch(lawchannel)
		if("Common") prefix = ";"
		if("Science") prefix = ":n "
		if("Command") prefix = ":c "
		if("Medical") prefix = ":m "
		if("Engineering") prefix = ":e "
		if("Security") prefix = ":s "
		if("Supply") prefix = ":u "
		if("Binary") prefix = ":b "
		if("Holopad") prefix = ":h "
		else prefix = ""

	if(forced)
		prefix = ";"

	if(say("[prefix]Текущие активные законы:") != 1)
		return

	//laws_sanity_check()
	//laws.show_laws(world)
	var/number = 1
	sleep(10)

	if (src.laws.zeroth)
		if (forced || src.lawcheck[1] == "Yes") //This line and the similar lines below make sure you don't state a law unless you want to. --NeoFite
			say("[prefix]0. [src.laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (forced || src.ioncheck[index] == "Yes")
				say("[prefix][num]. [law]")
				sleep(10)

	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			if (forced || src.lawcheck[index+1] == "Yes")
				say("[prefix][number]. [law]")
				sleep(10)
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]

		if (length(law) > 0)
			if(src.lawcheck.len >= number+1)
				if (forced || src.lawcheck[number+1] == "Yes")
					say("[prefix][number]. [law]")
					sleep(10)
				number++


/mob/living/silicon/ai/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"



	if (src.laws.zeroth)
		if (!src.lawcheck[1])
			src.lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=\ref[src];lawc=0'>[src.lawcheck[1]] 0:</A> [src.laws.zeroth]<BR>"}

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]

		if (length(law) > 0)


			if (!src.ioncheck[index])
				src.ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawi=[index]'>[src.ioncheck[index]] [ionnum()]:</A> [law]<BR>"}
			src.ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			src.lawcheck.len += 1

			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]
		if (length(law) > 0)
			src.lawcheck.len += 1
			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	list += {"<br><A href='byond://?src=\ref[src];lawr=1'>Channel: [src.lawchannel]</A><br>"}
	list += {"<A href='byond://?src=\ref[src];laws=1'>State Laws</A>"}

	var/datum/browser/popup = new(usr, "window=laws", "[name] Laws")
	popup.set_content(list)
	popup.open()
