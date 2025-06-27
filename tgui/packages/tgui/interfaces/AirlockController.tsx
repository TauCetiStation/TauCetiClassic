import { useBackend } from '../backend';
import {
  AirlockControllerBase,
  DoorStatus,
  DoorOpen,
  AirlockControllerPressureIndicator,
} from './common/AirlockControllerBase';

import { Button, Table } from '../components';

type Data = {
  chamberPressure: number;
  exteriorStatus: DoorStatus;
  interiorStatus: DoorStatus;
  processing: boolean;
};

export const AirlockController = (_, context) => {
  const { data, act } = useBackend<Data>(context);

  const { processing, exteriorStatus, interiorStatus, chamberPressure } = data;

  return (
    <AirlockControllerBase
      width={350}
      height={208}
      abortEnabled={processing}
      statusItems={[
        {
          title: 'Chamber pressure',
          children: (
            <AirlockControllerPressureIndicator value={chamberPressure} />
          ),
        },
      ]}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            <Button
              mb={1}
              fluid
              icon="step-backward"
              content="Cycle to Exterior"
              disabled={processing}
              onClick={() => act('cycleExterior')}
            />
          </Table.Cell>
          <Table.Cell width="50%">
            <Button
              mb={1}
              fluid
              icon="step-forward"
              content="Cycle to Interior"
              disabled={processing}
              onClick={() => act('cycleInterior')}
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              fluid
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
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
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
          </Table.Cell>
        </Table.Row>
      </Table>
    </AirlockControllerBase>
  );
};
