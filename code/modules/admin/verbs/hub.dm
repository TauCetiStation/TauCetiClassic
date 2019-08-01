/client/proc/toggle_hub()
	set category = "Server"
	set name = "Toggle Hub"

	world.update_hub_visibility(!hub_visibility)

	log_admin("[key_name(usr)] has toggled the server's hub status for the round, it is now [(hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(usr)] has toggled the server's hub status for the round, it is now [(hub_visibility?"on":"off")] the hub.")
	if (hub_visibility && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a filewall is blocking incoming connections.")

	world.send2bridge(
		type = list(BRIDGE_ADMINALERT),
		attachment_title = "HUB visibility",
		attachment_msg = "**[key_name(src)]** has toggled hub **[(hub_visibility?"on":"off")]**",
		attachment_color = BRIDGE_COLOR_ADMINALERT,
	)