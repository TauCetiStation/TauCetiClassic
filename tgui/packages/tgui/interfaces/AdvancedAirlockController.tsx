import { useBackend } from '../backend';
import {
  AirlockControllerBase,
  AirlockControllerPressureIndicator,
} from './common/AirlockControllerBase';

import { Button, Table } from '../components';

type Data = {
  externalPressure: number;
  internalPressure: number;
  chamberPressure: number;
  processing: boolean;
  purge: boolean;
  secure: boolean;
};

export const AdvancedAirlockController = (_, context) => {
  const { data, act } = useBackend<Data>(context);

  const {
    processing,
    externalPressure,
    chamberPressure,
    internalPressure,
    secure,
    purge,
  } = data;

  return (
    <AirlockControllerBase
      width={350}
      height={285}
      abortEnabled={processing}
      statusItems={[
        {
          title: 'External pressure',
          children: (
            <AirlockControllerPressureIndicator value={externalPressure} />
          ),
        },
        {
          title: 'Chamber pressure',
          children: (
            <AirlockControllerPressureIndicator value={chamberPressure} />
          ),
        },
        {
          title: 'Internal pressure',
          children: (
            <AirlockControllerPressureIndicator value={internalPressure} />
          ),
        },
      ]}>
      <Table>
        <Table.Row>
          <Table.Cell width="50%">
            <Button
              fluid
              mb={1}
              icon="step-backward"
              content="Cycle to Exterior"
              disabled={processing}
              onClick={() => act('cycleExterior')}
            />
          </Table.Cell>
          <Table.Cell width="50%">
            <Button
              fluid
              mb={1}
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
              mb={1}
              icon="warning"
              content="Force exterior door"
              color={processing ? 'yellow' : null}
              onClick={() => act('forceExterior')}
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              mb={1}
              icon="warning"
              content="Force interior door"
              color={processing ? 'yellow' : null}
              onClick={() => act('forceInterior')}
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              fluid
              icon="refresh"
              content="Purge"
              disabled={processing}
              color={purge && 'green'}
              onClick={() => act('purge')}
            />
          </Table.Cell>
          <Table.Cell>
            <Button
              fluid
              icon={secure ? 'lock' : 'unlock'}
              content="Secure"
              disabled={processing}
              color={secure && 'green'}
              onClick={() => act('secure')}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </AirlockControllerBase>
  );
};
