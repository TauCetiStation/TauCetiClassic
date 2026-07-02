import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  Section,
} from '../components';
import { Window } from '../layouts';

export const PharmacyFridge = (props, context) => {
  const { act, data } = useBackend(context);
  const contents = data.contents || [];
  const {
    is_staff,
    can_set_prices,
    vend_pending,
    pending_price,
    pending_item,
  } = data;

  const [editingPrice, setEditingPrice] = useLocalState(
    context,
    'editingPrice',
    null
  );
  const [priceInput, setPriceInput] = useLocalState(context, 'priceInput', '');

  const submitPrice = (vend) => {
    const price = parseInt(priceInput, 10);
    if (!isNaN(price) && price >= 0) {
      act('set_price', { index: vend, price });
    }
    setEditingPrice(null);
  };

  return (
    <Window width={600} height={640}>
      <Window.Content scrollable>
        <NoticeBox>
          {vend_pending
            ? `Please swipe your ID card to pay ${pending_price} cr. for ${pending_item}.`
            : is_staff
              ? 'Medical access confirmed. Free dispensing and price setting available.'
              : 'Restricted access. Purchase items at prices set by the chemist.'}
        </NoticeBox>
        <Section title="Storage">
          {contents.length ? (
            <LabeledList>
              {contents.map((item) => (
                <LabeledList.Item label="Vend" key={item.vend}>
                  <Flex align="center" justify="space-between">
                    <Flex.Item width="45%">
                      {is_staff ? (
                        <>
                          <Button
                            content="x1"
                            icon="circle-down"
                            onClick={() =>
                              act('vend', {
                                index: item.vend,
                                amount: 1,
                              })
                            }
                          />
                          {item.quantity > 5 && (
                            <Button
                              content="x5"
                              icon="circle-down"
                              onClick={() =>
                                act('vend', {
                                  index: item.vend,
                                  amount: 5,
                                })
                              }
                            />
                          )}
                          {item.quantity > 10 && (
                            <Button
                              content="x10"
                              icon="circle-down"
                              onClick={() =>
                                act('vend', {
                                  index: item.vend,
                                  amount: 10,
                                })
                              }
                            />
                          )}
                          {item.quantity > 25 && (
                            <Button
                              content="x25"
                              icon="circle-down"
                              onClick={() =>
                                act('vend', {
                                  index: item.vend,
                                  amount: 25,
                                })
                              }
                            />
                          )}
                          {item.quantity > 1 && (
                            <Button
                              content="All"
                              icon="circle-down"
                              onClick={() =>
                                act('vend', {
                                  index: item.vend,
                                  amount: item.quantity,
                                })
                              }
                            />
                          )}
                          {!!can_set_prices && (
                            <Button
                              content="Set Price"
                              icon="dollar-sign"
                              ml={1}
                              onClick={() => {
                                setEditingPrice(item.vend);
                                setPriceInput(item.price || '');
                              }}
                            />
                          )}
                        </>
                      ) : item.price > 0 ? (
                        <Button
                          content={`Buy (${item.price} cr.)`}
                          icon="shopping-cart"
                          onClick={() =>
                            act('buy', {
                              index: item.vend,
                              amount: 1,
                            })
                          }
                        />
                      ) : (
                        <Button content="Not for sale" icon="ban" disabled />
                      )}
                      {editingPrice === item.vend && (
                        <Box mt={1}>
                          <Input
                            value={priceInput}
                            width="70px"
                            onInput={(e, val) => setPriceInput(val)}
                            onEnter={() => submitPrice(item.vend)}
                          />
                          {' cr. '}
                          <Button
                            icon="check"
                            color="good"
                            onClick={() => submitPrice(item.vend)}
                          />
                          <Button
                            icon="times"
                            onClick={() => setEditingPrice(null)}
                          />
                        </Box>
                      )}
                    </Flex.Item>
                    <Flex.Item>{item.display_name}</Flex.Item>
                    <Flex.Item italic width="25%" textAlign="right">
                      {item.quantity + ' available'}
                      {item.price > 0 && <div>{item.price + ' cr. each'}</div>}
                      {!item.price && <div>no price set</div>}
                    </Flex.Item>
                  </Flex>
                  <LabeledList.Divider />
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            'No products loaded.'
          )}
          {!!vend_pending && (
            <Button
              content="Cancel"
              icon="times"
              mt={1}
              onClick={() => act('cancel_buy')}
            />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
