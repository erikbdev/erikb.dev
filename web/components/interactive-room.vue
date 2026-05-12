<script setup lang="ts">
import { BackSide } from "three";
import { GLTFLoader, OrbitControls } from "three/examples/jsm/Addons.js";

const { state: model } = useLoader(GLTFLoader, "/models/erik-b-logo-3d-model.gltf");
const scene = computed(() => model.value?.scene);
const graph = useGraph(scene);

const nodes = computed(() => graph.value?.nodes);
const logoRef = ref();
const { onBeforeRender } = useLoop();

onBeforeRender(({ elapsed }) => {
  if (logoRef.value) {
    logoRef.value.rotation.z = elapsed * -0.5;
  }
});
</script>

<template>
  <TresPerspectiveCamera :position="[0, 0, 0]" />

  <TresMesh>
    <TresBoxGeometry width="50" height="50" :args="[1, 1, 1]" color="#ff0000" />
    <TresMeshBasicMaterial color="#00ff00" />
    <!-- <TresMeshBasicMaterial color="#1c1c1c" :side="BackSide" /> -->
  </TresMesh>
</template>

<!-- <template> -->
<!-- <TresPerspectiveCamera :position="[4, 3.5, 5.5]" :look-at="[-0.5, 1.5, 0]" :fov="50" /> -->

<!-- <TresAmbientLight :intensity="0.45" color="#8888a8" />
  <TresDirectionalLight :position="[4, 8, 3]" :intensity="1.4" color="#fff5e8" cast-shadow />
  <TresPointLight :position="[0.2, 2.4, -0.35]" color="#4488cc" :intensity="0.8" :distance="3.5" /> -->

<!-- Floor -->
<!-- <TresMesh :rotation="[-Math.PI / 2, 0, 0]" receive-shadow>
    <TresPlaneGeometry :args="[20, 20]" />
    <TresMeshStandardMaterial color="#101012" />
  </TresMesh> -->

<!-- Back wall -->
<!-- <TresMesh :position="[0, 3.5, -3.0]" receive-shadow>
    <TresPlaneGeometry :args="[14, 7]" />
    <TresMeshStandardMaterial color="#171720" />
  </TresMesh> -->

<!-- Left wall -->
<!-- <TresMesh :position="[-3.2, 3.5, 0]" :rotation="[0, Math.PI / 2, 0]" receive-shadow>
    <TresPlaneGeometry :args="[12, 7]" />
    <TresMeshStandardMaterial color="#171720" />
  </TresMesh> -->

<!-- Desk surface -->
<!-- <TresMesh :position="[0, 1.0, 0]" cast-shadow receive-shadow>
    <TresBoxGeometry :args="[3.6, 0.12, 1.8]" />
    <TresMeshStandardMaterial color="#3a2818" :roughness="0.7" />
  </TresMesh> -->

<!-- Desk leg: front-left -->
<!-- <TresMesh :position="[-1.7, 0.5, 0.82]" cast-shadow>
    <TresBoxGeometry :args="[0.09, 1.0, 0.09]" />
    <TresMeshStandardMaterial color="#2a1c0e" />
  </TresMesh> -->
<!-- Desk leg: front-right -->
<!-- <TresMesh :position="[1.7, 0.5, 0.82]" cast-shadow>
    <TresBoxGeometry :args="[0.09, 1.0, 0.09]" />
    <TresMeshStandardMaterial color="#2a1c0e" />
  </TresMesh> -->
<!-- Desk leg: back-left -->
<!-- <TresMesh :position="[-1.7, 0.5, -0.82]" cast-shadow>
    <TresBoxGeometry :args="[0.09, 1.0, 0.09]" />
    <TresMeshStandardMaterial color="#2a1c0e" />
  </TresMesh> -->
<!-- Desk leg: back-right -->
<!-- <TresMesh :position="[1.7, 0.5, -0.82]" cast-shadow>
    <TresBoxGeometry :args="[0.09, 1.0, 0.09]" />
    <TresMeshStandardMaterial color="#2a1c0e" />
  </TresMesh> -->

