import { InfernoNode } from 'inferno';
import { useBackend } from '../backend';
import { Component } from 'inferno';

import {
  Button,
  Box,
  LabeledList,
  Section,
  Divider,
  Dropdown,
  Stack,
  Tooltip,
} from '../components';

import { Window } from '../layouts';

type Data = {
  scan?: string;
  authenticated: boolean;
  sendCooldown: number;
  paper: string;
  paperName?: string;
  destination: string;
  allDepartments: string[];
};

export const Fax = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    scan,
    authenticated,
    sendCooldown,
    paper,
    paperName,
    destination,
    allDepartments,
  } = data;

  return (
    <Window width={480} height={320}>
      <Window.Content>
        <Stack width="100%" textAlign="base">
          <Stack.Item grow bold={1}>
            Confirm Identity:
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eject"
              content={scan ? scan : '-------'}
              onClick={() => act('scan')}
              color={!scan ? 'default' : authenticated ? 'green' : 'red'}
              tooltip={
                !scan
                  ? 'Insert the ID-card'
                  : authenticated
                    ? 'Access Granted'
                    : 'Access Denied'
              }
            />
          </Stack.Item>
        </Stack>
        <Stack mt={1} width="100%" textAlign="base">
          <Stack.Item grow bold={1}>
            Sending to:
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              width={12}
              selected={destination}
              options={allDepartments}
              onSelected={(dept) => act('setDestination', { to: dept })}
            />
          </Stack.Item>
        </Stack>
        <Stack>
          <Stack.Item width="100%" textAlign="base" mt={1} bold={1}>
            Currently sending:
          </Stack.Item>
          <Stack.Item>
            <Button
              mt={1}
              icon="fa-file"
              content={paper ? paperName : 'No content found'}
              tooltip={
                !paper ? 'Add attachment for sending' : 'Remove attachment'
              }
              onClick={() => act('paperinteraction')}
            />
          </Stack.Item>
        </Stack>
        <Box textAlign={'center'} mt={2}>
          <Divider />
          <Button
            icon="fa-solid fa-paper-plane"
            content={'Send Message'}
            onClick={() => act('send')}
            disabled={sendCooldown || !paper || !authenticated}
          />
        </Box>
      </Window.Content>
    </Window>
  );
};
