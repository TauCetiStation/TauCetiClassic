import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  ProgressBar,
  Box,
  Stack,
  Slider,
  Flex,
} from '../components';
import { Window } from '../layouts';

export const SkillsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    skill_list,
    IQ,
    MDI,
    skill_min_value,
    skill_max_value,
    compatible_species,
    inserted_cartridge,
    cartridge_name,
    cartridge_unpacked,
    connected_table,
    cartridge_points,
    connected_patient,
    free_points,
    can_inject,
    power_usage,
    power_max,
    power_current,
  } = data;
  return (
    <Window resizable width={600} height={675}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Power info">
              <LabeledList>
                <LabeledList.Item label="Active power usage">
                  {power_usage / 1000} kW
                </LabeledList.Item>
                <LabeledList.Item label="Available power in area">
                  <ProgressBar
                    ranges={{
                      good: [0.5, Infinity],
                      average: [0.25, 0.5],
                      bad: [-Infinity, 0.25],
                    }}
                    value={
                      power_max !== 'No data'
                        ? power_current / power_max
                        : 'No data'
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Stack>
              <Stack.Item width="40%" mr={1}>
                <Section title="Patient status">
                  <LabeledList>
                    {!connected_table && (
                      <Box>CMF manipulion table is not connected</Box>
                    )}
                    {!connected_patient && <Box>No patient detected</Box>}
                    {connected_table && connected_patient && (
                      <>
                        <LabeledList.Item label="IQ">{IQ}</LabeledList.Item>
                        <LabeledList.Item label="MDI">{MDI}</LabeledList.Item>
                      </>
                    )}
                  </LabeledList>
                </Section>
              </Stack.Item>
              <Stack.Item width="60%">
                <Section title="Cartridge information">
                  {!inserted_cartridge && <Box>No cartridge inserted</Box>}
                  {inserted_cartridge === 1 && (
                    <LabeledList>
                      <LabeledList.Item label="Installed cartridge">
                        {cartridge_name}
                        {!cartridge_unpacked && (
                          <Box as="span" m={5}>
                            <Button
                              icon="eject"
                              content="Eject cartridge"
                              onClick={() => {
                                act('eject');
                              }}
                              style={{ marginLeft: 20 }}
                            />
                          </Box>
                        )}
                      </LabeledList.Item>
                      <LabeledList.Item label="Compatible species">
                        {compatible_species.join(', ')}
                      </LabeledList.Item>
                      <LabeledList.Item label="Available USP">
                        {cartridge_unpacked === 0 && cartridge_points}
                        {cartridge_unpacked === 1 && free_points}
                      </LabeledList.Item>
                    </LabeledList>
                  )}
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {cartridge_unpacked === 0 && inserted_cartridge === 1 && (
            <Box textAlign="center">
              <Button
                onClick={() => {
                  act('unpack');
                }}
                fluid
                color="danger"
                tooltip="This action will destroy the cartridge and begin the CMF manipulation procedure.">
                Unpack cartridge
              </Button>
            </Box>
          )}
          {cartridge_unpacked === 1 && inserted_cartridge === 1 && (
            <Stack.Item>
              <Section title="CMF manipulation">
                {Object.keys(skill_list).map((skill) => {
                  return (
                    <LabeledList.Item label={skill} key={skill}>
                      <Flex inline width="100%">
                        <Flex.Item grow={1} mx={1}>
                          <Slider
                            onChange={(_e, value) => {
                              skill_list[skill] = value;

                              act('change_skill', skill_list);
                            }}
                            step={1}
                            value={skill_list[skill]}
                            maxValue={skill_max_value}
                            stepPixelSize={50}
                            minValue={skill_min_value}
                          />
                        </Flex.Item>
                      </Flex>
                    </LabeledList.Item>
                  );
                })}
                <Box textAlign="center">
                  <Button
                    onClick={() => {
                      act('inject');
                    }}
                    fluid
                    disabled={can_inject === 0}
                    color="green">
                    Inject implant
                  </Button>
                  <Button.Confirm
                    onClick={() => {
                      act('abort');
                    }}
                    fluid
                    color="danger"
                    confirmContent="Confirm ">
                    Abort
                  </Button.Confirm>
                </Box>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
