import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  base: './',
  build: {
    target: 'es2020',
    assetsInlineLimit: 1_474_560,
    cssCodeSplit: false,
    sourcemap: false,
    minify: 'esbuild'
  }
});
