import { useBackend } from '../backend';
import { Box, Button, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

type Interaction = {
  key: string;
  name: string;
  desc: string;
  contact: boolean;
};

type InteractionState = {
  available: boolean;
  reason?: string;
};

type Data = {
  targetName?: string;
  interactions: Interaction[];
  states: Record<string, InteractionState>;
};

const COLUMNS = 2;

const chunk = <T,>(items: T[], size: number): T[][] => {
  const rows: T[][] = [];
  for (let i = 0; i < items.length; i += size) {
    rows.push(items.slice(i, i + size));
  }
  return rows;
};

const GestureGrid = (props: {
  items: Interaction[];
  states: Record<string, InteractionState>;
  onPick: (key: string) => void;
}) => {
  const { items, states, onPick } = props;
  return (
    <Stack vertical>
      {chunk(items, COLUMNS).map((row, index) => (
        <Stack.Item key={index}>
          <Stack>
            {row.map((interaction) => {
              const state = states[interaction.key];
              const available = !!state?.available;
              return (
                <Stack.Item grow basis={0} key={interaction.key}>
                  <Button
                    fluid
                    textAlign="center"
                    content={interaction.name}
                    disabled={!available}
                    tooltip={available ? interaction.desc : state?.reason}
                    tooltipPosition="bottom"
                    onClick={() => onPick(interaction.key)}
                  />
                </Stack.Item>
              );
            })}
            {row.length < COLUMNS && <Stack.Item grow basis={0} />}
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const InteractionPanel = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { targetName, interactions = [], states = {} } = data;

  if (!targetName) {
    return (
      <Window width={340} height={460}>
        <Window.Content>
          <NoticeBox>Не с кем взаимодействовать.</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  const byName = (a: Interaction, b: Interaction) =>
    a.name.localeCompare(b.name);
  const contact = interactions.filter((i) => i.contact).sort(byName);
  const distant = interactions.filter((i) => !i.contact).sort(byName);
  const onPick = (key: string) => act('interact', { key });

  return (
    <Window width={340} height={460}>
      <Window.Content scrollable>
        <Section>
          <Box color="label" fontSize="0.85em">
            Взаимодействие с
          </Box>
          <Box fontSize="1.4em" bold>
            {targetName}
          </Box>
        </Section>
        {!!contact.length && (
          <Section title="Рядом">
            <GestureGrid items={contact} states={states} onPick={onPick} />
          </Section>
        )}
        {!!distant.length && (
          <Section title="На расстоянии">
            <GestureGrid items={distant} states={states} onPick={onPick} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
