import { useBackend } from '../backend';

/* todo */
import { Section, Box, Button, Input, NumberInput, Tabs, Dropdown, Flex, Slider, NoticeBox, ColorBox, Tooltip, Icon } from '../components';
import { Window } from '../layouts';

export const ClientSettings = (props, context) => {
  const { act, data } = useBackend(context);

  const { active_tab, settings, tabs, tabs_tips } = data;

  return (
    <Window
      title="Настройки"
      width={500}
      height={650}>
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
        {settings.map(setting => (
          <SettingField setting={setting} key={setting.type} />
        ))}
      </Window.Content>
    </Window>
  );
};

const SettingField = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  const settingTypes = {
    boolean: <SettingFieldBoolean {...props} />,
    text: <SettingFieldText {...props} />,
    range: <SettingFieldRange {...props} />,
    select: <SettingFieldSelect {...props} />,
    hex: <SettingFieldHex {...props} />,
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
          { JSON.stringify(setting.v_parameters) }
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

const SettingFieldRange = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  // approximately for default windows width
  // should be part of the slider option...
  let relativeStepSize = 250 / (setting.v_parameters[1] - setting.v_parameters[0]);
  if(setting.v_parameters[2]) {
    relativeStepSize = relativeStepSize * setting.v_parameters[2]
  }
  relativeStepSize = Math.floor(relativeStepSize) || 1

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

const SettingFieldHex = (props, context) => {
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

const SettingFieldText = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    setting,
  } = props;

  return (
    <Input fluid
      value={setting.value}
      onInput={(e, value) => act('set_value', { type: setting.type, value: value })}
    />
  );
};

const SettingFieldSelect = (props, context) => {
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
        noscroll={true}
        onSelected={value => act('set_value', { type: setting.type, value: value })}
      />
    );
  } else {
    return (
      <Dropdown
        width="100%"
        options={Object.values(setting.v_parameters)}
        selected={setting.v_parameters[setting.value]}
        noscroll={true}
        onSelected={value => act('set_value', { type: setting.type, value: Object.keys(setting.v_parameters).find(key => setting.v_parameters[key] === value) })}
      />
    );
  }
};

const SettingFieldBoolean = (props, context) => {
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
