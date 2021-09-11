import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Flex } from '../components';
import { Window } from '../layouts';

export const OutfitEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { outfit, saveable, dummy64 } = data;
  return (
    <Window
      width={750}
      height={580}>
      <Window.Content>
        <Section
          fill>
          <Flex direction="row" height="100%">
            <Flex.Item mr={1} grow={1} width="350px">
              <Section fill textAlign="center">
                <Flex mb={2}>
                  <OutfitSlot name="Headgear" icon="hard-hat" slot="head" />
                  <OutfitSlot name="Glasses" icon="glasses" slot="glasses" />
                  <OutfitSlot name="Mask" icon="theater-masks" slot="mask" />
                </Flex>
                <Flex mb={2}>
                  <OutfitSlot name="Accessory" icon="stethoscope" slot="neck" />
                  <OutfitSlot name="L Ear" icon="headphones-alt" slot="l_ear" />
                  <OutfitSlot name="R Ear" icon="headphones-alt" slot="r_ear" />
                </Flex>
                <Flex mb={2}>
                  <OutfitSlot name="Uniform" icon="tshirt" slot="uniform" />
                  <OutfitSlot name="Suit" icon="user-tie" slot="suit" />
                  <OutfitSlot name="Gloves" icon="mitten" slot="gloves" />
                </Flex>
                <Flex mb={2}>
                  <OutfitSlot name="Suit Storage" icon="briefcase-medical" slot="suit_store" />
                  <OutfitSlot name="Back" icon="shopping-bag" slot="back" />
                  <OutfitSlot name="ID" icon="id-card-o" slot="id" />
                </Flex>
                <Flex mb={2}>
                  <OutfitSlot name="Belt" icon="band-aid" slot="belt" />
                  <OutfitSlot name="Left Hand" icon="hand-paper" slot="l_hand" />
                  <OutfitSlot name="Right Hand" icon="hand-paper" slot="r_hand" />
                </Flex>
                <Flex mb={2}>
                  <OutfitSlot name="Shoes" icon="socks" slot="shoes" />
                  <OutfitSlot name="Left Pocket" icon="envelope-open-o" iconRot={180} slot="l_pocket" />
                  <OutfitSlot name="Right Pocket" icon="envelope-open-o" iconRot={180} slot="r_pocket" />
                </Flex>
              </Section>
            </Flex.Item>
            <Flex.Item grow={1} direction="column" height="96%" width="400px">
              <Flex.Item grow={1}
                style={{
                  'overflow': 'hidden',
                  'white-space': 'nowrap',
                  'text-overflow': 'ellipsis',
                }}>
                <Button
                  ml={0.5}
                  color="transparent"
                  icon="pencil-alt"
                  title="Rename this outfit"
                  onClick={() => act("rename", {})} />
                {outfit.name}
                <Button
                  color="transparent"
                  icon="info"
                  title="Ctrl-click a button to select *any* item instead of what will probably fit in that slot."
                  tooltipPosition="bottom-start" />
                <Button
                  icon="code"
                  title="Edit this outfit on a VV window"
                  tooltipPosition="bottom-start"
                  onClick={() => act("vv")} />
                <Button
                  color={!saveable && "bad"}
                  icon={saveable ? "save" : "trash-alt"}
                  title={saveable
                    ? "Save this outfit to the custom outfit list"
                    : "Remove this outfit from the custom outfit list"}
                  tooltipPosition="bottom-start"
                  onClick={() => act(saveable ? "save" : "delete")} />
                <Button
                  icon="dice"
                  title="Random Equip"
                  tooltipPosition="bottom-start"
                  onClick={() => act("random")} />
              </Flex.Item>
              <Section
                fill
                title={name}
                textAlign="center">
                <Box
                  as="img"
                  height="85%"
                  src={`data:image/jpeg;base64,${dummy64}`}
                  style={{
                    '-ms-interpolation-mode': 'nearest-neighbor',
                  }} />
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

const OutfitSlot = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, icon, iconRot, slot } = props;
  const { outfit } = data;
  const currItem = outfit[slot];
  return (
    <Flex.Item grow={1} basis={0}>
      <Button fluid height={2}
        bold
        // todo: intuitive way to clear items
        onClick={e => act(e.ctrlKey ? "ctrlClick" : "click", { slot })} >
        <Icon name={icon} rotation={iconRot} />
        {name}
      </Button>
      <Box height="32px">
        {currItem?.sprite && (
          <>
            <Box
              as="img"
              src={`data:image/jpeg;base64,${currItem?.sprite}`}
              title={currItem?.desc}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }} />
            <Icon
              position="absolute"
              name="times"
              color="label"
              style={{ cursor: 'pointer' }}
              onClick={() => act("clear", { slot })} />
          </>
        )}
      </Box>
      <Box
        color="label"
        style={{
          'overflow': 'hidden',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
        }}
        title={currItem?.path}>
        {currItem?.name || "Empty"}
      </Box>
    </Flex.Item>
  );
};
