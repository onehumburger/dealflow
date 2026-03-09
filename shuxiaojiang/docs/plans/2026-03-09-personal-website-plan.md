# Arthur Cang Personal Website — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a bilingual (CN/EN) static personal website for Arthur Cang, cross-border lawyer at Jingtian & Gongcheng.

**Architecture:** Astro 5 static site with Tailwind CSS. Bilingual routing via `/zh/` and `/en/` prefixes. Content stored as markdown using Astro Content Collections with glob loaders. i18n handled via a custom utility layer (getLangFromUrl, useTranslations). No JS framework — pure Astro components with minimal client-side JS for mobile menu and language toggle.

**Tech Stack:** Astro 5, Tailwind CSS v4, Astro Content Collections, TypeScript

**Design doc:** `docs/plans/2026-03-09-personal-website-design.md`

---

### Task 1: Project Scaffolding

**Files:**
- Create: `package.json`
- Create: `astro.config.mjs`
- Create: `tsconfig.json`
- Create: `src/env.d.ts`

**Step 1: Initialize Astro project**

```bash
cd /Users/BBB/ccproj/shuxiaojiang
npm create astro@latest . -- --template minimal --no-git --no-install --typescript strict
```

If prompted to overwrite, allow it (empty project).

**Step 2: Install dependencies**

```bash
npm install
npm install @astrojs/tailwind tailwindcss
```

**Step 3: Configure Astro with i18n and Tailwind**

Update `astro.config.mjs`:

```javascript
import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  integrations: [tailwind()],
  i18n: {
    defaultLocale: 'zh',
    locales: ['zh', 'en'],
    routing: {
      prefixDefaultLocale: true,
    },
  },
});
```

**Step 4: Verify dev server starts**

```bash
npm run dev
```

Expected: Server starts at localhost:4321 with no errors.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: scaffold Astro 5 project with Tailwind and i18n config"
```

---

### Task 2: i18n Utility Layer

**Files:**
- Create: `src/i18n/ui.ts`
- Create: `src/i18n/utils.ts`

**Step 1: Create UI translation strings**

Create `src/i18n/ui.ts`:

```typescript
export const languages = {
  zh: '中文',
  en: 'English',
};

export const defaultLang = 'zh';
export const showDefaultLang = true;

export const ui = {
  zh: {
    'site.title': '仓晨阳 | 竞天公诚律师事务所',
    'site.description': '仓晨阳律师，竞天公诚律师事务所合伙人，专注跨境投资并购、时尚与奢侈品、科技与云计算法律服务',
    'nav.home': '首页',
    'nav.about': '关于',
    'nav.practice': '业务领域',
    'nav.experience': '代表案例',
    'nav.insights': '专业文章',
    'nav.contact': '联系方式',
    'hero.tagline': '跨境法律服务 · 连接中国与世界',
    'hero.subtitle': '竞天公诚律师事务所 · 合伙人',
    'hero.cta': '联系我',
    'section.practice': '专注业务领域',
    'section.experience': '代表案例',
    'section.insights': '专业文章',
    'section.contact': '联系方式',
    'footer.copyright': '© 2026 仓晨阳 | 竞天公诚律师事务所',
    'footer.address': '上海市徐汇区淮海中路1010号嘉华中心45层',
    'contact.email': '电子邮箱',
    'contact.phone': '电话',
    'contact.office': '办公地址',
    'contact.wechat': '微信',
    'about.education': '教育背景',
    'about.publications': '发表成果',
    'about.memberships': '社会活动',
    'insights.readmore': '阅读全文',
    'insights.empty': '文章即将上线，敬请期待。',
  },
  en: {
    'site.title': 'Arthur Cang | Jingtian & Gongcheng',
    'site.description': 'Arthur Cang, Partner at Jingtian & Gongcheng, specializing in cross-border investment, fashion & luxury, and technology law',
    'nav.home': 'Home',
    'nav.about': 'About',
    'nav.practice': 'Practice Areas',
    'nav.experience': 'Experience',
    'nav.insights': 'Insights',
    'nav.contact': 'Contact',
    'hero.tagline': 'Cross-Border Legal Services · Connecting China and the World',
    'hero.subtitle': 'Jingtian & Gongcheng · Partner',
    'hero.cta': 'Get in Touch',
    'section.practice': 'Key Practice Areas',
    'section.experience': 'Representative Experience',
    'section.insights': 'Insights',
    'section.contact': 'Contact',
    'footer.copyright': '© 2026 Arthur Cang | Jingtian & Gongcheng',
    'footer.address': '45F, Jiahua Center, 1010 Huaihai Middle Road, Xuhui District, Shanghai',
    'contact.email': 'Email',
    'contact.phone': 'Phone',
    'contact.office': 'Office',
    'contact.wechat': 'WeChat',
    'about.education': 'Education',
    'about.publications': 'Publications',
    'about.memberships': 'Activities',
    'insights.readmore': 'Read More',
    'insights.empty': 'Articles coming soon.',
  },
} as const;
```

**Step 2: Create i18n utility functions**

Create `src/i18n/utils.ts`:

```typescript
import { ui, defaultLang, showDefaultLang, languages } from './ui';

