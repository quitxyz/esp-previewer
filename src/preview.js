import * as THREE from 'three';
import { GLTFLoader } from 'three/addons/loaders/GLTFLoader.js';
import { drawBox } from './box.js';
import { drawName } from './name.js';

export function createPreview(viewport, overlay, onStatus) {
  const renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  viewport.prepend(renderer.domElement);
  const context = overlay.getContext('2d');
  const scene = new THREE.Scene();
  scene.background = new THREE.Color('#17181a');
  scene.add(new THREE.HemisphereLight(0xffffff, 0x6d6d76, 2.1));
  const light = new THREE.DirectionalLight(0xffffff, 2.2);
  light.position.set(-3, 8, 7);
  scene.add(light);

  const grid = new THREE.GridHelper(40, 40, 0x292a2c, 0x292a2c);
  scene.add(grid);
  const avatar = new THREE.Group();
  const world = new THREE.Group();
  scene.add(avatar, world);
  const crate = new THREE.Mesh(
    new THREE.BoxGeometry(2, 2, 1.5),
    new THREE.MeshStandardMaterial({ color: '#66615a', roughness: 1 }),
  );
  crate.position.y = 1;
  world.add(crate);

  const frontCamera = new THREE.OrthographicCamera(-4, 4, 3.4, -3.4, 0.1, 100);
  const orbitCamera = new THREE.PerspectiveCamera(38, 1, 0.1, 100);
  const localBounds = new THREE.Box3();
  const point = new THREE.Vector3();
  let group = 'Enemy';
  let view = '2d';
  let yaw = 0.48;
  let settings;
  let modelReady = false;
  let modelFailed = false;
  let width = 0;
  let height = 0;
  let pendingFrame = 0;
  let drag = null;

  function updateStatus() {
    onStatus(
      group === 'World'
        ? 'WORLD OBJECT'
        : modelFailed
          ? 'MODEL LOAD FAILED'
          : !modelReady
            ? 'Loading model…'
            : view === '2d'
              ? '2D / FRONT'
              : '3D / DRAG TO ROTATE',
    );
  }

  function draw() {
    pendingFrame = 0;
    if (!width || !height) return;
    const target = group === 'World' ? world : avatar;
    avatar.visible = target === avatar;
    world.visible = target === world;
    target.rotation.y = view === '3d' ? yaw : 0;
    target.updateMatrixWorld(true);
    const camera = view === '2d' ? frontCamera : orbitCamera;
    camera.position.set(0, 2.4, view === '2d' ? 15 : 11.8);
    camera.lookAt(0, 2.4, 0);
    camera.updateMatrixWorld();
    renderer.render(scene, camera);
    context.clearRect(0, 0, width, height);
    if (target === avatar && !modelReady) return;

    const bounds = { left: Infinity, top: Infinity, right: -Infinity, bottom: -Infinity };
    const box = target === world ? crate.geometry.boundingBox : localBounds;
    for (const x of [box.min.x, box.max.x]) {
      for (const y of [box.min.y, box.max.y]) {
        for (const z of [box.min.z, box.max.z]) {
          point.set(x, y, z);
          if (target === world) point.add(crate.position);
          point.applyMatrix4(target.matrixWorld).project(camera);
          const screenX = ((point.x + 1) * width) / 2;
          const screenY = ((1 - point.y) * height) / 2;
          bounds.left = Math.min(bounds.left, screenX);
          bounds.right = Math.max(bounds.right, screenX);
          bounds.top = Math.min(bounds.top, screenY);
          bounds.bottom = Math.max(bounds.bottom, screenY);
        }
      }
    }
    drawBox(context, bounds, settings.box);
    drawName(context, bounds, settings.name, settings.box.padding, { width, height });
  }

  function invalidate() {
    if (!pendingFrame) pendingFrame = requestAnimationFrame(draw);
  }

  function resize() {
    width = viewport.clientWidth;
    height = viewport.clientHeight;
    if (!width || !height) return;
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    renderer.setPixelRatio(ratio);
    renderer.setSize(width, height, false);
    overlay.width = Math.round(width * ratio);
    overlay.height = Math.round(height * ratio);
    context.setTransform(ratio, 0, 0, ratio, 0, 0);
    frontCamera.left = (-3.4 * width) / height;
    frontCamera.right = (3.4 * width) / height;
    frontCamera.updateProjectionMatrix();
    orbitCamera.aspect = width / height;
    orbitCamera.updateProjectionMatrix();
    invalidate();
  }

  crate.geometry.computeBoundingBox();
  new GLTFLoader().load(
    new URL('../assets/r6.glb', import.meta.url).href,
    ({ scene: model }) => {
      model.updateMatrixWorld(true);
      const bounds = new THREE.Box3().setFromObject(model, true);
      const size = bounds.getSize(new THREE.Vector3());
      model.scale.multiplyScalar(4.65 / size.y);
      model.updateMatrixWorld(true);
      bounds.setFromObject(model, true);
      model.position.set(
        -(bounds.min.x + bounds.max.x) / 2,
        -bounds.min.y,
        -(bounds.min.z + bounds.max.z) / 2,
      );
      model.updateMatrixWorld(true);
      localBounds.setFromObject(model, true);
      avatar.add(model);
      modelReady = true;
      updateStatus();
      invalidate();
    },
    undefined,
    (error) => {
      modelFailed = true;
      console.error('Unable to load R6 model', error);
      updateStatus();
    },
  );

  viewport.addEventListener('pointerdown', (event) => {
    if (view !== '3d' || !event.isPrimary || event.button !== 0) return;
    drag = { id: event.pointerId, x: event.clientX };
    viewport.setPointerCapture(event.pointerId);
  });
  viewport.addEventListener('pointermove', (event) => {
    if (!drag || drag.id !== event.pointerId) return;
    yaw += (event.clientX - drag.x) / 180;
    drag.x = event.clientX;
    invalidate();
  });
  for (const name of ['pointerup', 'pointercancel', 'lostpointercapture']) {
    viewport.addEventListener(name, () => {
      drag = null;
    });
  }
  new ResizeObserver(resize).observe(viewport);
  window.addEventListener('resize', resize);
  resize();

  return {
    update(nextGroup, nextSettings) {
      group = nextGroup;
      settings = nextSettings;
      updateStatus();
      invalidate();
    },
    setView(nextView) {
      view = nextView;
      drag = null;
      viewport.classList.toggle('orbit', view === '3d');
      updateStatus();
      invalidate();
    },
    reset() {
      yaw = 0.48;
      invalidate();
    },
  };
}
