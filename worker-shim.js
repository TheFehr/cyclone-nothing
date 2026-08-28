// new Worker(url) requires a same-origin script (unlike a page's own
// <script type="module">, which can load a cross-origin module fine via
// CORS) -- so this can't point at the jsdelivr URL directly. This shim is
// served same-origin; its only job is importing the real worker, which is
// itself a normal cross-origin ES module import (allowed).
import 'https://cdn.jsdelivr.net/npm/openscad-customizer-web@0.3.0/dist/worker.js';
