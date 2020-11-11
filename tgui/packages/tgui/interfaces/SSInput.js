import { useBackend, useLocalState } from "../backend";
import { Input, Button } from "../components";
import { Window } from "../layouts";

export const SSInput = (props, context) => {
  const { act, data } = useBackend(context);
  const { new_placeholder, possible_prefix, title } = data;

  const [
    theme,
    setTheme,
  ] = useLocalState(context, 'theme');

  const [
    text,
    setText,
  ] = useLocalState(context, 'text');


  const handleKeyPress = event => {
    if (event.keyCode === 13) {
      onEnter(text);
    }
    if (event.keyCode === 27) {
      onCancel();
    }
  };

  const onCancel = e => {
    act('cancel');
    removeEventListener('keydown', handleKeyPress);
  };

  const onEnter = msg => {
    act('onenter', { message: msg });
    removeEventListener('keydown', handleKeyPress);
  };

  addEventListener('keydown', handleKeyPress);

  const set_ic_theme = msg => {
    let prefix = msg[0] + msg[1];
    const channel = possible_prefix[prefix];
    const channel2theme = new Map([
      ['changeling', 'abductor'],
      ['alientalk', 'malfunction'],
      ['Syndicate', 'syndicate'],
      ['binary', 'hackerman'],
      ['dronechat', 'hackerman'],
      ['department', 'ntos_department'],
      ['Science', 'ntos_rnd'],
      ['Command', 'ntos'],
      ['Medical', 'ntos_med'],
      ['Command', 'ntos'],
      ['Engineering', 'ntos_eng'],
      ['Security', 'ntos_sec'],
      ['Supply', 'ntos_supply'],
      ['whisper', 'retro'],
    ]);

    if (channel2theme.has(channel)) {
      setTheme(channel2theme.get(channel));
    }
    else {
      setTheme("");
    }

    prefix = msg[0];
    if (prefix === "*") {
      setTheme("retro");
    }
  };

  const input_text = msg => {
    act('oninput', { message: msg });
    setText(msg);
    switch (title) {
      case "IC":
        set_ic_theme(msg);
        break;
    }
  };

  return (
    <Window
      width={320}
      height={100}
      theme={theme}>
      <Window.Content>
        <div className="SSInput">
          <Input
            width={23}
            autoFocus
            placeholder={new_placeholder}
            onInput={(e, value) => input_text(value)}
            onEnter={(e, value) => onEnter(value)}
            onEscape={() => onCancel()}
          />
        </div>
        <div className="SSInput-Box-Buttons">
          <Button
            className="SSInput-Button"
            content={"Ok"}
            onClick={() => onEnter(text)}
          />
          <Button
            className="SSInput-Button"
            content={"Cancel"}
            onClick={() => onCancel()}
          />
        </div>
      </Window.Content>
    </Window>
  );
};
