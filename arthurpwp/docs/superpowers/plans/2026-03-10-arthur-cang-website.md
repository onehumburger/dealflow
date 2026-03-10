# Arthur Cang Personal Website Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a bilingual (Chinese/English) personal website for lawyer 仓晨阳 (Arthur Cang) using Astro 5.x with a dark, premium design.

**Architecture:** Astro static site with file-based routing for i18n (`/zh/`, `/en/`). Content data stored in TypeScript files per language. Tailwind CSS for styling with a custom dark theme. No backend — pure static build.

**Tech Stack:** Astro 5.x, Tailwind CSS 4.x, TypeScript

**Spec:** `docs/superpowers/specs/2026-03-10-arthur-cang-personal-website-design.md`

**Resume source:** `Arthur Cang Bio_Jingtian-Bilingual.pdf` (6 pages, full bilingual content already extracted)

---

## File Structure

```
arthurpwp/
├── astro.config.mjs          # Astro config with site settings
├── package.json               # Dependencies
├── tailwind.config.mjs        # Tailwind theme (colors, fonts)
├── tsconfig.json              # TypeScript config
├── public/
│   └── favicon.svg            # Gold scales-of-justice icon
├── src/
│   ├── i18n/
│   │   ├── ui.ts              # All UI translation strings (nav, buttons, labels)
│   │   └── utils.ts           # getLangFromUrl(), useTranslations() helpers
│   ├── layouts/
│   │   └── BaseLayout.astro   # HTML shell: head, fonts, Header, Footer, slot
│   ├── components/
│   │   ├── Header.astro       # Fixed top nav + language toggle
│   │   ├── Footer.astro       # Copyright + social links
│   │   ├── Hero.astro         # Full-screen hero for home page
│   │   ├── PracticeAreaCard.astro  # Reusable card with icon + title + description
│   │   ├── Timeline.astro     # Vertical timeline for education/career
│   │   └── CaseGroup.astro    # Case list grouped by practice area
│   ├── data/
│   │   ├── bio.ts             # Bio text, education, career, memberships (zh + en)
│   │   ├── practice-areas.ts  # 8 practice areas with descriptions and services (zh + en)
│   │   ├── cases.ts           # Representative cases grouped by area (zh + en)
│   │   └── publications.ts    # Publications list (zh + en)
│   ├── styles/
│   │   └── global.css         # Tailwind imports + custom base styles
│   └── pages/
│       ├── index.astro        # Root redirect → /zh/
│       ├── zh/
│       │   ├── index.astro    # Chinese home
│       │   ├── about.astro    # Chinese about
│       │   ├── practice.astro # Chinese practice areas
│       │   ├── cases.astro    # Chinese representative cases
│       │   ├── insights.astro # Chinese publications & insights
│       │   └── contact.astro  # Chinese contact
│       └── en/
│           ├── index.astro    # English home
│           ├── about.astro    # English about
│           ├── practice.astro # English practice areas
│           ├── cases.astro    # English representative cases
│           ├── insights.astro # English publications & insights
│           └── contact.astro  # English contact
```

---

## Chunk 1: Project Foundation

### Task 1: Scaffold Astro Project and Configure Tooling

**Files:**
- Create: `package.json`
- Create: `astro.config.mjs`
- Create: `tailwind.config.mjs`
- Create: `tsconfig.json`
- Create: `src/styles/global.css`
- Create: `public/favicon.svg`

- [ ] **Step 1: Initialize Astro project**

```bash
cd /Users/BBB/ccproj/arthurpwp
npm create astro@latest . -- --template minimal --no-install --typescript strict
```

Accept overwriting if prompted. This creates `package.json`, `astro.config.mjs`, `tsconfig.json`, and `src/pages/index.astro`.

- [ ] **Step 2: Install dependencies**

```bash
npm install
npm install @astrojs/tailwind tailwindcss @tailwindcss/vite
```

- [ ] **Step 3: Configure astro.config.mjs**

Replace contents of `astro.config.mjs`:

```js
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  vite: {
    plugins: [tailwindcss()],
  },
});
```

- [ ] **Step 4: Create global.css with Tailwind imports and theme**

Create `src/styles/global.css`:

```css
@import "tailwindcss";

@theme {
  --color-navy: #0A1628;
  --color-charcoal: #1A2332;
  --color-gold: #C49A6C;
  --color-gold-light: #D4AF7F;
  --color-text-primary: #E8E8E8;
  --color-text-secondary: #A0A8B4;
  --color-border: #2A3444;

  --font-serif: 'Playfair Display', 'Noto Serif SC', serif;
  --font-sans: 'Inter', 'Noto Sans SC', system-ui, sans-serif;
}

@layer base {
  body {
    @apply bg-navy text-text-primary font-sans;
  }

  h1, h2, h3 {
    @apply font-serif;
  }
}
```

- [ ] **Step 5: Create favicon.svg**

Create `public/favicon.svg` — a minimal gold scales-of-justice icon:

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <path d="M16 2 L16 28 M8 28 L24 28 M6 8 L26 8 M6 8 L3 16 Q3 20 9 20 Q15 20 9 16 Z M26 8 L23 16 Q23 20 29 20 Q35 20 29 16 Z" fill="none" stroke="#C49A6C" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
```

- [ ] **Step 6: Verify dev server starts**

```bash
npm run dev
```

Expected: Astro dev server starts on `localhost:4321` without errors. Stop it after verifying.

- [ ] **Step 7: Commit**

```bash
git add package.json package-lock.json astro.config.mjs tsconfig.json src/styles/global.css public/favicon.svg src/env.d.ts
git commit -m "feat: scaffold Astro project with Tailwind and dark theme"
```

---

### Task 2: Set Up i18n Utilities and UI Strings

**Files:**
- Create: `src/i18n/utils.ts`
- Create: `src/i18n/ui.ts`

- [ ] **Step 1: Create i18n utility functions**

Create `src/i18n/utils.ts`:

```ts
import { ui, defaultLang, type Lang } from './ui';

export function getLangFromUrl(url: URL): Lang {
  const [, lang] = url.pathname.split('/');
  if (lang in ui) return lang as Lang;
  return defaultLang;
}

export function useTranslations(lang: Lang) {
  return function t(key: keyof typeof ui[typeof defaultLang]): string {
    return ui[lang][key] || ui[defaultLang][key];
  };
}

export function getAlternateLang(lang: Lang): Lang {
  return lang === 'zh' ? 'en' : 'zh';
}

export function getAlternateUrl(url: URL): string {
  const lang = getLangFromUrl(url);
  const altLang = getAlternateLang(lang);
  return url.pathname.replace(`/${lang}/`, `/${altLang}/`);
}
```

- [ ] **Step 2: Create UI translation strings**

Create `src/i18n/ui.ts`:

```ts
export const defaultLang = 'zh' as const;

export type Lang = 'zh' | 'en';

