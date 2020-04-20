/*
 * Holds procs designed to help with filtering text
 * Contains groups:
 *			SQL sanitization
 *			Text sanitization
 *			Text searches
 *			Text modification
 *			Misc
 */

/*
 * SQL sanitization
 */

// Run all strings to be used in an SQL query through this proc first to properly escape out injection attempts.
/proc/sanitize_sql(t)
	var/sqltext = dbcon.Quote("[t]") // http://www.byond.com/forum/post/2218538
	return copytext(sqltext, 2, lentext(sqltext))

/*
 * Text sanitization
 */

//Used for preprocessing entered text
/proc/sanitize(input, max_length = MAX_MESSAGE_LEN, encode = TRUE, trim = TRUE, extra = TRUE)
	if(!input)
		return

	if(max_length)
		input = copytext(input,1,max_length)

	input = replacetext(input, JA_CHARACTER, JA_PLACEHOLDER)

	if(extra)
		input = replace_characters(input, list("\n"=" ","\t"=" "))

	if(encode)
		//In addition to processing html, html_encode removes byond formatting codes like "\red", "\i" and other.
		//It is important to avoid double-encode text, it can "break" quotes and some other characters.
		//Also, keep in mind that escaped characters don't work in the interface (window titles, lower left corner of the main window, etc.)
		input = html_encode(input)
	else
		//If not need encode text, simply remove < and >
		//note: we can also remove here byond formatting codes: 0xFF + next byte
		input = replace_characters(input, list("<"=" ", ">"=" "))

	if(trim)
		//Maybe, we need trim text twice? Here and before copytext?
		input = trim(input)

	return input

//Run sanitize(), but remove <, >, " first to prevent displaying them as &gt; &lt; &34; in some places, after html_encode().
//Best used for sanitize object names, window titles.
//If you have a problem with sanitize() in chat, when quotes and >, < are displayed as html entites -
//this is a problem of double-encode(when & becomes &amp;), use sanitize() with encode=0, but not the sanitize_safe()!
/proc/sanitize_safe(input, max_length = MAX_MESSAGE_LEN, encode = TRUE, trim = TRUE, extra = TRUE)
	return sanitize(replace_characters(input, list(">"=" ","<"=" ", "\""="'")), max_length, encode, trim, extra)

//Filters out undesirable characters from names
/proc/sanitize_name(input, max_length = MAX_NAME_LEN, allow_numbers = 0, force_first_letter_uppercase = TRUE)
	if(!input || length(input) > max_length)
		return //Rejects the input if it is null or if it is longer then the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/output = ""

	for(var/i=1, i<=length(input), i++)
		var/ascii_char = text2ascii(input,i)
		switch(ascii_char)
			// A  .. Z
			if(65 to 90)			//Uppercase Letters
				output += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// a  .. z
			if(97 to 122)			//Lowercase Letters
				if(last_char_group<2 && force_first_letter_uppercase)
					output += ascii2text(ascii_char-32)	//Force uppercase first character
				else
					output += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 4

			// 0  .. 9
			if(48 to 57)			//Numbers
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				output += ascii2text(ascii_char)
				number_of_alphanumeric++
				last_char_group = 3

			// '  -  .
			if(39,45,46)			//Common name punctuation
				if(!last_char_group) continue
				output += ascii2text(ascii_char)
				last_char_group = 2

			// ~   |   @  :  #  $  %  &  *  +
			if(126,124,64,58,35,36,37,38,42,43)			//Other symbols that we'll allow (mainly for AI)
				if(!last_char_group)		continue	//suppress at start of string
				if(!allow_numbers)			continue
				output += ascii2text(ascii_char)
				last_char_group = 2

			//Space
			if(32)
				if(last_char_group <= 1)	continue	//suppress double-spaces and spaces at start of string
				output += ascii2text(ascii_char)
				last_char_group = 1
			else
				return

	if(number_of_alphanumeric < 2)	return		//protects against tiny names like "A" and also names like "' ' ' ' ' ' ' '"

	if(last_char_group == 1)
		output = copytext(output,1,length(output))	//removes the last character (in this case a space)

	if(lowertext(output) in forbidden_names)	//prevents these common metagamey names
		return	//(not case sensitive)

	return output

