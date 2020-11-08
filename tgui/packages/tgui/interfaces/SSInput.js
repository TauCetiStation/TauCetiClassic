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

  const set_ic_theme = msg => {
    const prefix = msg[0] + msg[1];
    const channel = possible_prefix[prefix];
    switch (channel) {
      case "changeling":
        setTheme("abductor");
        break;
      case "alientalk":
        setTheme("malfunction");
        break;
      case "Syndicate":
        setTheme("syndicate");
        break;
      case "binary":
        setTheme("hackerman");
        break;
      case "dronechat":
        setTheme("hackerman");
        break;
      case "department":
        setTheme("ntos_department");
        break;
      case "Science":
        setTheme("ntos_rnd");
        break;
      case "Command":
        setTheme("ntos");
        break;
      case "Medical":
        setTheme("ntos_med");
        break;
      case "Engineering":
        setTheme("ntos_eng");
        break;
      case "Security":
        setTheme("ntos_sec");
        break;
      case "Supply":
        setTheme("ntos_supply");
        break;
      case "whisper":
        setTheme("retro");
        break;
      default:
        setTheme("");
        break;
    }
    prefix = msg[0];
    if (prefix == "*") {
      setTheme("retro")
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
            onEnter={(e, value) => act('onenter', { message: value })}
            onEscape={() => act('cancel')}
          />
        </div>
        <div className="SSInput-Box-Buttons">
          <Button
            className="SSInput-Button"
            content={"Ok"}
            onClick={() => act('onenter', { message: text })}
          />
          <Button
            className="SSInput-Button"
            content={"Cancel"}
            onClick={() => act('cancel')}
          />
        </div>
      </Window.Content>
    </Window>
  );
};
