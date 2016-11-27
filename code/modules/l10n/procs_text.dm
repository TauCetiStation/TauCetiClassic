//В виду не совсем корректной работы бьенда и ССки с кирилицей, тут будут складываться альтернативы некоторым функциям по работе с текстом и дополнения к ним
//Все еще не решенные проблемы искать по TODO:CYRILLIC

/*
	UPD: На случай, если вы ищите варианты пофиксить "я"!
	Это старый фикс, с тех пор мы немного отрефакторили оригинальный бэй и
	создали RuBaystation, тамошний фикс "я" более правильный и актуальный.
	https://github.com/TauCetiStation/RuBaystation12
	В ожидании чуда: http://www.byond.com/forum/?post=1768158
*/

/*
*	Part I: Борьба за "я"
*
*	Пачка костылей, что помогает нам донести "я" до пользователя.
*	LETTER_255 определен в setup.dm
*/

var/letter_255_ascii = text2ascii(LETTER_255)

//Removes a few problematic characters
/proc/sanitize_simple(t,list/repl_chars = list("\n"=" ","\t"=" ","я"=LETTER_255))

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \blue <b>Sanitize_simple, entered. Text:</b> <i>[t]</i>")
	var/params
	for(var/a in repl_chars)
		params += " [html_decode(a)] replaced by [html_decode(repl_chars[a])]\n"
	to_chat(world, "<i>Params:\n[params]</i>")
	#endif

	for(var/char in repl_chars)
		var/len_rchar = length(repl_chars[char])
		var/len_char = length(char)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+len_char)
			index = findtext(t, char, index + len_rchar)

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \red <b>Sanitize_simple, finished. Return text:</b> <i>[t]</i>")
	#endif

	return t

/proc/sanitize(t,list/repl_chars = null)

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \blue <b>Sanitize, entered. Text:</b> <i>[t]</i>")
	var/params
	for(var/a in repl_chars)
		params += " [html_decode(a)] replaced by [html_decode(repl_chars[a])]\n"
	to_chat(world, "<i>Params:\n[params]</i>")
	#endif

	t = html_encode(sanitize_simple(t, repl_chars))

	var/index = findtext(t, LETTER_255)
	while(index)
		t = copytext(t, 1, index) + "&#255;" + copytext(t, index+1)
		index = findtext(t, LETTER_255, index + 6)//index+len("&#255;")

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \red <b>Sanitize, finished. Return text:</b> <i>[t]</i>")
	#endif

	return t

/proc/sanitize_alt(t,list/repl_chars = null)

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \blue <b>Sanitize_alt, entered. Text:</b> <i>[t]</i>")
	var/params
	for(var/a in repl_chars)
		params += " [html_decode(a)] replaced by [html_decode(repl_chars[a])]\n"
	to_chat(world, "<i>Params:\n[params]</i>")
	#endif

	t = html_encode(sanitize_simple(t, repl_chars))

	var/index = findtext(t, LETTER_255)
	while(index)
		t = copytext(t, 1, index) + "&#1103;" + copytext(t, index+1)
		index = findtext(t, LETTER_255, index + 7)//index+len("&#1103;")

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \red <b>Sanitize_alt, finished. Return text:</b> <i>[t]</i>")
	#endif

	return t

/proc/sanitize_popup(t)
	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \green <b>Sanitize_popup processed text:</b> <i>[t]</i>")
	#endif
	return replacetext(t, "&#255;", "&#1103;")

/proc/sanitize_chat(t)
	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \green <b>Sanitize_alt_chat processed text:</b> <i>[t]</i>")
	#endif
	return replacetext(t, "&#1103;", "&#255;")

/proc/sanitize_plus(t,list/repl_chars = null)

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \blue <b>Sanitize_plus, entered. Text:</b> <i>[t]</i>")
	var/params
	for(var/a in repl_chars)
		params += " [html_decode(a)] replaced by [html_decode(repl_chars[a])]\n"
	to_chat(world, "<i>Params:\n[params]</i>")
	#endif

	t = html_encode(sanitize_simple(t, repl_chars))

	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \red <b>Sanitize_plus, finished. Return text:</b> <i>[t]</i>")
	#endif

	return t

/proc/sanitize_plus_chat(t)
	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \green <b>Sanitize_plus_chat processed text:</b> <i>[t]</i>")
	#endif
	return replacetext(t, LETTER_255, "&#255;")

/proc/sanitize_plus_popup(t)
	#ifdef DEBAG_CYRILLIC
	to_chat(world, "\magenta #DEBAG \green <b>Sanitize_plus_popup processed text:</b> <i>[t]</i>")
	#endif
	return replacetext(t, LETTER_255, "&#1103;")


//TODO: придумать способ вернуть "я" для полей ввода и логов
/proc/revert_ja(t, list/repl_chars = list("&#255;", "&#1103;"))
	return replacetext(replacetext(t, "&#255;", LETTER_255), "&#1103;", LETTER_255)

/*
*	Part II: Бьендофункции
*
*	Стандартные lowertext и uppertext игнорируют кирилицу
*	Возможно, их можно было бы как-то переопределить, как это сделанно с isBanned(), но у меня не вышло.
*/

/proc/lowertext_plus(text)
	var/lenght = length(text)
	var/new_text = null
	var/lcase_letter
	var/letter_ascii

	var/p = 1
	while(p <= lenght)
		lcase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(lcase_letter)

		if((letter_ascii >= 65 && letter_ascii <= 90) || (letter_ascii >= 192 && letter_ascii < 223))
			lcase_letter = ascii2text(letter_ascii + 32)
		else if(letter_ascii == 223)
			lcase_letter = LETTER_255	//"я"

		new_text += lcase_letter
		p++

	return new_text

/proc/uppertext_plus(text)
	var/lenght = length(text)
	var/new_text = null
	var/ucase_letter
	var/letter_ascii

	var/p = 1
	while(p <= lenght)
		ucase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(ucase_letter)

		if((letter_ascii >= 97 && letter_ascii <= 122) || (letter_ascii >= 224 && letter_ascii < 255))
			ucase_letter = ascii2text(letter_ascii - 32)
		else if(letter_ascii == letter_255_ascii)
			ucase_letter = "Я"

		new_text += ucase_letter
		p++

	return new_text
