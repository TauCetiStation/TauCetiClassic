import { Button, Icon, NumberInput, Stack, NoticeBox } from '../components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

interface SlotMachineData {
  busy?: string;
  balance: number;
  cost: number;
  working: boolean;
  plays: number;
}

export const SlotMachine = (props, context) => {
  const { act, data } = useBackend<SlotMachineData>(context);
  const { busy, balance, cost, plays, working } = data;
  return (
    <Window width={380} height={210}>
      {!working ? (
        <Window.Content>
          <Stack vertical>
            <Stack.Item>
              <NoticeBox success>
                <div>Wager some credits!</div>
              </NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item>
                  <strong>Account Balance:</strong>
                </Stack.Item>
                <Stack.Item>{balance}cr</Stack.Item>
                <Stack.Item>
                  <Button
                    tooltip="Pull Funds"
                    tooltipPosition="bottom"
                    onClick={() => act('cashout')}>
                    Cash Out
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center" fill>
                <Stack.Item>Amount Wagered:</Stack.Item>
                <Stack.Item>
                  <Button
                    icon="fast-backward"
                    tooltip="Min Bet"
                    onClick={() => act('set_cost', { bet: 20 })}
                  />
                  <Button
                    icon="minus"
                    onClick={() => act('set_cost', { bet: cost - 10 })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    value={cost}
                    minValue={20}
                    maxValue={1000}
                    step={10}
                    width="80px"
                    format={(value) => value + 'cr'}
                    onChange={(e, value) => act('set_cost', { bet: value })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="plus"
                    onClick={() => act('set_cost', { bet: cost + 10 })}
                  />
                  <Button
                    icon="fast-forward"
                    tooltip="Max Bet"
                    onClick={() => act('set_cost', { bet: 1000 })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <div>{plays} attempts have been made today!</div>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Button
                icon="dice"
                disabled={balance < cost}
                color={balance < cost * 2 ? 'average' : 'default'}
                tooltip={
                  balance < cost
                    ? 'Not enough funds!'
                    : balance < cost * 2
                      ? 'Last spin at this wager!'
                      : 'Pull the lever'
                }
                onClick={() => act('spin')}>
                Play!
              </Button>
            </Stack.Item>
          </Stack>
        </Window.Content>
      ) : (
        <Window.Content>
          <NoticeBox info>{busy}</NoticeBox>
        </Window.Content>
      )}
    </Window>
  );
};
