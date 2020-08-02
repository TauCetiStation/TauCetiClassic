//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "cyborg analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	throw_speed = 5
	throw_range = 10
	//matter = list("metal" = 200)
	origin_tech = "magnets=1;biotech=1"
	var/mode = TRUE
	var/output_to_chat = TRUE

/obj/item/device/robotanalyzer/verb/toggle_output()
	set name = "Toggle Output"
	set category = "Object"

	output_to_chat = !output_to_chat
	if(output_to_chat)
		to_chat(usr, "The scanner now outputs data to chat.")
	else
		to_chat(usr, "The scanner now outputs data in a seperate window.")

/obj/item/device/robotanalyzer/attack(mob/living/M, mob/living/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span clas='warning'>You don't have the dexterity to do this!</span>")
		return

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.species.flags[IS_SYNTHETIC])
			to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
			return
	else
		if(!istype(M, /mob/living/silicon/robot))
			to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
			return

	add_fingerprint(user)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		user.visible_message("<span class='warning'>[user] has analyzed the floor's vitals!</span>", "<span class='warning'>You try to analyze the floor's vitals!</span>")
		var/message = ""
		if(!output_to_chat)
			message += "<HTML><head><title>floor's scan results</title></head><BODY>"

		message += "<span class='notice'>Analyzing Results for The floor:<br>&emsp; Overall Status: Healthy</span><br>"
		message += "<span class='notice'>&emsp; Damage Specifics: 0-0-0-0</span><br>"
		message += "<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span><br>"
		message += "<span class='notice'>Body Temperature: ???</span><br>"

		if(!output_to_chat)
			message += "</BODY></HTML>"
			user << browse(message, "window=[M.name]_scan_report;size=400x400;can_resize=1")
			onclose(user, "[M.name]_scan_report")
		else
			to_chat(user, message)
		return

	user.visible_message("<span class='notice'> [user] has analyzed [M]'s components.</span>","<span class='notice'> You have analyzed [M]'s components.</span>")

	var/message = ""
	if(!output_to_chat)
		message += "<HTML><head><title>[M.name]'s scan results</title></head><BODY>"

	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()

	message += "<span class='notice'>Analyzing Results for [M]:<br>&emsp; Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.halloss]% functional"]</span><br>"
	message += "&emsp; Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font><br>"
	message += "&emsp; Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font><br>"
	if(M.tod && M.stat == DEAD)
		message += "<span class='notice'>Time of Disable: [M.tod]</span><br>"

	if(istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/H = M
		var/list/damaged = H.get_damaged_components(1,1,1)

		message += "<span class='notice'>Localized Damage:</span><br>"
		if(length(damaged)>0)
			for(var/datum/robot_component/org in damaged)
				message += text("<span class='notice'>&emsp; []: [][] - [] - [] - []</span><br>",	\
				capitalize(org.name),					\
				(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
				(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
				(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
				(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
				(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>")
		else
			message += "<span class='notice'>&emsp; Components are OK.</span><br>"
		if(H.emagged && prob(5))
			message += "<span class='warning'>&emsp; ERROR: INTERNAL SYSTEMS COMPROMISED</span><br>"

	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1, 1)
		message += "<span class='notice'>Localized Damage, Brute/Electronics:</span><br>"
		if(length(damaged) > 0)
			for(var/obj/item/organ/external/BP in damaged)
				message += text("<span class='notice'>&emsp; []: [] - []</span><br>",	\
				capitalize(BP.name),					\
				(BP.brute_dam > 0)	?	"<span class='warning'>[BP.brute_dam]</span>"	:0,		\
				(BP.burn_dam > 0)	?	"<font color='#FFA500'>[BP.burn_dam]</font>"	:0)
		else
			message += "<span class='notice'>&emsp; Components are OK.</span><br>"

	message += "<span class='notice'>Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)</span><br>"

	if(!output_to_chat)
		user << browse(message, "window=[M.name]_scan_report;size=400x400;can_resize=1")
		onclose(user, "[M.name]_scan_report")
	else
		to_chat(user, message)
