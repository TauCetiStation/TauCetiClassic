//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Посетить Википедию."
	set hidden = TRUE
	link_with_alert(src, config.wikiurl)

/client/verb/forum()
	set name = "forum"
	set desc = "Посетить форум."
	set hidden = TRUE
	link_with_alert(src, config.forumurl)

/client/verb/rules()
	set name = "Rules"
	set desc = "Ознакомиться с правилами сервера."
	set hidden = TRUE
	link_with_alert(src, config.server_rules_url)

/client/verb/reportissue()
	set name = "report-issue"
	set desc = "Сообщить о баге или проблеме."
	set hidden = 1

	var/githuburl = config.repository_link
	if(!githuburl)
		to_chat(src, "<span class='danger'>Данная ссылка не встроена в конфигурацию сервера. Пожалуйста, оповестите об этом хоста.</span>")
		return

	var/message = "Вы откроете GitHub в вашем браузере. Вы уверены?"
	if(tgui_alert(usr, message, "Report Issue", list("Да", "Нет")) != "Да")
		return

	var/servername = config.server_name
	var/url_params = ""
	if(global.round_id || config.server_name)
		url_params += "Issue reported from [global.round_id ? " Round ID: [global.round_id][servername ? " ([servername])" : ""]" : servername]\n"
	url_params += "Testmerges: ```[test_merges ? "#" + jointext(test_merges, "# ") : "No test merges"]```\n"
	url_params += "Reporting client version: [byond_version].[byond_build]\n"
	DIRECT_OUTPUT(src, link("[githuburl]/issues/new?labels=Bug&template=bug_report.yml&additional=[url_encode(url_params)]"))

/client/verb/changes()
	set name = "Changelog"
	set desc = "Ознакомиться со списком недавних изменений."
	set hidden = 1

	link_with_alert(src, config.changelog_link)

	if(prefs.lastchangelog != changelog_hash)
		prefs.lastchangelog = changelog_hash
		prefs.save_preferences()
		winset(src, "rpane.changelog", "font-style=")

/client/verb/discord()
	set name = "Discord"
	set desc = "Посетить Discord сервер."
	set hidden = TRUE
	link_with_alert(src, config.discord_invite_url)

/proc/link_with_alert(client/user, link_url)
	if(link_url)
		if(tgui_alert(usr, "Будет открыт ваш браузер. Вы уверены?",, list("Да", "Нет")) == "Да")
			user << link(link_url)
	else
		to_chat(user, "<span class='danger'>Данная ссылка не встроена в конфигурацию сервера. Пожалуйста, оповестите об этом хоста.</span>")
