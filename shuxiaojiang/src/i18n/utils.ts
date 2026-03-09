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
