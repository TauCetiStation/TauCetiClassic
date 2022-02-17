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

/client/verb/reportissue()
	set name = "report-issue"
	set desc = "Report an issue"
	set hidden = 1

	var/githuburl = config.repository_link
	if(!githuburl)
		to_chat(src, "<span class='danger'>The URL is not set in the server configuration. Please tell host about it.</span>")
		return

	var/message = "This will open the Github issue reporter in your browser. Are you sure?"
	if(tgui_alert(usr, message, "Report Issue", list("Yes", "No")) != "Yes")
		return
	var/static/issue_template = file2text(".github/ISSUE_TEMPLATE.md")
	var/servername = config.server_name
	var/url_params = "[issue_template]"
	if(global.round_id || config.server_name)
		url_params += "Issue reported from [global.round_id ? " Round ID: [global.round_id][servername ? " ([servername])" : ""]" : servername]\n"
	url_params += "Testmerges: ```[test_merges ? test_merges : "No test merges"]```\n"
	url_params += "Reporting client version: [byond_version].[byond_build]\n"
	DIRECT_OUTPUT(src, link("[githuburl]/issues/new?body=[url_encode(url_params)]"))

	return

/client/verb/changes()
	set name = "Changelog"
	set desc = "View the changelog."
	set hidden = 1

	link_with_alert(src, config.changelog_link)

	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		prefs.save_preferences()
		winset(src, "rpane.changelog", "font-style=")

/client/verb/discord()
	set name = "Discord"
	set desc = "Invite Discord conference."
	set hidden = TRUE
	link_with_alert(src, config.discord_invite_url)

/proc/link_with_alert(client/user, link_url)
	if(link_url)
		if(tgui_alert(usr, "This will open your browser. Are you sure?",, list("Yes", "No")) == "Yes")
			user << link(link_url)
	else
		to_chat(user, "<span class='danger'>The URL is not set in the server configuration. Please tell host about it.</span>")