<!-- Monitor body -->
<!-- <TresMesh :position="[0.2, 2.16, -0.66]" cast-shadow>
    <TresBoxGeometry :args="[1.65, 0.98, 0.08]" />
    <TresMeshStandardMaterial color="#111118" :roughness="0.4" :metalness="0.1" />
  </TresMesh> -->
<!-- Monitor screen (emissive) -->
<!-- <TresMesh :position="[0.2, 2.16, -0.615]">
    <TresMesh ref="logoRef" v-if="nodes?.ErikB" :scale="[6, 6, 6]" :rotation="[8, 0, 0]" :position="[0, -0.04, 0]" :geometry="nodes.ErikB.geometry" />
    <TresBoxGeometry :args="[1.53, 0.86, 0.001]" />
    <TresMeshStandardMaterial color="#1c1c1c" :emissive="'#1c1c1c'" :emissive-intensity="2.5" />
  </TresMesh> -->
<!-- Monitor neck -->
<!-- <TresMesh :position="[0.2, 1.66, -0.66]" cast-shadow>
    <TresBoxGeometry :args="[0.08, 0.42, 0.08]" />
    <TresMeshStandardMaterial color="#191919" :metalness="0.3" />
  </TresMesh> -->
<!-- Monitor base -->
<!-- <TresMesh :position="[0.2, 1.088, -0.64]" cast-shadow>
    <TresBoxGeometry :args="[0.52, 0.05, 0.32]" />
    <TresMeshStandardMaterial color="#191919" :metalness="0.2" :roughness="0.5" />
  </TresMesh> -->

<!-- Keyboard -->
<!-- <TresMesh :position="[0.1, 1.078, 0.18]" cast-shadow>
    <TresBoxGeometry :args="[1.15, 0.04, 0.4]" />
    <TresMeshStandardMaterial color="#1c1c22" :roughness="0.9" />
  </TresMesh> -->

<!-- Mousepad -->
<!-- <TresMesh :position="[1.0, 1.065, 0.18]">
    <TresBoxGeometry :args="[0.38, 0.007, 0.32]" />
    <TresMeshStandardMaterial color="#141417" :roughness="1.0" />
  </TresMesh> -->
<!-- Mouse -->
<!-- <TresMesh :position="[1.0, 1.082, 0.18]" cast-shadow>
    <TresBoxGeometry :args="[0.13, 0.042, 0.22]" />
    <TresMeshStandardMaterial color="#202028" :roughness="0.6" />
  </TresMesh> -->

<!-- MP3 player (lying flat, face-up) -->
<!-- <TresGroup :position="[-1.25, 1.0, -0.08]"> -->
<!-- Body -->
<!-- <TresMesh :position="[0, 0.072, 0]" cast-shadow>
      <TresBoxGeometry :args="[0.105, 0.014, 0.205]" />
      <TresMeshStandardMaterial color="#c4c4cc" :roughness="0.15" :metalness="0.55" />
    </TresMesh> -->
<!-- Screen -->
<!-- <TresMesh :position="[0, 0.08, -0.038]">
      <TresBoxGeometry :args="[0.07, 0.001, 0.08]" />
      <TresMeshStandardMaterial color="#0e3880" :emissive="'#081020'" :emissive-intensity="1.8" />
    </TresMesh> -->
<!-- Click wheel -->
<!-- <TresMesh :position="[0, 0.08, 0.052]" :rotation="[Math.PI / 2, 0, 0]">
      <TresCylinderGeometry :args="[0.025, 0.025, 0.002, 16]" />
      <TresMeshStandardMaterial color="#aaaaaa" :metalness="0.5" />
    </TresMesh> -->
<!-- </TresGroup> -->

<!-- Headphones (lying flat on desk, U-shape in horizontal plane) -->
<!-- <TresGroup :position="[-0.78, 1.07, 0.4]" :rotation="[0, -0.3, 0]"> -->
<!-- Band: half torus rotated to lie in XZ plane -->
<!-- <TresMesh :rotation="[Math.PI / 2, 0, 0]">
      <TresTorusGeometry :args="[0.13, 0.013, 8, 20, Math.PI]" />
      <TresMeshStandardMaterial color="#222226" />
    </TresMesh> -->
