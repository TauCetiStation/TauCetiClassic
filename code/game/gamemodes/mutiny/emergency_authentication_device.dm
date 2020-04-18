/obj/machinery/emergency_authentication_device
	var/datum/game_mode/mutiny/mode

	name = "Emergency Authentication Device"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE

	var/captains_key
	var/secondary_key
	var/activated = FALSE

/obj/machinery/emergency_authentication_device/atom_init(mapload, mode)
	src.mode = mode
	. = ..()

/obj/machinery/emergency_authentication_device/proc/check_key_existence()
	if(!mode.captains_key)
		captains_key = 1

	if(!mode.secondary_key)
		secondary_key = 1

/obj/machinery/emergency_authentication_device/proc/get_status()
	if(activated)
		return "Activated"
	if(captains_key && secondary_key)
		return "Both Keys Authenticated"
	if(captains_key)
		return "Captain's Key Authenticated"
	if(secondary_key)
		return "Secondary Key Authenticated"
	else
		return "Inactive"

/obj/machinery/emergency_authentication_device/attack_hand(mob/user)
	if(..())
		return

	if(activated)
		to_chat(user, "<span class='notice'>\The [src] is already active!</span>")
		return

	if(!mode.current_directive.directives_complete())
		state("Command aborted. Communication with CentCom is prohibited until Directive X has been completed.")
		return

	check_key_existence()
	if(captains_key && secondary_key)
		activated = 1
		to_chat(user, "<span class='notice'>You activate \the [src]!</span>")
		state("Command acknowledged. Initiating quantum entanglement relay to NanoTrasen High Command.")
		return

	if(!captains_key && !secondary_key)
		state("Command aborted. Please present the authentication keys before proceeding.")
		return

	if(!captains_key)
		state("Command aborted. Please present the Captain's Authentication Key.")
		return

	if(!secondary_key)
		state("Command aborted. Please present the Emergency Secondary Authentication Key.")
		return

	// Impossible!
	state("Command aborted. This unit is defective.")

/obj/machinery/emergency_authentication_device/attackby(obj/item/weapon/O, mob/user)
	if(activated)
		to_chat(user, "<span class='notice'>\The [src] is already active!</span>")
		return

	if(!mode.current_directive.directives_complete())
		state({"Command aborted. Communication with CentCom is prohibited until Directive X has been completed."})
		return

	check_key_existence()
	if(istype(O, /obj/item/weapon/mutiny/auth_key/captain) && !captains_key)
		captains_key = O
		user.drop_item()
		O.loc = src

		state("Key received. Thank you, Captain [mode.head_loyalist].")
		spawn(5)
			state(secondary_key ? "Your keys have been authenticated. Communication with CentCom is now authorized." : "Please insert the Emergency Secondary Authentication Key now.")
		return

	if(istype(O, /obj/item/weapon/mutiny/auth_key/secondary) && !secondary_key)
		secondary_key = O
		user.drop_item()
		O.loc = src

		state("Key received. Thank you, Secondary Authenticator [mode.head_mutineer].")
		spawn(5)
			state(captains_key ? "Your keys have been authenticated. Communication with CentCom is now authorized." : "Please insert the Captain's Authentication Key now.")
		return
	..()

/obj/machinery/emergency_authentication_device/examine(mob/user)
	..()
	to_chat(user, {"
This is a specialized communications device that is able to instantly send a message to <b>NanoTrasen High Command</b> via quantum entanglement with a sister device at CentCom.
The EAD's status is [get_status()]."})
