import { createSearch } from 'common/string';
import { useBackend, useLocalState } from "../backend";
import { Box, Button, Collapsible, Dropdown, Flex, Input, Table, Section } from '../components';
import { Window } from "../layouts";
import { refocusLayout } from '../layouts';
import { MiningUser } from './common/Mining';
import { classes } from 'common/react';

const sortTypes = {
  'Alphabetical': (a, b) => a - b,
  'By availability': (a, b) => -(a.affordable - b.affordable),
  'By price': (a, b) => a.price - b.price,
};

export const MiningVendor = (props, context) => {
  return (
    <Window width={410} height={450}>
      <Window.Content className="Layout__content--flexColumn" scrollable>
        <MiningUser
          insertIdText="Please insert an ID in order to make purchases." />
        <MiningVendorSearch />
        <MiningVendorItems />
      </Window.Content>
    </Window>
  );
};


const MiningVendorItems = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_id,
    id,
    items,
  } = data;
  // Search thingies
  const [
    searchText,
    _setSearchText,
  ] = useLocalState(context, 'search', '');
  const [
    sortOrder,
    _setSortOrder,
  ] = useLocalState(context, 'sort', 'Alphabetical');
  const [
    descending,
    _setDescending,
  ] = useLocalState(context, 'descending', false);
  const searcher = createSearch(searchText, item => {
    return item[0];
  });

  let has_contents = false;
  let contents = Object.entries(items).map((kv, _i) => {
    let items_in_cat = Object.entries(kv[1])
      .filter(searcher)
      .map(kv2 => {
        kv2[1].affordable = has_id && id.points >= kv2[1].price;
        return kv2[1];
      })
      .sort(sortTypes[sortOrder]);
    if (items_in_cat.length === 0) {
      return;
    }
    if (descending) {
      items_in_cat = items_in_cat.reverse();
    }

    has_contents = true;
    return (
      <MiningVendorItemsCategory
        key={kv[0]}
        title={kv[0]}
        items={items_in_cat}
      />
    );
  });
  return (
    <Flex.Item grow="1" overflow="auto">
      <Section onClick={e => refocusLayout()}>
        {has_contents
          ? contents : (
            <Box color="label">
              No items matching your criteria was found!
            </Box>
          )}
      </Section>
    </Flex.Item>
  );
};

const MiningVendorSearch = (props, context) => {
  const [
    _searchText,
    setSearchText,
  ] = useLocalState(context, 'search', '');
  const [
    _sortOrder,
    setSortOrder,
  ] = useLocalState(context, 'sort', '');
  const [
    descending,
    setDescending,
  ] = useLocalState(context, 'descending', false);
  return (
    <Box mb="0.5rem">
      <Flex width="100%">
        <Flex.Item grow="1" mr="0.5rem">
          <Input
            placeholder="Search by item name.."
            width="100%"
            autoFocus
            onInput={(_e, value) => setSearchText(value)}
          />
        </Flex.Item>
        <Flex.Item basis="30%">
          <Dropdown
            selected="Alphabetical"
            options={Object.keys(sortTypes)}
            width="100%"
            lineHeight="19px"
            onSelected={v => setSortOrder(v)} />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon={descending ? "arrow-down" : "arrow-up"}
            height="19px"
            tooltip={descending ? "Descending order" : "Ascending order"}
            tooltipPosition="bottom-left"
            ml="0.5rem"
            onClick={() => setDescending(!descending)}
          />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const MiningVendorItemsCategory = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    title,
    items,
    ...rest
  } = properties;
  return (
    <Collapsible open title={title} {...rest}>
      {items.map(item => (
        <Table key={item.name}>
          <Table.Cell collapsing>
            <span
              className={classes([
                'equipment_locker32x32',
                item.path,
              ])}
              style={{
                'vertical-align': 'middle',
                'horizontal-align': 'middle',
              }} />
          </Table.Cell>
          <Table.Cell>
            {item.name}
          </Table.Cell>
          <Table.Cell collapsing textAlign="center">
            <Button
              fluid
              icon="certificate"
              disabled={!data.has_id || data.id.points < item.price}
              content={item.price.toLocaleString('en-US')}
              onClick={() => act('purchase', {
                cat: title,
                name: item.name,
              })}
            />
          </Table.Cell>
        </Table>
      ))}
    </Collapsible>
  );
};
