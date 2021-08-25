import { filter, map, sortBy, uniq } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Input, Section, Flex, Tabs } from '../components';
import { Window } from '../layouts';

// here's an important mental define:
// custom outfits give a ref keyword instead of path
const getOutfitKey = outfit => outfit.path || outfit.ref;

const useOutfitTabs = (context, categories) => {
  return useLocalState(context, 'selected-tab', categories[0]);
};

export const SelectEquipment = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    name,
    icon64,
    current_outfit,
    favorites,
  } = data;

  const isFavorited = entry => favorites?.includes(entry.path);

  const outfits = map(entry => ({
    ...entry,
    favorite: isFavorited(entry),
  }))([
    ...data.outfits,
    ...data.custom_outfits,
  ]);

  // even if no custom outfits were sent, we still want to make sure there's
  // at least a 'Custom' tab so the button to create a new one pops up
  const categories = uniq([
    ...outfits.map(entry => entry.category),
    'Custom',
  ]);
  const [tab] = useOutfitTabs(context, categories);

  const [searchText, setSearchText] = useLocalState(
    context, 'searchText', '');
  const searchFilter = createSearch(searchText, entry => (
    entry.name + entry.path
  ));

  const visibleOutfits = flow([
    filter(entry => entry.category === tab),
    filter(searchFilter),
    sortBy(
      entry => !entry.favorite,
      entry => !entry.priority,
      entry => entry.name
    ),
  ])(outfits);

  const getOutfitEntry = current_outfit => outfits.find(outfit => (
    getOutfitKey(outfit) === current_outfit
  ));

  const currentOutfitEntry = getOutfitEntry(current_outfit);

  return (
    <Window
      width={650}
      height={415}>
      <Window.Content>
        <Flex direction="row" height="100%" >
          <Flex.Item mr={1} width="250px">
            <Flex direction="column" height="100%">
              <Flex.Item>
                <Input
                  fluid
                  autoFocus
                  placeholder="Search"
                  value={searchText}
                  onInput={(e, value) => setSearchText(value)} />
              </Flex.Item>
              <Flex.Item mt={1}>
                <DisplayTabs categories={categories} />
              </Flex.Item>
              <Flex.Item mt={1} grow={1} basis={0}>
                <OutfitDisplay
                  entries={visibleOutfits}
                  currentTab={tab} />
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item grow={1} basis={0}>
            <Flex direction="column" height="100%">
              <Flex.Item>
                <Section>
                  <CurrentlySelectedDisplay entry={currentOutfitEntry} />
                </Section>
              </Flex.Item>
              <Flex.Item mt={1} grow={1} direction="column">
                <Section
                  fill
                  title={name}
                  textAlign="center">
                  <Box
                    as="img"
                    m={0}
                    src={`data:image/jpeg;base64,${icon64}`}
                    height="100%"
                    style={{
                      '-ms-interpolation-mode': 'nearest-neighbor',
                    }} />
                </Section>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const DisplayTabs = (props, context) => {
  const { categories } = props;
  const [tab, setTab] = useOutfitTabs(context, categories);
  return (
    <Tabs textAlign="center">
      {categories.map(category => (
        <Tabs.Tab
          key={category}
          selected={tab === category}
          onClick={() => setTab(category)}>
          {category}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const OutfitDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_outfit } = data;
  const { entries, currentTab } = props;
  return (
    <Section fill scrollable>
      {entries.map(entry => (
        <Button
          key={getOutfitKey(entry)}
          fluid
          ellipsis
          icon={entry.favorite && 'star'}
          iconColor="gold"
          content={entry.name}
          title={entry.path || entry.name}
          selected={getOutfitKey(entry) === current_outfit}
          onClick={() => act('preview', { path: getOutfitKey(entry) })} />
      ))}
      {currentTab === "Custom" && (
        <Button
          color="transparent"
          icon="plus"
          fluid
          onClick={() => act('customoutfit')}>
          Create a custom outfit...
        </Button>
      )}
    </Section>
  );
};

const CurrentlySelectedDisplay = (props, context) => {
  const { act, data } = useBackend(context);
  const { current_outfit } = data;
  const { entry } = props;
  return (
    <Flex align="center">
      {entry?.path && (
        <Flex.Item mt={1}>
          <Icon
            size={1.6}
            name={entry.favorite ? 'star' : 'star-o'}
            color="gold"
            style={{ cursor: 'pointer' }}
            onClick={() => act('togglefavorite', {
              path: entry.path,
            })} />
        </Flex.Item>
      )}
      <Flex.Item mt={1} grow={1} basis={0}>
        <Box color="label" mr={2}>
          Currently selected:
        </Box>
        <Box
          title={entry?.path}
          style={{
            'overflow': 'hidden',
            'white-space': 'nowrap',
            'text-overflow': 'ellipsis',
          }}>
          {entry?.name}
        </Box>
      </Flex.Item>
      <Flex.Item mt={1}>
        <Button
          mr={0.8}
          lineHeight={2}
          color="green"
          onClick={() => act('applyoutfit', {
            path: current_outfit,
          })}>
          Confirm
        </Button>
      </Flex.Item>
    </Flex>
  );
};
