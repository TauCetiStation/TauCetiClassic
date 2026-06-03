import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { FONTS } from './constants';
import { useSettings } from './use-settings';

function LinkedToChat() {
  return <NoticeBox color="red">Unlink Stat Panel from chat!</NoticeBox>;
}

export function SettingsStatPanel(props) {
  const [freeFont, setFreeFont] = useState(false);
  const { settings, updateSettings } = useSettings();
  const { statLinked, statFontSizeDefault, statFontSize, statFontFamily } =
    settings;

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Font size">
              <Stack.Item grow>
                {statLinked ? (
                  <LinkedToChat />
                ) : (
                  <Stack>
                    <Slider
                      width="100%"
                      step={1}
                      stepPixelSize={20}
                      minValue={1}
                      maxValue={32}
                      value={statFontSize}
                      disabled={statFontSizeDefault}
                      unit="pt"
                      format={(value) => toFixed(value)}
                      onChange={(e, value) =>
                        updateSettings({ statFontSize: value })
                      }
                    />

                    <Button
                      ml={0.5}
                      icon={statFontSizeDefault ? 'check' : 'close'}
                      color={statFontSizeDefault ? 'good' : 'bad'}
                      onClick={() => {
                        updateSettings({
                          statFontSizeDefault: !statFontSizeDefault,
                        });
                      }}
                    >
                      Default
                    </Button>
                  </Stack>
                )}
              </Stack.Item>
            </LabeledList.Item>
            <LabeledList.Item label="Font style">
              <Stack.Item>
                {statLinked ? (
                  <LinkedToChat />
                ) : !freeFont ? (
                  <Collapsible
                    title={statFontFamily}
                    width="100%"
                    buttons={
                      <Button
                        icon={freeFont ? 'lock-open' : 'lock'}
                        color={freeFont ? 'good' : 'bad'}
                        onClick={() => {
                          setFreeFont(!freeFont);
                        }}
                      >
                        Custom font
                      </Button>
                    }
                  >
                    {FONTS.map((FONT) => (
                      <Button
                        key={FONT}
                        fontFamily={FONT}
                        selected={statFontFamily === FONT}
                        color="transparent"
                        onClick={() =>
                          updateSettings({
                            statFontFamily: FONT,
                          })
                        }
                      >
                        {FONT}
                      </Button>
                    ))}
                  </Collapsible>
                ) : (
                  <Stack>
                    <Input
                      fluid
                      value={statFontFamily}
                      onBlur={(value) =>
                        updateSettings({
                          statFontFamily: value,
                        })
                      }
                    />
                    <Button
                      ml={0.5}
                      icon={freeFont ? 'lock-open' : 'lock'}
                      color={freeFont ? 'good' : 'bad'}
                      onClick={() => {
                        setFreeFont(!freeFont);
                      }}
                    >
                      Custom font
                    </Button>
                  </Stack>
                )}
              </Stack.Item>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Box italic color="label">
          {/* remove when browser statpanel */}
          Changing the stat panel font size might take a rejoin to apply
          correctly.
        </Box>
        <Stack.Divider />
        <Stack.Item textAlign="center">
          <Button
            fluid
            icon={statLinked ? 'unlink' : 'link'}
            color={statLinked ? 'bad' : 'good'}
            onClick={() => updateSettings({ statLinked: !statLinked })}
          >
            {statLinked ? 'Unlink from chat' : 'Link to chat'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