export const ui = {
  zh: {
    'nav.home': '首页',
    'nav.about': '关于',
    'nav.practice': '业务领域',
    'nav.cases': '代表案例',
    'nav.insights': '发表与洞察',
    'nav.contact': '联系方式',
    'lang.toggle': 'EN',
    'hero.name': '仓晨阳',
    'hero.title': '合伙人 · 竞天公诚律师事务所',
    'hero.tagline': '跨境投资并购 · 时尚与奢侈品 · 金融科技',
    'hero.cta': '联系仓律师',
    'section.practice': '业务领域',
    'section.about': '关于仓律师',
    'section.education': '教育背景',
    'section.career': '执业经历',
    'section.memberships': '专业资质与社会活动',
    'section.cases': '代表案例',
    'section.publications': '发表成果',
    'section.insights': '行业洞察',
    'section.contact': '联系方式',
    'contact.phone': '电话',
    'contact.email': '邮箱',
    'contact.office': '办公室',
    'contact.form.name': '姓名',
    'contact.form.email': '邮箱',
    'contact.form.message': '请简要描述您的需求',
    'contact.form.submit': '发送',
    'footer.copyright': '© 2026 仓晨阳. 保留所有权利.',
    'footer.firm': '竞天公诚律师事务所',
  },
  en: {
    'nav.home': 'Home',
    'nav.about': 'About',
    'nav.practice': 'Practice',
    'nav.cases': 'Cases',
    'nav.insights': 'Insights',
    'nav.contact': 'Contact',
    'lang.toggle': '中文',
    'hero.name': 'Arthur Cang',
    'hero.title': 'Partner · Jingtian & Gongcheng',
    'hero.tagline': 'Cross-border Investment · Fashion & Luxury · Fintech',
    'hero.cta': 'Contact Arthur',
    'section.practice': 'Practice Areas',
    'section.about': 'About Arthur',
    'section.education': 'Education',
    'section.career': 'Career',
    'section.memberships': 'Professional Memberships',
    'section.cases': 'Representative Cases',
    'section.publications': 'Publications',
    'section.insights': 'Insights',
    'section.contact': 'Contact',
    'contact.phone': 'Phone',
    'contact.email': 'Email',
    'contact.office': 'Office',
    'contact.form.name': 'Name',
    'contact.form.email': 'Email',
    'contact.form.message': 'Briefly describe your needs',
    'contact.form.submit': 'Send',
    'footer.copyright': '© 2026 Arthur Cang. All rights reserved.',
    'footer.firm': 'Jingtian & Gongcheng',
  },
} as const;
```

- [ ] **Step 3: Commit**

```bash
git add src/i18n/
git commit -m "feat: add i18n utilities and bilingual UI strings"
```

---

### Task 3: Create Base Layout, Header, and Footer

**Files:**
- Create: `src/layouts/BaseLayout.astro`
- Create: `src/components/Header.astro`
- Create: `src/components/Footer.astro`

- [ ] **Step 1: Create Header component**

Create `src/components/Header.astro`:

```astro
---
import { getLangFromUrl, useTranslations, getAlternateUrl } from '../i18n/utils';

const lang = getLangFromUrl(Astro.url);
const t = useTranslations(lang);
const altUrl = getAlternateUrl(Astro.url);

const navItems = [
  { key: 'nav.home' as const, href: `/${lang}/` },
  { key: 'nav.about' as const, href: `/${lang}/about` },
  { key: 'nav.practice' as const, href: `/${lang}/practice` },
  { key: 'nav.cases' as const, href: `/${lang}/cases` },
  { key: 'nav.insights' as const, href: `/${lang}/insights` },
  { key: 'nav.contact' as const, href: `/${lang}/contact` },
];
---

<header id="main-header" class="fixed top-0 left-0 right-0 z-50 transition-all duration-300 bg-navy/80 backdrop-blur-md border-b border-border/50">
  <nav class="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
    <a href={`/${lang}/`} class="font-serif text-xl text-gold tracking-wide">
      {t('hero.name')}
    </a>

    <div class="hidden md:flex items-center gap-8">
      {navItems.map(item => (
        <a href={item.href} class="text-sm text-text-secondary hover:text-gold transition-colors">
          {t(item.key)}
        </a>
      ))}
      <a href={altUrl} class="text-sm border border-gold/40 text-gold px-3 py-1 rounded hover:bg-gold/10 transition-colors">
        {t('lang.toggle')}
      </a>
    </div>

    <button id="mobile-menu-btn" class="md:hidden text-text-secondary" aria-label="Menu">
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/>
      </svg>
    </button>
  </nav>

  <div id="mobile-menu" class="hidden md:hidden border-t border-border/50 bg-navy/95 backdrop-blur-md">
    <div class="px-6 py-4 flex flex-col gap-4">
      {navItems.map(item => (
        <a href={item.href} class="text-sm text-text-secondary hover:text-gold transition-colors">
          {t(item.key)}
        </a>
      ))}
      <a href={altUrl} class="text-sm border border-gold/40 text-gold px-3 py-1 rounded hover:bg-gold/10 transition-colors w-fit">
        {t('lang.toggle')}
      </a>
    </div>
  </div>
</header>

<script>
  const btn = document.getElementById('mobile-menu-btn');
  const menu = document.getElementById('mobile-menu');
  btn?.addEventListener('click', () => menu?.classList.toggle('hidden'));
</script>
```

- [ ] **Step 2: Create Footer component**

Create `src/components/Footer.astro`:

```astro
---
import { getLangFromUrl, useTranslations } from '../i18n/utils';

const lang = getLangFromUrl(Astro.url);
const t = useTranslations(lang);
---

<footer class="border-t border-border/50 bg-charcoal">
  <div class="max-w-6xl mx-auto px-6 py-10 flex flex-col md:flex-row items-center justify-between gap-4 text-sm text-text-secondary">
    <div>
      <p>{t('footer.copyright')}</p>
      <p class="text-xs mt-1">{t('footer.firm')}</p>
    </div>
    <div class="flex gap-4">
      <a href="https://www.linkedin.com" target="_blank" rel="noopener noreferrer" class="hover:text-gold transition-colors" aria-label="LinkedIn">
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>
      </a>
      <a href="https://www.zhihu.com/people/cang-chen-yang-85" target="_blank" rel="noopener noreferrer" class="hover:text-gold transition-colors" aria-label="Zhihu">
        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M5.721 0C2.251 0 0 2.25 0 5.719V18.28C0 21.751 2.252 24 5.721 24h12.56C21.751 24 24 21.75 24 18.281V5.72C24 2.249 21.75 0 18.281 0zm1.964 4.078h6.139c.186 0 .322.14.29.333l-.18 1.2c-.03.186-.191.333-.378.333H8.029c-.229 0-.382.167-.382.417v8.47c0 .25.153.417.382.417h1.396c.229 0 .382-.167.382-.417V9.34h2.326l-1.522 7.152c-.05.23.09.424.322.424h1.628c.186 0 .348-.125.387-.31l1.556-7.266h.896v5.49c0 .25-.153.417-.382.417h-.896c-.229 0-.382.167-.382.417v1.2c0 .25.153.417.382.417h2.072c.764 0 1.338-.583 1.338-1.333V9.339h.896c.186 0 .348-.147.378-.333l.18-1.2c.032-.193-.104-.333-.29-.333h-1.164V4.828c0-.25-.153-.417-.382-.417h-1.396c-.229 0-.382.167-.382.417v2.645H9.807V4.495c0-.23-.153-.417-.382-.417h-1.74z"/></svg>
      </a>
    </div>
  </div>
