import { useBackend } from '../../backend';
import { Box, Section, LabeledList, Button, AnimatedNumber, ProgressBar } from '../../components';

export const PortableBasicInfo = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    connected,
    holding,
    on,
    pressure,
    power_draw,
    cell_charge,
    cell_maxcharge,
  } = data;

  const cell_chargepercent = cell_charge / cell_maxcharge;

  return (
    <>
      <Section
        title="Status"
        buttons={(
          <Button
            icon={on ? 'power-off' : 'times'}
            content={on ? 'On' : 'Off'}
            selected={on}
            onClick={() => act('power')} />
        )}>
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <AnimatedNumber value={pressure} />
            {' kPa'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Port"
            color={connected ? 'good' : 'average'}>
            {connected ? 'Connected' : 'Not Connected'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Cell" >
        <LabeledList>
          <LabeledList.Item label="Load">
            <AnimatedNumber value={power_draw} />
            {' W'}
          </LabeledList.Item>
          <LabeledList.Item label="Charge">
            <ProgressBar
              ranges={{
                bad: [-Infinity, .1],
                average: [.1, .6],
                good: [.6, Infinity],
              }}
              value={cell_chargepercent} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Holding Tank"
        minHeight="82px"
        buttons={(
          <Button
            icon="eject"
            content="Eject"
            disabled={!holding}
            onClick={() => act('eject')} />
        )}>
        {holding ? (
          <LabeledList>
            <LabeledList.Item label="Label">
              {holding.name}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={holding.pressure} />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="average">
            No holding tank
          </Box>
        )}
      </Section>
    </>
  );
};