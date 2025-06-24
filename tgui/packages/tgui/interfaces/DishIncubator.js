import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

const VirusDish = (props, context) => {
  const { act, data } = useBackend(context);
  const { affected_species, analysed, effects, infection_rate } = props;

  if (!analysed) {
    return (
      <Box color="average">Unable to get any information from database.</Box>
    );
  }
  return (
    <Box>
      <Box inline color="label" bold preserveWhitespace my={1}>
        Infection rate:{' '}
      </Box>
      <Box inline>{infection_rate}</Box>
      <Box color="label" bold my={1}>
        Symptoms:
      </Box>
      {effects.map((item) => (
        <Flex key={item.reference}>
          <Flex.Item grow={1} ml={1}>
            {item.name}
          </Flex.Item>
          <Flex.Item>
            <Button
              icon="circle-question"
              tooltip="Symptom info"
              mb={1}
              onClick={() =>
                act('info', {
                  symptomref: item.reference,
                })
              }
            />
          </Flex.Item>
        </Flex>
      ))}
      <Box color="label" bold my={1}>
        Affected species:
      </Box>
      <Box ml={1}>{affected_species}</Box>
    </Box>
  );
};

export const DishIncubator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    affected_species,
    analysed,
    blood_already_infected,
    can_breed_virus,
    chemical_volume,
    chemicals_inserted,
    dish_inserted,
    effects,
    food_supply,
    infection_rate,
    max_chemical_volume,
    phoron_supply,
    sleeptoxin_supply,
    supply_cap,
    symptomdesc,
    symptomname,
    synaptizine_supply,
    system_in_use,
    toxin_supply,
    virus,
  } = data;
  if (system_in_use) {
    return (
      <Window>
        <Window.Content>
          <NoticeBox>The Incubator is currently busy...</NoticeBox>
        </Window.Content>
      </Window>
    );
  }
  if (symptomname) {
    return (
      <Window>
        <Window.Content>
          <Section title={symptomname}>{symptomdesc}</Section>
          <Button icon="arrow-left-long" onClick={() => act('back')}>
            Back
          </Button>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window
      width={360}
      height={
        380 +
        (chemicals_inserted ? 80 : 0) +
        (dish_inserted && analysed ? 240 : 0)
      }>
      <Window.Content>
        <Box>
          <Section title="Environmental Conditions">
            <LabeledList>
              <LabeledList.Item label="Virus Food">
                <Flex justify="flex-end">
                  <Flex.Item grow={1}>
                    <ProgressBar maxValue={supply_cap} value={food_supply}>
                      {food_supply}/{supply_cap}
                    </ProgressBar>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      tooltip="Inject food"
                      icon="syringe"
                      mx={1}
                      disabled={food_supply < 1 || !dish_inserted}
                      onClick={() => act('food')}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Toxin">
                <Flex justify="flex-end">
                  <Flex.Item grow={1}>
                    <ProgressBar maxValue={supply_cap} value={toxin_supply}>
                      {toxin_supply}/{supply_cap}
                    </ProgressBar>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      tooltip="Inject toxin"
                      icon="syringe"
                      mx={1}
                      disabled={toxin_supply < 1 || !dish_inserted}
                      onClick={() => act('toxin')}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Synaptizine">
                <Flex justify="flex-end">
                  <Flex.Item grow={1}>
                    <ProgressBar
                      maxValue={supply_cap}
                      value={synaptizine_supply}>
                      {synaptizine_supply}/{supply_cap}
                    </ProgressBar>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      tooltip="Inject synaptizine"
                      icon="syringe"
                      mx={1}
                      disabled={synaptizine_supply < 1 || !dish_inserted}
                      onClick={() => act('synaptizine')}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Phoron">
                <Flex justify="flex-end">
                  <Flex.Item grow={1}>
                    <ProgressBar maxValue={supply_cap} value={phoron_supply}>
                      {phoron_supply}/{supply_cap}
                    </ProgressBar>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      tooltip="Inject phoron"
                      icon="syringe"
                      mx={1}
                      disabled={phoron_supply < 1 || !dish_inserted}
                      onClick={() => act('phoron')}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
              <LabeledList.Item label="Sleep-Toxin">
                <Flex justify="flex-end">
                  <Flex.Item grow={1}>
                    <ProgressBar
                      maxValue={supply_cap}
                      value={sleeptoxin_supply}>
                      {sleeptoxin_supply}/{supply_cap}
                    </ProgressBar>
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      tooltip="Inject sleep-toxin"
                      icon="syringe"
                      mx={1}
                      disabled={sleeptoxin_supply < 1 || !dish_inserted}
                      onClick={() => act('sleeptoxin')}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
            </LabeledList>
            <Button
              content="Irradiate"
              icon="radiation"
              my={1}
              disabled={!dish_inserted}
              onClick={() => act('rad')}
            />
          </Section>
          <Section
            title="Chemicals"
            buttons={
              <Button
                content="Eject chemicals"
                icon="eject"
                disabled={!chemicals_inserted}
                onClick={() => act('ejectchem')}
              />
            }>
            {!chemicals_inserted ? (
              <Box color="average">No chemicals inserted.</Box>
            ) : (
              <LabeledList>
                <LabeledList.Item label="Volume">
                  <ProgressBar
                    value={chemical_volume}
                    maxValue={max_chemical_volume}>
                    {chemical_volume}/{max_chemical_volume}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Breeding environment">
                  <Box class={can_breed_virus ? 'good' : 'average'}>
                    {!dish_inserted
                      ? 'N/A'
                      : can_breed_virus
                        ? 'Suitable'
                        : 'No hemolytic samples detected'}
                  </Box>
                  {!!blood_already_infected && (
                    <Box color="bad" bold italic>
                      CAUTION: Viral infection detected in blood sample.
                    </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            )}
            {!!chemicals_inserted && (
              <Button
                content="Breed virus"
                icon="viruses"
                disabled={!can_breed_virus || !dish_inserted}
                my={1}
                onClick={() => act('virus')}
              />
            )}
          </Section>
          <Section
            title="Virus Dish"
            buttons={
              <Button
                content="Eject dish"
                icon="eject"
                disabled={!dish_inserted}
                onClick={() => act('ejectdish')}
              />
            }>
            {!dish_inserted ? (
              <Box color="average">No dish loaded.</Box>
            ) : (
              <VirusDish
                analysed={analysed}
                infection_rate={infection_rate}
                effects={effects}
                affected_species={affected_species}
              />
            )}
          </Section>
        </Box>
      </Window.Content>
    </Window>
  );
};
