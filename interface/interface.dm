//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Visit the wiki."
	set hidden = TRUE
	link_with_alert(src, config.wikiurl)

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = TRUE
	link_with_alert(src, config.forumurl)

/client/verb/rules()
	set name = "Rules"
	set desc = "Show Server Rules."
	set hidden = TRUE
	link_with_alert(src, config.server_rules_url)

/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\t TAB = toggle hotkey-mode
\t a = left
\t s = down
\t d = right
\t w = up
\t q = drop
\t e = equip
\t r = throw
\t t = say
\t h = holder/unholder
\t x = swap-hand
\t z = click on held object (or y)
\t b = click on self
\t f = cycle-intents-left
\t g = cycle-intents-right
\t 1 = help-intent
\t 2 = disarm-intent
\t 3 = grab-intent
\t 4 = harm-intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\t Ctrl+a = left
\t Ctrl+s = down
\t Ctrl+d = right
\t Ctrl+w = up
\t Ctrl+q = drop
\t Ctrl+e = equip
\t Ctrl+r = throw
\t Ctrl+h = holder/unholder
\t Ctrl+x = swap-hand
\t Ctrl+z = click on held object (or Ctrl+y)
\t Ctrl+b = click on self
\t Ctrl+f = cycle-intents-left
\t Ctrl+g = cycle-intents-right
\t Ctrl+1 = help-intent
\t Ctrl+2 = disarm-intent
\t Ctrl+3 = grab-intent
\t Ctrl+4 = harm-intent
\t DEL = pull
\t INS = cycle-intents-right
\t HOME = drop
\t PGUP = swap-hand
\t PGDN = click on held object
\t END = throw
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\t F5 = Asay
\t F6 = player-panel-new
\t F7 = admin-pm
\t F8 = Invisimin
\t F9 = Mentorhelp
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)
	if(holder)
		to_chat(src, admin)

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set hidden = 1

	link_with_alert(src, config.changelog_link)

	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		prefs.save_preferences()
		winset(src, "rpane.changelog", "font-style=;background-color=#FFF;")

/client/verb/discord()
	set name = "Discord"
	set desc = "Invite Discord conference."
	set hidden = TRUE
	link_with_alert(src, config.discord_invite_url)

/proc/link_with_alert(client/user, link_url)
	if(link_url)
		if(alert("This will open your browser. Are you sure?",, "Yes", "No") == "Yes")
			user << link(link_url)
	else
		to_chat(user, "<span class='danger'>The URL is not set in the server configuration. Please tell host about it.</span>")