//В виду не совсем корректной работы бьенда и ССки с кирилицей, тут будут складываться альтернативы некоторым функциям по работе с текстом и дополнения к ним
//Все еще не решенные проблемы искать по TODO:CYRILLIC

/*
*	Part I: Бьендофункции
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
	while(p++ <= lenght)
		lcase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(lcase_letter)

		if((letter_ascii >= 65 && letter_ascii <= 90) || (letter_ascii >= 192 && letter_ascii < 223))
			lcase_letter = ascii2text(letter_ascii + 32)
		else if(letter_ascii == 223)
			lcase_letter = letter_255	//"я"
		else
			new_text += lcase_letter

	return new_text

/proc/uppertext_plus(text)
	var/lenght = length(text)
	var/new_text = null
	var/ucase_letter
	var/letter_ascii

	var/p = 1
	while(p++ <= lenght)
		ucase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(ucase_letter)

		if((letter_ascii >= 97 && letter_ascii <= 122) || (letter_ascii >= 224 && letter_ascii < 255))
			ucase_letter = ascii2text(letter_ascii - 32)
		else if(letter_ascii == 255)
			ucase_letter = "Я"
		else
			new_text += ucase_letter

	return new_text

/*
*	Part II: Борьба за "я"
*
*	Пачка костылей, что помогает нам донести эту ... "я" до пользователя.
*	Кроме всего что ниже, так-же в основном sanitize(что в text.dm) добавлена замена "я" на letter_255
*/

var/letter_255 = ascii2text(182) // "¶"

//Removes a few problematic characters
//На всякий случай, скроем существование проверки на длину от глаз гитхаба. Посмотрим, может что-то неожиданное откроется.
/proc/sanitize_simple(var/t,var/list/repl_chars = list("\n"=" ","\t"=" ","я"=letter_255))

	if(length(t) > 1500)																// Если "проблем" не обнаружится,
		world.log << "ERROR_SS_long_string([src]): [copytext(t, 1, MAX_MESSAGE_LEN)]"	// можно будет этот кусок закомментить.
		return "¶"

	for(var/char in repl_chars)
		var/len = length(repl_chars[char])
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+1)
			index = findtext(t, char, index + len)
	#ifdef DEBAG_CYRILLIC
	world << "DEBAG sanitize_simple: [t]"
	#endif
	return t

//Для правильного вывода текста в ЧАТЕ
//кодировка в чате соответствует таблице windows-1251(в случае русской локали)
/proc/sanitize_output(var/t)

	t = sanitize_simple(t, list(letter_255="&#255;","&#1103;"="&#255;"))	//проверяем &#1103; просто на всякий случай
	#ifdef DEBAG_CYRILLIC
	world << "DEBAG sanitize_output: [t]"
	#endif
	return t

//Для правильного вывода текста в сторонних окнах
//кодировка соответствует unicode("правильные" мнемоники html)
/proc/sanitize_output2(var/t)

	t = sanitize_simple(t, list(letter_255="&#1103;","&#255;"="&#1103;"))	//проверяем &#255; просто на всякий случай
	#ifdef DEBAG_CYRILLIC
	world << "DEBAG sanitize_output2: [t]"
	#endif
	return t

//Если текст выводится куда-нибудь сразу после инпута, то разделение на санитайз ввода\вывода не так актуально, можно все сразу
/proc/sanitize_plus(var/t,var/list/repl_chars = list("\n"=" ","\t"="","я"=letter_255))

	t = sanitize_output(sanitize(t, repl_chars))	//надеюсь, когда-нибудь проблемы с "я" закончатся...
	#ifdef DEBAG_CYRILLIC
	world << "DEBAG sanitize_plus: [t]"
	#endif
	return t

//Исключение - книги, которые изначально хранятся с "я" в виде "&#1103;". Обратная совместимость со старыми книгами, оптимальный вывод списка книг
//Кстати, то же самое касается и логов ПДА и реквест консоли
/proc/sanitize_plus2(var/t,var/list/repl_chars = list("\n"=" ","\t"="","я"=letter_255))

	t = sanitize_output2(sanitize(t, repl_chars))
	#ifdef DEBAG_CYRILLIC
	world << "DEBAG sanitize_plus2: [t]"
	#endif
	return t

//Необходимо, если мы хотим записывать на сервере читаемые логи.
//Так-же в случаях, когда исходный текст уже прошедший sanitize подается пользователю
//в виде дефолтного варианта в input() as text (флавор, как пример)
/proc/revert_ja(var/t, var/list/repl_chars = list("&#255;", "&#1103;", letter_255))

	t = sanitize_simple(t, repl_chars)
	#ifdef DEBAG_CYRILLIC
	world << "DEBAG sanitize_plus2: [t]"
	#endif
	return t