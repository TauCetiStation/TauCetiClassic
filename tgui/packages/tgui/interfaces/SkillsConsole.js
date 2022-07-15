import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar, Box } from '../components';
import { Window } from '../layouts';

export const SkillsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const { IQ, MDI } = { IQ: 135, MDI: 15 }; //MDI from 0 to 20
  const skill_list = ['Engineering', 'Chemistry', 'Surgery'];
  const cartridge_unpacked = false;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Power info">
          <LabeledList>
            <LabeledList.Item label="Active power usage">
              4000 kW
            </LabeledList.Item>
            <LabeledList.Item label="Available power in area">
              <ProgressBar
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
                value={0.35}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Patient status">
          <LabeledList>
            <LabeledList.Item label="IQ">{IQ}</LabeledList.Item>
            <LabeledList.Item label="MDI">{MDI}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Cartridge information">
          <LabeledList>
            <LabeledList.Item label="Installed cartridge">
              USP-7 cartridge
            </LabeledList.Item>
            <LabeledList.Item label="Compatible species">
              Human, Tajaran, Unathi
            </LabeledList.Item>
            <LabeledList.Item label="Available USP">7</LabeledList.Item>
          </LabeledList>
        </Section>
        {!cartridge_unpacked && (
          <Box textAlign="center">
            <Button
              fluid
              color="danger"
              tooltip="This action will destroy the cartridge and begin the CMF manipulation procedure.">
              Unpack cartridge
            </Button>
          </Box>
        )}

        {cartridge_unpacked && <Section title="CMF manipulation"></Section>}
      </Window.Content>
    </Window>
  );
};
