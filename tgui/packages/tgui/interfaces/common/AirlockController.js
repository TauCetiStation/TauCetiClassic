import { useBackend } from '../backend';
import {
  Box,
  Section,
  LabeledList,
  Button,
  AnimatedNumber,
  ProgressBar,
} from '../../components';

export const AirlockControllerInterface = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    chamber_pressure,
    exterior_status,
    interior_status,
    processing,
  } = data;formatPower
  return (
    <Window width={300} height={405}>
      <Window.Content>
    <LabeledList>
      <LabeledList.Item label="Pressure">
        <AnimatedNumber value={chamber_pressure} />
        {' kPa'}
      </LabeledList.Item>
      </LabeledList>
    <LabeledList>
          <Button
           icon="eject"
           content="Cycle to Exterior"
           onClick={() => act('exterior_status')}
           />
   </LabeledList>
    <LabeledList>
          <Button
           icon="eject"
           content="Cycle to Interior"
           onClick={() => act('interior_status')}
           />
   </LabeledList>
      </Window.Content>
    </Window>
  )
}
