const boxDefaults = {
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
const nameDefaults = {
  enabled: true,
  text: 'Player',
  position: 'top',
  size: 13,
  gap: 5,
  color: '#dddddd',
  opacity: 100,
  outline: true,
  outlineColor: '#050505',
};
const groups = {
  Enemy: { color: '#c6c6c8', text: 'Player' },
  Friendly: { color: '#87c4c6', text: 'Teammate' },
  Self: { color: '#d1bd9d', text: 'You' },
  World: { color: '#d1ad73', text: 'Crate' },
};

export function createSettings(group) {
  return {
    box: { ...boxDefaults, color: groups[group].color },
    name: { ...nameDefaults, text: groups[group].text },
  };
}

export const states = Object.fromEntries(
  Object.keys(groups).map((group) => [group, createSettings(group)]),
);
