#define INSERT_WIKI_URL(wikipage) config.wikiurl ? "<a target='_blank' class='nostyle' href='[config.wikiurl]/[wikipage]'>[wikipage]</a>" : "(link not configured)"
#define INSERT_RULES_URL(chapter) config.server_rules_url ? "<a target='_blank' class='nostyle' href='[config.server_rules_url]/#[chapter]'>[chapter]</a>" : "(link not configured)"

var/global/metahelps

/client/proc/show_metahelp_greeting(id)
	if(!metahelps[id])
		return


	var/datum/metahelp/help = metahelps[id]

	//todo: possible a way to add some metahelps ID's in personal ignore list

	var/msg = "[help.greeting] <a href=?src=\ref[src];metahelp=[help.id]>(Читать)</a>"

	to_chat(src, "<font color='purple'><span class='ooc'><span class='prefix'>OOC-INFO:</span> <span class='message'>[msg]</span></span></font>")

/client/proc/show_metahelp_message(id)
	if(!metahelps[id])
		return

	var/datum/metahelp/help = metahelps[id]

	var/popup_text = replace_characters(trim(metahelps[id].text), list("\n"="<br>"))
	popup_text += "\n<hr>\n<i>Если ссылки в сообщении не работают, или какая-то информация уже не актуальна - пожалуйста, сообщите в нашем репозитории на GitHub.</i>"

	var/datum/browser/popup = new(usr, "metahelp_[help.id]", "[help.title]", 500, 700)
	popup.set_content(popup_text)
	popup.open()

/datum/metahelp
	var/id = "your_unique_id"
	var/title = "Заголовок сообщения"
	var/greeting = "Короткое сообщение в чате с ссылкой на открытие сообщения"
	var/text = {"
Ваш полный текст для сообщения в отдельном окне
	"}

/datum/metahelp/ionlaws/New()
	id = "ionlaws"
	title = "ИИ с ионными законами"
	greeting = "У вас появился ионный закон! Прочитайте, если не знаете как это отыгрывать."
	text = {"
Поздравляем, ввиду случайного ивента или внешнего вмешательства у вас появился ионный закон. Это может разнообразить вашу игру за ИИ в этом раунде. Но имейте в виду, что ионные законы не отменяют остальные, и не делают вас антагонистом. Вы не должны действовать как антагонист, если им не являетесь, иначе к вам могут появиться претензии со стороны администрации.
Подробнее про ИИ можно почитать на нашей вики в статье [INSERT_WIKI_URL("AI")].
	"}

/datum/metahelp/hulk/New()
	id = "hulk"
	title = "Как отыгрывать Халка"
	greeting = "Вы большой и зеленый, что с этим сделать?"
	text = {"
Вау, вы стали [INSERT_WIKI_URL("Hulk")]-ом. Жертва эксперимента или стечения обстоятельств, подробнее про особенности халка можете почитать соответствующую статью на вики.
Основные моменты:
* Халк сохраняет своё сознание и по нашему бэку не имеет изменений в личности (но на ваше усмотрение можно отыграть что-то незначительное, не запрещено, просто не \"ХАЛК КРУШИТЬ\")
* Халк - не антагонист, не должен идти и грифонить станцию. Если у него не появится для этого повода. Как и у обычного экипажа - у вас должа быть IC-причина для эскалации конфликта.
* За неимением других вариантов, и если конфликт эскалировали за вас - вы вполне можете защищаться. Это будет уже обоснованная IC реакция с вашей стороны.
* Ваше существование вне отсека RnD может быть незаконным по 217 статье [INSERT_WIKI_URL("Space_Law")], и к вам могут быть применены меры по [INSERT_WIKI_URL("NanoTrasen_Rules_and_Regulations#Инструкция отдела исследований и разработок 534: Изменение генетического кода")]. Как Халк, если вы не являлись офицером СБ или главой - вы не обязательно должны это знать. Но как законопослушный член экипажа, вам следует прислушаться к требованиям СБ и глав, если вас поймали вне отсека.
* Под ответственность глав и под надзором, если есть надобность, или вы вежливо попросили, вас вполне могут выпустить из RnD погулять и даже отправить вбивать в ближайший шлюз прилетевших нюкеров.
	"}
