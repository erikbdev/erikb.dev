export type Residency = {
  city: string;
  state: string;
}

export type Location = {
  city?: string;
  state?: string;
  region?: string;
  residency?: Residency;
}

export type NowPlaying = {
  title: string;
  artist?: string;
  album?: string;
  progress: number;
  duration: number;
  service: 'apple';
}

export type Activity = {
  location?: Location;
  nowPlaying?: NowPlaying;
}

export const defaultResidency: Residency = {
  city: 'Irvine',
  state: 'CA'
};
