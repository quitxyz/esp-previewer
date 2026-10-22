export function drawBox(context, bounds, settings) {
  if (!settings.enabled || !bounds) return;

  const { padding, thickness, cornerLength } = settings;
  const left = bounds.left - padding;
  const top = bounds.top - padding;
  const width = bounds.right - bounds.left + padding * 2;
  const height = bounds.bottom - bounds.top + padding * 2;
  const path = new Path2D();

  if (settings.style === 'full') {
    path.rect(left, top, width, height);
  } else {
    const horizontal = (width * cornerLength) / 100;
    const vertical = (height * cornerLength) / 100;
    for (const [x, y, dx, dy] of [
      [left, top, 1, 1],
      [left + width, top, -1, 1],
      [left, top + height, 1, -1],
      [left + width, top + height, -1, -1],
    ]) {
      path.moveTo(x, y + dy * vertical);
      path.lineTo(x, y);
      path.lineTo(x + dx * horizontal, y);
    }
  }

  context.save();
  context.lineJoin = 'miter';
  if (settings.fill) {
    context.globalAlpha = settings.fillOpacity / 100;
    context.fillStyle = settings.fillColor;
    context.fillRect(left, top, width, height);
  }
  context.globalAlpha = settings.opacity / 100;
  if (settings.outline) {
    context.strokeStyle = settings.outlineColor;
    context.lineWidth = thickness + 2;
    context.stroke(path);
  }
  context.strokeStyle = settings.color;
  context.lineWidth = thickness;
  context.stroke(path);
  context.restore();
}
