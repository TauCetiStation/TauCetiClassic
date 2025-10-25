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

export const IsolationCentrifuge = (props, context) => {
  const { act, data } = useBackend(context);
  const pathogens = data.pathogens || {};
  const { antibodies, busy, is_antibody_sample, sample_inserted } = data;
  return (
    <Window width={380} height={210}>
      <Window.Content>
        {!busy ? (
          sample_inserted ? (
            <Section
              title={is_antibody_sample ? 'Antibody Sample' : 'Blood sample'}
              buttons={
                <Button
                  content="Eject"
                  icon="eject"
                  disabled={!sample_inserted}
                  onClick={() => act('sample')}
                />
              }>
              <Button
                content="Print report"
                icon="print"
                mb="0.5em"
                disabled={!(pathogens || antibodies)}
                onClick={() => act('print')}
              />
              <LabeledList>
                <LabeledList.Item label="Antibodies">
                  {antibodies || 'None'}
                  {!!antibodies && (
                    <Button
                      ml="1em"
                      icon="eye-dropper"
                      tooltip="Isolate antibodies"
                      onClick={() => act('antibody')}
                    />
                  )}
                </LabeledList.Item>
                <LabeledList.Item label="Pathogens">
                  {pathogens.length ? (
                    <Flex direction="column">
                      {pathogens.map((P) => (
                        <Flex.Item mb="0.5em" key={P.reference}>
                          {P.name + ' (' + P.spread_type + ')'}
                          <Button
                            ml="1em"
                            icon="eye-dropper"
                            tooltip="Isolate strain"
                            onClick={() =>
                              act('isolate', {
                                index: P.reference,
                              })
                            }
                          />
                        </Flex.Item>
                      ))}
                    </Flex>
                  ) : (
                    'None'
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ) : (
            <Box color="average">No vial detected.</Box>
          )
        ) : (
          <NoticeBox info>{busy}</NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
