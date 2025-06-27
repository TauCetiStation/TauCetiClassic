import { InfernoNode } from 'inferno';
import { useBackend } from '../../backend';
import {
  Section,
  Button,
  AnimatedNumber,
  Stack,
  ProgressBar,
  LabeledList,
  Box,
} from '../../components';

import { Window } from '../../layouts';

import { BooleanLike } from 'common/react';

export enum DoorOpen {
  Open = 'open',
  Closed = 'closed',
}

export enum DoorLock {
  Locked = 'locked',
  Unlocked = 'unlocked',
}

export type DoorStatus = {
  state: DoorOpen;
  lock: DoorLock;
};

type AirlockControllerStatusItem = {
  title?: string;
  children: InfernoNode;
};

type AirlockControllerBaseProps = {
  statusItems?: AirlockControllerStatusItem[];
  children?: InfernoNode;
  abortEnabled?: BooleanLike;
  width?: number | string;
  height?: number | string;
};

export const AirlockControllerBase = (
  props: AirlockControllerBaseProps,
  context
) => {
  const { act } = useBackend(context);
  const { statusItems, children, abortEnabled, width, height } = props;
  return (
    <Window width={width} height={height}>
      <Window.Content>
        <Stack vertical fill>
          {statusItems?.length && (
            <Stack.Item>
              <Section title="Status">
                <LabeledList>
                  {statusItems.map((statusItem, i) => (
                    <LabeledList.Item
                      key={statusItem.title + i}
                      label={statusItem.title}>
                      {statusItem.children}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
          {children && (
            <Stack.Item grow>
              <Section
                title="Commands"
                buttons={
                  // eslint-disable-next-line eqeqeq
                  abortEnabled != null && (
                    <Button
                      icon="exclamation-circle"
                      content="Abort"
                      disabled={!abortEnabled}
                      color="red"
                      onClick={() => act('abort')}
                    />
                  )
                }>
                {children}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type AirlockControllerPressureIndicatorProps = {
  value: number;
};

export const AirlockControllerPressureIndicator = (
  props: AirlockControllerPressureIndicatorProps
) => {
  const { value } = props;
  return (
    <Stack align="baseline">
      <Stack.Item grow>
        <ProgressBar
          value={value}
          color={
            value < 80 || value > 120
              ? 'bad'
              : value < 95 || value > 110
                ? 'average'
                : 'good'
          }
          minValue={0}
          maxValue={202}>
          &nbsp;
        </ProgressBar>
      </Stack.Item>
      <Stack.Item width="4.5rem">
        <AnimatedNumber
          value={value}
          format={(value: number) => `${value.toFixed()} kPa`}
        />
      </Stack.Item>
    </Stack>
  );
};
