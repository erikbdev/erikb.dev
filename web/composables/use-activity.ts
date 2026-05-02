import { readonly, ref } from "vue";

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
  service: NowPlayingService;
};

export enum NowPlayingService {
  appleMusic = "apple",
}

const activity = ref(undefined as Activity | undefined);

export function useActivity() {
  return {
    activity: readonly(activity),
    async fetchActivity() {
      const response = await fetch("/api/activity");
      const a = response.json() as Activity;
      activity.value = a;
    },
  };
}
