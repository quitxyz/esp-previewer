import { createPreview } from './preview.js';
import { createSettings, states } from './settings.js';

const get = (id) => document.getElementById(id);
const groupButtons = document.querySelectorAll('[data-group]');
const styleButtons = document.querySelectorAll('[data-style]');
const viewButtons = document.querySelectorAll('[data-view]');
const inputs = document.querySelectorAll('[data-visual][data-key]');
let group = 'Enemy';

function select(buttons, key, value) {
  for (const button of buttons) {
    const active = button.dataset[key] === value;
    button.classList.toggle('active', active);
    button.setAttribute('aria-pressed', String(active));
  }
}

let preview;
try {
  preview = createPreview(get('viewport'), get('overlay'), (text) => {
    get('sceneLabel').textContent = text;
  });
} catch (error) {
  console.error('Unable to start preview', error);
  get('sceneLabel').textContent = 'Preview unavailable — WebGL is required.';
}

function sync() {
  const settings = states[group];
  get('subjectLabel').textContent = group === 'World' ? 'Object' : 'R6';
  for (const input of inputs) {
    const value = settings[input.dataset.visual][input.dataset.key];
    if (input.type === 'checkbox') input.checked = value;
    else if (input.value !== String(value)) input.value = value;
    if (input.type === 'range') {
      get(`${input.id}Out`).textContent = value + input.dataset.unit;
    }
    if (input.type === 'color') get(`${input.id}Hex`).textContent = value;
  }
  select(groupButtons, 'group', group);
  select(styleButtons, 'style', settings.box.style);
  get('cornerRow').hidden = settings.box.style !== 'corner';
  get('outlineRow').hidden = !settings.box.outline;
  get('fillOptions').hidden = !settings.box.fill;
  get('nameOutlineRow').hidden = !settings.name.outline;
  preview?.update(group, settings);
}

for (const input of inputs) {
  input.addEventListener('input', () => {
    states[group][input.dataset.visual][input.dataset.key] =
      input.type === 'checkbox'
        ? input.checked
        : input.type === 'range'
          ? Number(input.value)
          : input.value;
    sync();
  });
}
for (const button of groupButtons) {
  button.addEventListener('click', () => {
    group = button.dataset.group;
    sync();
  });
}
for (const button of styleButtons) {
  button.addEventListener('click', () => {
    states[group].box.style = button.dataset.style;
    sync();
  });
}
for (const button of viewButtons) {
  button.addEventListener('click', () => {
    select(viewButtons, 'view', button.dataset.view);
    preview?.setView(button.dataset.view);
  });
}
get('resetView').addEventListener('click', () => preview?.reset());
get('resetSettings').addEventListener('click', () => {
  states[group] = createSettings(group);
  sync();
});
select(viewButtons, 'view', '2d');
sync();
