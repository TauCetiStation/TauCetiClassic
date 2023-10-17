var/global/metahelps

/client/proc/show_metahelp_greeting(id)
	if(!config.wikiurl || !metahelps[id])
		return


	var/datum/metahelp/help = metahelps[id]

	//todo: possible a way to add some metahelps ID's in personal ignore list

	var/msg = "[help.greeting] <a href=?src=\ref[src];metahelp=[help.id]>(Читать)</a>"

	to_chat(src, "<font color='purple'><span class='ooc'><span class='prefix'>OOC-INFO:</span> <span class='message'>[msg]</span></span></font>")

/client/proc/show_metahelp_message(id)
	if(!config.wikiurl || !metahelps[id])
		return

	var/datum/metahelp/help = metahelps[id]

	var/popup_content = {"
		<!DOCTYPE html>
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
				<meta http-equiv="X-UA-Compatible" content="IE=edge">
				<title>Metahelp: [help.title]</title>
				<style>
					html, body {
						box-sizing: border-box;
						height: 100%;
						margin: 0px;
						padding: 0px;
					}
					iframe {
						padding: 0px;
						margin: 0px;
						display: none;
					}
				</style>
			</head>
			<body>
				<script type="text/javascript">
					function pageloaded(myframe) {
						document.getElementById("loading").style.display = "none";
						myframe.style.display = "inline";
					}
				</script>
				<p id='loading'>You start skimming through the manual...</p>
				<iframe width='100%' height='97%' onload="pageloaded(this)" src="[config.wikiurl]/[help.wiki_page]?printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
			</body>
		</html>
		"}

	usr << browse("[popup_content]", "window=metahelp_[help.id];size=700x500")

/datum/metahelp
	var/id = "your_unique_id"
	var/wiki_page = "your_wiki_page"
	var/title = "Заголовок сообщения"
	var/greeting = "Короткое сообщение в чате перед ссылкой"

/datum/metahelp/ionlaws/New()
	id = "ionlaws"
	wiki_page = "Metahelp: Ion Laws"
	title = "ИИ с ионными законами"
	greeting = "У вас появился ионный закон! Прочитайте, если не знаете, как это отыгрывать."

/datum/metahelp/hulk/New()
	id = "hulk"
	wiki_page = "Metahelp: Hulk"
	title = "Как отыгрывать Халка"
	greeting = "Вы большой и зеленый, что с этим делать?"

/datum/metahelp/replicator/New()
	id = "replicator"
	wiki_page = "Replicator"
	title = "Как играть за Репликатора"
	greeting = "Нужна помощь в репликации?"
