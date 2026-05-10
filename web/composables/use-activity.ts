import { ref } from "vue";

export type Activity = {
  location?: Location;
  nowPlaying?: NowPlaying;
};

export type Location = {
  city?: string;
  state?: string;
  region?: string;
  residency?: Residency;
};

export type Residency = {
  city: string;
  state: string;
};

export type NowPlaying = {
  title: string;
  artist?: string;
  album?: string;
  progress: number;
  duration: number;
  timestamp: Date;
  service: NowPlayingService;
};

export enum NowPlayingService {
  appleMusic = "apple",
}

const activity = ref(undefined as Optional<Activity>);

const residency = Object.freeze({
  city: "Irvine",
  state: "CA",
});

export function useActivity() {
  return {
    nowPlaying: computed(() => activity.value?.nowPlaying),
    location: computed(() => ((activity.value?.location?.city && activity.value?.location.city !== residency.city) || (activity.value?.location?.state && activity.value.location.state !== residency.state) ? activity.value?.location : undefined)),
    residency: computed(() => (activity.value?.location?.residency?.city || activity.value?.location?.residency?.state ? activity.value.location.residency : residency)),
    async fetchActivity() {
      const response = await $fetch<Activity>("/api/activity");
      if (response.nowPlaying?.timestamp && typeof response.nowPlaying.timestamp === "string") {
        response.nowPlaying.timestamp = new Date(response.nowPlaying.timestamp);
      }
      activity.value = response;
    },
  };
}
