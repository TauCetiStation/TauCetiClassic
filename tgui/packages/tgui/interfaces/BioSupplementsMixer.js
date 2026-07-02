import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

const RPM_LEVELS = [
  { key: 250, label: 'Low' },
  { key: 500, label: 'Med' },
  { key: 1000, label: 'High' },
];

const COOLANT_LEVELS = [
  { key: 0, label: 'Off' },
  { key: 2, label: 'Low' },
  { key: 5, label: 'Med' },
  { key: 10, label: 'High' },
];

export const BioSupplementsMixer = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    fuel_loaded,
    fuel_amount,
    fuel_max,
    nutriment_loaded,
    nutriment_amount,
    nutriment_max,
    blood_loaded,
    blood_amount,
    blood_max,
    phoron_ok,
    phoron_temp,
    phoron_efficiency,
    bio_amount,
    bio_max,
    working,
    cartridge_loaded,
    cartridge_name,
    cartridge_volume,
    cartridge_max_volume,
    mixer_temperature,
    mixer_seal_integrity,
    mixer_rpm,
    mixer_rpm_target,
    coolant_usage_rate,
    unused_coolant_abs,
    unused_coolant_per,
    coolant_purity,
  } = data;

  const beakers_ok = fuel_loaded && nutriment_loaded && blood_loaded;
  const tempColor =
    mixer_temperature < 100 ? 'good' : mixer_temperature < 400 ? 'average' : 'bad';
  const sealColor =
    mixer_seal_integrity > 50 ? 'good' : mixer_seal_integrity > 20 ? 'average' : 'bad';

  return (
    <Window width={500} height={640}>
      <Window.Content scrollable>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <Box color={tempColor}>{mixer_temperature} K</Box>
            </LabeledList.Item>
            <LabeledList.Item label="RPM">
              <ProgressBar maxValue={1000} value={mixer_rpm}>
                {mixer_rpm} / {mixer_rpm_target}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Seal">
              <ProgressBar
                maxValue={100}
                value={mixer_seal_integrity}
                color={sealColor}
              >
                {mixer_seal_integrity}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="RPM Set">
              {RPM_LEVELS.map((lvl) => (
                <Button
                  key={lvl.key}
                  icon="cog"
                  selected={mixer_rpm_target === lvl.key}
                  onClick={() => act('rpm', { target: lvl.key })}
                >
                  {lvl.label}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Coolant">
          <LabeledList>
            <LabeledList.Item label="Level">
              <ProgressBar maxValue={100} value={unused_coolant_per} mr={1}>
                {unused_coolant_abs} u
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Purity">
              <Box inline>{coolant_purity}%</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Flow">
              {COOLANT_LEVELS.map((lvl) => (
                <Button
                  key={lvl.key}
                  icon="tint"
                  selected={coolant_usage_rate === lvl.key}
                  onClick={() => act('coolant_level', { level: lvl.key })}
                >
                  {lvl.label}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Ingredients">
          <LabeledList>
            <LabeledList.Item label="Phoron">
              {phoron_temp <= 0 ? (
                <Box color="bad">Not connected</Box>
              ) : (
                <Box>
                  {phoron_temp} K — {phoron_efficiency}% efficiency
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Fuel">
              {fuel_loaded ? (
                <Box>
                  <ProgressBar maxValue={fuel_max} value={fuel_amount} mr={1}>
                    {fuel_amount}/{fuel_max} u
                  </ProgressBar>
                  <Button icon="eject" onClick={() => act('eject_fuel')} />
                </Box>
              ) : (
                <Box color="average">Empty</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Nutriment">
              {nutriment_loaded ? (
                <Box>
                  <ProgressBar maxValue={nutriment_max} value={nutriment_amount} mr={1}>
                    {nutriment_amount}/{nutriment_max} u
                  </ProgressBar>
                  <Button icon="eject" onClick={() => act('eject_nutriment')} />
                </Box>
              ) : (
                <Box color="average">Empty</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Organic Liquid">
              {blood_loaded ? (
                <Box>
                  <ProgressBar maxValue={blood_max} value={blood_amount} mr={1}>
                    {blood_amount}/{blood_max} u
                  </ProgressBar>
                  <Button icon="eject" onClick={() => act('eject_blood')} />
                </Box>
              ) : (
                <Box color="average">Empty</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Production">
          <LabeledList>
            <LabeledList.Item label="Bio-BADs">
              <ProgressBar maxValue={bio_max} value={bio_amount}>
                {bio_amount}/{bio_max} u
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
          {working ? (
            <Button
              icon="stop"
              color="bad"
              content="Stop"
              mt={1}
              onClick={() => act('stop')}
            />
          ) : (
            <Button
              icon="play"
              color="good"
              content="Start"
              disabled={!beakers_ok || !phoron_ok}
              mt={1}
              onClick={() => act('produce')}
            />
          )}
          <Button
            icon="fill-drip"
            content="Dispense"
            disabled={!bio_amount || !cartridge_loaded}
            ml={1}
            mt={1}
            onClick={() => act('dispense')}
          />
          {!!cartridge_loaded && (
            <Box mt={1}>
              {cartridge_name}: {cartridge_volume}/{cartridge_max_volume}u{' '}
              <Button icon="eject" onClick={() => act('eject_cartridge')} />
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