export function getLangFromUrl(url: URL) {
  const [, lang] = url.pathname.split('/');
  if (lang in ui) return lang as keyof typeof ui;
  return defaultLang;
}

export function useTranslations(lang: keyof typeof ui) {
  return function t(key: keyof (typeof ui)[typeof defaultLang]) {
    return ui[lang][key] || ui[defaultLang][key];
  };
}

export function useTranslatedPath(lang: keyof typeof ui) {
  return function translatePath(path: string, l: string = lang) {
    return !showDefaultLang && l === defaultLang ? path : `/${l}${path}`;
  };
}

export function getLanguageToggleUrl(url: URL) {
  const lang = getLangFromUrl(url);
  const targetLang = lang === 'zh' ? 'en' : 'zh';
  const pathWithoutLang = url.pathname.replace(/^\/(zh|en)/, '');
  return `/${targetLang}${pathWithoutLang || '/'}`;
}

export { languages, defaultLang };
```

**Step 3: Commit**

```bash
git add src/i18n/
git commit -m "feat: add i18n translation strings and utility functions"
```

---

### Task 3: Content Collections Setup

**Files:**
- Create: `src/content.config.ts`
- Create: `src/data/about/en.md`
- Create: `src/data/about/zh.md`
- Create: `src/data/practice-areas/en/cross-border.md`
- Create: `src/data/practice-areas/en/fashion-luxury.md`
- Create: `src/data/practice-areas/en/technology.md`
- Create: `src/data/practice-areas/en/media.md`
- Create: `src/data/practice-areas/en/financial.md`
- Create: `src/data/practice-areas/en/franchise.md`
- Create: `src/data/practice-areas/en/gaming.md`
- Create: `src/data/practice-areas/zh/cross-border.md`
- Create: `src/data/practice-areas/zh/fashion-luxury.md`
- Create: `src/data/practice-areas/zh/technology.md`
- Create: `src/data/practice-areas/zh/media.md`
- Create: `src/data/practice-areas/zh/financial.md`
- Create: `src/data/practice-areas/zh/franchise.md`
- Create: `src/data/practice-areas/zh/gaming.md`
- Create: `src/data/experience/en.md`
- Create: `src/data/experience/zh.md`
- Create: `src/data/insights/en/` (empty directory with .gitkeep)
- Create: `src/data/insights/zh/` (empty directory with .gitkeep)

**Step 1: Define content collections**

Create `src/content.config.ts`:

```typescript
import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const about = defineCollection({
  loader: glob({ pattern: '*.md', base: './src/data/about' }),
  schema: z.object({
    title: z.string(),
    lang: z.enum(['zh', 'en']),
  }),
});

const practiceAreas = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/data/practice-areas' }),
  schema: z.object({
    title: z.string(),
    lang: z.enum(['zh', 'en']),
    icon: z.string(),
    order: z.number(),
    summary: z.string(),
  }),
});

const experience = defineCollection({
  loader: glob({ pattern: '*.md', base: './src/data/experience' }),
  schema: z.object({
    title: z.string(),
    lang: z.enum(['zh', 'en']),
  }),
});

