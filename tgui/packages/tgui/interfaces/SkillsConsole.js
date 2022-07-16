import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  ProgressBar,
  Box,
  Stack,
  Slider,
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
    skill_values,
    compatible_species,
    inserted_cartridge,
    cartridge_name,
    cartridge_unpacked,
    connected_table,
    cartridge_points,
    connected_patient,
  } = data;
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

        <Stack>
          <Stack.Item>
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
          <Stack.Item>
            <Section title="Cartridge information">
              {!inserted_cartridge && <Box>No cartridge inserted</Box>}
              {inserted_cartridge === 1 && (
                <LabeledList>
                  <LabeledList.Item label="Installed cartridge">
                    {cartridge_name}
                    {!cartridge_unpacked && (
                      <Box as="span" m={5}>
                        <Button
                          onClick={() => {
                            act('eject');
                          }}
                          style={{ marginLeft: 20 }}>
                          Eject cartridge
                        </Button>
                      </Box>
                    )}
                  </LabeledList.Item>
                  <LabeledList.Item label="Compatible species">
                    {compatible_species.join(', ')}
                  </LabeledList.Item>
                  <LabeledList.Item label="Available USP">
                    {cartridge_points}
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>
          </Stack.Item>
        </Stack>

        {!cartridge_unpacked === true && inserted_cartridge && (
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

        {cartridge_unpacked === 1 && (
          <Box>
            <Section title="CMF manipulation">
            {skill_list.map((skill, v) => {
              return (
                <Slider key={skill}
                  onChange={(_e, value) => {
                    act('change_skill', value);
                  }}
                  step={1}
                  value={skill_values[v]}
                  maxValue={skill_max_value}
                  minValue={skill_min_value}>
                  {skill}
                </Slider>
              );
            })}
              <Box textAlign="center">
                <Button
                  onClick={() => {
                    act('inject');
                  }}
                  fluid
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
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
