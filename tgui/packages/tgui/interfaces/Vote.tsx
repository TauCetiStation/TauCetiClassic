import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { sanitizeText } from '../sanitize';
import {
  Box,
  Button,
  Section,
  Stack,
  NoticeBox,
  Divider,
  Modal,
  Icon,
} from '../components';
import { Window } from '../layouts';

type Poll = {
  name: string;
  type: string;
  canStart: BooleanLike;
  forceBlocked: BooleanLike;
  adminOnly: BooleanLike;
  message: string;
};

type Choice = {
  name: string;
  ref: string;
  votes: number;
  selected: BooleanLike;
};

type ActivePoll = {
  poll: Poll;
  question?: string;
  description?: string;
  showWarning: BooleanLike;
  timeRemaining: number;
  choices: Choice[];
  canVoteMultiple: BooleanLike;
  canRevote: BooleanLike;
  canUnvote: BooleanLike;
  minimumWinPercentage: number;
};

type Data = {
  isAdmin: BooleanLike;
  currentPoll?: ActivePoll;
  polls: Poll[];
};

export const Vote = (_, context) => {
  const { data } = useBackend<Data>(context);
  const { isAdmin, currentPoll, polls } = data;

  const height = Math.min(
    730,
    90
    + (!currentPoll || isAdmin ? 45 + 26 * polls.filter(poll => (!poll.adminOnly || !!isAdmin)).length : 0)
    + (currentPoll ? 135 + 22 * currentPoll.choices.length : 23)
  );

  return (
    <Window width={450} height={height}>
      <Window.Content>
        <VoteInfoModal />
        <Stack fill vertical>
          <Choices />
          {(!currentPoll || !!isAdmin) && <ListPolls />}
          {!!currentPoll && <Timer />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const VoteInfoModal = (_, context) => {
  const { data } = useBackend<Data>(context);
  const { currentPoll } = data;
  const [infoModalOpen, setinfoModalOpen] = useLocalState<boolean>(
    context,
    'infoModalOpen',
    false
  );

  if (!infoModalOpen) return null;

  if (!currentPoll) {
    setinfoModalOpen(false);
    return null;
  }

  return (
    <Modal>
      Вы можете проголосовать{' '}
      <Box inline bold>
        {currentPoll.canVoteMultiple
          ? 'за несколько вариантов'
          : 'только за один вариант'}
      </Box>
      <br />
      Вы{' '}
      <Box inline bold>
        {currentPoll.canRevote ? 'можете изменить' : 'не можете изменить'}
      </Box>{' '}
      свой голос
      <br />
      Вы{' '}
      <Box inline bold>
        {currentPoll.canUnvote ? 'можете отменить' : 'не можете отменить'}
      </Box>{' '}
      свой голос
      <br />
      {currentPoll.minimumWinPercentage ? (
        <>
          Необходимо набрать минимум{' '}
          <Box inline bold>
            {currentPoll.minimumWinPercentage * 100}%
          </Box>
          , чтобы вариант победил
        </>
      ) : (
        ''
      )}
      {currentPoll.description && (
        <>
          <hr />
          <Box dangerouslySetInnerHTML={{ __html: sanitizeText(currentPoll.description) }} />
        </>
      )}
      <hr />
      <Button fluid align="center" onClick={() => setinfoModalOpen(false)}>
        Закрыть
      </Button>
    </Modal>
  );
};

const Choices = (_, context) => {
  const { act, data } = useBackend<Data>(context);
  const { currentPoll } = data;
  const [infoModalOpen, setInfoModalOpen] = useLocalState<boolean>(
    context,
    'infoModalOpen',
    false
  );

  let anyChoiceMade = currentPoll?.choices.some((choice) => choice.selected);

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable={!!currentPoll && currentPoll.choices.length !== 0}
        title={
          currentPoll ? `Голосование: ${currentPoll.poll.name}` : 'Голосование'
        }
        buttons={
          currentPoll ? (
            <Button
              icon="info"
              color="transparent"
              disabled={!currentPoll}
              onClick={() => setInfoModalOpen(true)}
            />
          ) : undefined
        }>
        {!!currentPoll && currentPoll.choices.length !== 0 ? (
          <>
            {!currentPoll.showWarning ? (
              ''
            ) : (
              <NoticeBox>{currentPoll.poll.message}</NoticeBox>
            )}
            {!!currentPoll.question && (
              <Box italic>{currentPoll.question}</Box>
            )}
            <Divider />
            <Stack vertical>
              <Stack fill justify="space-around">
                <Box bold>Варианты</Box>
                <Box bold>Голоса</Box>
              </Stack>
              <br />
              {currentPoll.choices.map(choice => (
                <Stack key={choice.ref} justify="space-between">
                  <Box height="22px">
                    <Button
                      maxWidth="260px"
                      ellipsis
                      disabled={!currentPoll.canRevote && anyChoiceMade}
                      selected={choice.selected}
                      onClick={() =>
                        act('putVote', {
                          choiceRef: choice.ref,
                        })}>
                      {choice.name.replace(/^\w/, (c) => c.toUpperCase())}
                    </Button>
                    {!!choice.selected && (
                      <Icon name="vote-yea" color="green" ml={1} verticalAlign="super" />
                    )}
                  </Box>
                  <Box mr={15}>{choice.votes}</Box>
                </Stack>
              ))}
            </Stack>
          </>
        ) : (
          <NoticeBox info mb="0">
            {!currentPoll
              ? 'Нет активного голосования!'
              : 'Нет доступных вариантов!'}
          </NoticeBox>
        )}
      </Section>
    </Stack.Item>
  );
};

const ListPolls = (_, context) => {
  const { act, data } = useBackend<Data>(context);
  const { isAdmin, polls } = data;

  return (
    <Stack.Item>
      <Section title="Начать голосование">
        <Stack vertical justify="space-between">
          {polls ? (
            polls.map(poll => (!poll.adminOnly || !!isAdmin) && (
              <Stack.Item key={poll.name}>
                <Stack horizontal>
                  {!!isAdmin && (
                    <Stack.Item>
                      <Button
                        width={9.5}
                        textAlign="center"
                        onClick={() =>
                          act('toggleAdminOnly', {
                            pollRef: poll.type,
                          })}>
                        {poll.adminOnly ? 'Только админы' : 'Разрешено всем'}
                      </Button>
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Button
                      disabled={
                        (!poll.canStart && !isAdmin) || poll.forceBlocked
                      }
                      color={
                        !isAdmin
                          ? undefined
                          : !poll.canStart
                            ? 'red'
                            : undefined
                      }
                      tooltip={poll.message}
                      content={poll.name}
                      onClick={() =>
                        act('callVote', {
                          pollRef: poll.type,
                        })} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))
          ) : (
            <NoticeBox info>Нет доступных голосований!</NoticeBox>
          )}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const Timer = (_, context) => {
  const { act, data } = useBackend<Data>(context);
  const { currentPoll, isAdmin } = data;

  return (
    <Stack.Item>
      <Section>
        <Stack justify="space-between">
          <Box fontSize={1.5}>
            Осталось времени: {currentPoll?.timeRemaining || 0}с
          </Box>
          {!!isAdmin && !!currentPoll && (
            <Button
              color="red"
              disabled={!isAdmin}
              onClick={() => act('cancelVote')}>
              Отменить голосование
            </Button>
          )}
        </Stack>
      </Section>
    </Stack.Item>
  );
};
