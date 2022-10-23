import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Collapsible, Dropdown, Flex, Input, NoticeBox, Section, LabeledList, AnimatedNumber } from '../components';
import { Window } from "../layouts";
import { MiningUser } from './common/Mining';

export const MiningOreProcessingConsole = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    unclaimedPoints,
    ores,
    showAllOres,
    power,
    speed,
    ore_values,
  } = data;

  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <MiningUser insertIdText={(
          <Box>
            <Button
              icon="arrow-right"
              mr={1}
              onClick={() => act("insert")}>
              Insert ID
            </Button>
            in order to claim points.
          </Box>
        )} />
        <Section title="Status" buttons={
          <Button
            icon="power-off"
            selected={power}
            onClick={() => act("power")}>
            {power ? "Processing" : "Disabled"}
          </Button>
        }>
          <LabeledList>
            <LabeledList.Item label="Current unclaimed points" buttons={
              <Button
                disabled={unclaimedPoints < 1}
                icon="download"
                onClick={() => act("claim")}>
                Claim
              </Button>
            }>
              <AnimatedNumber value={unclaimedPoints} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <MOPCOres />
      </Window.Content>
    </Window>
  );
};

// ORDER IS IMPORTANT HERE.
const processingOptions = [
  "Not Processing",
  "Smelting",
  "Compressing",
  "Alloying",
];

// Higher in the list == closer to top
// This is just kind of an arbitrary list to sort by because
// the machine has no predictable ore order in it's list
// and alphabetizing them doesn't really make sense
const oreOrder = [
  "glass",
  "iron",
  "coal",
  "steel",
  "hydrogen",
  "uranium",
  "phoron",
  "phoron glass",
  "silver",
  "gold",
  "platinum",
  "plasteel",
  "diamond",
];

const MOPCOres = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ores,
    showAllOres,
    ore_values,
  } = data;
  return (
    <Section title="Ore Processing Controls" buttons={
      <Button
        icon={showAllOres ? "toggle-on" : "toggle-off"}
        selected={showAllOres}
        onClick={() => act("showAllOres")}>
        {showAllOres ? "All Ores" : "Ores in Machine"}
      </Button>
    }>
      <LabeledList>
        {ores.length && ores.sort().map(ore => (
          <LabeledList.Item key={ore.ore} label={toTitleCase(ore.ore)} buttons={
            <Dropdown
              width="120px"
              color={
                ore.processing === 0 && 'red'
                || ore.processing === 1 && 'green'
                || ore.processing === 2 && 'blue'
                || ore.processing === 3 && 'yellow'
              }
              options={processingOptions}
              selected={processingOptions[ore.processing]}
              onSelected={val => act("toggleSmelting", {
                ore: ore.ore,
                set: processingOptions.indexOf(val),
              })} />
          }>
            <Box inline>
              <AnimatedNumber value={ore.amount} />
            </Box>
          </LabeledList.Item>
        )) || (
          <Box color="bad" textAlign="center">
            No ores in machine.
          </Box>
        )}
      </LabeledList>
      <Section>
        <LabeledList>
          <Collapsible title="Mineral Value List" >
            {ore_values.length && ore_values.sort().map(item => (
              <LabeledList.Item key={item.name} label={toTitleCase(item.name)} >
                {item.amount} points
              </LabeledList.Item>
            ))}
          </Collapsible>
        </LabeledList>
      </Section>
    </Section>
  );
};
