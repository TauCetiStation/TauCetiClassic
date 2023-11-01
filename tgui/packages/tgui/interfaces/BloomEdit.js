import { useBackend } from '../backend';

import { LabeledList, Section, Box, Button, NumberInput } from '../components';

import { Window } from '../layouts';

export const BloomEdit = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    glow_brightness_base,
    glow_brightness_power,
    glow_contrast_base,
    glow_contrast_power,
    exposure_brightness_base,
    exposure_brightness_power,
    exposure_contrast_base,
    exposure_contrast_power,
  } = data;

  return (
    <Window
      title="BloomEdit"
      width={500}
      height={500}>
      <Window.Content>
        <Section title="Bloom Edit">
          <LabeledList>
            <LabeledList.Item label="Lamp Brightness Base">
              <Box
                inline>
                Базовая яркость лампочки, независимо от света
              </Box>
              <NumberInput
                fluid
                value={glow_brightness_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('glow_brightness_base', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Lamp Brightness Power">
              <Box
                inline>
                Яркость лампочки на power света
              </Box>
              <NumberInput
                fluid
                value={glow_brightness_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('glow_brightness_power', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Lamp Contrast Base">
              <Box
                inline>
                Базовый контраст лампочки, независимо от света
              </Box>
              <NumberInput
                fluid
                value={glow_contrast_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('glow_contrast_base', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Lamp Contrast Power">
              <Box
                inline>
                Контраст лампочки на power света
              </Box>
              <NumberInput
                fluid
                value={glow_contrast_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('glow_contrast_power', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Brightness Base">
              <Box
                inline>
                Яркость свечения конуса
              </Box>
              <NumberInput
                fluid
                value={exposure_brightness_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('exposure_brightness_base', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Brightness Power">
              <Box
                inline>
                Яркость свечения конуса на power света
              </Box>
              <NumberInput
                fluid
                value={exposure_brightness_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('exposure_brightness_power', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Contrast Base">
              <Box
                inline>
                Контраст свечения конуса
              </Box>
              <NumberInput
                fluid
                value={exposure_contrast_base}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('exposure_contrast_base', {
                  value: value,
                })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Exposure Contrast Power">
              <Box
                inline>
                Контраст свечения конуса на power света
              </Box>
              <NumberInput
                fluid
                value={exposure_contrast_power}
                minValue={-10}
                maxValue={10}
                step={0.01}
                width="20px"
                onChange={(e, value) => act('exposure_contrast_power', {
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
