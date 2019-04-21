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
	var/mode = 1;

/obj/item/device/robotanalyzer/attack(mob/living/M, mob/living/user)
	if(( (CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		to_chat(user, text("\red You try to analyze the floor's vitals!"))
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red [user] has analyzed the floor's vitals!"), 1)
		user.show_message(text("\blue Analyzing Results for The floor:\n&emsp; Overall Status: Healthy"), 1)
		user.show_message(text("\blue &emsp; Damage Specifics: [0]-[0]-[0]-[0]"), 1)
		user.show_message("\blue Key: Suffocation/Toxin/Burns/Brute", 1)
		user.show_message("\blue Body Temperature: ???", 1)
		return
	if(!(istype(user, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		to_chat(user, "\red You don't have the dexterity to do this!")
		return
	if(!istype(M, /mob/living/silicon/robot) && !(ishuman(M) && M:species.flags[IS_SYNTHETIC]))
		to_chat(user, "\red You can't analyze non-robotic things!")
		return

	user.visible_message("<span class='notice'> [user] has analyzed [M]'s components.</span>","<span class='notice'> You have analyzed [M]'s components.</span>")
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	user.show_message("\blue Analyzing Results for [M]:\n&emsp; Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.halloss]% functional"]")
	user.show_message("&emsp; Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>", 1)
	user.show_message("&emsp; Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	if(M.tod && M.stat == DEAD)
		user.show_message("\blue Time of Disable: [M.tod]")

	if (istype(M, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/H = M
		var/list/damaged = H.get_damaged_components(1,1,1)
		user.show_message("\blue Localized Damage:",1)
		if(length(damaged)>0)
			for(var/datum/robot_component/org in damaged)
				user.show_message(text("\blue &emsp; []: [][] - [] - [] - []",	\
				capitalize(org.name),					\
				(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
				(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
				(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
				(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
				(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
		else
			user.show_message("\blue &emsp; Components are OK.",1)
		if(H.emagged && prob(5))
			user.show_message("\red &emsp; ERROR: INTERNAL SYSTEMS COMPROMISED",1)

	if (ishuman(M) && M:species.flags[IS_SYNTHETIC])
		var/mob/living/carbon/human/H = M
		var/list/damaged = H.get_damaged_bodyparts(1, 1)
		user.show_message("\blue Localized Damage, Brute/Electronics:",1)
		if(length(damaged)>0)
			for(var/obj/item/organ/external/BP in damaged)
				user.show_message(text("\blue &emsp; []: [] - []",	\
				capitalize(BP.name),					\
				(BP.brute_dam > 0)	?	"\red [BP.brute_dam]"							:0,		\
				(BP.burn_dam > 0)	?	"<font color='#FFA500'>[BP.burn_dam]</font>"	:0),1)
		else
			user.show_message("\blue &emsp; Components are OK.",1)

	user.show_message("\blue Operating Temperature: [M.bodytemperature-T0C]&deg;C ([M.bodytemperature*1.8-459.67]&deg;F)", 1)

	src.add_fingerprint(user)
	return
