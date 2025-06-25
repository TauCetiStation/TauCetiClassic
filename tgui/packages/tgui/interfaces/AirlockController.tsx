import { useBackend } from '../backend';
import {
  Box,
  Section,
  LabeledList,
  Button,
  AnimatedNumber,
  Stack,
  ProgressBar,
} from '../components';

import { Window } from '../layouts';

enum DoorOpen {
  Open = 'open',
  Closed = 'closed',
}

enum DoorLock {
  Locked = 'locked',
  Unlocked = 'unlocked',
}

type DoorStatus = {
  state: DoorOpen;
  lock: DoorLock;
};

type Data = {
  chamberPressure: number;
  exteriorStatus: DoorStatus;
  interiorStatus: DoorStatus;
  processing: boolean;
};

export const AirlockController = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { chamberPressure, exteriorStatus, interiorStatus, processing } = data;

  return (
    <Window width={350} height={205}>
      <Window.Content fitted>
        <Stack m="5px" vertical fill>
          <Stack.Item>
            <Section title="Chamber pressure">
              <Stack align="baseline">
                <Stack.Item grow>
                  <ProgressBar
                    value={chamberPressure}
                    color={
                      chamberPressure < 80 || chamberPressure > 120
                        ? 'bad'
                        : chamberPressure < 95 || chamberPressure > 110
                          ? 'average'
                          : 'good'
                    }
                    minValue={0}
                    maxValue={202}>
                    &nbsp;
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <AnimatedNumber
                    value={chamberPressure}
                    format={(value: number) => `${value.toFixed(1)} kPa`}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Actions"
              buttons={
                <Button
                  icon="exclamation-circle"
                  content="Abort"
                  disabled={!processing}
                  color="red"
                  onClick={() => act('abort')}
                />
              }>
              <Stack align="baseline" wrap>
                <Button
                  icon="step-backward"
                  content="Cycle to Exterior"
                  disabled={processing}
                  onClick={() => act('cycleExterior')}
                />
                <Button
                  icon="step-forward"
                  content="Cycle to Interior"
                  disabled={processing}
                  onClick={() => act('cycleInterior')}
                />
                <Button
                  icon="warning"
                  content="Force exterior door"
                  color={
                    interiorStatus.state === DoorOpen.Open
                      ? 'red'
                      : processing
                        ? 'yellow'
                        : null
                  }
                  onClick={() => act('forceExterior')}
                />
                <Button
                  icon="warning"
                  content="Force interior door"
                  color={
                    exteriorStatus.state === DoorOpen.Open
                      ? 'red'
                      : processing
                        ? 'yellow'
                        : null
                  }
                  onClick={() => act('forceInterior')}
                />
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
