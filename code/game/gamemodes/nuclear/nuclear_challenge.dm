#define CHALLENGE_TELECRYSTALS 200
#define CHALLENGE_TIME_LIMIT 6000
#define CHALLENGE_MIN_PLAYERS 40

var/global/war_device_activated
var/global/war_device_activation_forbidden



/obj/item/device/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon = 'icons/obj/device.dmi'
	icon_state = "recaller"
	item_state = "walkietalkie"
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
			Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
			Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE


/obj/item/device/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = alert(user, "Consult your team carefully before you declare war on [station_name()]]. Are you sure you want to alert the enemy crew? You have [-round((world.time-round_start_time - CHALLENGE_TIME_LIMIT)/10)] seconds to decide", "Declare war?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure == "No")
		to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		return

	var/war_declaration = "[user.real_name] has declared his intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them."

	declaring_war = TRUE
	var/custom_threat = alert(user, "Do you want to customize your declaration?", "Customize?", "No", "Yes")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = sanitize(input(user, "Insert your custom declaration", "Declaration"))
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return
	command_alert(war_declaration, "Declaration of War")
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/machines/Alarm.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)

	to_chat(user, "You've attracted the attention of powerful forces within the syndicate. \
	A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")

	war_device_activated = TRUE

	var/obj/item/device/radio/uplink/U = new(get_turf(user))
	U.hidden_uplink.uses = CHALLENGE_TELECRYSTALS
	U.hidden_uplink.uplink_type = "nuclear"

	message_admins("[key_name_admin(usr)] is declaring war on station.")
	log_admin("[key_name(usr)] is declaring war on station.")
	feedback_set_details("NUCLEAR_WAR", "Declared by [key_name(usr)]")

	qdel(src)

/obj/item/device/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "You are already in the process of declaring war! Make your mind up.")
		return 0
	if(player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, "The enemy crew is too small to be worth declaring war on.")
		return 0
	if(!is_centcom_level(user.z))
		to_chat(user, "You have to be at your base to use this.")
		return 0
	if(world.time-round_start_time > CHALLENGE_TIME_LIMIT)
		to_chat(user, "It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make do with what you have on hand.")
		return 0
	if(war_device_activation_forbidden)
		to_chat(user, "The invasion has already begun. War can not be declared at this point.")
		return 0
	return 1

#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_MIN_PLAYERS
