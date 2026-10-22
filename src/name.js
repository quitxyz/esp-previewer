export function drawName(context, bounds, settings, padding, viewport) {
  if (!settings.enabled || !settings.text.trim() || settings.opacity === 0) return;

  context.save();
  context.font = `${settings.size}px Arial, sans-serif`;
  context.textAlign = 'left';
  context.textBaseline = 'top';
  let text = settings.text.trim();
  const maxWidth = viewport.width - 8;
  while (text.length > 1 && context.measureText(text).width > maxWidth) {
    text = text.slice(0, -2).trimEnd() + '…';
  }
  const width = context.measureText(text).width;
  const height = settings.size;
  const gap = settings.gap + padding;
  let x = (bounds.left + bounds.right - width) / 2;
  let y = bounds.top - gap - height;

  if (settings.position === 'bottom') y = bounds.bottom + gap;
  if (settings.position === 'left' || settings.position === 'right') {
    x = settings.position === 'left' ? bounds.left - gap - width : bounds.right + gap;
    y = (bounds.top + bounds.bottom - height) / 2;
  }
  x = Math.max(4, Math.min(x, viewport.width - width - 4));
  y = Math.max(4, Math.min(y, viewport.height - height - 4));

  context.globalAlpha = settings.opacity / 100;
  if (settings.outline) {
    context.lineWidth = 3;
    context.lineJoin = 'round';
    context.strokeStyle = settings.outlineColor;
    context.strokeText(text, x, y);
  }
  context.fillStyle = settings.color;
  context.fillText(text, x, y);
  context.restore();
}
