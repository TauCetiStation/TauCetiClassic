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
	return copytext(sqltext, 2, -1)

/*
 * Text sanitization
 */

// You need this for every user text input()
/proc/sanitize(input, max_length = MAX_MESSAGE_LEN, encode = TRUE, trim = TRUE, extra = TRUE, ascii_only = FALSE)
	if(!input)
		return

	if(max_length)
		input = copytext_char(input, 1, max_length)

	if(extra)
		input = replace_characters(input, list("\n"=" ","\t"=" "))

	if(ascii_only)
		// Some procs work differently depending on unicode/ascii string
		// You should always consider this with any text processing work
		// More: http://www.byond.com/docs/ref/info.html#/{notes}/Unicode
		//       http://www.byond.com/forum/post/2520672
		input = stip_non_ascii(input)
	else
		// Strip Unicode control/space-like chars here exept for line endings (\n,\r) and normal space (0x20)
		// codes from https://www.compart.com/en/unicode/category/
		//            https://en.wikipedia.org/wiki/Whitespace_character#Unicode
		var/static/regex/unicode_control_chars = regex(@"[\u0001-\u0009\u000B\u000C\u000E-\u001F\u007F\u0080-\u009F\u00A0\u1680\u180E\u2000-\u200D\u2028\u2029\u202F\u205F\u2060\u3000\uFEFF]", "g")
		input = unicode_control_chars.Replace(input, "")

	if(encode)
		// In addition to processing html, html_encode removes byond formatting codes like "\red", "\i" and other.
		// It is important to avoid double-encode text, it can "break" quotes and some other characters.
		// Also, keep in mind that escaped characters don't work in the interface (window titles, lower left corner of the main window, etc.)
		input = html_encode(input)
	else
		// If not need encode text, simply remove < and >
		// note: we can also remove here byond formatting codes: 0xFF + next byte
		input = replace_characters(input, list("<"=" ", ">"=" "))

	if(trim)
		input = trim(input)

	return input

//Run sanitize(), but remove <, >, " first to prevent displaying them as &gt; &lt; &34; in some places after html_encode().
//Best used for sanitize object names, window titles.
//If you have a problem with sanitize() in chat, when quotes and >, < are displayed as html entites -
//this is a problem of double-encode(when & becomes &amp;), use sanitize() with encode=0, but not the sanitize_safe()!
/proc/sanitize_safe(input, max_length = MAX_MESSAGE_LEN, encode = TRUE, trim = TRUE, extra = TRUE, ascii_only = FALSE)
	return sanitize(replace_characters(input, list(">"=" ","<"=" ", "\""="'")), max_length, encode, trim, extra, ascii_only)

//Filters out undesirable characters from character names
//todo: rewrite this
/proc/sanitize_name(input, max_length = MAX_NAME_LEN, allow_numbers = 0, force_first_letter_uppercase = TRUE)
	if(!input || length_char(input) > max_length)
		return //Rejects the input if it is null or if it is longer then the max length allowed

	var/number_of_alphanumeric	= 0
	var/last_char_group			= 0
	var/output = ""

	var/char = ""
	var/bytes_length = length(input)
	var/ascii_char
	for(var/i = 1, i <= bytes_length, i += length(char))
		char = input[i]

		ascii_char = text2ascii(char)

		switch(ascii_char) //todo: unicode names?
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
		output = copytext(output, 1, -1)	//removes the last character (in this case a space)

	if(lowertext(output) in forbidden_names)	//prevents these common metagamey names
		return

	return output

/proc/shelleo_url_scrub(url)
	var/static/regex/bad_chars_regex = regex(@"[^#%&./:=?\w]+", "g")
	var/scrubbed_url = ""
	var/bad_match = ""
	var/last_good = 1
	var/bad_chars = 1
	do
		bad_chars = bad_chars_regex.Find(url)
		scrubbed_url += copytext(url, last_good, bad_chars)
		if(bad_chars)
			bad_match = bad_chars_regex.match
			scrubbed_url += url_encode(bad_match)
			last_good = bad_chars + length(bad_match)
	while(bad_chars)
	. = scrubbed_url

/proc/input_default(text)
	return html_decode(text)

/*
 * Text searches
 */

//Checks the beginning of a string for a specified sub-string
//Returns the position of the substring or 0 if it was not found
/proc/dd_hasprefix(text, prefix)
	var/start = 1
	var/end = length(prefix) + 1
	return findtext(text, prefix, start, end)

//Checks the end of a string for a specified substring.
//Returns the position of the substring or 0 if it was not found
/proc/dd_hassuffix(text, suffix)
	var/start = length(text) - length(suffix)
	if(start)
		return findtext(text, suffix, start, null)
	return

/*
 * Text modification
 */