</footer>
```

- [ ] **Step 3: Create BaseLayout**

Create `src/layouts/BaseLayout.astro`:

```astro
---
import Header from '../components/Header.astro';
import Footer from '../components/Footer.astro';
import '../styles/global.css';

interface Props {
  title: string;
  description?: string;
}

const { title, description = '仓晨阳律师 | Arthur Cang - Partner at Jingtian & Gongcheng' } = Astro.props;
---

<!doctype html>
<html lang={Astro.url.pathname.startsWith('/en') ? 'en' : 'zh-CN'}>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="description" content={description} />
  <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Noto+Sans+SC:wght@400;500;600&family=Noto+Serif+SC:wght@600;700&family=Playfair+Display:wght@600;700&display=swap" rel="stylesheet" />
  <title>{title}</title>
</head>
<body class="min-h-screen flex flex-col">
  <Header />
  <main class="flex-1 pt-16">
    <slot />
  </main>
  <Footer />
</body>
</html>
```

- [ ] **Step 4: Create root redirect page**

Replace `src/pages/index.astro`:

```astro
---
return Astro.redirect('/zh/');
---
```

- [ ] **Step 5: Verify layout renders**

Create a minimal `src/pages/zh/index.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
---
<BaseLayout title="仓晨阳律师">
  <div class="max-w-6xl mx-auto px-6 py-20">
    <h1 class="text-4xl text-gold">测试页面</h1>
  </div>
</BaseLayout>
```

Create a minimal `src/pages/en/index.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
---
<BaseLayout title="Arthur Cang">
  <div class="max-w-6xl mx-auto px-6 py-20">
    <h1 class="text-4xl text-gold">Test Page</h1>
  </div>
</BaseLayout>
```

Run `npm run dev` and verify:
- `localhost:4321` redirects to `/zh/`
- `/zh/` shows header with Chinese nav, gold title, footer
- `/en/` shows header with English nav
- Language toggle switches between `/zh/` and `/en/`
- Mobile hamburger menu works

- [ ] **Step 6: Commit**

```bash
git add src/layouts/ src/components/Header.astro src/components/Footer.astro src/pages/
git commit -m "feat: add base layout with header, footer, and i18n routing"
```

---

## Chunk 2: Content Data and Home Page

### Task 4: Create Content Data Files

**Files:**
- Create: `src/data/bio.ts`
- Create: `src/data/practice-areas.ts`
- Create: `src/data/cases.ts`
- Create: `src/data/publications.ts`

- [ ] **Step 1: Create bio data**

Create `src/data/bio.ts` with bilingual bio text, education, career, and memberships. All content extracted from the PDF resume:

```ts
export const bio = {
  zh: {
    intro: [
      '执业十余年以来，仓律师已经协助数十家跨国企业在中国境内和境外拓展业务。',
      '仓律师在外国直接在华投资法律法规，投资框架、市场准入和行业规范分析，企业合规及竞争法问题以及并购交易和公司金融事项等方面，为客户提供全面的法律协助。',
      '仓律师为众多知名的时尚与奢侈品、金融科技、新技术、媒体和通讯产业、医药和生命科学企业提供法律支持，对行业相关的法律事务具有极为丰富的经验，并且对市场最前沿的发展具有良好的商业洞察，使其能够提供精准满足客户商业需求的法律解决方案。',
      '在服务领先跨国企业的同时，仓律师也成功代表多家中国上市企业完成跨境并购和对外直接投资，其服务的客户包括国内知名的金融、医药和时尚及消费品企业。',
      '曾于上海、英国及美国法学院接受法学教育的专业背景使仓律师拥有强烈的全球化视野，以及通过符合国际客户需求的方式解决中国法律问题的专业技能。',
    ],
  },
  en: {
    intro: [
      'Arthur has been practicing law for more than a decade and has helped dozens of multi-national firms to expand their businesses within and without China.',
      'Arthur provides comprehensive assistance on Chinese foreign direct investment laws and regulations, analysis on investment structure, market entry and industry regulation, compliance and competition law issues, and corporate finance and transactional matters.',
      'Supporting a wide range of prestigious companies in the fintech, technology, media and telecommunications, pharmaceutical and life science, fashion and luxury sectors, Arthur is extensively experienced in related legal matters and have good insights in the most cutting-edge development of the market, allowing him to provide legal solutions precisely satisfying clients\' commercial needs.',
      'Arthur has also successfully serviced many Chinese public companies in cross-border transactions and outbound direct investments. His Chinese clientele include well-known finance, pharmaceutical and fashion and consumable enterprises.',
      'With legal education from law schools in Shanghai, England and the U.S., Arthur has obtained a strong global vision and the expertise of solving Chinese legal issues in an approach compatible with the needs of international clients.',
    ],
  },
};

export const education = [
  {
    year: '2017',
    school: { zh: '西北大学', en: 'Northwestern University School of Law' },
    degree: { zh: '法学硕士，美国法', en: 'LL.M., American Law' },
  },
  {
    year: '2012',
    school: { zh: '华东政法大学', en: 'East China University of Political Science and Law' },
    degree: { zh: '法学硕士，国际法', en: 'LL.M., International Law' },
  },
  {
    year: '2011',
    school: { zh: '英国华威大学', en: 'University of Warwick School of Law, UK' },
    degree: { zh: '法学硕士，国际经济法', en: 'LL.M., International Economic Law' },
  },
  {
    year: '2006',
    school: { zh: '华东政法大学', en: 'East China University of Political Science and Law' },
    degree: { zh: '法学学士，国际法', en: 'LL.B., International Law' },
  },
];

export const career = [
  {
    period: { zh: '至今', en: 'Present' },
    firm: { zh: '竞天公诚律师事务所，上海', en: 'Jingtian & Gongcheng, Shanghai' },
    role: { zh: '合伙人', en: 'Partner' },
  },
  {
    period: { zh: '2012 - 2016', en: '2012 - 2016' },
    firm: { zh: 'Armstrong Teasdale LLP, 美国', en: 'Armstrong Teasdale LLP, USA' },
    role: { zh: '执业律师', en: 'Attorney' },
  },
  {
    period: { zh: '2006 - 2009', en: '2006 - 2009' },
    firm: { zh: '上海市方韬律师事务所', en: 'Shanghai Fangtao Law Firm' },
    role: { zh: '执业律师', en: 'Attorney' },
  },
];

