import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Dimmer,
  Flex,
  Knob,
  LabeledList,
  NumberInput,
  ProgressBar,
  RoundGauge,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

export const DnaModifier = (props, context) => {
  const { act, data } = useBackend(context);
  const { selectedMenuKey, opened, locked, irradiating } = data;
  return (
    <Window resizable width={640} height={530}>
      <Window.Content scrollable={selectedMenuKey === 3 && !irradiating}>
        <Scanner />
        <Tabs fluid>
          <Tabs.Tab
            icon="dna"
            selected={selectedMenuKey === 1}
            onClick={() => act('selectMenuKey', { menu: 1 })}>
            Modify U.I.
          </Tabs.Tab>
          <Tabs.Tab
            icon="dna"
            selected={selectedMenuKey === 2}
            onClick={() => act('selectMenuKey', { menu: 2 })}>
            Modify S.E.
          </Tabs.Tab>
          <Tabs.Tab
            icon="database"
            selected={selectedMenuKey === 3}
            onClick={() => act('selectMenuKey', { menu: 3 })}>
            Transfer buffers
          </Tabs.Tab>
          <Tabs.Tab
            icon="flask"
            selected={selectedMenuKey === 4}
            onClick={() => act('selectMenuKey', { menu: 4 })}>
            Chemicals
          </Tabs.Tab>
        </Tabs>
        <MainScreen />
      </Window.Content>
      {!!irradiating && (
        <Dimmer textAlign="center">
          <h1>Irradiating Subject</h1>
          <h3>For {irradiating} seconds.</h3>
        </Dimmer>
      )}
    </Window>
  );
};

const Scanner = (props, context) => {
  const { act, data } = useBackend(context);
  const { hasOccupant, occupant } = data;
  const stats = [
    ['good', 'conscious'],
    ['average', 'unconscious'],
    ['bad', 'dead'],
  ];
  return (
    <Section title="Scanner" buttons={<ScannerButtons />}>
      {!hasOccupant ? (
        <Box color="average">Cell is unoccupied</Box>
      ) : (
        <Flex align="center">
          <Flex.Item>
            <LabeledList>
              <LabeledList.Item label="Patient" preserveWhitespace>
                {occupant.name}
                {' - '}
                <Box inline color={stats[occupant.stat][0]}>
                  {stats[occupant.stat][1]}
                </Box>
              </LabeledList.Item>
              <LabeledList.Item label="Health">
                <ProgressBar
                  min="0"
                  max={occupant.maxHealth}
                  value={occupant.health / occupant.maxHealth}
                  minWidth={12}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0, 0.5],
                    bad: [-Infinity, 0],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Unique enzymes">
                {occupant.uniqueEnzymes}
              </LabeledList.Item>
            </LabeledList>
          </Flex.Item>
          <Flex.Item grow>
            <Flex align="center" justify="space-evenly" direction="column">
              <Flex.Item>
                <RoundGauge
                  size={2.5}
                  value={occupant.radiationLevel}
                  minValue={0}
                  maxValue={100}
                  format={() => {
                    return '';
                  }}
                  ranges={{
                    'good': [0, 49],
                    'average': [50, 74],
                    'bad': [75, 100],
                  }}
                />
              </Flex.Item>
              <Flex.Item>
                <LabeledList>
                  <LabeledList.Item label="Radiation level">
                    {occupant.radiationLevel}
                  </LabeledList.Item>
                </LabeledList>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};

const ScannerButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { opened, locked } = data;
  return (
    <>
      <Button
        selected={!opened}
        icon={opened ? 'door-open' : 'door-closed'}
        onClick={() => act('toggleOpen')}>
        {opened ? 'Opened' : 'Closed'}
      </Button>
      <Button
        selected={locked}
        disabled={opened}
        icon={locked ? 'lock' : 'lock-open'}
        onClick={() => act('toggleLock')}>
        {locked ? 'Locked' : 'Unlocked'}
      </Button>
    </>
  );
};

const EmitterControls = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    radiationIntensity,
    radiationDuration,
    selectedUITarget,
    selectedUITargetHex,
  } = data;
  const { showUITarget } = props;

  return (
    <Box>
      <Knob
        value={radiationDuration}
        minValue={2}
        maxValue={20}
        stepPixelSize={4}
        size={2}
        mb={1}
        ranges={{
          good: [2, 8],
          average: [9, 14],
          bad: [15, 20],
        }}
        onChange={(e, value) =>
          act('radiationDuration', {
            duration: value,
          })
        }
      />
      <Box textAlign="center">
        <Box inline preserveWhitespace color="grey" mb={2}>
          Pulse duration:{' '}
        </Box>
        <AnimatedNumber value={radiationDuration} />
      </Box>
      <Knob
        value={radiationIntensity}
        minValue={1}
        maxValue={10}
        stepPixelSize={4}
        size={2}
        mb={1}
        ranges={{
          good: [1, 3],
          average: [4, 6],
          bad: [7, 10],
        }}
        onChange={(e, value) =>
          act('radiationIntensity', {
            intensity: value,
          })
        }
      />
      <Box textAlign="center">
        <Box inline preserveWhitespace color="grey" mb={2}>
          Pulse intensity:{' '}
        </Box>
        <AnimatedNumber value={radiationIntensity} />
      </Box>
      {!!showUITarget && (
        <Box textAlign="center">
          <Box inline preserveWhitespace color="grey" mb={2}>
            Target UI value:{' '}
          </Box>
          <NumberInput
            value={selectedUITarget}
            minValue={0}
            maxValue={15}
            stepPixelSize={4}
            width="30px"
            onChange={(e, value) =>
              act('changeUITarget', {
                target: value,
              })
            }
            format={(num) => {
              return num.toString(16).toUpperCase();
            }}
          />
        </Box>
      )}
    </Box>
  );
};

