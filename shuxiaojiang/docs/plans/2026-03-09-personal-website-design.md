# Personal Website Design — 仓晨阳 (Arthur Cang)

## Overview

A bilingual (Chinese/English) personal website for Arthur Cang, Partner at Jingtian & Gongcheng (竞天公诚律师事务所) Shanghai Office. The site serves as both a professional brand showcase and a content platform for thought leadership articles.

## Target Audience

- Foreign companies entering China (FDI clients)
- Chinese enterprises going abroad (outbound M&A)
- Multinational corporations in fashion/luxury, technology, media, financial services
- Potential referral sources and professional network

## Pages

1. **Home (首页)** — Hero with photo, name, title, tagline. Three key practice area cards. CTA to contact.
2. **About (关于)** — Full bio, education timeline (4 degrees across China/UK/US), publications (3 ACCA reports), memberships.
3. **Practice Areas (业务领域)** — Cards for each area:
   - Cross-border Investment & M&A (跨境投资并购)
   - Fashion & Luxury (时尚与奢侈品)
   - Technology & Cloud (信息技术与云计算)
   - Media (媒体)
   - Financial Services (金融)
   - Franchise (特许经营)
   - Gaming (游戏)
4. **Experience (代表案例)** — Representative cases grouped by category, anonymized.
5. **Insights (专业文章)** — Markdown-powered blog section.
6. **Contact (联系方式)** — Email, phone, office address, WeChat QR placeholder.

## Visual Design

- **Palette:** Deep navy (#1a2744), muted gold (#b8965a), white (#ffffff), light gray (#f7f8fa), charcoal text (#2d2d2d)
- **Typography:** Inter (English), Noto Sans SC (Chinese)
- **Layout:** Generous whitespace, responsive, fixed navbar with language toggle
- **Polish:** Hover animations on cards, subtle scroll fade-ins, parallax touches, refined photo framing in hero
- **Footer:** Firm name, address, contact, copyright

## Bilingual Architecture

- URL structure: `/en/...` and `/zh/...`
- Language toggle in header preserves current page
- Default language: Chinese (`/zh/`)
- Content stored as parallel markdown files per language
- UI strings (nav labels, buttons) in `src/i18n/` translation files

## Content Structure

```
src/content/
├── about/
│   ├── en.md
│   └── zh.md
├── practice-areas/
│   ├── en/*.md
│   └── zh/*.md
├── experience/
│   ├── en.md
│   └── zh.md
└── insights/
    ├── en/*.md
    └── zh/*.md
```

Adding a new article: create a `.md` file with frontmatter (title, date, summary, tags) in the appropriate language folder. Rebuild to publish.

## Technical Stack

- **Astro 5** — static site generator
- **Tailwind CSS** — utility-first styling
- **Astro Content Collections** — type-safe markdown
- **No JS framework** — pure Astro components; minimal client JS for language toggle and mobile menu
- **Local dev:** `npm run dev` at localhost:4321, `npm run build` outputs to `dist/`

## Excluded Content

- No cryptocurrency/blockchain/stablecoins references
- No fintech practice area listing

## Contact Info

- Email: arhur.cang@jingtian.com
- Phone: (86) 137.6451.3451
- Office: 上海市徐汇区淮海中路1010号嘉华中心45层