export const memberships = {
  zh: [
    '执业律师，上海律师协会成员',
    '中国民主建国会成员',
  ],
  en: [
    'Member, Shanghai Bar Association',
    'Member, China Democratic and Nation Building Committee',
  ],
};
```

- [ ] **Step 2: Create practice areas data**

Create `src/data/practice-areas.ts` with all 8 areas. Each area has an id, icon name, title, description, and service items in both languages. Full content from PDF:

```ts
export interface PracticeArea {
  id: string;
  icon: string;
  title: { zh: string; en: string };
  description: { zh: string; en: string };
  services: { zh: string[]; en: string[] };
}

export const practiceAreas: PracticeArea[] = [
  {
    id: 'cross-border',
    icon: 'globe',
    title: { zh: '跨境投资并购', en: 'Cross-border Investment & M&A' },
    description: {
      zh: '仓律师在外国直接在华投资法律法规，投资框架、市场准入和行业规范分析，企业合规及竞争法问题以及并购交易和公司金融事项等方面，为客户提供全面的法律协助。',
      en: 'Arthur provides comprehensive assistance on Chinese foreign direct investment laws and regulations, analysis on investment structure, market entry and industry regulation, compliance and competition law issues, and corporate finance and transactional matters.',
    },
    services: {
      zh: [
        '外国直接在华投资法律法规咨询',
        '投资框架和市场准入分析',
        '企业合规及竞争法',
        '并购交易和公司金融',
      ],
      en: [
        'Chinese FDI laws and regulations advisory',
        'Investment structure and market entry analysis',
        'Compliance and competition law',
        'M&A transactions and corporate finance',
      ],
    },
  },
  {
    id: 'fashion',
    icon: 'diamond',
    title: { zh: '时尚与奢侈品', en: 'Fashion & Luxury' },
    description: {
      zh: '为众多知名时尚与奢侈品企业提供全方位法律服务，涵盖品牌许可、特许经营转型、合资企业设立、知识产权保护及侵权打击。',
      en: 'Comprehensive legal services for prestigious fashion and luxury brands, covering licensing, franchise transitions, joint ventures, IP portfolio management, and anti-counterfeiting enforcement.',
    },
    services: {
      zh: [
        '品牌许可与特许经营安排',
        '商标和著作权组合管理',
        '知识产权侵权打击',
        '合资企业设立',
      ],
      en: [
        'Brand licensing and franchising arrangements',
        'Trademark and copyright portfolio management',
        'IP infringement enforcement',
        'Joint venture establishment',
      ],
    },
  },
  {
    id: 'fintech',
    icon: 'chart',
    title: { zh: '金融科技', en: 'Fintech' },
    description: {
      zh: '为金融科技企业提供法律支持，涵盖网上支付、保险中介、资产管理等领域的合规和市场准入咨询。',
      en: 'Legal support for fintech enterprises, including compliance and market entry advisory for online payments, insurance intermediaries, and asset management.',
    },
    services: {
      zh: [
        '金融科技合规咨询',
        '网上支付业务准入',
        '保险中介业务',
        '资产管理服务',
      ],
      en: [
        'Fintech regulatory compliance',
        'Online payment market entry',
        'Insurance intermediary business',
        'Asset management services',
      ],
    },
  },
  {
    id: 'crypto',
    icon: 'blocks',
    title: { zh: '加密货币与区块链', en: 'Crypto & Blockchain' },
    description: {
      zh: '向去中心化金融创业团队、区块链项目和DAO管理者提供合规咨询和法律实体设立方面的专业服务。',
      en: 'Advisory services for DeFi startups, blockchain projects, and DAO managers on regulatory compliance and legal incorporation.',
    },
    services: {
      zh: [
        '去中心化交易所和收益聚合器合规',
        'Web 3.0 和 NFT 项目法律咨询',
        '房地产 NFT 发行咨询',
        'DAO 运营和法律实体设立',
      ],
      en: [
        'DEX and yield aggregator compliance',
        'Web 3.0 and NFT project advisory',
        'Real estate NFT issuance advisory',
        'DAO operation and legal incorporation',
      ],
    },
  },
  {
    id: 'technology',
    icon: 'cpu',
    title: { zh: '信息技术与云计算', en: 'Technology & Cloud Computing' },
    description: {
      zh: '为全球顶尖技术公司的云计算服务和IDC基础设施进入中国市场提供法律建议。',
      en: 'Legal advisory for top global technology companies on cloud computing services and IDC infrastructure entry into China.',
    },
    services: {
      zh: [
        'IaaS 云计算服务中国市场准入',
        '娱乐、财务和医药行业云服务合规',
        '自由贸易区准入咨询',
      ],
      en: [
        'IaaS cloud computing China market entry',
        'Cloud services compliance for entertainment, finance, and healthcare',
        'Free Trade Zone entry advisory',
      ],
    },
  },
  {
    id: 'media',
    icon: 'film',
    title: { zh: '媒体', en: 'Media' },
    description: {
      zh: '为领先媒体集团提供在中国的电视合作、知识产权许可和主题公园业务等方面的法律支持。',
      en: 'Legal support for leading media groups on TV cooperation, IP licensing, and theme park businesses in China.',
    },
    services: {
      zh: [
        '品牌及媒体运营法律服务',
        '电视合作与知识产权许可',
        '电影合资企业',
        '杂志合作与交易文件',
      ],
      en: [
        'Brand and media operation legal services',
        'TV cooperation and IP licensing',
        'Film joint ventures',
        'Magazine cooperation and deal documents',
      ],
    },
  },
  {
    id: 'gaming',
    icon: 'gamepad',
    title: { zh: '游戏', en: 'Gaming' },
    description: {
      zh: '为游戏公司的中国市场准入和体育联赛许可安排提供专业法律建议。',
      en: 'Legal advisory for gaming companies on China market entry and sports league licensing arrangements.',
    },
    services: {
      zh: [
        '手游中国市场准入',
        '体育联赛许可安排',
      ],
      en: [
        'Mobile game China market entry',
        'Sports league licensing arrangements',
      ],
    },
  },
  {
    id: 'franchise',
    icon: 'store',
    title: { zh: '特许经营', en: 'Franchise' },
    description: {
      zh: '为国际特许经营集团在中国建立、重组和处置特许经营网络提供全面的法律服务。',
      en: 'Comprehensive legal services for international franchise groups on establishing, restructuring, and disposing franchise networks in China.',
    },
    services: {
      zh: [
        '特许经营系统建立与商务部备案',
        '品牌本土化策略',
        '特许经营网络重组与清算',
        '特许人与被特许人纠纷处理',
      ],
      en: [
        'Franchise system establishment and MOFCOM registration',
        'Brand localization strategy',
        'Franchise network restructuring and liquidation',
        'Franchisor-franchisee dispute resolution',
      ],
    },
  },
];
```

- [ ] **Step 3: Create cases data**

Create `src/data/cases.ts` with representative cases from the PDF, grouped by category:

```ts
export interface CaseItem {
  zh: string;
  en: string;
}

export interface CaseGroup {
  id: string;
  title: { zh: string; en: string };
  cases: CaseItem[];
}

