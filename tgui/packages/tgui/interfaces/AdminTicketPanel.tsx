/* eslint react/no-danger: "off" */
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const State = {
  open: 'Open',
  resolved: 'Resolved',
  closed: 'Closed',
  unknown: 'Unknown',
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

export const AdminTicketPanel = (props, context) => {
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
              <Button icon="pen" onClick={() => act('retitle')}>
                Rename Ticket
              </Button>
              <Button onClick={() => act('legacy')}>Legacy UI</Button>
            </Box>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Admin Help Ticket">
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
                <Button onClick={() => act('reopen')}>Reopen</Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Actions">
              {actions}
            </LabeledList.Item>
            <LabeledList.Item label="Log">
              {Object.keys(log).map((L, i) => (
                log[L]
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
