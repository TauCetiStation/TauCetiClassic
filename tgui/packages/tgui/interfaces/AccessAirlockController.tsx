import {
  AirlockControllerBase,
  DoorStatus,
  DoorOpen,
} from './common/AirlockControllerBase';

import { Button, Table } from '../components';

import { useBackend } from '../backend';

type Data = {
  exteriorStatus: DoorStatus;
  interiorStatus: DoorStatus;
  processing: boolean;
};

export const AccessAirlockController = (_, context) => {
  const { data, act } = useBackend<Data>(context);
  const { exteriorStatus, interiorStatus, processing } = data;

  return (
    <AirlockControllerBase
      width={350}
      height={200}
      statusItems={[
        {
          title: 'Exterior Door Status',
          children:
            exteriorStatus.state === DoorOpen.Closed ? 'Locked' : 'Open',
        },
        {
          title: 'Interior Door Status',
          children:
            interiorStatus.state === DoorOpen.Closed ? 'Locked' : 'Open',
        },
      ]}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            {exteriorStatus.state === DoorOpen.Open ? (
              <Button
                fluid
                icon="warning"
                content="Lock Exterior Door"
                disabled={processing}
                onClick={() => act('forceExterior')}
              />
            ) : (
              <Button
                fluid
                icon="step-backward"
                content="Cycle to Exterior"
                disabled={processing}
                onClick={() => act('cycleExterior')}
              />
            )}
          </Table.Cell>
          <Table.Cell>
            {interiorStatus.state === DoorOpen.Open ? (
              <Button
                fluid
                icon="warning"
                content="Lock Interior Door"
                disabled={processing}
                onClick={() => act('forceInterior')}
              />
            ) : (
              <Button
                fluid
                icon="step-forward"
                content="Cycle to Interior"
                disabled={processing}
                onClick={() => act('cycleInterior')}
              />
            )}
          </Table.Cell>
        </Table.Row>
      </Table>
    </AirlockControllerBase>
  );
};
