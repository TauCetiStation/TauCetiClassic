import { useBackend } from '../backend';

import { LabeledList, Section, Box, Button, NumberInput } from '../components';

import { Window } from '../layouts';

export const BloomEdit = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    glow_base,
    glow_power,
    exposure_base,
    exposure_power,
  } = data;

  return (
    <Window
      title="BloomEdit"
      width={500}
      height={500}>
      <Window.Content>
        <Section title="Bloom Edit">
          <LabeledList>
            <LabeledList.Item label="Glow Base">
              <Box
                inline>
                Базовое свечение лампочки, не зависимо от света
              </Box>
              <NumberInput
                fluid
                value={glow_base}
                minValue={-5}
                maxValue={5}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('glow_base', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Glow Power">
              <Box
                inline>
                Сила свечения лампочки на power света
              </Box>
              <NumberInput
                fluid
                value={glow_power}
                minValue={-5}
                maxValue={5}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('glow_power', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Base">
              <Box
                inline>
                Сила свечения конуса
              </Box>
              <NumberInput
                fluid
                value={exposure_base}
                minValue={-5}
                maxValue={5}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('exposure_base', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Power">
              <Box
                inline>
                Сила свечения конуса на power света
              </Box>
              <NumberInput
                fluid
                value={exposure_power}
                minValue={-5}
                maxValue={5}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('exposure_power', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item>
              <Button
                content="Перезагрузить лампы с новыми параметрами"
                onClick={() => act('update_lamps')} />
              <Button
                content="Сбросить по умолчанию"
                onClick={() => act('default')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