/proc/shelleo_url_scrub(url)
	var/static/regex/bad_chars_regex = regex("\[^#%&./:=?\\w]*", "g")
	var/scrubbed_url = ""
	var/bad_match = ""
	var/last_good = 1
	var/bad_chars = 1
	do
		bad_chars = bad_chars_regex.Find(url)
		scrubbed_url += copytext(url, last_good, bad_chars)
		if(bad_chars)
			bad_match = url_encode(bad_chars_regex.match)
			scrubbed_url += bad_match
			last_good = bad_chars + length(bad_match)
	while(bad_chars)
	. = scrubbed_url


//Returns null if there is any bad text in the string
/proc/reject_bad_text(text, max_length=512)
	if(length(text) > max_length)	return			//message too long
	var/non_whitespace = 0
	for(var/i=1, i<=length(text), i++)
		switch(text2ascii(text,i))
			if(62,60,92,47)	return			//rejects the text if it contains these bad characters: <, >, \ or /
			if(127 to 181)	return			//rejects weird letters like �
			if(183 to 191)	return			//rejects weird letters like � // todo: JA_PLACEHOLDER
			if(0 to 31)		return			//more weird stuff
			if(32)			continue		//whitespace
			else			non_whitespace = 1
	if(non_whitespace)		return text		//only accepts the text if it has some non-spaces


//reset to placeholder for inputs, logs
/proc/reset_ja(text)
	return replace_characters(text, list(JA_ENTITY=JA_PLACEHOLDER, JA_ENTITY_ASCII=JA_PLACEHOLDER, JA_CHARACTER=JA_PLACEHOLDER))

//replace ja with entity for chat/popup
/proc/entity_ja(text)
	return replace_characters(text, list(JA_PLACEHOLDER=JA_ENTITY, JA_ENTITY_ASCII=JA_ENTITY))

//Reset ja to cp1251. Only needed for loading screen ban messages.
/proc/initial_ja(text)
	return replace_characters(text, list(JA_ENTITY=JA_CHARACTER, JA_ENTITY_ASCII=JA_CHARACTER, JA_PLACEHOLDER=JA_CHARACTER))


/proc/input_default(text)
	return html_decode(reset_ja(text))//replace br with \n?
/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

//Checks the beginning of a string for a specified sub-string. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix_case(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtextEx(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

