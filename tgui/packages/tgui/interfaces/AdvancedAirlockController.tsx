import { useBackend } from '../backend';
import {
  AirlockControllerBase,
  AirlockControllerPressureIndicator,
} from './common/AirlockControllerBase';

import { Button } from '../components';

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
      height={279}
      hasAbort
      processing={processing}
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
      <br />
      <Button
        icon="warning"
        content="Force exterior door"
        color={processing ? 'yellow' : null}
        onClick={() => act('forceExterior')}
      />
      <Button
        icon="warning"
        content="Force interior door"
        color={processing ? 'yellow' : null}
        onClick={() => act('forceInterior')}
      />
      <br />
      <Button
        icon="refresh"
        content="Purge"
        disabled={processing}
        color={purge && 'green'}
        onClick={() => act('purge')}
      />
      <Button
        icon={secure ? 'lock' : 'unlock'}
        content="Secure"
        disabled={processing}
        color={secure && 'green'}
        onClick={() => act('secure')}
      />
    </AirlockControllerBase>
  );
};
