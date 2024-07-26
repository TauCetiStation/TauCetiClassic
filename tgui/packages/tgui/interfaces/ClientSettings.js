import { useBackend, useLocalState } from '../backend';

import { 
  Section,
  Box,
  Button,
  Input,
  NumberInput,
  Tabs,
  Dropdown,
  Flex,
  Stack,
  Slider,
  NoticeBox,
  ColorBox,
  Tooltip,
  Icon,
  KeyListener,
  TrackOutsideClicks,
  Modal,
} from '../components';
import { isEscape } from 'common/keys';
import { decodeHtmlEntities } from 'common/string';
import { KeyEvent } from '../events';
import { Window } from '../layouts';

// byond <-> IE names
// order is important, we use it for replace, so place verbose names up
// p.s. i hate them both endlessly
const byond2jsKeysDictionary = {
  "Northwest": "Home",
  "Northeast": "PageUp",
  "Southwest": "End",
  "Southeast": "PageDown",
  "Space": "Spacebar",
  "Ctrl": "Control",
  "Return": "Enter",
  "Delete": "Del",
  "North": "Up",
  "East": "Right",
  "South": "Down",
  "West": "Left",
};

export const ClientSettings = (props, context) => {
  const { act, data } = useBackend(context);

  const { active_tab, settings, tabs, tabs_tips } = data;

  const [keyBindingState, setKeyBindingState] = useLocalState(context, 'showmodal', null);

  let settingsList;

  // this all is too overcomplicated because of keybinds tab that handled differently
  if (active_tab === "keybinds") {
    const sortedByCategory = settings.reduce((acc, setting) => {
      if (!acc[setting.category]) {
        acc[setting.category] = [];
      }
      acc[setting.category].push(setting);
      return acc;
    }, {});

    settingsList = Object.keys(sortedByCategory).map(categoryName => (
      <Section key={categoryName} title={categoryName}>
        {sortedByCategory[categoryName].map(setting => (
          <SettingField 
            setting={setting} 
            setKeyBindingState={setKeyBindingState} 
            key={setting.type} 
          />
        ))}
      </Section>
    ));

  } else {
    settingsList = settings.map(setting => (
      <SettingField 
        setting={setting} 
        key={setting.type} 
      />
    ));
  }

  return (
    <Window
      title="Настройки"
      width={500}
      height={650}>

      {keyBindingState 
        && <KeyBindingModal 
          settings={settings}
          keyBindingState={keyBindingState} 
          setKeyBindingState={setKeyBindingState} 
        />}

      <Window.Content scrollable>
        <Tabs>
          {Object.keys(tabs).map(tab => (
            <Tabs.Tab
              key={tab}
              selected={tab === active_tab}
              onClick={() => act("set_tab", { "tab": tab })} >
              {tabs[tab]}
            </Tabs.Tab>
          ))}
        </Tabs>
        {tabs_tips[active_tab] && (
          <NoticeBox info>
            {tabs_tips[active_tab]}
          </NoticeBox>
        )}
        {settingsList}
      </Window.Content>
    </Window>
  );
};

const KeyBindingModal = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    settings,
    keyBindingState,
    setKeyBindingState,
  } = props;

  const handleKeyDown = (keyEvent) => {
    const event = keyEvent.event;

    event.preventDefault();
  };

  const handleKeyUp = (keyEvent) => {
    const event = keyEvent.event;

    event.preventDefault();

    if (isEscape(event.key)) { // empty key (reset)
      act('set_keybind_value', {
        type: keyBindingState.type, 
        index: keyBindingState.index+1,
        key: "",
      });
      setKeyBindingState(null);
      return;
    }

    // todo: rewrite it all to use event.code with 516
    // also maybe this should be moved to keyEvent.toString()

    let sanitizedKey = event.key;

    // so shift+numeric keys will be parsed as 1234 instead of !@#$
    if (47 < event.keyCode && event.keyCode < 58) {
      sanitizedKey = String.fromCharCode(event.keyCode);
    }
    // so shift+letter keys will be parsed as latin and in lower case
    else if (64 < event.keyCode && event.keyCode < 91) {
      sanitizedKey = String.fromCharCode(event.keyCode);
    }
    // format Numpad0-Numpad9 for byond
    else if (95 < event.keyCode && event.keyCode < 106) {
      sanitizedKey = "Numpad"+sanitizedKey;
    }

    // replace by dictionary if needed
    sanitizedKey = Object.keys(byond2jsKeysDictionary)
      .find(key => byond2jsKeysDictionary[key] === sanitizedKey) || sanitizedKey;

    act('set_keybind_value', {
      type: keyBindingState.type, 
      index: keyBindingState.index+1,
      key: sanitizedKey,
      altMod: event.altKey,
      ctrlMod: event.ctrlKey,
      shiftMod: event.shiftKey,
    });
    setKeyBindingState(null);
  };

  const preference = settings.find(pref => pref.type === keyBindingState.type);

  return (
    <Modal textAlign="center">
      <KeyListener
        onKeyDown={handleKeyDown}
        onKeyUp={handleKeyUp}
      />
      <Section title={`Назначить клавишу для ${preference.name}`}>
        <Box italic>
          {preference.description} <br /><br />
        </Box>
        <Box bold>
          Нажмити любую клавишу.<br /><br />
          Можно использовать комбинации с Alt/Ctrl/Shift.<br /><br />
          Нажмите ESC для сброса.
        </Box>
      </Section>
    </Modal>
  );
};

