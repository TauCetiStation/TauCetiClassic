import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const ParticlesPowerBattery = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    isActivated,
    insertedBattery,
    batteryEnergy,
    batteryMaxEnergy,
  } = data;

  return (
    <Window width={450} height={200}>
      <Window.Content>
        <Section title={"Power managment"} buttons={(
          <Button
            disabled={!insertedBattery}
            content={"Eject battery"}
            icon={"eject"}
            onClick={() => act("ejectBattery")} />
        )}>
          <LabeledList>
            <LabeledList.Item label="Battery charge">
              {insertedBattery && (
                <ProgressBar
                  fractionDigits={1}
                  value={batteryEnergy / batteryMaxEnergy || 0} />
              )||(
                <Box color="bad" textAlign={"right"}>
                  Battery missing
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label={"Battery status"}
              buttons={(
                <>
                  <Box inline mx={2}
                    color={isActivated ? 'bad' : 'good'}>
                    {isActivated ? 'Activated' : 'Deactivated'}
                  </Box>
                  <Button
                    content={isActivated ? 'Halt': "Start radiating"}
                    disabled={!insertedBattery || batteryEnergy <= 0}
                    onClick={() => act(isActivated ? "turnOff" : "turnOn")} />
                </>
              )} />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
