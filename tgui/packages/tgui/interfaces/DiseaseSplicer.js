import { map } from 'common/collections';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  NoticeBox,
  Section,
} from '../components';
import { Window } from '../layouts';

export const DiseaseSplicer = (props, context) => {
  const { act, data } = useBackend(context);
  const effects = data.effects || {};
  const {
    affected_species,
    busy,
    buffer,
    can_splice,
    dish_inserted,
    info,
    species_buffer,
  } = data;
  return (
    <Window width={480} height={400}>
      {!busy ? (
        <Window.Content>
          <Section
            title="Virus dish"
            buttons={
              <Button
                content="Eject"
                icon="eject"
                disabled={!dish_inserted}
                onClick={() => act('eject')}
              />
            }>
            {dish_inserted && effects.length ? (
              <Box>
                <NoticeBox>
                  CAUTION: Reverse engineering will destroy the viral sample.
                </NoticeBox>
                <LabeledList>
                  <LabeledList.Item label="Symptoms">
                    <Flex direction="column">
                      {effects.map((E) => (
                        <Flex.Item mb="0.5em" key={E.reference}>
                          {E.stage + '. ' + E.name}
                          <Button
                            ml="1em"
                            icon="arrow-right-arrow-left"
                            tooltip="Take genome"
                            onClick={() =>
                              act('grab', {
                                index: E.reference,
                              })
                            }
                          />
                        </Flex.Item>
                      ))}
                    </Flex>
                  </LabeledList.Item>
                  <LabeledList.Item label="Affected species">
                    {affected_species}
                    <Button
                      ml="1em"
                      icon="arrow-right-arrow-left"
                      tooltip="Take genome"
                      onClick={() => act('affected_species')}
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            ) : (
              <Box color="average">No dish loaded.</Box>
            )}
          </Section>
          <Section title="Storage">
            <LabeledList>
              <LabeledList.Item label="Memory buffer">
                {buffer
                  ? buffer.name
                  : species_buffer
                    ? species_buffer
                    : 'Empty'}
              </LabeledList.Item>
            </LabeledList>
            <Button
              mr="0.5em"
              mt="0.5em"
              icon="floppy-disk"
              content="Save to disk"
              disabled={!buffer && !species_buffer}
              onClick={() => act('disk')}
            />
            <Button
              mt="0.5em"
              icon="pencil"
              content="Splice symptom"
              disabled={(!buffer && !species_buffer) || !dish_inserted}
              onClick={() => act('splice')}
            />
          </Section>
        </Window.Content>
      ) : (
        <NoticeBox info>{busy}</NoticeBox>
      )}
    </Window>
  );
};
