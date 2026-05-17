import { useBackend } from '../backend';

import {
  Section,
  NoticeBox,
  LabeledList,
  Box,
  Button,
  Flex,
} from '../components';

import { Window } from '../layouts';

export const ProfileSettings = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    key,
    guest,
    password_authenticated,
    hub_authenticated,
    guest_lobby_warning,
  } = data;

  return (
    <Window title="Profile Settings" width={500} height={300}>
      <Window.Content>
        <Section
          title={`Добро пожаловать, ${key}`}
          buttons={
            <>
              {!!guest && (
                <Button
                  icon="right-to-bracket"
                  content="Войти"
                  onClick={() => act('login')}
                />
              )}
              {!!password_authenticated && (
                <Button
                  icon="right-from-bracket"
                  content="Выйти"
                  onClick={() =>
                    act('logout', {
                      token: window.domainStorage.getItem('access_token'),
                    })
                  }
                />
              )}
            </>
          }>
          {guest ? (
            <>
              <NoticeBox warning>
                Вы не верифицированы. Ввойдите в свой аккаунт в Byond Pager, или
                авторизуйтесь через серверный пароль.
              </NoticeBox>
              {!!guest_lobby_warning && (
                <NoticeBox danger>
                  Игра для гостевых аккаунтов ограничена, вам доступно только
                  лобби.
                </NoticeBox>
              )}
            </>
          ) : (
            <>
              {!!hub_authenticated && (
                <NoticeBox success>
                  Вы верифицированы через Byond Hub.
                </NoticeBox>
              )}
              {!!password_authenticated && (
                <NoticeBox success>
                  Вы верифицированы через серверный пароль.
                </NoticeBox>
              )}
              <p>
                Установите пароль, чтобы иметь доступ к своему аккаунту на
                сервере, даже если Byond Hub недоступен.
              </p>
              <p>
                Если Byond Hub не работает, подключитесь к серверу без входа в
                BYOND (в режиме гостевого аккаунта) и введите свой серверный
                пароль.
              </p>
              <Button
                fluid
                align="center"
                onClick={() => act('changepassword')}>
                Установить пароль
              </Button>
            </>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
