<script setup lang="ts">
import { DRACOLoader, GLTFLoader } from "three/examples/jsm/Addons.js";

const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath("https://www.gstatic.com/draco/versioned/decoders/1.5.6/");

const { state: model } = useLoader(
  GLTFLoader,
  "/models/erik-b-logo-3d-model.gltf",
  // , {
  //   extensions: (loader) => {
  //     if (loader instanceof GLTFLoader) {
  //       loader.setDRACOLoader(dracoLoader);
  //     }
  //   },
  // }
);

const modelRef = ref();

const scene = computed(() => model.value?.scene);
const graph = useGraph(scene);

const nodes = computed(() => graph.value?.nodes);

// const modelRef = ref(null);
const { onBeforeRender } = useLoop();

onBeforeRender(({ elapsed }) => {
  if (modelRef.value) {
    modelRef.value.rotation.z = elapsed * -0.5;
  }
});
</script>
<template>
  <TresPerspectiveCamera :position="[0, 20, 0]" :zoom="100" :look-at="[0, 0, 0]" />

  <!-- <TresAmbientLight :intensity="1.5" /> -->
  <!-- <TresDirectionalLight :position="[5, 5, 5]" :intensity="2" /> -->

  <TresMesh ref="modelRef" v-if="nodes?.ErikB" :geometry="nodes.ErikB?.geometry" cast-shadow />

  <!-- <TresAxesHelper /> -->
  <!-- <TresGridHelper /> -->
</template>
