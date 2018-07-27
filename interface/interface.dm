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

/client/verb/banhub()
	set name = "Banhub"
	set desc = "Use our exclusive banhub!"
	set hidden = 1

	link_with_alert(src, "http://5.9.12.156:9999/")
/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tt = say
\tx = swap-hand
\tz = activate held object (or y)
\tf = cycle-intents-left
\tg = cycle-intents-right
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+f = cycle-intents-left
\tCtrl+g = cycle-intents-right
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\tF5 = Asay
\tF6 = player-panel-new
\tF7 = admin-pm
\tF8 = Invisimin
\tF9 = Mentorhelp
</font>"}

	to_chat(src, hotkey_mode)
	to_chat(src, other)
	if(holder)
		to_chat(src, admin)

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set hidden = 1

	getFiles(
		'html/assets/images/icons/BugFix.png',
		'html/assets/images/icons/CircledPlus.png',
		'html/assets/images/icons/CircledMinus.png',
		'html/assets/images/icons/Picture.png',
		'html/assets/images/icons/Sound.png',
		'html/assets/images/icons/SpellCheck.png',
		'html/assets/images/icons/Wrench.png',
		'html/assets/images/icons/Performance.png',
		'html/assets/images/icons/NukeBurn.png',
		'html/assets/images/icons/Balance.png',
		'html/assets/images/icons/Map.png',
		'html/assets/images/space.png',
		'html/assets/css/bootstrap.min.css',
		'html/assets/css/changelog.css',
		'html/assets/scripts/jquery-3.2.1.min.js',
		'html/assets/scripts/bootstrap.min.js',
		'html/assets/scripts/changelog.js',
		'html/changelog.html'
	)

	src << browse('html/changelog.html', "window=changes;size=675x650")

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