const DnaBlocks = (props, context) => {
  const { act } = useBackend(context);
  const { dnaString, selectedBlock, selectedSubBlock, dnaBlockSize, dnaType } =
    props;

  const characters = dnaString.toUpperCase().split('');
  const blocks = [];
  for (let i = 0; i < characters.length; i += dnaBlockSize) {
    blocks.push(characters.slice(i, i + dnaBlockSize));
  }

  let action = '';
  if (dnaType === 'SE') {
    action = 'selectSEBlock';
  } else if (dnaType === 'UI') {
    action = 'selectUIBlock';
  }

  return (
    <Flex wrap justify="space-evenly">
      {blocks.map((block, blockIndex) => (
        <Flex.Item key={blockIndex} inline>
          <Box
            style={{ border: '1px solid rgba(62, 97, 137, 0.5)' }}
            backgroundColor="rgba(10, 10, 10, 0.5)"
            inline
            m={1}
            p={0.5}
            nowrap
            width="90px"
            textAlign="right">
            <Box preserveWhitespace mr="5px" inline color="rgba(170,170,170,1)">
              {blockIndex + 1}
            </Box>
            {block.map((char, charIndex) => {
              let index = blockIndex * dnaBlockSize + charIndex;
              return (
                <Button
                  selected={
                    index ===
                    dnaBlockSize * (selectedBlock - 1) + selectedSubBlock - 1
                  }
                  key={index}
                  width="1.5em"
                  align="center"
                  onClick={() =>
                    act(action, {
                      block: blockIndex + 1,
                      subblock: charIndex + 1,
                    })
                  }>
                  {char}
                </Button>
              );
            })}
          </Box>
        </Flex.Item>
      ))}
    </Flex>
  );
};

