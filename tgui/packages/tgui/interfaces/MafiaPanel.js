import { classes } from 'common/react';
import { multiline } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Flex, NoticeBox, Section, Stack, TimeDisplay } from '../components';
import { Window } from '../layouts';

export const MafiaPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    actions,
    phase,
    roleinfo,
    role_theme,
    admin_controls,
  } = data;
  return (
    <Window
      title="Мафия"
      theme={role_theme}
      width={650}
      height={580}>
      <Window.Content>
        <Stack fill vertical>
          {!roleinfo && (
            <Stack.Item grow>
              <MafiaLobby />
            </Stack.Item>
          )}
          {!!roleinfo && (
            <Stack.Item>
              <MafiaRole />
            </Stack.Item>
          )}
          {actions?.map(action => (
            <Stack.Item key={action}>
              <Button
                onClick={() => act('mf_action', {
                  atype: action,
                })}>
                {action}
              </Button>
            </Stack.Item>
          ))}
          {!!roleinfo && (
            <Stack.Item>
              <MafiaJudgement />
            </Stack.Item>
          )}
          {phase !== "Нет Игры" && (
            <Stack.Item grow>
              <Stack fill>
                <Stack.Item grow={1.34} basis={0}>
                  <MafiaPlayers />
                </Stack.Item>
                <Stack.Item grow={1} basis={0}>
                  <Stack fill vertical>
                    <Stack.Item grow>
                      <MafiaListOfRoles />
                    </Stack.Item>
                    {!!roleinfo && (
                      <Stack.Item height="80px">
                        <Section fill scrollable>
                          {roleinfo.action_log?.map(line => (
                            <Box key={line}>{line}</Box>
                          ))}
                        </Section>
                      </Stack.Item>
                    )}
                  </Stack>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}
          {!!admin_controls && (
            <Stack.Item>
              <MafiaAdmin />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MafiaLobby = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobbydata,
    phase,
    timeleft,
  } = data;
  const readyGhosts = lobbydata ? lobbydata.filter(
    player => player.status === "Готов") : null;
  return (
    <Section
      fill
      scrollable
      title="Lobby"
      buttons={(
        <>
          Стадия = {phase}
          {' | '}
          <TimeDisplay auto="down" value={timeleft} />
          {' '}
          <Button
            icon="clipboard-check"
            tooltipPosition="bottom-start"
            tooltip={multiline`
            Регистрация в игру. Если она уже идёт, то
            Вы войдёте в следующую.
            `}
            content="Войти"
            onClick={() => act('mf_signup')} />
          <Button
            icon="eye"
            tooltipPosition="bottom-start"
            tooltip={multiline`
            Вы будете наблюдателем, пока не Выключите это.
            Автоматически включается, когда Вы умираете, чтобы увидеть результат игры.
            Сообщения не будут приходить, если Вы войдёте в раунд.
            `}
            content="Наблюдать"
            onClick={() => act('mf_spectate')} />
        </>
      )}>
      <NoticeBox info>
        В лобби {readyGhosts
          ? readyGhosts.length : "0"}/12 валидных игроков.
      </NoticeBox>
      {lobbydata?.map(lobbyist => (
        <Stack
          key={lobbyist}
          className="candystripe"
          p={1}
          align="baseline">
          <Stack.Item grow>
            {lobbyist.name}
          </Stack.Item>
          <Stack.Item>
            Статус:
          </Stack.Item>
          <Stack.Item
            color={lobbyist.status === 'Готов' ? 'green' : 'red'}>
            {lobbyist.spectating} {lobbyist.status}
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};

const MafiaRole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    phase,
    roleinfo,
    timeleft,
  } = data;
  return (
    <Section
      title={phase}
      minHeight="100px"
      maxHeight="50px"
      buttons={(
        <Box
          style={{
            'font-family': 'Consolas, monospace',
            'font-size': '14px',
            'line-height': 1.5,
            'font-weight': 'bold',
          }}>
          <TimeDisplay auto="down" value={timeleft} />
        </Box>
      )}>
      <Stack align="center">
        <Stack.Item grow textAlign="center">
          <Box bold>
            Вы - {roleinfo.role}
          </Box>
          <Box italic>
            {roleinfo.desc}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            className={classes([
              'mafia32x32',
              roleinfo.revealed_icon,
            ])}
            style={{
              'transform': 'scale(2) translate(0px, 10%)',
              'vertical-align': 'middle',
            }} />
          <Box
            className={classes([
              'mafia32x32',
              roleinfo.hud_icon,
            ])}
            style={{
              'transform': 'scale(2) translate(-5px, -5px)',
              'vertical-align': 'middle',
            }} />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const MafiaListOfRoles = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    all_roles,
  } = data;
  return (
    <Section
      fill
      scrollable
      title="Роли и Заметки"
      minHeight="120px"
      buttons={
        <>
          <Button
            color="transparent"
            icon="address-book"
            tooltipPosition="bottom-start"
            tooltip={multiline`
            Верхний раздел - это роли в игре. Вы можете нажать на знак вопроса,
            чтобы узнать информацию о роли.`}
          />
          <Button
            color="transparent"
            icon="edit"
            tooltipPosition="bottom-start"
            tooltip={multiline`
            Нижний раздел - ваши текущие заметки. На некоторых ролях он будет пустой,
            но на других туда будут записываться ваши действия(детективные расследования)`}
          />
        </>
      }>
      <Flex direction="column">
        {all_roles?.map(r => (
          <Flex.Item
            key={r}
            height="30px"
            className="Section__title candystripe">
            <Flex
              height="18px"
              align="center"
              justify="space-between">
              <Flex.Item>
                {r}
              </Flex.Item>
              <Flex.Item
                textAlign="right">
                <Button
                  color="transparent"
                  icon="question"
                  onClick={() => act('mf_lookup', {
                    atype: r.slice(0, -3),
                  })}
                />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaJudgement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    judgement_phase,
  } = data;
  return (
    <Section
      title="Суд"
      buttons={
        <Button
          color="transparent"
          icon="info"
          tooltipPosition="left"
          tooltip={multiline`
          Когда кого-то судят, вы решаете его судьбу.
          Победа НЕВИНОВЕН означает, что человек сможет увидеть ещё один день,
          но... в случае поражения этого уже не случится.
          Вы можете не голосовать, нажав на среднюю кнопку.
          `}
        />
      }>
      <Flex justify="space-around">
        <Button
          icon="smile-beam"
          content="НЕВИНОВЕН!"
          color="good"
          disabled={!judgement_phase}
          onClick={() => act('vote_innocent')} />
        {!judgement_phase && (
          <Box>
            В данный момент никто не судится.
          </Box>
        )}
        {!!judgement_phase && (
          <Box>
            Время голосования. Проголосуй или воздержись.
          </Box>
        )}
        <Button
          icon="angry"
          color="bad"
          disabled={!judgement_phase}
          onClick={() => act('vote_guilty')}>
          ВИНОВЕН!
        </Button>
      </Flex>
      <Flex justify="center">
        <Button
          icon="meh"
          color="white"
          disabled={!judgement_phase}
          onClick={() => act('vote_abstain')}>
          Воздержаться
        </Button>
      </Flex>
    </Section>
  );
};

const MafiaPlayers = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    players,
  } = data;
  return (
    <Section fill scrollable title="Играцфоки">
      <Flex direction="column">
        {players?.map(player => (
          <Flex.Item
            height="30px"
            className="Section__title candystripe"
            key={player.ref}>
            <Stack height="18px" align="center">
              <Stack.Item grow color={!player.alive && 'red'}>
                {player.name} {!player.alive && '(МЁРТВ)'}
              </Stack.Item>
              <Stack.Item shrink={0}>
                {player.votes !== undefined
                  && !!player.alive
                  && `Голоса: ${player.votes}`}
              </Stack.Item>
              <Stack.Item shrink={0} minWidth="42px" textAlign="center">
                {player.actions?.map(action => (
                  <Button
                    key={action}
                    onClick={() => act('mf_targ_action', {
                      atype: action,
                      target: player.ref,
                    })}>
                    {action}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
};

const MafiaAdmin = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Collapsible
      title="АДМИН ПАНЕЛЬ УПРАВЛЕНИЯ"
      color="red">
      <Section>
        <Collapsible
          title="Предупреждение от Кодеров!"
          color="transparent">
          Почти все это создано для того, чтобы помочь мне отладить
          игру (ой, отладка игры на 12 игроков!). Так что, оно все
          грубоватое и склонно ломаться по малейшему поводу.
          Убедитесь, что Вы знаете действие кнопки, когда жмёте на неё.
          Так же(один из администраторов это сделал), никого не гибайте и не удаляйте любыми способами!
          Это приведёт к рантайму, который сломает всю игру, которая сломает сервер!
        </Collapsible>
        <Button
          icon="arrow-right"
          onClick={() => act('next_phase')}>
          Следующая стадия
        </Button>
        <Button
          icon="home"
          onClick={() => act('players_home')}
          tooltip={multiline`
                    Надеюсь, Вы не будете нажимать эту кнопку очень часто,
                    это нужно на тот случай, если какой-то игрок
                    каким-то образом сбегает (nullspace, телепортации, открытая дверь).
                    В любом случае, ОЧЕНЬ ПЛОХО ЕСЛИ ЭТО ПРОИЗОЙДЕТ.
                    Используй это, чтобы игроков вернуть, а затем сообщи на гитхаб.`}>
          Отправить Всех Домой
        </Button>
        <Button
          icon="sync-alt"
          onClick={() => act('new_game')}
          tooltip={multiline`
                    Это незамедлительно завершает текущую игру и попытается начать новую`}>
          Новая Игра
        </Button>
        <Button
          icon="skull"
          onClick={() => act('nuke')}
          tooltip={multiline`
                    Удаляет датумы, очищает все landmarks, убивает всех жителей и мафию,
                    стирает место игры. Нажми это, если действительно всё поломано.
                    Ты ведь уже всё сломал, не так ли?`}>
          Nuke
        </Button>
        <br />
        <Button
          icon="paint-brush"
          onClick={() => act('debug_setup')}
          tooltip={multiline`
                    Это позволит создать свою настройку для игры, это так... просто.
                    Вы добавляете роль до тех пор, пока не нажмёте CANCEL или FINISH.
                    Сбрасывается после завершения раунда, возвращая случайные настройки.`}>
          Создать Свою Игру
        </Button>
        <Button
          icon="paint-roller"
          onClick={() => act('cancel_setup')}
          tooltip={multiline`
                    Если вы что-то напутали, то можете сюда нажать, чтобы сбросить свою настройку.
                    Игра автоматически сбрасывает её после каждой игры.`}>
          Сбросить Свою Игру
        </Button>
      </Section>
    </Collapsible>
  );
};