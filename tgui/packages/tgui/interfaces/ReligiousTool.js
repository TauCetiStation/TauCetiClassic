import { toTitleCase, capitalize, createSearch } from 'common/string';
import { useBackend, useSharedState } from '../backend';
import { BlockQuote, Box, Button, Collapsible, Icon, Section, Tabs, Stack, Input } from '../components';
import { Window } from '../layouts';

const ASPECT2COLOR = [];

const GetTab = (tab, sects) => {
  if (tab === 3) {
    return <Encyclopedia />;
  }

  if (sects) {
    return <SectSelectTab />;
  }

  if (tab === 1) {
    return <ReligionTab />;
  }

  if (tab === 2) {
    return <RiteTab />;
  }
};

export const ReligiousTool = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 1);
  const {
    sects,
    encyclopedia,
  } = data;

  encyclopedia.ASPECTS.map(aspect => (ASPECT2COLOR[aspect.name] = aspect.color));

  return (
    <Window
      width={1000}
      height={700}>
      <Window.Content fontSize="14px">
        <Tabs textAlign="center">
          <Stack direction="raw" width="100%">
            <Stack.Item grow>
              <Tabs.Tab
                fluid
                selected={tab === 1}
                onClick={() => setTab(1)}>
                Religion <Icon name="place-of-worship" />
              </Tabs.Tab>
            </Stack.Item>
            {!sects && (
              <Stack.Item grow>
                <Tabs.Tab
                  fluid
                  selected={tab === 2}
                  onClick={() => setTab(2)}>
                  Rites <Icon name="pray" />
                </Tabs.Tab>
              </Stack.Item>
            )}
            <Stack.Item grow>
              <Tabs.Tab
                fluid
                selected={tab === 3}
                onClick={() => setTab(3)}>
                Encyclopedia <Icon name="book-open" />
              </Tabs.Tab>
            </Stack.Item>
          </Stack>
        </Tabs>
        <Stack.Item>
          {GetTab(tab, sects)}
        </Stack.Item>
      </Window.Content>
    </Window>
  );
};

const GetInfoItem = (title, list) => {
  let listItems = null;
  if (!list.length) {
    listItems = (
      <Box color="gray">
        Nothing.
      </Box>
    );
  } else {
    listItems = list.map(elem => (
      <li key={elem}>
        <Box>
          {toTitleCase(elem)}
        </Box>
      </li>));
  }

  return (
    <Stack.Item width="100%" height={22}>
      <Section
        title={title}
        fill={1}>
        <Box
          textAlign="left"
          ml={!list.length ? 0 : 3}>
          <ui>{listItems}</ui>
        </Box>
      </Section>
    </Stack.Item >
  );
};

const ReligionTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    deities,
    favor,
    piety,
    max_favor,
    passive_favor_gain,
    aspects,
    techs,
    god_spells,
    holy_reagents,
    faith_reactions,
  } = data;

  return (
    <Section
      title={name}
      textAlign="center">
      <Box>
        {deities}
      </Box>
      <Box>
        <Stack mt={2}>
          <Stack.Item width="100%" height={22}>
            <Section
              title="Resources"
              fill={1}>
              <Box
                textAlign="left"
                ml={3}>
                <ui>
                  <li>
                    <Box color="yellow">
                      Favor: {favor} / {max_favor}
                      <span style={{ 'color': 'gray', 'font-size': '8pt' }}> (+{passive_favor_gain})</span>
                    </Box>
                  </li>
                  <li>
                    <Box color="pink">
                      Piety: {piety}
                    </Box>
                  </li>
                </ui>
              </Box>
            </Section>
          </Stack.Item>
          <Stack.Item width="100%" height={22}>
            <Section
              title="Aspects"
              fill={1}>
              <Box
                textAlign="left">
                {GetAspectBox("", aspects)}
              </Box>
            </Section>
          </Stack.Item>
          {GetInfoItem("Techs", techs)}
        </Stack>
        <Stack>
          {GetInfoItem("God Spells", god_spells)}
          {GetInfoItem("Holy Reagents", holy_reagents)}
          {GetInfoItem("Faith Reactions", faith_reactions)}
        </Stack>
      </Box>
    </Section >
  );
};