/proc/replace_characters(var/t,var/list/repl_chars)
	for(var/char in repl_chars)
		t = replacetext(t, char, repl_chars[char])
	return t

/proc/random_string(length, list/characters)
	. = ""
	for (var/i in 1 to length)
		. += pick(characters)

//Adds zeros ahead of the text 't' until length == u
/proc/add_zero(t, u)
	var/needs = u - length_char(t)
	while (needs-- > 0)
		t = "0[t]"
	return t

//Adds spaces ahead of the text 't' until length == u
/proc/add_lspace(t, u)
	var/needs = u - length_char(t)
	while(needs-- > 0)
		t = " [t]"
	return t

//Adds spaces behind the text 't' until length == u
/proc/add_tspace(t, u)
	var/needs = u - length_char(t)
	while(needs-- > 0)
		t = "[t] "
	return t

// Returns a string with reserved characters and spaces before the first letter removed
// not work for unicode spaces - you should cleanup them first with sanitize()
/proc/trim_left(text)
	for (var/i = 1 to length(text))
		if (text2ascii(text, i) > 32)
			return copytext(text, i)
	return ""

// Returns a string with reserved characters and spaces after the last letter removed
// not work for unicode spaces - you should cleanup them first with sanitize()
/proc/trim_right(text)
	for (var/i = length(text), i > 0, i--)
		if (text2ascii(text, i) > 32)
			return copytext(text, 1, i + 1)

	return ""

// Returns a string with reserved characters and spaces before the first word and after the last word removed.
// not work for unicode spaces - you should cleanup them first with sanitize()
/proc/trim(text)
	return trim_left(trim_right(text))

//Returns a string with the first element of the string capitalized.
/proc/capitalize(text)
	if(text)
		text = uppertext(text[1]) + copytext(text, 1 + length(text[1]))
	return text

//Returns a string with the first element of the every word of the string capitalized.
/proc/capitalize_words(text)
	var/list/S = splittext(text, " ")
	var/list/M = list()
	for (var/w in S)
		M += capitalize(w)
	return jointext(M, " ")

/proc/stip_non_ascii(text)
	var/static/regex/non_ascii_regex = regex(@"[^\x00-\x7F]+", "g")
	return non_ascii_regex.Replace(text, "")

//This proc strips html properly, remove < > and all text between
//for complete text sanitizing should be used sanitize()
/proc/strip_html_properly(input)
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

/proc/stringmerge_ascii(text,compare,replace = "*")
//This proc fills in all spaces with the "replace" var (* by default) with whatever
//is in the other string at the same spot (assuming it is not a replace char).
//This is used for fingerprints
//fingerprints has only ascii chars so this proc does not support unicode strings
	var/newtext = text
	if(length(text) != length(compare))
		return 0
	for(var/i = 1, i < length(text), i++)
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

/proc/stringpercent_ascii(text,character = "*")
//This proc returns the number of chars of the string that is the character
//This is used for detective work to determine fingerprint completion.
//fingerprints has only ascii chars so this proc does not support unicode strings
	if(!text || !character)
		return 0
	var/count = 0
	for(var/i = 1, i <= length(text), i++)
		var/a = copytext(text,i,i+1)
		if(a == character)
			count++
	return count

/proc/reverse_text(text = "")
	var/new_text = ""
	var/bytes_length = length(text)
	var/letter = ""
	for(var/i = 1, i <= bytes_length, i += length(letter))
		letter = text[i]
		new_text = letter + new_text
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

// Fix for pre-513 cyrillic text that Byond in 513 wrongly convert as 
// ISO-8859-5 -> utf-8 instead of Windows-1251 -> utf-8
// Byond choises first encoding based on server locale, this fix for ru_RU
// On you locale this fix may not work and you should change or 
// drop this proc completly if you not have any pre-513 cyrillics
// Does nothing with standart latin
// ...
// UPDATE: OK, actually I don't understand how it works and how BYOND chooses encoding to fuck us
/proc/fix_cyrillic(text)

	var/char = ""
	var/new_text = ""
	var/new_char
	var/bytes_length = length(text)
	var/ascii_char

	for(var/i = 1, i <= bytes_length, i += length(char))
		char = text[i]
		new_char = char
		ascii_char = text2ascii(char)

		/*switch(ascii_char)
			if(167)
				new_char = "э"
			if(1032)
				new_char = "Ё"
			if(1048)
				new_char = "ё"
			if(1046) // ¶ (Ж in ISO)
				new_char = "я"
			if(8470)
				new_char = "р"
			if(1056 to 1119)
				new_char = ascii2text(ascii_char - 16)*/
		
		// win1251 -> unicode
		if(ascii_char <= 255 && ascii_char >= 192)
			new_char = ascii2text(ascii_char + 848)
		if(ascii_char == 182)
			new_char = "я"

		new_text += new_char

	return new_text
