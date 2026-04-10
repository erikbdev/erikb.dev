<script lang="ts" setup>
import { ref, onMounted, nextTick, computed } from 'vue';
import { posts } from '../types/post';
import type { Activity } from '../types/activity';
import { defaultResidency } from '../types/activity';
import HeaderView from '../components/HeaderView.vue';
import FooterView from '../components/FooterView.vue';
import SpacerDivider from '../components/SpacerDivider.vue';
import SectionView from '../components/SectionView.vue';
import MapPinIcon from '../components/icons/MapPinIcon.vue';
import NavigationArrowIcon from '../components/icons/NavigationArrowIcon.vue';
import WaveformIcon from '../components/icons/WaveformIcon.vue';
import { useHLJS } from '@/hooks/useHLJS';
import { useCodeLang } from '@/hooks/useCodeLang';

const hljs = useHLJS();
const codeLang = useCodeLang();
const activity = ref<Activity | null>(null);

const residency = computed(
  () => activity.value?.location?.residency ?? defaultResidency
);

const currentLocation = computed(() => {
  if (!activity.value?.location) return null;
  const loc = activity.value.location;
  const resid = residency.value;
  if (loc.city === resid.city && loc.state === resid.state) return null;
  return [loc.city, loc.state, loc.region === 'United States' ? null : loc.region]
    .filter((x) => x)
    .join(', ');
});

const nowPlaying = computed(() => {
  if (!activity.value?.nowPlaying) return null;
  const np = activity.value.nowPlaying;
  return [np.title, np.artist ? '—' : null, np.artist]
    .filter((x) => x)
    .join(' ');
});

const aboutDescription =
  'A software developer who builds applications using Swift and modern web technologies.';

const sortedPosts = computed(() => [...posts].reverse());

onMounted(async () => {
  try {
    const res = await fetch('/api/activity');
    if (res.ok) {
      activity.value = await res.json();
    }
  } catch (e) {
    console.error('Failed to fetch activity:', e);
  }

  // Highlight code blocks
  await nextTick();
  hljs?.highlightAll?.();
});
</script>