export const caseGroups: CaseGroup[] = [
  {
    id: 'cross-border',
    title: { zh: '跨境并购及投资', en: 'Cross-border Transactions' },
    cases: [
      {
        zh: '代表某国内知名医药上市企业收购某总部位于瑞士的全球知名医药企业的重要医药制造（CDMO）资产。',
        en: 'Represented a renowned Chinese public pharmaceutical company in its acquisition of a major CDMO asset from a world leading pharmaceutical group headquartered in Switzerland.',
      },
      {
        zh: '代表某国内医药上市企业收购全球知名医药企业在欧洲的医药生产中心，代表客户管理交易所涉及的各地区顾问团队。',
        en: 'Represented a renowned Chinese public pharmaceutical company in its acquisition of major manufacturing facilities from a world leading pharmaceutical group; project manage respective advisor teams on behalf of client.',
      },
      {
        zh: '代表某工业阀门行业的国内上市企业在德国和加拿大收购当地企业。在交割后协助客户整合其在欧洲的业务经营。',
        en: 'Represented a public traded valve manufacturer in its acquisition of manufacturing assets in Germany and Canada; assist in the integration of client\'s European operation post-closing.',
      },
      {
        zh: '代表某国内知名医药上市企业收购在美国的医药研发（CRO）公司。',
        en: 'Represented a renowned Chinese public pharmaceutical company in its acquisition of two CRO entities in the United States.',
      },
      {
        zh: '参与某总部位于美国的知名跨国汽车集团的股权收购项目，负责该收购项目在中国的尽职调查和项目管理。',
        en: 'Participated in acquisition of multi-national business assets by a U.S. automotive client; project managed the Chinese part of the acquisition.',
      },
      {
        zh: '代表一家大型中国央企处理其与某俄罗斯大宗金属企业共同设立的合资公司的股权转让事宜。',
        en: 'Represented a major Chinese centrally managed, state owned enterprise group in the transaction of equities in a joint venture set up between the client and a Russian major commodity metal enterprise.',
      },
      {
        zh: '代表一家法国保险公司以协议控制方式收购中国的持牌保险代理机构。',
        en: 'Represented a French insurance provider in its acquisition of a Chinese insurance broker via a nominee structure.',
      },
      {
        zh: '代表一家美国的主要日用品企业出售其在中国的生产设施。',
        en: 'Represented a U.S. major home product company in the sale of its manufacturing facilities in China.',
      },
      {
        zh: '代表一家美国客户收购位于上海的广告和设计外商独资企业。',
        en: 'Represented a U.S. client in its acquisition of a WOFE engaging in advertising and design business locating in Shanghai, China.',
      },
      {
        zh: '代表一家英国建筑设计企业收购其在中国的合资公司的所有股份。',
        en: 'Represented a British architect design company in the buy-out of the equities in its joint venture in China.',
      },
    ],
  },
];
```

- [ ] **Step 4: Create publications data**

Create `src/data/publications.ts`:

```ts
export interface Publication {
  title: { zh: string; en: string };
  year: string;
  org?: string;
}

export const publications: Publication[] = [
  {
    title: {
      zh: '区块链法律漫谈：稳定币监管及其法律风险',
      en: 'Stablecoins Regulation and Legal Risks',
    },
    year: '',
  },
  {
    title: {
      zh: '参与撰写亚洲云计算协会《医疗产业云计算应用法律规范的研究报告》',
      en: 'Report on the Regulations for Adoption of Cloud in the Healthcare Sector',
    },
    year: '2016',
    org: 'Asia Cloud Computing Association',
  },
  {
    title: {
      zh: '参与撰写亚洲云计算协会《为云计算做好准备：关于影响亚太市场云计算的FSI规则的研究报告》',
      en: 'Ready for the Cloud: A Report on FSI Regulations Impacting Cloud in Asia Pacific Markets',
    },
    year: '2015',
    org: 'Asia Cloud Computing Association',
  },
  {
    title: {
      zh: '参与撰写亚洲云计算协会《亚洲云计算数据主权的影响》',
      en: 'The Impact of Data Sovereignty on Cloud Computing in Asia',
    },
    year: '2013',
    org: 'Asia Cloud Computing Association',
  },
];
```

- [ ] **Step 5: Commit**

```bash
git add src/data/
git commit -m "feat: add bilingual content data files from resume"
```

---

### Task 5: Build Home Page

**Files:**
- Create: `src/components/Hero.astro`
- Create: `src/components/PracticeAreaCard.astro`
- Modify: `src/pages/zh/index.astro`
- Modify: `src/pages/en/index.astro`

- [ ] **Step 1: Create Hero component**

Create `src/components/Hero.astro`:

```astro
---
import { getLangFromUrl, useTranslations } from '../i18n/utils';

const lang = getLangFromUrl(Astro.url);
const t = useTranslations(lang);
---

<section class="min-h-[90vh] flex items-center justify-center relative overflow-hidden">
  <div class="absolute inset-0 bg-gradient-to-b from-navy via-navy to-charcoal"></div>
  <div class="absolute inset-0 opacity-5">
    <div class="absolute top-1/4 left-1/4 w-96 h-96 border border-gold/20 rounded-full"></div>
    <div class="absolute bottom-1/4 right-1/4 w-64 h-64 border border-gold/10 rounded-full"></div>
  </div>

  <div class="relative z-10 text-center px-6 max-w-3xl">
    <div class="w-16 h-px bg-gold mx-auto mb-8"></div>
    <h1 class="text-5xl md:text-7xl font-serif text-text-primary mb-4 tracking-wide">
      {t('hero.name')}
    </h1>
    <p class="text-lg md:text-xl text-gold mb-4 tracking-widest uppercase font-sans font-medium">
      {t('hero.title')}
    </p>
    <p class="text-sm md:text-base text-text-secondary mb-10 tracking-wider">
      {t('hero.tagline')}
    </p>
    <div class="w-16 h-px bg-gold mx-auto mb-10"></div>
    <a
      href={`/${lang}/contact`}
      class="inline-block border border-gold text-gold px-8 py-3 text-sm tracking-wider hover:bg-gold hover:text-navy transition-all duration-300"
    >
      {t('hero.cta')}
    </a>
  </div>
</section>
```

- [ ] **Step 2: Create PracticeAreaCard component**

Create `src/components/PracticeAreaCard.astro`:

```astro
---
import type { Lang } from '../i18n/ui';

interface Props {
  title: string;
  icon: string;
  href: string;
}

const { title, icon, href } = Astro.props;

const icons: Record<string, string> = {
  globe: 'M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2zM2 12h4m16 0h-4M12 2v4m0 16v-4',
  diamond: 'M12 2L2 12l10 10 10-10L12 2z',
  chart: 'M3 3v18h18M7 16l4-4 4 4 5-5',
  blocks: 'M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z',
  cpu: 'M6 6h12v12H6zM9 2v4M15 2v4M9 18v4M15 18v4M2 9h4M2 15h4M18 9h4M18 15h4',
  film: 'M4 4h16v16H4zM4 8h16M4 16h16M8 4v16',
  gamepad: 'M6 11h4M8 9v4M15 12h.01M18 10h.01M2 15.2V8.8a3 3 0 013-3h14a3 3 0 013 3v6.4a3 3 0 01-3 3H5a3 3 0 01-3-3z',
  store: 'M3 9l1-4h16l1 4M3 9v10h18V9M3 9h18M9 9v10M15 9v10',
};

