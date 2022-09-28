import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const ArtifactHarvester = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    isBatteryLoaded,
    isHarvesting,
    isDraining,
    maxEnergy,
    currentEnergy,
  } = data;

  return (
    <Window width={450} height={200}>
      <Window.Content>
        <Section title={"Power managment"} buttons={(
          <>
            <Button
              disabled={isDraining || isHarvesting}
              content={"Locate Telepad"}
              onClick={() => act("locate_telepad")}
            />
            <Button
              content={"Eject battery"}
              icon={"eject"}
              disabled={!isBatteryLoaded || isDraining || isHarvesting}
              onClick={() => act("eject_battery")}
            />
          </>
        )}>
          <LabeledList>
            <LabeledList.Item label="Battery status">
              {isBatteryLoaded && (
                <ProgressBar
                  fractionDigits={1}
                  value={currentEnergy / maxEnergy || 0} />
              )||(
                <Box color="bad" textAlign={"right"}>
                  Battery missing
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label={"Battery harvesting"}
              buttons={(
                <>
                  <Box inline mx={2}
                    color={isHarvesting ? 'good' : 'bad'}>
                    {isHarvesting ? 'Harvesting' : 'Off'}
                  </Box>
                  <Button
                    content={isHarvesting ? "Halt Harvest" : "Start harvest"}
                    disabled={!isBatteryLoaded || isDraining}
                    onClick={() => act(isHarvesting ? "stop_harvest" : "start_harvest")} />
                </>
              )} />
            <LabeledList.Item
              label={"Battery draining"}
              buttons={(
                <>
                  <Box inline mx={2}
                    color={isDraining ? 'good' : 'bad'}>
                    {isDraining ? 'Draining' : 'Off'}
                  </Box>
                  <Button
                    content={"Drain battery"}
                    disabled={!isBatteryLoaded || isHarvesting || isDraining}
                    onClick={() => act("drain_battery")} />
                </>
              )} />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