const insights = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/data/insights' }),
  schema: z.object({
    title: z.string(),
    lang: z.enum(['zh', 'en']),
    date: z.coerce.date(),
    summary: z.string(),
    tags: z.array(z.string()).optional(),
  }),
});

export const collections = { about, practiceAreas, experience, insights };
```

**Step 2: Create about content**

`src/data/about/en.md` — Full English bio from the PDF (paragraphs 1-4 of the bio, education, publications, memberships). Frontmatter: `title: "About Arthur Cang"`, `lang: "en"`.

`src/data/about/zh.md` — Full Chinese bio from the PDF. Frontmatter: `title: "关于仓晨阳"`, `lang: "zh"`.

Content is taken directly from the PDF bio. Include education as a structured section (use markdown headings/lists). Include the 3 ACCA publications (NOT the stablecoins one). Include memberships.

**Step 3: Create practice area content (all 7 areas, both languages)**

Each practice area `.md` file has frontmatter with `title`, `lang`, `icon` (SVG icon name), `order` (display order), and `summary` (one-line description).

Content body: bullet points of representative work from the PDF for that practice area.

Example `src/data/practice-areas/en/cross-border.md`:
```markdown
---
title: "Cross-border Investment & M&A"
lang: "en"
icon: "globe"
order: 1
summary: "Advising multinational and Chinese enterprises on cross-border transactions, outbound investments, and market entry strategies."
---

- Represented a renowned Chinese public pharmaceutical company in its acquisition of a major CDMO asset from a world leading pharmaceutical group headquartered in Switzerland.
- Represented a public traded valve manufacturer in its acquisition of manufacturing assets in Germany and Canada.
...
```

Repeat for all 7 areas in both `en/` and `zh/` using the PDF content.

**Step 4: Create experience content**

`src/data/experience/en.md` and `src/data/experience/zh.md` — the "Practice Experience: Cross-border Transactions" section from the PDF, formatted as markdown bullet lists. Frontmatter: `title`, `lang`.

**Step 5: Create empty insights directories**

```bash
mkdir -p src/data/insights/en src/data/insights/zh
touch src/data/insights/en/.gitkeep src/data/insights/zh/.gitkeep
```

**Step 6: Verify build**

```bash
npm run build
```

Expected: Build succeeds with no errors.

**Step 7: Commit**

```bash
git add src/content.config.ts src/data/
git commit -m "feat: add content collections and all bilingual content from bio"
```

---

### Task 4: Base Layout & Global Styles

**Files:**
- Create: `src/layouts/BaseLayout.astro`
- Create: `src/styles/global.css`
- Create: `public/images/` (directory for headshot)

**Step 1: Extract headshot from PDF**

The user's professional headshot needs to be saved to `public/images/arthur-cang.jpg`. Since we cannot programmatically extract from the PDF, create a placeholder and note that the user should provide the image file.

```bash
mkdir -p public/images
```

Create a placeholder note: `public/images/README.md` with instruction to place `arthur-cang.jpg` here.

**Step 2: Create global styles**

Create `src/styles/global.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Noto+Sans+SC:wght@300;400;500;600;700&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    scroll-behavior: smooth;
    font-family: 'Inter', 'Noto Sans SC', sans-serif;
  }

  body {
    @apply text-charcoal bg-white antialiased;
  }

  h1, h2, h3, h4, h5, h6 {
    @apply font-semibold text-navy;
  }
}

@layer components {
  .section-container {
    @apply max-w-6xl mx-auto px-6 py-16 md:py-24;
  }

  .section-title {
    @apply text-3xl md:text-4xl font-bold text-navy mb-12 text-center;
  }

  .card {
    @apply bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 hover:-translate-y-1 p-8;
  }

  .gold-accent {
    @apply text-gold;
  }

  .btn-primary {
    @apply inline-block bg-navy text-white px-8 py-3 rounded-lg font-medium hover:bg-opacity-90 transition-all duration-300;
  }

  .btn-outline {
    @apply inline-block border-2 border-navy text-navy px-8 py-3 rounded-lg font-medium hover:bg-navy hover:text-white transition-all duration-300;
  }
}

/* Fade-in animation on scroll */
.fade-in {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}