const path = icons[icon] || icons.globe;
---

<a href={href} class="group block bg-charcoal border border-border hover:border-gold/40 p-6 transition-all duration-300">
  <div class="text-text-secondary group-hover:text-gold transition-colors mb-4">
    <svg class="w-8 h-8" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" d={path}/>
    </svg>
  </div>
  <h3 class="font-serif text-lg text-text-primary group-hover:text-gold transition-colors">
    {title}
  </h3>
</a>
```

- [ ] **Step 3: Build Chinese home page**

Replace `src/pages/zh/index.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Hero from '../../components/Hero.astro';
import PracticeAreaCard from '../../components/PracticeAreaCard.astro';
import { practiceAreas } from '../../data/practice-areas';
import { bio } from '../../data/bio';
---

<BaseLayout title="仓晨阳律师 | 竞天公诚律师事务所">
  <Hero />

  <section class="max-w-6xl mx-auto px-6 py-20">
    <p class="text-text-secondary text-lg leading-relaxed max-w-3xl">
      {bio.zh.intro[0]}
    </p>
  </section>

  <section class="max-w-6xl mx-auto px-6 pb-20">
    <h2 class="text-2xl font-serif text-gold mb-10">业务领域</h2>
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {practiceAreas.map(area => (
        <PracticeAreaCard
          title={area.title.zh}
          icon={area.icon}
          href={`/zh/practice#${area.id}`}
        />
      ))}
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 4: Build English home page**

Replace `src/pages/en/index.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Hero from '../../components/Hero.astro';
import PracticeAreaCard from '../../components/PracticeAreaCard.astro';
import { practiceAreas } from '../../data/practice-areas';
import { bio } from '../../data/bio';
---

<BaseLayout title="Arthur Cang | Jingtian & Gongcheng">
  <Hero />

  <section class="max-w-6xl mx-auto px-6 py-20">
    <p class="text-text-secondary text-lg leading-relaxed max-w-3xl">
      {bio.en.intro[0]}
    </p>
  </section>

  <section class="max-w-6xl mx-auto px-6 pb-20">
    <h2 class="text-2xl font-serif text-gold mb-10">Practice Areas</h2>
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {practiceAreas.map(area => (
        <PracticeAreaCard
          title={area.title.en}
          icon={area.icon}
          href={`/en/practice#${area.id}`}
        />
      ))}
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 5: Verify home page**

Run `npm run dev` and verify:
- Hero section displays with name, title, tagline, CTA button
- 8 practice area cards render in a grid
- Cards have hover gold highlight effect
- Both `/zh/` and `/en/` work correctly
- CTA button links to contact page

- [ ] **Step 6: Commit**

```bash
git add src/components/Hero.astro src/components/PracticeAreaCard.astro src/pages/zh/index.astro src/pages/en/index.astro
git commit -m "feat: build home page with hero and practice area cards"
```

---

## Chunk 3: About, Practice, and Cases Pages

### Task 6: Build About Page

**Files:**
- Create: `src/components/Timeline.astro`
- Create: `src/pages/zh/about.astro`
- Create: `src/pages/en/about.astro`

- [ ] **Step 1: Create Timeline component**

Create `src/components/Timeline.astro`:

```astro
---
interface TimelineItem {
  label: string;
  title: string;
  subtitle: string;
}

interface Props {
  items: TimelineItem[];
}

const { items } = Astro.props;
---

<div class="relative pl-8 border-l border-gold/30">
  {items.map((item, i) => (
    <div class="mb-8 last:mb-0 relative">
      <div class="absolute -left-[2.55rem] top-1 w-3 h-3 rounded-full bg-gold border-2 border-navy"></div>
      <span class="text-gold text-sm font-mono">{item.label}</span>
      <h3 class="text-text-primary font-serif text-lg mt-1">{item.title}</h3>
      <p class="text-text-secondary text-sm mt-1">{item.subtitle}</p>
    </div>
  ))}
</div>
```

- [ ] **Step 2: Create Chinese about page**

Create `src/pages/zh/about.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Timeline from '../../components/Timeline.astro';
import { bio, education, career, memberships } from '../../data/bio';
---

<BaseLayout title="关于仓律师 | 仓晨阳">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">关于仓律师</h1>
    <div class="w-16 h-px bg-gold mb-10"></div>

    <div class="space-y-4 text-text-secondary leading-relaxed mb-16">
      {bio.zh.intro.map(p => <p>{p}</p>)}
    </div>

    <h2 class="text-2xl font-serif text-gold mb-8">教育背景</h2>
    <Timeline items={education.map(e => ({
      label: e.year,
      title: e.school.zh,
      subtitle: e.degree.zh,
    }))} />

    <h2 class="text-2xl font-serif text-gold mt-16 mb-8">执业经历</h2>
    <Timeline items={career.map(c => ({
      label: c.period.zh,
      title: c.firm.zh,
      subtitle: c.role.zh,
    }))} />

    <h2 class="text-2xl font-serif text-gold mt-16 mb-8">专业资质与社会活动</h2>
    <ul class="space-y-2 text-text-secondary">
      {memberships.zh.map(m => (
        <li class="flex items-start gap-3">
          <span class="text-gold mt-1.5 text-xs">&#9670;</span>
          <span>{m}</span>
        </li>
      ))}
    </ul>
  </section>
</BaseLayout>
```

- [ ] **Step 3: Create English about page**

Create `src/pages/en/about.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import Timeline from '../../components/Timeline.astro';
import { bio, education, career, memberships } from '../../data/bio';
---

<BaseLayout title="About Arthur | Arthur Cang">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">About Arthur</h1>
    <div class="w-16 h-px bg-gold mb-10"></div>

    <div class="space-y-4 text-text-secondary leading-relaxed mb-16">
      {bio.en.intro.map(p => <p>{p}</p>)}
    </div>

    <h2 class="text-2xl font-serif text-gold mb-8">Education</h2>
    <Timeline items={education.map(e => ({
      label: e.year,
      title: e.school.en,
      subtitle: e.degree.en,
    }))} />

    <h2 class="text-2xl font-serif text-gold mt-16 mb-8">Career</h2>
    <Timeline items={career.map(c => ({
      label: c.period.en,
      title: c.firm.en,
      subtitle: c.role.en,
    }))} />

    <h2 class="text-2xl font-serif text-gold mt-16 mb-8">Professional Memberships</h2>
    <ul class="space-y-2 text-text-secondary">
      {memberships.en.map(m => (
        <li class="flex items-start gap-3">
          <span class="text-gold mt-1.5 text-xs">&#9670;</span>
          <span>{m}</span>
        </li>
      ))}
    </ul>
  </section>
</BaseLayout>
```

- [ ] **Step 4: Verify and commit**