const SettingField = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  const settingTypes = {
    boolean: <SettingTypeBoolean {...props} />,
    text: <SettingTypeText {...props} />,
    range: <SettingTypeRange {...props} />,
    select: <SettingTypeSelect {...props} />,
    hex: <SettingTypeHex {...props} />,
    keybind: <SettingTypeKeybind {...props} />,
  };

  let outline = null;
  let access_message = null;
  if (setting.admins_only) {
    outline = "1px solid rgb(0, 255, 255)";
    access_message = "Эта настройка доступна вам, так как вы админ.";
  } else if (setting.supporters_only) {
    outline = "1px solid rgb(255, 200, 0)";
    access_message = "Эта настройка доступна вам, так как вы поддерживаете сервер.";
  }

  return (
    <Section style={{ "outline": outline }} >
      <Flex wrap="wrap">
        <Flex.Item basis="30%" grow="2" color="label" pr="1em" bold>
          { setting.name }
        </Flex.Item>
        <Flex.Item basis="50%" shrink grow="2">
          {settingTypes[setting.v_type] || "Unknown Setting Type"}
        </Flex.Item>
        {/* button size with icon around 2em, basis here is as min-width to contain them */}
        <Flex.Item basis="4em" grow="1" textAlign="right">
          { !setting.default 
            && <Button
              tooltip={"Сбросить"}
              color="neutral"
              icon={"undo"}
              onClick={() => act("reset_value", { type: setting.type })}
            />}
        </Flex.Item>
        <Flex.Item basis="100%" pt="1em" style={{ "white-space": "pre-wrap" }}>
          { setting.description }
          { /* JSON.stringify(setting.v_parameters)*/ }
          { access_message && (
            <>
              <br />
              <br />
              <i>{ access_message }</i>
            </>
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const SettingTypeRange = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  // approximately for default windows width
  // should be part of the slider option...
  let relativeStepSize = 250 / (setting.v_parameters[1] - setting.v_parameters[0]);
  if (setting.v_parameters[2]) {
    relativeStepSize = relativeStepSize * setting.v_parameters[2];
  }
  relativeStepSize = Math.floor(relativeStepSize) || 1;

  return (
    <Tooltip position="top" content="Вы можете единожды нажать на слайдер для установки точного значения">
      <Slider
        value={setting.value}
        minValue={setting.v_parameters[0]}
        maxValue={setting.v_parameters[1]}
        step={setting.v_parameters[2] || 1}
        stepPixelSize={relativeStepSize}
        unit={setting.v_parameters[3]}
        onChange={(e, value) => act('set_value', { type: setting.type, value: value })}
      />
    </Tooltip>
  );
};

const SettingTypeHex = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Button
      onClick={() => act('modify_color_value', { type: setting.type })} 
    >
      <ColorBox color={setting.value} mr={0.5} />
      {setting.value}
    </Button>
  );
};

const SettingTypeText = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Input fluid
      value={decodeHtmlEntities(setting.value)}
      onChange={(e, value) => act('set_value', { type: setting.type, value: value })}
    />
  );
};

const SettingTypeSelect = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  // dropdown is not select, apparently, and we can't do different value/text, so this part is a mess
  if (Array.isArray(setting.v_parameters)) {
    return (
      <Dropdown
        width="100%"
        options={setting.v_parameters}
        selected={setting.value}
        noscroll
        onSelected={value => act('set_value', { type: setting.type, value: value })}
      />
    );
  } else {
    return (
      <Dropdown
        width="100%"
        options={Object.values(setting.v_parameters)}
        selected={setting.v_parameters[setting.value]}
        noscroll
        onSelected={value => act('set_value', { type: setting.type, value: Object.keys(setting.v_parameters).find(key => setting.v_parameters[key] === value) })}
      />
    );
  }
};

const SettingTypeBoolean = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Button.Checkbox
      checked={setting.value}
      selected={setting.value}
      content={setting.value ? "Включено" : "Выключено"}
      onClick={() => act('set_value', { type: setting.type, value: !setting.value })}
    />
  );
};


const SettingTypeKeybind = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
    setKeyBindingState,
  } = props;

  const humaniseByondKey = (text) => {
    const patterns = Object.keys(byond2jsKeysDictionary).join("|");
    return text.replace(new RegExp(patterns, "g"), match => byond2jsKeysDictionary[match]);
  };

  let binds = []; 
  if (setting.value) {
    binds = setting.value.split(" ");
  }
  let buttons = [];

  for (let i=0; i < 3; i++) {
    buttons.push(
      <Stack.Item basis="33.3%">
        <Button fluid textAlign="center"
          content={binds[i] ? humaniseByondKey(binds[i]) : "---"}
          color={!binds[i] && "neutral"}
          onClick={() => setKeyBindingState({ type: setting.type, index: i })}
        />
      </Stack.Item>
    );
  }

  return (<Stack>{buttons}</Stack>);
};
