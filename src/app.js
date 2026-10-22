import { createPreview } from './preview.js';

const defaults = {
  enabled: true,
  style: 'corner',
  thickness: 1.5,
  padding: 3,
  cornerLength: 25,
  color: '#c6c6c8',
  opacity: 100,
  outline: true,
  outlineColor: '#050505',
  fill: false,
  fillColor: '#c6c6c8',
  fillOpacity: 15,
};
const colors = { Enemy: '#c6c6c8', Friendly: '#87c4c6', Self: '#d1bd9d', World: '#d1ad73' };
const createSettings = (group) => ({ ...defaults, color: colors[group] });
const states = Object.fromEntries(
  Object.keys(colors).map((group) => [group, createSettings(group)]),
);
const get = (id) => document.getElementById(id);
const groupButtons = document.querySelectorAll('[data-group]');
const styleButtons = document.querySelectorAll('[data-style]');
const viewButtons = document.querySelectorAll('[data-view]');
const inputs = Object.keys(defaults)
  .filter((key) => key !== 'style')
  .map(get);
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
    const value = settings[input.id];
    if (input.type === 'checkbox') input.checked = value;
    else input.value = value;
    if (input.type === 'range') {
      const unit = ['thickness', 'padding'].includes(input.id) ? ' px' : '%';
      get(`${input.id}Out`).textContent = value + unit;
    }
    if (input.type === 'color') get(`${input.id}Hex`).textContent = value;
  }
  select(groupButtons, 'group', group);
  select(styleButtons, 'style', settings.style);
  get('cornerRow').hidden = settings.style !== 'corner';
  get('outlineRow').hidden = !settings.outline;
  get('fillOptions').hidden = !settings.fill;
  preview?.update(group, settings);
}

for (const input of inputs) {
  input.addEventListener('input', () => {
    states[group][input.id] =
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
    states[group].style = button.dataset.style;
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
