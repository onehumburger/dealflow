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
