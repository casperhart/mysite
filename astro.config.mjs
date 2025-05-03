// @ts-check
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
  site: "https://casperhart.github.io",
  base: "mysite",
  devToolbar: {
    enabled: false,
  },
  output: "static",
});