//Checks the end of a string for a specified substring. This proc is case sensitive
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix_case(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtextEx(text, suffix, start, null)

/*
 * Text modification
 */

/proc/replace_characters(var/t,var/list/repl_chars)
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

var/global/list/hex_characters = list("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")
/proc/random_string(length, list/characters)
	. = ""
	for (var/i in 1 to length)
		. += pick(characters)

/proc/random_short_color()
	return "#" + random_string(3, global.hex_characters)

/proc/random_color()
	return "#" + random_string(6, global.hex_characters)

//Adds 'u' number of zeros ahead of the text 't'
/proc/add_zero(t, u)
	while (length(t) < u)
		t = "0[t]"
	return t

//Adds 'u' number of spaces ahead of the text 't'
/proc/add_lspace(t, u)
	while(length(t) < u)
		t = " [t]"
	return t

//Adds 'u' number of spaces behind the text 't'
/proc/add_tspace(t, u)
	while(length(t) < u)
		t = "[t] "
	return t

//Returns a string with reserved characters and spaces before the first letter removed
/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

//Returns a string with reserved characters and spaces after the last letter removed
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

//Returns a string with reserved characters and spaces before the first word and after the last word removed.
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns a string with the first element of the string capitalized.
/proc/capitalize(t)
	return uppertext_(copytext(t, 1, 2)) + copytext(t, 2)

//This proc strips html properly, remove < > and all text between
//for complete text sanitizing should be used sanitize()
/proc/strip_html_properly(var/input)
	if(!input)
		return
	var/opentag = 1 //These store the position of < and > respectively.
	var/closetag = 1
	while(1)
		opentag = findtext(input, "<")
		closetag = findtext(input, ">")
		if(closetag && opentag)
			if(closetag < opentag)
				input = copytext(input, (closetag + 1))
			else
				input = copytext(input, 1, opentag) + copytext(input, (closetag + 1))
		else if(closetag || opentag)
			if(opentag)
				input = copytext(input, 1, opentag)
			else
				input = copytext(input, (closetag + 1))
		else
			break

	return input

//Centers text by adding spaces to either side of the string.
/proc/dd_centertext(message, length)
	var/new_message = message
	var/size = length(message)
	var/delta = length - size
	if(size == length)
		return new_message
	if(size > length)
		return copytext(new_message, 1, length + 1)
	if(delta == 1)
		return new_message + " "
	if(delta % 2)
		new_message = " " + new_message
		delta--
	var/spaces = add_lspace("",delta/2-1)
	return spaces + new_message + spaces

//Limits the length of the text. Note: MAX_MESSAGE_LEN and MAX_NAME_LEN are widely used for this purpose
/proc/dd_limittext(message, length)
	var/size = length(message)
	if(size <= length)
		return message
	return copytext(message, 1, length + 1)

/proc/stringmerge(text,compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
	var/newtext = text
	if(lentext(text) != lentext(compare))
		return 0
	for(var/i = 1, i < lentext(text), i++)
		var/a = copytext(text,i,i+1)
		var/b = copytext(compare,i,i+1)
//if it isn't both the same letter, or if they are both the replacement character
//(no way to know what it was supposed to be)
		if(a != b)
			if(a == replace) //if A is the replacement char
				newtext = copytext(newtext,1,i) + b + copytext(newtext, i+1)
			else if(b == replace) //if B is the replacement char
				newtext = copytext(newtext,1,i) + a + copytext(newtext, i+1)
			else //The lists disagree, Uh-oh!
				return 0
	return newtext

/proc/stringpercent(text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= lentext(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/proc/reverse_text(text = "")
	var/new_text = ""
	for(var/i = length(text); i > 0; i--)
		new_text += copytext(text, i, i+1)
	return new_text

/proc/parsebbcode(t, colour = "black")
	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[br\]", "<br>")
	t = replacetext(t, "\[b\]", "<b>")
	t = replacetext(t, "\[/b\]", "</b>")
	t = replacetext(t, "\[i\]", "<i>")
	t = replacetext(t, "\[/i\]", "</i>")
	t = replacetext(t, "\[u\]", "<u>")
	t = replacetext(t, "\[/u\]", "</u>")
	t = replacetext(t, "\[large\]", "<font size=\"4\">")
	t = replacetext(t, "\[/large\]", "</font>")
	t = replacetext(t, "\[*\]", "<li>")
	t = replacetext(t, "\[small\]", "<font size = \"1\">")
	t = replacetext(t, "\[/small\]", "</font>")
	t = replacetext(t, "\[list\]", "<ul>")
	t = replacetext(t, "\[/list\]", "</ul>")
	t = replacetext(t, "\[hr\]", "<hr>")
	t = replace_characters(t, list("\[/br\]\n"="", "\n\[/br\]"="", "\[/br\]"="")) // for the tables sake
	t = replacetext(t, "\n", "<br>")

	// tables
	t = replacetext(t, "\[table\]", "<table border=3px cellpadding=5px bordercolor=\"[colour]\">")
	t = replacetext(t, "\[/table\]", "</table>")
	t = replacetext(t, "\[tr\]", "<tr>")
	t = replacetext(t, "\[/tr\]", "</tr>")
	t = replacetext(t, "\[td\]", "<td><font color=\"[colour]\">")
	t = replacetext(t, "\[/td\]", "</font></td>")
	t = replacetext(t, "\[th\]", "<th><font color=\"[colour]\">")
	t = replacetext(t, "\[/th\]", "</font></th>")

	// standart head
	t = replacetext(t, "\[h\]", "<font size=\"4\"><center><b>")
	t = replacetext(t, "\[/h\]", "</b></center></font>")

	// bordered head;
	t = replacetext(t, "\[bh\]", "<div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b>")
	t = replacetext(t, "\[/bh\]", "</b></center></font></div>")

	// blockquote
	t = replacetext(t, "\[quote\]", "<blockquote style=\"line-height:normal; margin-bottom:10px; font-style:italic; letter-spacing: 1.25px; text-align:right;\">")
	t = replacetext(t, "\[/quote\]", "</blockquote>")

	// div
	t = replacetext(t, "\[block\]", "<div style=\"border-width: 4px; border-style: dashed;\">")
	t = replacetext(t, "\[/block\]", "</div>")

	// date & time
	t = replacetext(t, "\[date\]", "[current_date_string]")
	t = replacetext(t, "\[time\]", "[worldtime2text()]")

	return t

/*
 * Byond
 * (remove this when byond lern unicode)
 */

/proc/lowertext_(var/text)
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
			lcase_letter = JA_PLACEHOLDER

		new_text += lcase_letter
		p++

	return new_text

/proc/uppertext_(var/text)
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
		else if(letter_ascii == JA_PLACEHOLDER_CODE)
			ucase_letter = JA_UPPERCHARACTER

		new_text += ucase_letter
		p++

	return new_text
