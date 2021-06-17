import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  AnimatedNumber,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

export const ChemDispenser = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    amount,
    energy,
    maxEnergy,
    isBeakerLoaded,
    glass,
    beakerContents,
    beakerCurrentVolume,
    beakerMaxVolume,
    chemicals,
  } = data;

  const DISPENSE_AMOUNTS = [5, 10, 20, 30, 40];

  return (
    <Window width={420} height={650}>
      <Window.Content>
        <Section title={"Status"}>
          <LabeledList>
            <LabeledList.Item label="Energy">
              <ProgressBar
                value={energy / maxEnergy}>
                {toFixed(energy) + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title={"Dispense"}
          buttons={(
            <>
              {DISPENSE_AMOUNTS.map(amountSel => (
                <Button
                  key={amountSel}
                  icon={"plus"}
                  align={"center"}
                  content={amountSel}
                  selected={amountSel === amount}
                  onClick={() => act("change_amount", {
                    new_amount: amountSel,
                  })}
                />
              ))}
              <NumberInput
                width={"40px"}
                animated={1}
                step={5}
                minValue={1}
                maxValue={100}
                stepPixelSize={3}
                value={amount}
                onChange={(_, value) => act("change_amount", {
                  new_amount: value,
                })}
              />
            </>
          )}>
          {
            chemicals.map(chemical => (
              <Button
                disabled={!isBeakerLoaded}
                key={chemical.id}
                icon={"tint"}
                width={"130px"}
                lineHeight={1.75}
                content={chemical.title}
                onClick={() => act("dispense", {
                  chemical: chemical.id,
                })}
              />
            ))
          }
        </Section>
        <Section title={(glass ? "Glass" : "Beaker") + " contents"} buttons={(
          <Button
            content={"Eject beaker"}
            icon={"eject"}
            disabled={!isBeakerLoaded}
            onClick={() => act("eject_beaker")}
          />
        )}>
          <LabeledList>
            <LabeledList.Item
              label={(glass ? "Glass" : "Beaker")}>
              {isBeakerLoaded
              && (
                <>
                  <AnimatedNumber
                    initial={0}
                    value={beakerCurrentVolume}
                  />
                  /{beakerMaxVolume} units
                </>
              )
              || 'No ' + (glass ? "glass" : "beaker")}
            </LabeledList.Item>
            <LabeledList.Item
              label="Contents">
              <Box color="label">
                {!isBeakerLoaded && 'N/A'
                || beakerContents.length === 0 && 'Nothing'}
              </Box>
              {beakerContents.map(chemical => (
                <Box
                  key={chemical.name}
                  color="label">
                  <AnimatedNumber
                    initial={0}
                    value={chemical.volume}
                  />
                  {' '}
                  units of {chemical.name}
                </Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
