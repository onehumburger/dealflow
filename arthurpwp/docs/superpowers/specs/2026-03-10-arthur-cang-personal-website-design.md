# Arthur Cang Personal Website - Design Spec

## Overview

Personal website for 仓晨阳 (Chenyang "Arthur" Cang), Partner at Jingtian & Gongcheng (竞天公诚律师事务所), Shanghai Office. The site targets both international clients (foreign companies entering China) and domestic clients (Chinese companies going global), requiring full bilingual (Chinese/English) support.

## Visual Design

- **Background**: Deep navy (`#0A1628`) + dark charcoal (`#1A2332`)
- **Accent**: Gold-copper (`#C49A6C`) for decorative lines, buttons, icon highlights
- **Text**: Light gray-white (`#E8E8E8`) for body text on dark backgrounds
- **Headings (EN)**: Serif typeface (Playfair Display) for authority
- **Headings (ZH)**: Noto Serif SC or system serif
- **Body text**: Sans-serif (Inter / Noto Sans SC)
- **Overall feel**: Top-tier international law firm — authoritative, restrained, premium

## Pages

### 1. Home (首页)

- Full-screen hero: dark background + name in large type + tagline ("Cross-border Investment · Fashion & Luxury · Fintech" / "跨境投资并购 · 时尚与奢侈品 · 金融科技")
- Brief personal intro (2-3 sentences)
- Core practice area cards (6-8, with icons, gold hover highlight)
- CTA button: "Contact Arthur" / "联系仓律师"

### 2. About (关于)

- Detailed personal biography (from resume, bilingual)
- Education timeline (vertical, with institution names and degrees):
  - Northwestern University (LLM, American Law, 2017)
  - East China University of Political Science and Law (LLM, International Law, 2012)
  - University of Warwick (LLM, International Economic Law, 2011)
  - East China University of Political Science and Law (LLB, International Law, 2006)
- Career timeline:
  - Jingtian & Gongcheng, Shanghai — Partner (current)
  - Armstrong Teasdale LLP, USA — Attorney (2012-2016)
  - Shanghai Fangtao Law Firm — Attorney (2006-2009)
- Professional memberships: Shanghai Bar Association, China Democratic National Construction Association

### 3. Practice Areas (业务领域)

Eight practice area cards, each expandable with description + representative services:

1. Cross-border Investment & M&A (跨境投资并购)
2. Fashion & Luxury (时尚与奢侈品)
3. Fintech (金融科技)
4. Crypto & Blockchain (加密货币与区块链)
5. Technology & Cloud Computing (信息技术与云计算)
6. Media (媒体)
7. Gaming (游戏)
8. Franchise (特许经营)

### 4. Representative Cases (代表案例)

- Grouped by practice area
- One-line anonymized descriptions per case (preserving resume's anonymization)
- Focus on cross-border M&A section (richest content)

### 5. Publications & Insights (发表与洞察)

- Published works list:
  - Stablecoins Regulation and Legal Risks (区块链法律漫谈：稳定币监管及其法律风险)
  - Healthcare Cloud Regulations Report, ACCA (2016)
  - FSI Cloud Regulations Report, ACCA (2015)
  - Data Sovereignty and Cloud Computing in Asia, ACCA (2013)
- Blog/insights section for future articles
- Tag-based filtering

### 6. Contact (联系方式)

- Phone: (86) 137.6451.3451
- Email: arhur.cang@jingtian.com
- Office: Jingtian & Gongcheng, Shanghai Office
- Simple contact form (name, email, brief description)

## Global Features

- **Bilingual toggle**: Top-right nav button, routes `/zh/` and `/en/`
- **Responsive**: Desktop, tablet, mobile
- **Navigation**: Fixed top bar, dark semi-transparent, shrinks on scroll; logo/name + page links + language toggle
- **Footer**: Copyright + firm name + social links (LinkedIn, Zhihu)
- **Animations**: Scroll fade-in, card hover effects — restrained, not flashy

## Tech Stack

- **Framework**: Astro 5.x
- **Styling**: Tailwind CSS
- **Bilingual**: File-based routing + i18n config
- **Deployment**: Static build, deployable to Vercel/Netlify/GitHub Pages
- **No backend dependencies** — pure static site
