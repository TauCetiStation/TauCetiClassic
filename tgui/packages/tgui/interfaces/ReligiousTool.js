import { toTitleCase, capitalize } from 'common/string';
import { useBackend, useSharedState } from '../backend';
import { BlockQuote, Box, Button, Collapsible, Icon, Section, Tabs, Flex } from '../components';
import { Window } from '../layouts';

// TODO: REMOVE THIS!!!!
import { createLogger } from '../logging';
const logger = createLogger('aboba');

const ASPECT2COLOR = []

export const ReligiousTool = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    sects,
    encyclopedia,
  } = data;

  encyclopedia.ASPECTS.map(aspect => (ASPECT2COLOR[aspect.name] = aspect.color))

  return (
    <Window
      width={1000}
      height={700}>
      <Window.Content scrollable>
        <Flex vertical fill>
          <Tabs textAlign="center" fluid>
            <Tabs.Tab
              selected={tab === 1}
              onClick={() => setTab(1)}>
              Sect <Icon name="place-of-worship" />
            </Tabs.Tab>
            {!sects && (
              <Tabs.Tab
                selected={tab === 2}
                onClick={() => setTab(2)}>
                Rites <Icon name="pray" />
              </Tabs.Tab>
            )}
            <Tabs.Tab
              selected={tab === 3}
              onClick={() => setTab(3)}>
              Encyclopedia <Icon name="book-open" />
            </Tabs.Tab>
          </Tabs>
        </Flex>
        <Flex.Item grow={1}>
          {tab === 1 && (
            !!sects && (
              <SectSelectTab />
            ) || (
              <SectTab />
            )
          )}
          {tab === 2 && (
            <RiteTab />
          )}
          {tab === 3 && (
            <Encyclopedia />
          )}
        </Flex.Item>
      </Window.Content>
    </Window>
  );
};

const SectTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    desc,
    favor,
    deity,
  } = data;
  return (
    <Section fill>
      <Flex fill vertical fontSize="15px" textAlign="center">
        <Box>
          <Flex.Item fontSize="32px" textAlign="center">
            {" " + name + " "}
          </Flex.Item>
          <Flex.Item mb={2} textAlign="center">
            {desc}
          </Flex.Item>
          <Flex.Item color={favor === 0 ? "white" : "green"}>
            {favor}
          </Flex.Item>
        </Box>
      </Flex>
    </Section>
  );
};

const GetAspectBox = (title, aspects, need_br = true) => {
  if (!aspects)
    return null;
  return (
    <Box>
      <Box bold>
        {title}
      </Box>
      <Box ml={3}>
        <ui>
          {Object.keys(aspects).map(aspect => (
            <li>
              <Box color={ASPECT2COLOR[aspect]}>
                {aspect} = {aspects[aspect]}
              </Box>
            </li>
          ))}
        </ui>
        {need_br ? <br /> : ""}
      </Box>
    </Box>
  )
}

const GetCostsBox = (favor, piety, need_br = true) => {
  if (!favor && !piety)
    return null;
  return (
    <Box>
      <Box bold>
        Costs:
      </Box>
      <Box ml={3}>
        <ui>
          {!!favor && (
            <li>
              <Box color="yellow">
                {favor} favor.
              </Box>
            </li>
          )}
          {!!piety && (
            <li>
              <Box color="pink">
                {piety} piety.
              </Box>
            </li>
          )}
        </ui>
      </Box>
      {need_br ? <br /> : ""}
    </Box>
  )
}

const SectSelectTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    sects,
  } = data;

  return (
    <Section fill title="Sect Select">
      <Flex direction="column">
        {sects.map(sect => (
          <Collapsible
            title={(
              <Flex mt={-3.3} ml={3}>
                <Flex.Item>
                </Flex.Item>
                <Flex.Item grow>
                  {sect.name}
                </Flex.Item>
              </Flex>
            )}
            color="transparent">
            <Flex.Item key={sect} >
              <BlockQuote>
                <Box>
                  <Box bold>
                    {sect.desc}
                  </Box>
                  <Box>
                    {sect.aspect_preset || sect.aspects_count ? <br /> : ""}
                    {GetAspectBox("Aspects:", sect.aspect_preset)}
                    {sect.aspects_count && (
                      <Box>
                        You can choose {sect.aspects_count} aspects.
                      </Box>
                    )}
                  </Box>
                </Box>
              </BlockQuote>
              <Button
                mt={2}
                textAlign="center"
                icon="plus"
                fluid
                onClick={() => act('sect_select', {
                  path: sect.path,
                })}>
                {sect.aspects_count ? "Create" : "Select"} {sect.name}
              </Button>
            </Flex.Item>
          </Collapsible>
        ))}
      </Flex>
    </Section>
  );
};