.fade-in.visible {
  opacity: 1;
  transform: translateY(0);
}
```

**Step 3: Configure Tailwind with custom theme**

Create or update `tailwind.config.mjs`:

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        navy: '#1a2744',
        gold: '#b8965a',
        charcoal: '#2d2d2d',
        lightgray: '#f7f8fa',
      },
      fontFamily: {
        sans: ['Inter', 'Noto Sans SC', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
```

**Step 4: Create BaseLayout**

Create `src/layouts/BaseLayout.astro`:

```astro
---
import '../styles/global.css';
import Header from '../components/Header.astro';
import Footer from '../components/Footer.astro';
import { getLangFromUrl, useTranslations } from '../i18n/utils';

interface Props {
  title?: string;
  description?: string;
}

const lang = getLangFromUrl(Astro.url);
const t = useTranslations(lang);
const { title = t('site.title'), description = t('site.description') } = Astro.props;
---
<!doctype html>
<html lang={lang}>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content={description} />
    <title>{title}</title>
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  </head>
  <body class="min-h-screen flex flex-col">
    <Header />
    <main class="flex-1">
      <slot />
    </main>
    <Footer />
    <script>
      // Scroll fade-in observer
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add('visible');
            }
          });
        },
        { threshold: 0.1 }
      );
      document.querySelectorAll('.fade-in').forEach((el) => observer.observe(el));
    </script>
  </body>
</html>
```

**Step 5: Verify build**

```bash
npm run build
```

Expected: Build may warn about missing Header/Footer components — that's fine, we create them next.

**Step 6: Commit**

```bash
git add src/layouts/ src/styles/ tailwind.config.mjs public/images/
git commit -m "feat: add base layout, global styles, and Tailwind theme config"
```

---

### Task 5: Header & Footer Components

**Files:**
- Create: `src/components/Header.astro`
- Create: `src/components/Footer.astro`
- Create: `src/components/LanguageToggle.astro`
- Create: `src/components/MobileMenu.astro`

**Step 1: Create LanguageToggle component**

`src/components/LanguageToggle.astro` — A simple toggle that links to the same page in the other language. Uses `getLanguageToggleUrl` from i18n utils. Renders as a small pill button: "中" / "EN".

**Step 2: Create Header component**

`src/components/Header.astro` — Fixed navbar with:
- Left: Name "仓晨阳" / "Arthur Cang" (links to home)
- Center: Nav links (Home, About, Practice Areas, Experience, Insights, Contact) using `useTranslations` and `useTranslatedPath`
- Right: LanguageToggle component
- Mobile: Hamburger icon that triggers MobileMenu

Styling: `bg-white/95 backdrop-blur-sm shadow-sm` with `sticky top-0 z-50`. Navy text, gold hover underline.

**Step 3: Create MobileMenu component**

`src/components/MobileMenu.astro` — Full-screen overlay menu for mobile. Contains same nav links + language toggle. Uses a small `<script>` for open/close toggle (client-side JS).

**Step 4: Create Footer component**

`src/components/Footer.astro` — Dark navy background. Contains:
- Firm name and address (translated)
- Email and phone
- Copyright line
- Subtle gold horizontal rule at top

**Step 5: Verify dev server**

```bash
npm run dev
```

Navigate to `localhost:4321/zh/` and `localhost:4321/en/` — header and footer should render. Language toggle should switch between them.

**Step 6: Commit**

```bash
git add src/components/
git commit -m "feat: add Header, Footer, LanguageToggle, and MobileMenu components"
```

---

### Task 6: Home Page

**Files:**
- Create: `src/pages/index.astro` (redirect to `/zh/`)
- Create: `src/pages/zh/index.astro`
- Create: `src/pages/en/index.astro`
- Create: `src/components/Hero.astro`
- Create: `src/components/PracticeAreaCard.astro`

**Step 1: Create root redirect**

`src/pages/index.astro`:

```astro
---
return Astro.redirect('/zh/');
---
```

**Step 2: Create Hero component**

`src/components/Hero.astro` — Full-width hero section:
- Background: subtle gradient (navy to slightly lighter navy) or textured background
- Left side: Name (large), title, tagline, CTA button
- Right side: Professional photo with refined border/frame treatment
- Responsive: stacks vertically on mobile

