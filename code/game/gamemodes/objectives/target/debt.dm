/datum/objective/target/debt/format_explanation()
	to_chat(target.current, "<span class='notice'>Ты вспоминаешь, что [owner.current.real_name] перед тобой в долгу и сделает всё, что ты попросишь. Чтобы считать долг оплаченным, пожмите ПРАВУЮ РУКУ, СНЯВ ПЕРЧАТКИ.</span>")
	return "Ты в огромнейшем долгу перед [target.current.real_name], [target.assigned_role] и готов сделать всё, что угодно. Чтобы считать долг оплаченным, [target.current.real_name] нужно пожать твою ПРАВУЮ руку БЕЗ ПЕРЧАТОК."