Run `npm run dev`, verify `/zh/about` and `/en/about` render correctly with timelines and content.

```bash
git add src/components/Timeline.astro src/pages/zh/about.astro src/pages/en/about.astro
git commit -m "feat: add About page with bio, education and career timelines"
```

---

### Task 7: Build Practice Areas Page

**Files:**
- Create: `src/pages/zh/practice.astro`
- Create: `src/pages/en/practice.astro`

- [ ] **Step 1: Create Chinese practice areas page**

Create `src/pages/zh/practice.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { practiceAreas } from '../../data/practice-areas';
---

<BaseLayout title="业务领域 | 仓晨阳">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">业务领域</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    <div class="space-y-12">
      {practiceAreas.map(area => (
        <div id={area.id} class="scroll-mt-24">
          <h2 class="text-2xl font-serif text-text-primary mb-3">{area.title.zh}</h2>
          <div class="w-10 h-px bg-gold/50 mb-4"></div>
          <p class="text-text-secondary leading-relaxed mb-4">{area.description.zh}</p>
          <ul class="space-y-2 text-text-secondary text-sm">
            {area.services.zh.map(s => (
              <li class="flex items-start gap-3">
                <span class="text-gold mt-1 text-xs">&#9670;</span>
                <span>{s}</span>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 2: Create English practice areas page**

Create `src/pages/en/practice.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { practiceAreas } from '../../data/practice-areas';
---

<BaseLayout title="Practice Areas | Arthur Cang">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">Practice Areas</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    <div class="space-y-12">
      {practiceAreas.map(area => (
        <div id={area.id} class="scroll-mt-24">
          <h2 class="text-2xl font-serif text-text-primary mb-3">{area.title.en}</h2>
          <div class="w-10 h-px bg-gold/50 mb-4"></div>
          <p class="text-text-secondary leading-relaxed mb-4">{area.description.en}</p>
          <ul class="space-y-2 text-text-secondary text-sm">
            {area.services.en.map(s => (
              <li class="flex items-start gap-3">
                <span class="text-gold mt-1 text-xs">&#9670;</span>
                <span>{s}</span>
              </li>
            ))}
          </ul>
        </div>
      ))}
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 3: Verify and commit**

Verify `/zh/practice` and `/en/practice` — each area should be anchored by id so home page cards link directly.

```bash
git add src/pages/zh/practice.astro src/pages/en/practice.astro
git commit -m "feat: add Practice Areas page with 8 practice areas"
```

---

### Task 8: Build Representative Cases Page

**Files:**
- Create: `src/components/CaseGroup.astro`
- Create: `src/pages/zh/cases.astro`
- Create: `src/pages/en/cases.astro`

- [ ] **Step 1: Create CaseGroup component**

Create `src/components/CaseGroup.astro`:

```astro
---
interface Props {
  title: string;
  cases: string[];
}

const { title, cases } = Astro.props;
---

<div class="mb-12">
  <h2 class="text-2xl font-serif text-text-primary mb-3">{title}</h2>
  <div class="w-10 h-px bg-gold/50 mb-6"></div>
  <ul class="space-y-4">
    {cases.map(c => (
      <li class="flex items-start gap-3 text-text-secondary leading-relaxed">
        <span class="text-gold mt-1.5 text-xs shrink-0">&#9670;</span>
        <span>{c}</span>
      </li>
    ))}
  </ul>
</div>
```

- [ ] **Step 2: Create Chinese cases page**

Create `src/pages/zh/cases.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import CaseGroup from '../../components/CaseGroup.astro';
import { caseGroups } from '../../data/cases';
---

<BaseLayout title="代表案例 | 仓晨阳">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">代表案例</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    {caseGroups.map(group => (
      <CaseGroup title={group.title.zh} cases={group.cases.map(c => c.zh)} />
    ))}
  </section>
</BaseLayout>
```

- [ ] **Step 3: Create English cases page**

Create `src/pages/en/cases.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import CaseGroup from '../../components/CaseGroup.astro';
import { caseGroups } from '../../data/cases';
---

<BaseLayout title="Representative Cases | Arthur Cang">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">Representative Cases</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    {caseGroups.map(group => (
      <CaseGroup title={group.title.en} cases={group.cases.map(c => c.en)} />
    ))}
  </section>
</BaseLayout>
```

- [ ] **Step 4: Verify and commit**

```bash
git add src/components/CaseGroup.astro src/pages/zh/cases.astro src/pages/en/cases.astro
git commit -m "feat: add Representative Cases page"
```

---

## Chunk 4: Insights, Contact, and Polish

### Task 9: Build Publications & Insights Page

**Files:**
- Create: `src/pages/zh/insights.astro`
- Create: `src/pages/en/insights.astro`

- [ ] **Step 1: Create Chinese insights page**

Create `src/pages/zh/insights.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { publications } from '../../data/publications';
---

<BaseLayout title="发表与洞察 | 仓晨阳">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">发表与洞察</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    <h2 class="text-2xl font-serif text-text-primary mb-6">发表成果</h2>
    <div class="space-y-6">
      {publications.map(pub => (
        <div class="border-l-2 border-gold/30 pl-6 py-2">
          <h3 class="text-text-primary font-serif">{pub.title.zh}</h3>
          {(pub.year || pub.org) && (
            <p class="text-text-secondary text-sm mt-1">
              {[pub.org, pub.year].filter(Boolean).join(' · ')}
            </p>
          )}
        </div>
      ))}
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 2: Create English insights page**

Create `src/pages/en/insights.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { publications } from '../../data/publications';
---

<BaseLayout title="Publications & Insights | Arthur Cang">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">Publications & Insights</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    <h2 class="text-2xl font-serif text-text-primary mb-6">Publications</h2>
    <div class="space-y-6">
      {publications.map(pub => (
        <div class="border-l-2 border-gold/30 pl-6 py-2">
          <h3 class="text-text-primary font-serif">{pub.title.en}</h3>
          {(pub.year || pub.org) && (
            <p class="text-text-secondary text-sm mt-1">
              {[pub.org, pub.year].filter(Boolean).join(' · ')}
            </p>
          )}
        </div>
      ))}
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 3: Verify and commit**

```bash
git add src/pages/zh/insights.astro src/pages/en/insights.astro
git commit -m "feat: add Publications & Insights page"
```

---

### Task 10: Build Contact Page

**Files:**
- Create: `src/pages/zh/contact.astro`
- Create: `src/pages/en/contact.astro`

- [ ] **Step 1: Create Chinese contact page**