const MainScreen = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    selectedMenuKey,
    hasOccupant,
    isInjectorReady,
    hasDisk,
    disk,
    buffers,
    radiationIntensity,
    radiationDuration,
    irradiating,
    dnaBlockSize,
    selectedUIBlock,
    selectedUISubBlock,
    selectedSEBlock,
    selectedSESubBlock,
    selectedUITarget,
    selectedUITargetHex,
    occupant,
    isBeakerLoaded,
    beakerLabel,
    beakerVolume,
    beakerMaxVolume,
    injectAmount,
  } = data;
  switch (selectedMenuKey) {
    case 1:
      return (
        <Stack>
          <Stack.Item grow>
            <Section fill title="Modify unique identifier">
              {!hasOccupant ? (
                <Box color="average">No patient detected</Box>
              ) : (
                <DnaBlocks
                  dnaString={occupant.uniqueIdentity}
                  selectedBlock={selectedUIBlock}
                  selectedSubBlock={selectedUISubBlock}
                  dnaBlockSize={dnaBlockSize}
                  dnaType="UI"
                />
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section fill title="Emitter controls" width="180px">
              <EmitterControls showUITarget />
              <Box textAlign="center">
                <Button
                  icon="radiation"
                  m={1}
                  onClick={() => act('pulseUIRadiation')}>
                  Irradiate block
                </Button>
                <Button
                  m={1}
                  icon="triangle-exclamation"
                  onClick={() => act('pulseRadiation')}>
                  Pulse radiation
                </Button>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      );
    case 2:
      return (
        <Stack>
          <Stack.Item grow>
            <Section fill title="Modify structural enzymes">
              {!hasOccupant ? (
                <Box color="average">No patient detected</Box>
              ) : (
                <DnaBlocks
                  dnaString={occupant.structuralEnzymes}
                  selectedBlock={selectedSEBlock}
                  selectedSubBlock={selectedSESubBlock}
                  dnaBlockSize={dnaBlockSize}
                  dnaType="SE"
                />
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section fill title="Emitter controls" width="180px">
              <EmitterControls />
              <Box textAlign="center">
                <Button
                  icon="radiation"
                  m={1}
                  onClick={() => act('pulseSERadiation')}>
                  Irradiate block
                </Button>
                <Button
                  m={1}
                  icon="triangle-exclamation"
                  onClick={() => act('pulseRadiation')}>
                  Pulse radiation
                </Button>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      );
    case 3:
      return (
        <Section title="Transfer buffers">
          {buffers.map((buf, index) => {
            return (
              <Box key={index} mb={3}>
                <Flex mb={1} align="baseline">
                  <Flex.Item grow bold preserveWhitespace>
                    {'Buffer ' + (index + 1)}
                  </Flex.Item>
                  <Flex.Item align="right">
                    <Button
                      icon="xmark"
                      mb={-5}
                      tooltip="Clear buffer"
                      color="bad"
                      disabled={!buf.data}
                      onClick={() =>
                        act('bufferOption', {
                          bufferId: index + 1,
                          bufferOption: 'clear',
                        })
                      }
                    />
                  </Flex.Item>
                </Flex>
                <Box
                  p={1}
                  style={{ border: '2px solid rgba(62, 97, 137, 0.5)' }}
                  backgroundColor="rgba(10, 10, 10, 0.5)">
                  <LabeledList>
                    {!!buf.data && (
                      <LabeledList.Item label="Label">
                        {buf.label}
                        <Button
                          icon="pen-to-square"
                          ml={1}
                          tooltip="Change label"
                          onClick={() =>
                            act('bufferOption', {
                              bufferId: index + 1,
                              bufferOption: 'changeLabel',
                            })
                          }
                        />
                      </LabeledList.Item>
                    )}
                    {!!buf.data && (
                      <LabeledList.Item label="Subject">
                        {buf.owner ? buf.owner : 'Unknown'}
                      </LabeledList.Item>
                    )}
                    {!!buf.data && (
                      <LabeledList.Item label="Stored data">
                        {buf.type === 'ui'
                          ? 'Unique identifier'
                          : 'Structural enzymes'}
                        {buf.ue ? ' + unique enzymes' : ''}
                      </LabeledList.Item>
                    )}
                    {!buf.data && (
                      <Box color="grey" pl={1}>
                        Empty.
                      </Box>
                    )}
                    <LabeledList.Item label="Options">
                      <Button
                        icon="download"
                        disabled={!hasDisk && !hasOccupant}
                        onClick={() =>
                          act('bufferOption', {
                            bufferId: index + 1,
                            bufferOption: 'loadFrom',
                          })
                        }>
                        Load from...
                      </Button>
                      <Button
                        icon="syringe"
                        disabled={!buf.data || !isInjectorReady}
                        tooltip={
                          !isInjectorReady
                            ? 'Preparing the next injector...'
                            : ''
                        }
                        onClick={() =>
                          act('bufferOption', {
                            bufferId: index + 1,
                            bufferOption: 'createInjector',
                          })
                        }>
                        Injector
                      </Button>
                      <Button
                        icon="syringe"
                        disabled={!buf.data || !isInjectorReady}
                        tooltip={
                          !isInjectorReady
                            ? 'Preparing the next injector...'
                            : ''
                        }
                        onClick={() =>
                          act('bufferOption', {
                            bufferId: index + 1,
                            bufferOption: 'createInjector',
                            createBlockInjector: 1,
                          })
                        }>
                        Block injector
                      </Button>
                      <Button
                        icon="radiation"
                        disabled={!buf.data || !hasOccupant}
                        onClick={() =>
                          act('bufferOption', {
                            bufferId: index + 1,
                            bufferOption: 'transfer',
                          })
                        }>
                        Transfer to occupant
                      </Button>
                      <Button
                        icon="floppy-disk"
                        disabled={!hasDisk || !buf.data}
                        onClick={() =>
                          act('bufferOption', {
                            bufferId: index + 1,
                            bufferOption: 'saveDisk',
                          })
                        }>
                        Export to disk
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                </Box>
              </Box>
            );
          })}
          <Box>
            <Flex mb={1} align="baseline">
              <Flex.Item grow bold preserveWhitespace>
                Data disk
              </Flex.Item>
              <Flex.Item align="right">
                <Button
                  icon="eject"
                  mb={-5}
                  mr={1}
                  tooltip="Eject disk"
                  disabled={!hasDisk}
                  onClick={() => act('ejectDisk')}
                />
              </Flex.Item>
              <Flex.Item align="right">
                <Button
                  icon="xmark"
                  mb={-5}
                  tooltip="Wipe disk"
                  color="bad"
                  disabled={!disk.data}
                  onClick={() => act('wipeDisk')}
                />
              </Flex.Item>
            </Flex>
            <Box
              p={1}
              style={{ border: '2px solid rgba(62, 97, 137, 0.5)' }}
              backgroundColor="rgba(10, 10, 10, 0.5)">
              <LabeledList>
                {!!disk.data && !!hasDisk && (
                  <LabeledList.Item label="Label">
                    {disk.label}
                  </LabeledList.Item>
                )}
                {!!disk.data && !!hasDisk && (
                  <LabeledList.Item label="Subject">
                    {disk.owner ? disk.owner : 'Unknown'}
                  </LabeledList.Item>
                )}
                {!!disk.data && !!hasDisk && (
                  <LabeledList.Item label="Stored data">
                    {disk.type === 'ui'
                      ? 'Unique identifier'
                      : 'Structural enzymes'}
                    {disk.ue ? ' + unique enzymes' : ''}
                  </LabeledList.Item>
                )}
                {!disk.data && !!hasDisk && (
                  <Box color="grey" pl={1}>
                    Disk is blank.
                  </Box>
                )}
                {!hasDisk && (
                  <Box color="grey" pl={1}>
                    No disk inserted.
                  </Box>
                )}
              </LabeledList>
            </Box>
          </Box>
        </Section>
      );
    case 4:
      return (
        <Section
          fill
          title="Chemicals injection"
          buttons={
            <Button
              icon="eject"
              disabled={!beakerMaxVolume}
              onClick={() => act('ejectBeaker')}>
              Eject beaker
            </Button>
          }>
          {!beakerMaxVolume ? (
            <Box color="average">No beaker detected</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label={beakerLabel ? beakerLabel : 'Beaker'}>
                <ProgressBar
                  value={beakerVolume}
                  maxValue={beakerMaxVolume}
                  maxWidth={20}>
                  {beakerVolume}/{beakerMaxVolume}
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Inject">
                <NumberInput
                  inline
                  value={injectAmount}
                  minValue={0}
                  maxValue={beakerVolume}
                  onChange={(e, value) =>
                    act('injectAmount', {
                      amount: value,
                    })
                  }
                />
                <Button
                  inline
                  icon="syringe"
                  disabled={!injectAmount || !occupant}
                  onClick={() => act('injectRejuvenators')}
                />
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      );
  }
};