**Step 3: Create PracticeAreaCard component**

`src/components/PracticeAreaCard.astro` — Accepts props: `title`, `summary`, `icon`, `href`. Renders as a card with icon, title, summary. Hover animation (lift + shadow).

**Step 4: Create Home pages (zh and en)**

Both `src/pages/zh/index.astro` and `src/pages/en/index.astro` use BaseLayout and contain:
1. Hero component
2. "Key Practice Areas" section with 3 featured PracticeAreaCards (Cross-border, Fashion & Luxury, Technology)
3. Brief "about" teaser with link to full about page
4. CTA section linking to Contact

Query practice areas from content collections, filter by lang, show top 3 by order.

**Step 5: Verify**

```bash
npm run dev
```

Navigate to `localhost:4321` — should redirect to `/zh/`. Home page should render with hero, practice cards, and CTA. `/en/` should show English version.

**Step 6: Commit**

```bash
git add src/pages/ src/components/Hero.astro src/components/PracticeAreaCard.astro
git commit -m "feat: add Home page with Hero, practice area cards, and root redirect"
```

---

### Task 7: About Page

**Files:**
- Create: `src/pages/zh/about.astro`
- Create: `src/pages/en/about.astro`
- Create: `src/components/EducationTimeline.astro`

**Step 1: Create EducationTimeline component**

`src/components/EducationTimeline.astro` — Vertical timeline showing 4 degrees with school name, degree, and year. Alternating left/right on desktop, linear on mobile. Gold accent dots on the timeline.

**Step 2: Create About pages**

Both pages use BaseLayout. Content sections:
1. Photo + brief intro paragraph (from content collection)
2. Full bio text
3. Education timeline component (hardcoded data — 4 degrees)
4. Publications list (3 ACCA reports only — NO stablecoins)
5. Memberships (Shanghai Bar Association, China Democratic and Nation Building Committee)

Query `about` collection, filter by lang, render content.

**Step 3: Verify**

```bash
npm run dev
```

Navigate to `/zh/about` and `/en/about`. Both should render fully.

**Step 4: Commit**

```bash
git add src/pages/zh/about.astro src/pages/en/about.astro src/components/EducationTimeline.astro
git commit -m "feat: add About page with education timeline and publications"
```

---

### Task 8: Practice Areas Page

**Files:**
- Create: `src/pages/zh/practice.astro`
- Create: `src/pages/en/practice.astro`

**Step 1: Create Practice Areas pages**

Both pages use BaseLayout. Query `practiceAreas` collection filtered by lang, sort by order. Render each as a large card with:
- Icon (SVG inline)
- Title
- Summary
- Expandable or visible bullet list of representative work

Layout: responsive grid — 2 columns on desktop, 1 on mobile. Cards use `.card` styling with fade-in animation.

**Step 2: Verify**

```bash
npm run dev
```

Navigate to `/zh/practice` and `/en/practice`. All 7 practice areas should appear with content.

**Step 3: Commit**

```bash
git add src/pages/zh/practice.astro src/pages/en/practice.astro
git commit -m "feat: add Practice Areas page with all 7 practice areas"
```

---

### Task 9: Experience Page

**Files:**
- Create: `src/pages/zh/experience.astro`
- Create: `src/pages/en/experience.astro`

**Step 1: Create Experience pages**

Both pages use BaseLayout. Query `experience` collection filtered by lang. Render the cross-border transactions list as styled cards or an elegant list grouped by category. Each case is a bullet point.

**Step 2: Verify and commit**

```bash
npm run dev
git add src/pages/zh/experience.astro src/pages/en/experience.astro
git commit -m "feat: add Experience page with representative cases"
```

---

### Task 10: Insights (Blog) Page

**Files:**
- Create: `src/pages/zh/insights.astro`
- Create: `src/pages/en/insights.astro`
- Create: `src/pages/zh/insights/[...slug].astro`
- Create: `src/pages/en/insights/[...slug].astro`

**Step 1: Create Insights listing pages**

Both pages query `insights` collection filtered by lang, sorted by date descending. If no articles yet, show the `insights.empty` translated message. Each article card shows: title, date, summary, "Read More" link.