<!-- Left earcup -->
<!-- <TresMesh :position="[-0.13, 0.013, 0]">
      <TresCylinderGeometry :args="[0.04, 0.04, 0.026, 16]" />
      <TresMeshStandardMaterial color="#222226" />
    </TresMesh> -->
<!-- Right earcup -->
<!-- <TresMesh :position="[0.13, 0.013, 0]">
      <TresCylinderGeometry :args="[0.04, 0.04, 0.026, 16]" />
      <TresMeshStandardMaterial color="#222226" />
    </TresMesh> -->
<!-- Left ear pad -->
<!-- <TresMesh :position="[-0.13, 0.02, 0]">
      <TresCylinderGeometry :args="[0.032, 0.032, 0.01, 16]" />
      <TresMeshStandardMaterial color="#111114" :roughness="0.9" />
    </TresMesh> -->
<!-- Right ear pad -->
<!-- <TresMesh :position="[0.13, 0.02, 0]">
      <TresCylinderGeometry :args="[0.032, 0.032, 0.01, 16]" />
      <TresMeshStandardMaterial color="#111114" :roughness="0.9" />
    </TresMesh>
  </TresGroup> -->

<!-- Left wall: whiteboard frame -->
<!-- <TresMesh :position="[-3.16, 2.85, -0.55]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[2.48, 1.58, 0.014]" />
    <TresMeshStandardMaterial color="#3a3a40" />
  </TresMesh> -->
<!-- Whiteboard surface -->
<!-- <TresMesh :position="[-3.15, 2.85, -0.55]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[2.35, 1.45, 0.022]" />
    <TresMeshStandardMaterial color="#dedad0" :roughness="0.95" />
  </TresMesh> -->
<!-- Whiteboard marker lines -->
<!-- <TresMesh :position="[-3.136, 3.1, -0.3]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[1.2, 0.016, 0.002]" />
    <TresMeshStandardMaterial color="#3344aa" />
  </TresMesh> -->
<!-- <TresMesh :position="[-3.136, 2.9, -0.48]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[0.75, 0.016, 0.002]" />
    <TresMeshStandardMaterial color="#3344aa" />
  </TresMesh> -->
<!-- <TresMesh :position="[-3.136, 2.7, -0.6]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[1.0, 0.016, 0.002]" />
    <TresMeshStandardMaterial color="#aa3333" />
  </TresMesh> -->

<!-- Poster 1: navy blue -->
<!-- <TresMesh :position="[-3.17, 2.6, 0.65]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[0.72, 1.0, 0.017]" />
    <TresMeshStandardMaterial color="#0c2848" :roughness="0.85" />
  </TresMesh> -->
<!-- <TresMesh :position="[-3.155, 2.82, 0.65]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[0.5, 0.014, 0.002]" />
    <TresMeshStandardMaterial color="#4a88dd" />
  </TresMesh> -->

<!-- Poster 2: warm dark red -->
<!-- <TresMesh :position="[-3.17, 3.35, 0.78]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[0.58, 0.66, 0.017]" />
    <TresMeshStandardMaterial color="#48180a" :roughness="0.85" />
  </TresMesh> -->

<!-- Poster 3: dark teal -->
<!-- <TresMesh :position="[-3.17, 2.65, 1.5]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[0.68, 0.92, 0.017]" />
    <TresMeshStandardMaterial color="#083828" :roughness="0.85" />
  </TresMesh> -->

<!-- Poster 4: dark purple -->
<!-- <TresMesh :position="[-3.17, 3.3, 1.45]" :rotation="[0, Math.PI / 2, 0]">
    <TresBoxGeometry :args="[0.5, 0.58, 0.017]" />
    <TresMeshStandardMaterial color="#28083a" :roughness="0.85" />
  </TresMesh> -->
<!-- </template> -->