const Encyclopedia = (props, context) => {
  const { act, data } = useBackend(context);
  const [cat, setCat] = useSharedState(context, 'cat', '');
  const {
    encyclopedia,
  } = data;
  const {
    RITES,
    SECTS,
    ASPECTS,
  } = encyclopedia;

  // because space
  const CODE2STR = {
    GOD_SPELLS: 'GOD SPELLS',
    HOLY_REAGENTS: 'HOLY REAGENTS',
    FAITH_REACTIONS: 'FAITH REACTIONS',
  }

  const fontsize = "14px"
  // about categories here code\modules\religion\encyclopedia.dm
  return (
    <Flex height="100%" m={1} mr={0} >
      <Tabs vertical={1} fontSize={fontsize}>
        {Object.keys(encyclopedia).map(category => (
          <Tabs.Tab
            fluid
            key={category}
            selected={cat === category}
            onClick={() => setCat(category)}>
            {toTitleCase(category)}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Flex.Item
        m={1} mr={0}
        position="relative"
        grow={1}>

        {cat === "RITES" && (RITES.map(rite => (
          <Section
            title={rite.name}>
            <BlockQuote fontSize={fontsize}>
              <Box>
                {rite.desc.replace(/<[\/]?i>/g, '')}
              </Box>
              <br />
              <Box>
                <b>Length:</b> {rite.ritual_length / 10} seconds.
              </Box>
              <Box
                color={rite.can_talismaned ? "green" : "red"}>
                Can{rite.can_talismaned ? "" : "'t"} be talismaned.
              </Box>
              <br />
              {GetAspectBox("Needed Aspects:", rite.needed_aspects, false)}
              {(!!rite.favor_cost || !!rite.piety_cost) && <br />}
              {GetCostsBox(rite.favor_cost, rite.piety_cost, false)}
              <Box>
                {!!rite.tips.length && (
                  <Box>
                    <Box bold> <br />
                      Tips:
                    </Box>
                    <Box ml={3}>
                      <ui>
                        {rite.tips.map(tip => (
                          <li>
                            <Box>
                              {tip.replace(/<[\/]?i>/g, '')}
                            </Box>
                          </li>
                        ))}
                      </ui>
                    </Box>
                  </Box>
                )}
              </Box>
            </BlockQuote>
          </Section>
        )))}
        {cat === "SECTS" && (SECTS.map(sect => (
          <Section
            title={sect.name}>
            <BlockQuote fontSize={fontsize}>
              <Box>
                {sect.desc}
              </Box><br />
              {GetAspectBox("Aspect Preset:", sect.aspect_preset, false)}
              {sect.aspects_count && (
                <Box>
                  You can choose {sect.aspects_count} aspects.
                </Box>
              )}
            </BlockQuote>
          </Section>
        )))}

        {cat === "ASPECTS" && (ASPECTS.map(aspect => (
          <Section
            color={ASPECT2COLOR[aspect.name]}
            title={aspect.name}>
            <BlockQuote fontSize={fontsize}>
              <Box>
                {aspect.desc}
              </Box>
              {aspect.god_desc && (
                <Box> <br />
                  {aspect.god_desc}
                </Box>
              )}
            </BlockQuote>
          </Section>
        )))}

        {cat === "GOD SPELLS" && (encyclopedia[CODE2STR.GOD_SPELLS].map(spell => (
          <Section
            title={spell.name}>
            <BlockQuote fontSize={fontsize}>
              {GetAspectBox("Needed Aspects:", spell.needed_aspects)}
              {GetCostsBox(spell.favor_cost)}
              <Box>
                Cooldown: {spell.charge_max / 10} seconds
              </Box>
            </BlockQuote>
          </Section>
        )))}

        {cat === "HOLY REAGENTS" && (encyclopedia[CODE2STR.HOLY_REAGENTS].map(reagent => (
          <Section
            title={reagent.name}>
            <BlockQuote fontSize={fontsize}>
              {GetAspectBox("Needed Aspects:", reagent.needed_aspects, false)}
            </BlockQuote>
          </Section>
        )))}

        {cat === "FAITH REACTIONS" && (encyclopedia[CODE2STR.FAITH_REACTIONS].map(reaction => (
          <Section
            title={capitalize(reaction.convertable_id) + " to " + capitalize(reaction.result_id)}>
            <BlockQuote fontSize={fontsize}>
              {GetAspectBox("Needed Aspects:", reaction.needed_aspects, false)}
              {!!reaction.favor_cost ? <br /> : ""}
              {GetCostsBox(reaction.favor_cost, 0, false)}
            </BlockQuote>
          </Section>
        )))}

      </Flex.Item>
    </Flex>
  );
};

const RiteTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    rites,
    deity,
    icon,
    alignment,
    favor,
  } = data;
  return (<div>kek</div>)
}
  /*
return (
<>
{!rites.length && (
<Section fill >
<Dimmer>
<Flex vertical>
<Flex.Item textAlign="center">
<Icon
color={ALIGNMENT2COLOR[alignment]}
name={icon}
size={10}
/>
</Flex.Item>
<Flex.Item fontSize="18px" color={ALIGNMENT2COLOR[alignment]}>
{deity} does not have any invocations.
</Flex.Item>
</Flex>
</Dimmer>
</Section>
)}
<Flex vertical>
{rites.map(rite => (
<Flex.Item key={rite}>
<Section
title={rite.name}
buttons={(
<Button
fontColor="white"
iconColor={ALIGNMENT2COLOR[alignment]}
disabled={favor < rite.favor}
color="transparent"
icon="arrow-right"
onClick={() => act('perform_rite', {
rite_name: rite.name,
})} >
Invoke
</Button>
)} >
<Box
color={favor < rite.favor ? "red" : "grey"}
mb={0.5}>
<Icon name="star" /> Costs {rite.favor} favor.
</Box>
<BlockQuote>
{rite.desc}
</BlockQuote>
</Section>
</Flex.Item>
))}
</Flex>
</>
);
};
*/