**Step 2: Create Insights detail pages**

Dynamic route pages using `getStaticPaths`. Query insights collection, generate paths per article. Render full markdown content with BaseLayout.

**Step 3: Verify**

```bash
npm run dev
```

Navigate to `/zh/insights` and `/en/insights`. Should show empty state message (no articles yet).

**Step 4: Commit**

```bash
git add src/pages/zh/insights/ src/pages/en/insights/ src/pages/zh/insights.astro src/pages/en/insights.astro
git commit -m "feat: add Insights blog listing and detail pages"
```

---

### Task 11: Contact Page

**Files:**
- Create: `src/pages/zh/contact.astro`
- Create: `src/pages/en/contact.astro`

**Step 1: Create Contact pages**

Both pages use BaseLayout. Clean layout with:
- Email: arhur.cang@jingtian.com (mailto link)
- Phone: (86) 137.6451.3451 (tel link)
- Office address (translated) with embedded map or static map image
- WeChat QR code placeholder (gray box with "WeChat QR" text)
- Link to Jingtian & Gongcheng website

Styled with card layout, gold accent icons for each contact method.

**Step 2: Verify and commit**

```bash
npm run dev
git add src/pages/zh/contact.astro src/pages/en/contact.astro
git commit -m "feat: add Contact page with email, phone, and office info"
```

---

### Task 12: Visual Polish & Responsive Testing

**Files:**
- Modify: various component files for polish

**Step 1: Add SVG icons for practice areas**

Create `src/components/icons/` directory with simple SVG icon components for: globe (cross-border), diamond (fashion), cloud (technology), film (media), building (financial), store (franchise), gamepad (gaming).

**Step 2: Add scroll fade-in animations**

Ensure all major sections have the `fade-in` class. The IntersectionObserver in BaseLayout handles the rest.

**Step 3: Add hover states and micro-interactions**

- Nav links: gold underline on hover
- Cards: lift + shadow transition
- CTA buttons: subtle scale on hover
- Language toggle: smooth transition

**Step 4: Responsive testing**

Open dev tools, test at:
- Mobile: 375px (iPhone SE)
- Tablet: 768px (iPad)
- Desktop: 1280px+

Fix any layout issues.

**Step 5: Commit**

```bash
git add -A
git commit -m "feat: add SVG icons, scroll animations, and responsive polish"
```

---

### Task 13: Final Build & Cleanup

**Step 1: Production build**

```bash
npm run build
```

Expected: Clean build with no errors or warnings.

**Step 2: Preview production build**

```bash
npm run preview
```

Navigate through all pages in both languages. Verify:
- All links work
- Language toggle works on every page
- All content renders correctly
- No console errors
- Responsive layout is correct

**Step 3: Clean up**

- Remove any unused files from `src/pages/` (e.g., default Astro index page)
- Ensure `.gitignore` includes `node_modules/`, `dist/`, `.astro/`

**Step 4: Final commit**

```bash
git add -A
git commit -m "feat: production build verified, cleanup complete"
```

---

## Summary

| Task | Description | Key Files |
|------|-------------|-----------|
| 1 | Project scaffolding | `package.json`, `astro.config.mjs` |
| 2 | i18n utility layer | `src/i18n/ui.ts`, `src/i18n/utils.ts` |
| 3 | Content collections + all content | `src/content.config.ts`, `src/data/**/*.md` |
| 4 | Base layout & global styles | `src/layouts/BaseLayout.astro`, `src/styles/global.css` |
| 5 | Header & Footer | `src/components/Header.astro`, `Footer.astro` |
| 6 | Home page | `src/pages/{zh,en}/index.astro` |
| 7 | About page | `src/pages/{zh,en}/about.astro` |
| 8 | Practice Areas page | `src/pages/{zh,en}/practice.astro` |
| 9 | Experience page | `src/pages/{zh,en}/experience.astro` |
| 10 | Insights (blog) page | `src/pages/{zh,en}/insights.astro` |
| 11 | Contact page | `src/pages/{zh,en}/contact.astro` |
| 12 | Visual polish & responsive | Icons, animations, responsive fixes |
| 13 | Final build & cleanup | Production verification |
