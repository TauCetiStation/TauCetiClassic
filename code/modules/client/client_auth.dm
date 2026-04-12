#define CLIENT_PASSWORD_VERSION 1
#define CLIENT_PASSWORD_KEY_FILE "keys/auth_key_md5_v1.key"

/client
	var/bad_password_attempts = 0

/client/proc/set_password()

	if(usr.client != src)
		return

	if(IsGuestKey(key))
		to_chat(src, "<span class='warning'>Нельзя установить пароль для гостевого аккаунта.</span>")
		return

	if(!hub_authenticated) // todo: allow password_authenticated, but request current password
		to_chat(src, "<span class='warning'>На данный момент мы не можем достоверно верифицировать аккаунт, чтобы позволить смену пароля.</span>")
		return

	if(!establish_db_connection("erro_password", "erro_auth_token") || !fexists(CLIENT_PASSWORD_KEY_FILE))
		return

	var/password = input("Введите пароль для вашего аккаунта.\nЭто позволит вам получить доступ к аккаунту в случае недоступности Byond хаба.\nМинимум 8 символов, используйте уникальные и сложные пароли!", "Set Password") as null|text

	password = copytext_char(trim(password), 1, 1024)

	if(!password || length(password) < 8 || length(replacetext(password, regex(@"[0-9]", "g"), "")) == 0)
		to_chat(src, "<span class='warning'>Ваш пароль слишком простой. Попробуйте еще раз.</span>")
		return

	// app side - pepper
	password = md5("[file2text(CLIENT_PASSWORD_KEY_FILE)][password]")

	var/account_ckey = ckey(ckey)

	// db side - unique salt
	var/DBQuery/query = dbcon.NewQuery({"INSERT INTO erro_password (ckey, hash, version)
		VALUES ('[account_ckey]', HEX(RANDOM_BYTES(32)), [CLIENT_PASSWORD_VERSION])
		ON DUPLICATE KEY UPDATE
		hash = VALUES(hash),
		version = VALUES(version);
	"})

	if(!query.Execute())
		return

	query = dbcon.NewQuery({"UPDATE erro_password
		SET password = SHA2(CONCAT('[password]', hash), 512)
		WHERE ckey = '[account_ckey]';
	"})

	if(!query.Execute())
		return

	log_access("Authorization: [ckey] has updated their password.")
	to_chat(src, "<span class='warning'>Ваш пароль успешно обновлен.</span>")

/client/proc/authenticate_with_password()

	if(usr.client != src)
		return

	if(!establish_db_connection("erro_password", "erro_auth_token") || !fexists(CLIENT_PASSWORD_KEY_FILE))
		return

	if(!IsGuestKey(key))
		to_chat(src, "<span class='warning'>Вы уже авторизованы.</span>")
		return

	var/account_ckey = ckey(input("Введите имя byond-аккаунта.", "Key") as null|text)

	if(!length(account_ckey))
		return

	var/password = input("Введите пароль для [account_ckey].", "Password") as null|text

	password = copytext_char(trim(password), 1, 1024)

	if(!password)
		return

	password = md5("[file2text(CLIENT_PASSWORD_KEY_FILE)][password]")

	var/DBQuery/query = dbcon.NewQuery({"SELECT 1
		FROM erro_password
		WHERE ckey = '[account_ckey]' AND password = SHA2(CONCAT('[password]', hash), 512)
		LIMIT 1;
	"})

	if(!query.Execute())
		return

	var/verified = FALSE
	if(query.RowCount())
		verified = TRUE

	if(verified)
		log_access("Authorization: [ckey] successful login attempt to [account_ckey] using a password.")

		// generate temporary access token
		query = dbcon.NewQuery({"INSERT INTO erro_auth_token (token, ckey, ip, computerid, expires_at)
			VALUES (
				HEX(RANDOM_BYTES(32)),
				'[account_ckey]',
				'[sanitize_sql(address)]',
				'[sanitize_sql(computer_id)]',
				DATE_ADD(NOW(), INTERVAL 7 DAY)
			)
			RETURNING token;
		"})

		if(!query.Execute() || !query.NextRow())
			return

		var/token = query.item[1]

		// give user new ckey after reconnect
		handle_storage_access_token(token)

	else
		log_access("Authorization: [ckey] failed login attempt to [account_ckey] using a password.")

		to_chat(src, "<span class='warning'>Юзер не найден, или не верный пароль.</span>")
		bad_password_attempts++
		if(bad_password_attempts >= 5)
			force_disconnect("Слишком много неудачных попыток, вы будете отключены от сервера.")

// verify token and return associated ckey
/client/proc/verify_access_token(token)

	if(!establish_db_connection("erro_password", "erro_auth_token"))
		return

	var/DBQuery/query = dbcon.NewQuery({"SELECT ckey
		FROM erro_auth_token
		WHERE
			token = '[sanitize_sql(token)]' AND
			ip = '[sanitize_sql(address)]' AND
			computerid = '[sanitize_sql(computer_id)]' AND
			expires_at > NOW()
		LIMIT 1;
	"})

	if(!query.Execute() || !query.NextRow())
		return FALSE

	var/new_key = query.item[1]

	return ckey(new_key)

/client/proc/invalidate_access_tokens(token)

	if(usr.client != src)
		return

	if(!establish_db_connection("erro_password", "erro_auth_token"))
		return

	var/DBQuery/query
	if(token)
		query = dbcon.NewQuery({"DELETE FROM erro_auth_token
			WHERE ckey = '[ckey(ckey)]' AND token = '[sanitize_sql(token)]';
		"})
	else
		query = dbcon.NewQuery({"DELETE FROM erro_auth_token
			WHERE ckey = '[ckey(ckey)]';
		"})

	return !!query.Execute()

/client/proc/handle_storage_access_token(new_token, remove_token = FALSE)

	if(!establish_db_connection("erro_password", "erro_auth_token"))
		return

	if(!IsGuestKey(key))
		return

	var/token_script

	if(remove_token)
		token_script = {"
			let token = null;
			window.domainStorage.removeItem('access_token');
		"}
	else
		if(new_token)
			token_script = {"
				let token = '[new_token]';
				window.domainStorage.setItem('access_token', token);
			"}
		else
			token_script = {"
				let token = window.domainStorage.getItem('access_token');
			"}

	src << browse({"
		<!DOCTYPE html>
			<head>
				<meta http-equiv='Content-type' content='text/html; charset=utf-8' />
				<script type='text/javascript'>
					window.addEventListener('DOMContentLoaded', () => {
						setTimeout(() => {
							BYOND.winget(null, 'url').then(address_object => {
								let address = address_object.url;
								[token_script]
								if(token) {
									let token_redirect = `byond://${address}?password_token=${token}`
									/*window.location = token_redirect*/
									document.body.innerHTML = `Авторизация в процессе, вы будете переподключены к серверу. Если этого не произошло, нажмите <a id='redirect_link' href='${token_redirect}'>сюда</a>.`;
									document.getElementById('redirect_link').click();
									window.location = 'byond://winset?command=.quit';
								} else {
									document.body.innerHTML = 'Нет данных для авторизации.';
								}
							});
						}, 1000);
					});
				</script>
			</head>
			<body style='text-align: center;'>
				Выполняется авторизация гостевого аккаунта.
			</body>
		</html>
		"}, "window=storage_access_token;border=0;titlebar=0;size=500x100")

#undef CLIENT_PASSWORD_VERSION
#undef CLIENT_PASSWORD_KEY_FILE
