<script setup lang="ts">
import { OrbitControls } from "@tresjs/cientos";
import { GLTFLoader } from "three/examples/jsm/Addons.js";

const { state: nameModel } = useLoader(GLTFLoader, "/models/erik-b-logo-3d-model.gltf");
const { state: roomModel } = useLoader(GLTFLoader, "/models/interactive-room.glb");

const roomScene = computed(() => roomModel.value?.scene);
const nameScene = computed(() => nameModel.value?.scene);

const logoRef = ref();
const { onBeforeRender } = useLoop();

onBeforeRender(({ elapsed }) => {
  if (logoRef.value) {
    logoRef.value.rotation.z = elapsed * -0.5;
  }
});
</script>

<template>
  <TresPerspectiveCamera :position="[-8, 2, 0]" :look-at="[0, 1, 0]" :fov="95" />
  <!-- <OrbitControls /> -->

  <TresAmbientLight :intensity="1" />
  <!-- <TresDirectionalLight :position="[0, 0, 0]" :intensity="2" /> -->

  <primitive v-if="roomScene" :object="roomScene" />
</template>
