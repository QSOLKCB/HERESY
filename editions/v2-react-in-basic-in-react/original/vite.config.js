import { defineConfig } from 'vite';

export default defineConfig({
  base: './',
  build: {
    target: 'es2020',
    assetsInlineLimit: 1_474_560,
    cssCodeSplit: false,
    sourcemap: false,
    minify: 'esbuild'
  }
});