const GetAspectBox = (title, aspects, need_br = true) => {
  if (!aspects) {
    return null;
  }
  return (
    <Box>
      <Box bold>
        {title}
      </Box>
      <Box ml={3}>
        <ui>
          {Object.keys(aspects).map(aspect => (
            <li key={aspect}>
              <Box color={ASPECT2COLOR[aspect]}>
                {aspect} = {aspects[aspect]}
              </Box>
            </li>
          ))}
        </ui>
        {need_br ? <br /> : ""}
      </Box>
    </Box>
  );
};

const GetCostsBox = (favor, piety, need_br = true) => {
  if (!favor && !piety) {
    return null;
  }
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
                {favor} favor
              </Box>
            </li>
          )}
          {!!piety && (
            <li>
              <Box color="pink">
                {piety} piety
              </Box>
            </li>
          )}
        </ui>
      </Box>
      {need_br ? <br /> : ""}
    </Box>
  );
};

const SectSelectTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    sects,
    holds_religious_tool,
  } = data;

  return (
    <Section fill title="Sect Select">
      <Stack vertical>
        {sects.map(sect => (
          <Collapsible key={sect.name}
            title={(
              <b>{sect.name}</b>
            )}
            color="transparent">
            <Stack.Item key={sect.name} >
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
                disabled={!holds_religious_tool}
                onClick={() => act('sect_select', {
                  path: sect.path,
                })}>
                {sect.aspects_count ? "Create" : "Select"} {sect.name}
              </Button>
            </Stack.Item>
          </Collapsible>
        ))}
      </Stack>
    </Section>
  );
};

const Encyclopedia = (props, context) => {
  const { act, data } = useBackend(context);
  const [cat, setCat] = useSharedState(context, 'cat', '');
  const {
    encyclopedia,
  } = data;

  // about categories here code\modules\religion\encyclopedia.dm
  return (
    <Stack>
      <Tabs vertical={1}>
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
      <Section
        height={52}
        fill
        scrollable
        width="100%">
        <Stack.Item>
          {cat === "RITES" && (
            <ERitesTab />
          )}
          {cat === "SECTS" && (
            <ESectsTab />
          )}
          {cat === "ASPECTS" && (
            <EAspectsTab />
          )}
          {cat === "GOD SPELLS" && (
            <ESpellsTab />
          )}
          {cat === "HOLY REAGENTS" && (
            <EReagentsTab />
          )}
          {cat === "FAITH REACTIONS" && (
            <EReactionsTab />
          )}
        </Stack.Item>
      </Section>
    </Stack>
  );
};

const ERitesTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    encyclopedia,
  } = data;
  const {
    RITES,
  } = encyclopedia;

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, rite => rite.name);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && RITES
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || RITES;

  return (
    <Box>
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      {items.map(rite => (
        <Section key={rite.name}
          title={rite.name}>
          <BlockQuote>
            <Box>
              {rite.desc.replace(/<[/]?i>/g, '')}
            </Box>
            <br />
            <Box>
              <b>Length:</b> {rite.ritual_length / 10} seconds.
            </Box>
            <Box
              color={rite.can_talismaned ? "green" : "red"}>
              Can{rite.can_talismaned ? "" : "'t"} be talismaned.
            </Box>
            {!rite.needed_aspects ? "" : <br />}
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
                        <li key={tip}>
                          <Box>
                            {tip.replace(/<[/]?i>/g, '')}
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
      ))}
    </Box>);
};

const ESectsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    encyclopedia,
  } = data;
  const {
    SECTS,
  } = encyclopedia;

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, sect => sect.name);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && SECTS
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || SECTS;

  return (
    <Box>
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      {items.map(sect => (
        <Section key={sect.name}
          title={sect.name}>
          <BlockQuote>
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
      ))}
    </Box>
  );
};

const EAspectsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    encyclopedia,
  } = data;
  const {
    ASPECTS,
  } = encyclopedia;

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, aspect => aspect.name);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && ASPECTS
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || ASPECTS;

  return (
    <Box>
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      {items.map(aspect => (
        <Section key={aspect.name}
          color={ASPECT2COLOR[aspect.name]}
          title={aspect.name}>
          <BlockQuote>
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
      ))}
    </Box>
  );
};

const ESpellsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    encyclopedia,
  } = data;

  const GOD_SPELLS = encyclopedia["GOD SPELLS"];

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, spell => spell.name);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && GOD_SPELLS
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || GOD_SPELLS;

  return (
    <Box>
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      {items.map(spell => (
        <Section key={spell.name}
          title={spell.name}>
          <BlockQuote>
            {GetAspectBox("Needed Aspects:", spell.needed_aspects)}
            {GetCostsBox(spell.favor_cost)}
            <Box>
              Cooldown: {spell.charge_max / 10} seconds
            </Box>
          </BlockQuote>
        </Section>
      ))}
    </Box>
  );
};

const EReagentsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    encyclopedia,
  } = data;

  const HOLY_REAGENTS = encyclopedia["HOLY REAGENTS"];

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, reagent => reagent.name);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && HOLY_REAGENTS
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || HOLY_REAGENTS;

  return (
    <Box>
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      {items.map(reagent => (
        <Section key={reagent.name}
          title={reagent.name}>
          <BlockQuote>
            {GetAspectBox("Needed Aspects:", reagent.needed_aspects, false)}
          </BlockQuote>
        </Section>
      ))}
    </Box>
  );
};

const EReactionsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    encyclopedia,
  } = data;

  const FAITH_REACTIONS = encyclopedia["FAITH REACTIONS"];

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, reaction => reaction.convertable_id + " to " + reaction.result_id);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && FAITH_REACTIONS
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || FAITH_REACTIONS;

  return (
    <Box>
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      {items.map(reaction => (
        <Section key={capitalize(reaction.convertable_id) + " to " + capitalize(reaction.result_id)}
          title={capitalize(reaction.convertable_id) + " to " + capitalize(reaction.result_id)}>
          <BlockQuote>
            {GetAspectBox("Needed Aspects:", reaction.needed_aspects, false)}
            {reaction.favor_cost ? <br /> : ""}
            {GetCostsBox(reaction.favor_cost, 0, false)}
          </BlockQuote>
        </Section>
      ))}
    </Box>
  );
};

const RiteTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    rites,
    favor,
    piety,
    can_talismaning,
    holds_religious_tool,
  } = data;

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, 'searchText', '');

  const testSearch = createSearch(searchText, rite => rite.name);

  const items = searchText.length > 0
    // Flatten all categories and apply search to it
    && rites
      .filter(testSearch)
    // If none of that results in a list, return an empty list
    || rites;

  return (
    <Section
      height={52}
      fill
      scrollable
      width="100%">
      <Input
        autoFocus
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      <Stack vertical mt={2}>
        {items.map(rite => (
          <Stack.Item key={rite.name}>
            <Section
              title={rite.name}
              buttons={(
                <>
                  <Button
                    fontColor="white"
                    disabled={!holds_religious_tool || favor < rite.favor_cost || piety < rite.piety_cost}
                    icon="arrow-right"
                    onClick={() => act('perform_rite', {
                      rite_name: rite.name,
                    })} >
                    Invoke
                  </Button>
                  <Button
                    fontColor="white"
                    tooltip={
                      rite.favor_cost * 2 + " favor"
                      + (rite.piety_cost > 0 ? " " + rite.piety_cost + " piety" : "")
                    }
                    disabled={
                      !can_talismaning || !rite.can_talismaned
                      || favor < rite.favor_cost * 2 || piety < rite.piety_cost * 2
                    }
                    icon="scroll"
                    onClick={() => act('talismaning_rite', {
                      rite_name: rite.name,
                    })} >
                    Talismaning
                  </Button>
                </>
              )}>
              <Box
                color={favor < rite.favor_cost ? "red" : "yellow"}
                mb={0.5}>
                <Icon name="star" /> Costs: {rite.favor_cost} favor{rite.piety_cost > 0
                  ? " and " + rite.piety_cost + " piety" : ""}.
              </Box>
              <BlockQuote>
                <Box>
                  {rite.desc}
                </Box>
                <br />
                <Box>
                  Power: {rite.power}
                </Box>
                <Box>
                  {!!rite.tips.length && (
                    <Box>
                      <Box bold> <br />
                        Tips:
                      </Box>
                      <Box ml={3}>
                        <ui>
                          {rite.tips.map(tip => (
                            <li key={tip}>
                              <Box>
                                {tip.replace(/<[/]?i>/g, '')}
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
          </Stack.Item>
        ))}
      </Stack>
    </Section >
  );
};