Create `src/pages/zh/contact.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { useTranslations } from '../../i18n/utils';

const t = useTranslations('zh');
---

<BaseLayout title="联系方式 | 仓晨阳">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">联系方式</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    <div class="grid md:grid-cols-2 gap-12">
      <div class="space-y-8">
        <div>
          <h3 class="text-gold text-sm tracking-wider mb-2">电话</h3>
          <p class="text-text-primary">(86) 137.6451.3451</p>
        </div>
        <div>
          <h3 class="text-gold text-sm tracking-wider mb-2">邮箱</h3>
          <a href="mailto:arhur.cang@jingtian.com" class="text-text-primary hover:text-gold transition-colors">
            arhur.cang@jingtian.com
          </a>
        </div>
        <div>
          <h3 class="text-gold text-sm tracking-wider mb-2">办公室</h3>
          <p class="text-text-primary">竞天公诚律师事务所</p>
          <p class="text-text-secondary text-sm mt-1">上海办公室</p>
        </div>
      </div>

      <form class="space-y-6" action="#" method="POST">
        <div>
          <label for="name" class="text-gold text-sm tracking-wider block mb-2">{t('contact.form.name')}</label>
          <input type="text" id="name" name="name" required
            class="w-full bg-charcoal border border-border text-text-primary px-4 py-3 focus:border-gold focus:outline-none transition-colors" />
        </div>
        <div>
          <label for="email" class="text-gold text-sm tracking-wider block mb-2">{t('contact.form.email')}</label>
          <input type="email" id="email" name="email" required
            class="w-full bg-charcoal border border-border text-text-primary px-4 py-3 focus:border-gold focus:outline-none transition-colors" />
        </div>
        <div>
          <label for="message" class="text-gold text-sm tracking-wider block mb-2">{t('contact.form.message')}</label>
          <textarea id="message" name="message" rows="5" required
            class="w-full bg-charcoal border border-border text-text-primary px-4 py-3 focus:border-gold focus:outline-none transition-colors resize-none"></textarea>
        </div>
        <button type="submit"
          class="border border-gold text-gold px-8 py-3 text-sm tracking-wider hover:bg-gold hover:text-navy transition-all duration-300">
          {t('contact.form.submit')}
        </button>
      </form>
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 2: Create English contact page**

Create `src/pages/en/contact.astro`:

```astro
---
import BaseLayout from '../../layouts/BaseLayout.astro';
import { useTranslations } from '../../i18n/utils';

const t = useTranslations('en');
---

<BaseLayout title="Contact | Arthur Cang">
  <section class="max-w-4xl mx-auto px-6 py-20">
    <h1 class="text-4xl font-serif text-gold mb-2">Contact</h1>
    <div class="w-16 h-px bg-gold mb-12"></div>

    <div class="grid md:grid-cols-2 gap-12">
      <div class="space-y-8">
        <div>
          <h3 class="text-gold text-sm tracking-wider mb-2">Phone</h3>
          <p class="text-text-primary">(86) 137.6451.3451</p>
        </div>
        <div>
          <h3 class="text-gold text-sm tracking-wider mb-2">Email</h3>
          <a href="mailto:arhur.cang@jingtian.com" class="text-text-primary hover:text-gold transition-colors">
            arhur.cang@jingtian.com
          </a>
        </div>
        <div>
          <h3 class="text-gold text-sm tracking-wider mb-2">Office</h3>
          <p class="text-text-primary">Jingtian & Gongcheng</p>
          <p class="text-text-secondary text-sm mt-1">Shanghai Office</p>
        </div>
      </div>

      <form class="space-y-6" action="#" method="POST">
        <div>
          <label for="name" class="text-gold text-sm tracking-wider block mb-2">{t('contact.form.name')}</label>
          <input type="text" id="name" name="name" required
            class="w-full bg-charcoal border border-border text-text-primary px-4 py-3 focus:border-gold focus:outline-none transition-colors" />
        </div>
        <div>
          <label for="email" class="text-gold text-sm tracking-wider block mb-2">{t('contact.form.email')}</label>
          <input type="email" id="email" name="email" required
            class="w-full bg-charcoal border border-border text-text-primary px-4 py-3 focus:border-gold focus:outline-none transition-colors" />
        </div>
        <div>
          <label for="message" class="text-gold text-sm tracking-wider block mb-2">{t('contact.form.message')}</label>
          <textarea id="message" name="message" rows="5" required
            class="w-full bg-charcoal border border-border text-text-primary px-4 py-3 focus:border-gold focus:outline-none transition-colors resize-none"></textarea>
        </div>
        <button type="submit"
          class="border border-gold text-gold px-8 py-3 text-sm tracking-wider hover:bg-gold hover:text-navy transition-all duration-300">
          {t('contact.form.submit')}
        </button>
      </form>
    </div>
  </section>
</BaseLayout>
```

- [ ] **Step 3: Verify and commit**

```bash
git add src/pages/zh/contact.astro src/pages/en/contact.astro
git commit -m "feat: add Contact page with info and form"
```

---

### Task 11: Add Scroll Animations and Final Polish

**Files:**
- Modify: `src/styles/global.css`
- Modify: `src/layouts/BaseLayout.astro`

- [ ] **Step 1: Add scroll fade-in animation CSS**

Append to `src/styles/global.css`:

```css
@layer utilities {
  .fade-in-up {
    opacity: 0;
    transform: translateY(20px);
    transition: opacity 0.6s ease-out, transform 0.6s ease-out;
  }

  .fade-in-up.visible {
    opacity: 1;
    transform: translateY(0);
  }
}
```

- [ ] **Step 2: Add intersection observer script to BaseLayout**

Add before the closing `</body>` tag in `src/layouts/BaseLayout.astro`:

```html
<script>
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    },
    { threshold: 0.1 }
  );
  document.querySelectorAll('.fade-in-up').forEach(el => observer.observe(el));
</script>
```

- [ ] **Step 3: Add `fade-in-up` class to key sections across pages**

Add `class="fade-in-up"` to major content sections in all pages (practice area cards container, about sections, case groups, etc.). This is a lightweight pass — just add the class to top-level content wrappers.

- [ ] **Step 4: Run full build to verify**

```bash
npm run build
```

Expected: Build succeeds with no errors, all pages generated in `dist/`.

- [ ] **Step 5: Commit**

```bash
git add src/styles/global.css src/layouts/BaseLayout.astro src/pages/
git commit -m "feat: add scroll fade-in animations and final polish"
```

---

### Task 12: Final Verification

- [ ] **Step 1: Run production build and preview**

```bash
npm run build && npm run preview
```

- [ ] **Step 2: Verify all pages**

Check each page in both languages:
- [ ] `/zh/` — Home (hero, cards, intro)
- [ ] `/en/` — Home
- [ ] `/zh/about` — Bio, education timeline, career timeline, memberships
- [ ] `/en/about` — About
- [ ] `/zh/practice` — 8 practice areas with anchor links
- [ ] `/en/practice` — Practice areas
- [ ] `/zh/cases` — Representative cases
- [ ] `/en/cases` — Cases
- [ ] `/zh/insights` — Publications
- [ ] `/en/insights` — Insights
- [ ] `/zh/contact` — Contact info + form
- [ ] `/en/contact` — Contact
- [ ] Language toggle works on every page
- [ ] Mobile responsive on all pages
- [ ] Root `/` redirects to `/zh/`

- [ ] **Step 3: Commit any final fixes**

```bash
git add -A
git commit -m "chore: final verification and fixes"
```
