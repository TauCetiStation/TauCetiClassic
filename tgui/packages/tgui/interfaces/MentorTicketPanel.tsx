/* eslint react/no-danger: "off" */
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const State = {
  'open': 'Open',
  'resolved': 'Resolved',
  'unknown': 'Unknown',
};

type Data = {
  id: number;
  title: string;
  name: string;
  state: string;
  opened_at: number;
  closed_at: number;
  opened_at_date: string;
  closed_at_date: string;
  actions: string;
  log: string[];
};

export const MentorTicketPanel = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    id,
    title,
    name,
    state,
    opened_at,
    closed_at,
    opened_at_date,
    closed_at_date,
    actions,
    log,
  } = data;
  return (
    <Window width={900} height={600}>
      <Window.Content scrollable>
        <Section
          title={'Ticket #' + id}
          buttons={
            <Box nowrap>
              <Button
                icon="arrow-up"
                content="Escalate"
                onClick={() => act('escalate')}
              />{' '}
              <Button content="Legacy UI" onClick={() => act('legacy')} />
            </Box>
          }>
          <LabeledList>
            <LabeledList.Item label="Mentor Help Ticket">
              #{id}: <div dangerouslySetInnerHTML={{ __html: name }} />
            </LabeledList.Item>
            <LabeledList.Item label="State">{State[state]}</LabeledList.Item>
            {State[state] === State.open ? (
              <LabeledList.Item label="Opened At">
                {opened_at_date} ({Math.round((opened_at / 600) * 10) / 10}{' '}
                minutes ago.)
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Closed At">
                {closed_at_date} ({Math.round((closed_at / 600) * 10) / 10}{' '}
                minutes ago.){' '}
                <Button content="Reopen" onClick={() => act('reopen')} />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Actions">
              <div dangerouslySetInnerHTML={{ __html: actions }} />
            </LabeledList.Item>
            <LabeledList.Item label="Log">
              {Object.keys(log).map((L) => (
                <div dangerouslySetInnerHTML={{ __html: log[L] }} />
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
