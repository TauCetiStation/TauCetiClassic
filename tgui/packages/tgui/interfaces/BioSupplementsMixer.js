import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const BioSupplementsMixer = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    fuel_loaded,
    fuel_amount,
    fuel_max,
    nutriment_loaded,
    nutriment_amount,
    nutriment_max,
    radium_loaded,
    radium_amount,
    radium_max,
    phoron_ok,
    bio_amount,
    bio_max,
    working,
    cartridge_loaded,
    cartridge_name,
    cartridge_volume,
    cartridge_max_volume,
  } = data;

  const beakers_ok = fuel_loaded && nutriment_loaded && radium_loaded;

  return (
    <Window width={380} height={420}>
      <Window.Content>
        <Section title="Ingredients">
          <LabeledList>
            <LabeledList.Item label="Phoron gas">
              {phoron_ok ? '✓' : '✗'}
            </LabeledList.Item>
            <LabeledList.Item label="Welding fuel">
              {fuel_loaded ? (
                <Box>
                  <ProgressBar
                    maxValue={fuel_max}
                    value={fuel_amount}
                  />
                  <Button
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject_fuel')}
                  />
                </Box>
              ) : (
                <Box color="average">No beaker loaded.</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Nutriment">
              {nutriment_loaded ? (
                <Box>
                  <ProgressBar
                    maxValue={nutriment_max}
                    value={nutriment_amount}
                  />
                  <Button
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject_nutriment')}
                  />
                </Box>
              ) : (
                <Box color="average">No beaker loaded.</Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Blood">
              {radium_loaded ? (
                <Box>
                  <ProgressBar
                    maxValue={radium_max}
                    value={radium_amount}
                  />
                  <Button
                    icon="eject"
                    content="Eject"
                    onClick={() => act('eject_radium')}
                  />
                </Box>
              ) : (
                <Box color="average">No beaker loaded.</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Production">
          <LabeledList>
            <LabeledList.Item label="Bio-supplements">
              <ProgressBar maxValue={bio_max} value={bio_amount} />
            </LabeledList.Item>
          </LabeledList>
          <Box mt={1}>
            {working ? (
              <Button
                icon="stop"
                color="bad"
                content="Stop"
                onClick={() => act('stop')}
              />
            ) : (
              <Button
                icon="play"
                color="good"
                content="Start producing"
                disabled={!beakers_ok || !phoron_ok}
                onClick={() => act('produce')}
              />
            )}
            <Button
              icon="fill-drip"
              content="Dispense to cartridge"
              disabled={!bio_amount || !cartridge_loaded}
              ml={1}
              onClick={() => act('dispense')}
            />
          </Box>
        </Section>
        <Section title="Cartridge">
          {!cartridge_loaded ? (
            <Box color="average">No cartridge loaded.</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label={cartridge_name}>
                <ProgressBar
                  maxValue={cartridge_max_volume}
                  value={cartridge_volume}
                />
              </LabeledList.Item>
            </LabeledList>
          )}
          <Button
            icon="eject"
            content="Eject cartridge"
            disabled={!cartridge_loaded}
            mt={1}
            onClick={() => act('eject_cartridge')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