<template>
  <div>
    <HeaderView />
    <main>
      <SpacerDivider />

      <!-- User Section -->
      <SectionView id="user">
        <template #header="{ lang }">
          <template v-if="lang === 'swift'">
            let user = User(
            <br />
            &nbsp;&nbsp;name: "Erik Bautista Santibanez",
            <br />
            &nbsp;&nbsp;role: [.mobile, .web],
            <br />
            &nbsp;&nbsp;home: "{{ residency.city }}, {{ residency.state }}"<span
              v-if="currentLocation"
              >,<br />
              &nbsp;&nbsp;location: "Currently in <em>{{ currentLocation }}</em>"</span
            ><span v-if="nowPlaying">,<br />
              &nbsp;&nbsp;listeningTo: "<em>{{ nowPlaying }}</em>"</span
            >
            <br />
            )
            <br />
            <br />
            &gt; print(user.about())
            <br />
            // {{ aboutDescription }}
          </template>
          <template v-else-if="lang === 'typescript'">
            const user: User = {
            <br />
            &nbsp;&nbsp;name: "Erik Bautista Santibanez",
            <br />
            &nbsp;&nbsp;role: [Role.Mobile, Role.Web],
            <br />
            &nbsp;&nbsp;home: "{{ residency.city }}, {{ residency.state }}"<span
              v-if="currentLocation"
              >,<br />
              &nbsp;&nbsp;location: "Currently in <em>{{ currentLocation }}</em>"</span
            ><span v-if="nowPlaying">,<br />
              &nbsp;&nbsp;listeningTo: "<em>{{ nowPlaying }}</em>"</span
            >
            <br />
            };
            <br />
            <br />
            &gt; console.log(user.about());
            <br />
            // {{ aboutDescription }}
          </template>
          <template v-else-if="lang === 'rust'">
            let user = User {
            <br />
            &nbsp;&nbsp;name: "Erik Bautista Santibanez",
            <br />
            &nbsp;&nbsp;role: [Role::Mobile, Role::Web],
            <br />
            &nbsp;&nbsp;home: "{{ residency.city }}, {{ residency.state }}"<span
              v-if="currentLocation"
              >,<br />
              &nbsp;&nbsp;location: "Currently in <em>{{ currentLocation }}</em>"</span
            ><span v-if="nowPlaying">,<br />
              &nbsp;&nbsp;listeningTo: "<em>{{ nowPlaying }}</em>"</span
            >
            <br />
            };
            <br />
            <br />
            &gt; println!("{}", user.about());
            <br />
            // {{ aboutDescription }}
          </template>
          <template v-else>
            <!-- markdown -->
            <h1 style="margin-bottom: 0.25rem">
              <span style="color: #808080; font-weight: 700">#</span>
              Erik Bautista Santibanez
            </h1>
            <div style="color: #d8d8d8">
              <p>Mobile & Web Developer</p>
              <p>
                <MapPinIcon />
                {{ residency.city }}, {{ residency.state }}
              </p>
              <p v-if="currentLocation">
                <NavigationArrowIcon />
                Currently in
                <span style="color: #808080; font-weight: 700">***</span>
                <em style="font-weight: 700; color: #fafafa">{{ currentLocation }}</em>
                <span style="color: #808080; font-weight: 700">***</span>
              </p>
              <p v-if="nowPlaying">
                <WaveformIcon />
                Listening to
                <span style="color: #808080; font-weight: 700">***</span>
                <em style="font-weight: 700; color: #fafafa">{{ nowPlaying }}</em>
                <span style="color: #808080; font-weight: 700">***</span>
              </p>
              <p style="margin-top: 0.75rem">{{ aboutDescription }}</p>
            </div>
          </template>
        </template>

        <template #content>
          <div class="user-buttons">
            <div class="button-row">
              <a href="mailto:me@erikb.dev" class="btn btn-primary">
                <code>user.email(){{ codeLang.value !== 'markdown' && codeLang.value !== 'swift' ? ';' : '' }}</code>
              </a>

              <a
                href="https://github.com/erikbdev"
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-secondary"
              >
                <code>user.github(){{ codeLang.value !== 'markdown' && codeLang.value !== 'swift' ? ';' : '' }}</code>
              </a>

              <a
                href="https://www.linkedin.com/in/erikbautista"
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-secondary"
              >
                <code>user.linkedin(){{ codeLang.value !== 'markdown' && codeLang.value !== 'swift' ? ';' : '' }}</code>
              </a>
            </div>
          </div>
        </template>
      </SectionView>

      <SpacerDivider />

      <!-- Posts Section -->
      <SectionView id="dev-logs" :selected="codeLang.value">
        <template #header="{ lang }">
          <template v-if="lang === 'swift'">
            // A curated list of projects I've worked on.
            <br />
            let logs: [DevLog] = await fetch(.all)
          </template>
          <template v-else-if="lang === 'typescript'">
            // A curated list of projects I've worked on.
            <br />
            const logs = await fetch(Filter.All);
          </template>
          <template v-else-if="lang === 'rust'">
            // A curated list of projects I've worked on.
            <br />
            let logs = fetch(Filter::All).await;
          </template>
          <template v-else>
            <!-- markdown -->
            <h1 style="margin-bottom: 0.25rem">
              <span style="color: #808080; font-weight: 700">#</span>
              Dev Logs
            </h1>
            <p style="color: #d8d8d8">A curated list of projects I've worked on.</p>
          </template>
        </template>

        <template #content>
          <div>
            <article v-for="(post, idx) in sortedPosts" :key="post.slug" :id="post.slug" class="post">
              <header>
                <hgroup class="post-header-row">
                  <span class="post-date">{{ post.datePosted }}</span>
                  <pre class="post-index">
                    <a :href="`#${post.slug}`">
                      <code :class="`hljs language-${codeLang.value}`">{{ codeLang.value === 'markdown' ? `log-${sortedPosts.length - idx - 1}.md` : `logs[${sortedPosts.length - idx - 1}]` }}</code>
                    </a>
                  </pre>
                </hgroup>

                <div v-if="post.header">
                  <div v-if="post.header.type === 'image'" class="post-header-media">
                    <img :src="post.header.src" :alt="post.header.label" />
                  </div>
                  <div v-else-if="post.header.type === 'video'" class="post-header-media">
                    <video autoplay playsinline muted controls loop>
                      <source :src="post.header.src" :type="post.header.mime" />
                      Your browser does not support playing this video
                    </video>
                  </div>
                  <div v-else-if="post.header.type === 'code'" class="post-header-media">
                    <pre><code :class="`hljs language-${post.header.lang}`">{{ post.header.code }}</code></pre>
                  </div>
                </div>
              </header>

              <h3 class="post-title">
                <span v-for="(el, i) in post.title.content" :key="i">
                  <template v-if="el.type === 'text'">{{ el.value }}</template>
                  <a v-else-if="el.type === 'link'" :href="el.url" target="_blank" rel="noopener noreferrer">
                    {{ el.title }}
                  </a>
                </span>
              </h3>

              <p v-if="post.content.content.length > 0" class="post-content">
                <span v-for="(el, i) in post.content.content" :key="i">
                  <template v-if="el.type === 'text'">{{ el.value }}</template>
                  <a v-else-if="el.type === 'link'" :href="el.url" target="_blank" rel="noopener noreferrer">
                    {{ el.title }}
                  </a>
                </span>
              </p>

              <footer v-if="post.links && post.links.length > 0">
                <section class="post-links">
                  <a
                    v-for="link in post.links"
                    :key="link.href"
                    :href="link.href"
                    target="_blank"
                    rel="noopener noreferrer"
                    :class="['post-link', `link-${link.role}`]"
                  >
                    {{ link.title }}
                  </a>
                </section>
                <p v-if="post.dateUpdated" class="post-updated">
                  <em>Last updated: {{ post.dateUpdated }}</em>
                </p>
              </footer>
            </article>
          </div>
        </template>
      </SectionView>

      <SpacerDivider />
    </main>

    <FooterView />
  </div>
