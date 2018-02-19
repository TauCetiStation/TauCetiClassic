#define CHALLENGE_TELECRYSTALS 200
#define CHALLENGE_TIME_LIMIT 6000
#define CHALLENGE_MIN_PLAYERS 30

var/global/obj/item/device/nuclear_challenge/Challenge

/obj/item/device/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon = 'icons/obj/device.dmi'
	icon_state = "recaller"
	item_state = "walkietalkie"
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
			Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
			Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE
	var/static/Gateway_hack = FALSE
	var/static/Dropod_used = FALSE
	var/static/shuttle_moved = FALSE

/obj/item/device/nuclear_challenge/atom_init()
	. = ..()
	Challenge = src

/obj/item/device/nuclear_challenge/Destroy()
	if(Challenge == src)
		Challenge = null
	return ..()


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
		war_declaration = stripped_input(user, "Insert your custom declaration", "Declaration")
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return
	command_alert(war_declaration, "Declaration of War")
	player_list << sound('sound/machines/Alarm.ogg')

	to_chat(user, "You've attracted the attention of powerful forces within the syndicate. \
	A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")

	var/obj/item/device/radio/uplink/U = new(get_turf(user))
	U.hidden_uplink.uses = CHALLENGE_TELECRYSTALS
	U.hidden_uplink.uplink_type = "nuclear"
	qdel(src)

/obj/item/device/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "You are already in the process of declaring war! Make your mind up.")
		return 0
	if(player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, "The enemy crew is too small to be worth declaring war on.")
		return 0
	if(user.z != ZLEVEL_CENTCOM)
		to_chat(user, "You have to be at your base to use this.")
		return 0
	if(world.time-round_start_time > CHALLENGE_TIME_LIMIT)
		to_chat(user, "It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make do with what you have on hand.")
		return 0
	if(Dropod_used)
		to_chat(user, "The Droppod has already been launch! You have forfeit the right to declare war.")
		return 0
	if(Gateway_hack)
		to_chat(user, "The Gateway hack has already been in progress! You have forfeit the right to declare war.")
		return 0
	if(shuttle_moved)
		to_chat(user, "The shuttle has already been moved! You have forfeit the right to declare war.")
		return 0
	return 1

#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_MIN_PLAYERS