</template>

<style scoped>
main {
  display: flex;
  flex-direction: column;
  overflow-x: hidden;
}

.user-buttons {
  margin-top: -1rem;
  padding: 0 1.5rem 1.5rem;
}

.button-row {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  gap: 0.625rem;
}

.btn {
  text-decoration: none;
  padding: 0.5rem 0.625rem;
  border: #444 1px solid;
  font-size: 0.8em;
  font-weight: 500;
  display: flex;
  align-items: center;
  cursor: pointer;
  color: inherit;
}

.btn-primary {
  background-color: unset;
}

.btn-secondary {
  background-color: #f0f0f0;
  color: #0f0f0f;
}

code {
  font-family: 'CommitMono', monospace;
  font-feature-settings: 'ss03', 'ss04', 'ss05';
  line-height: 1;
}

.post {
  width: 100%;
  display: inline-block;
  padding: 1.5rem;
  background-image: repeating-linear-gradient(90deg, #444 0 15px, transparent 0 30px);
  background-repeat: repeat-x;
  background-size: 100% 1px;
}

.post-header-row {
  display: flex;
  align-items: baseline;
  margin-bottom: 1rem;
  margin: 0;
}

.post-date {
  flex-grow: 1;
  color: #9a9a9a;
  font-size: 0.75em;
  font-weight: 599;
}

.post-index {
  font-size: 0.75em;
  font-weight: 500;
  text-align: end;
  margin: 0;
}

.post-index a {
  color: #777;
  text-decoration: none;
}

.post-header-media {
  background: #242423;
  border: 1.5px solid #3a3a3a;
  overflow-x: auto;
  width: 100%;
  margin-bottom: 1.25rem;
}

.post-header-media img,
.post-header-media video {
  display: block;
  max-width: 100%;
  width: 100%;
}

.post-header-media pre {
  padding: 0.75rem;
  font-size: 0.85em;
  margin: 0;
}

.post-title {
  margin-bottom: 0.5rem;
}

.post-content {
  white-space: pre-wrap;
  margin-bottom: 1rem;
}

.post-links {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

.post-link {
  text-decoration: none;
  padding: 0.5rem 0.625rem;
  border: #444 1px solid;
  font-size: 0.8em;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  color: inherit;
}

.link-secondary {
  background-color: #f0f0f0;
  color: #0f0f0f;
}

.post-updated {
  color: #6a7a7a;
  font-size: 0.578em;
  margin: 0;
}

.post footer {
  display: contents;
}
</style>
