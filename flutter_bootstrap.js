// prettier-ignore
(()=>{var L=()=>navigator.vendor==="Google Inc."||navigator.agent==="Edg/",W=()=>typeof ImageDecoder>"u"?!1:L(),E=()=>typeof Intl.v8BreakIterator<"u"&&typeof Intl.Segmenter<"u",P=()=>{let s=[0,97,115,109,1,0,0,0,1,5,1,95,1,120,0];return WebAssembly.validate(new Uint8Array(s))},p={hasImageCodecs:W(),hasChromiumBreakIterators:E(),supportsWasmGC:P(),crossOriginIsolated:window.crossOriginIsolated};function u(...s){return new URL(S(...s),document.baseURI).toString()}function S(...s){return s.filter(t=>!!t).map((t,i)=>i===0?_(t):j(_(t))).filter(t=>t.length).join("/")}function j(s){let t=0;for(;t<s.length&&s.charAt(t)==="/";)t++;return s.substring(t)}function _(s){let t=s.length;for(;t>0&&s.charAt(t-1)==="/";)t--;return s.substring(0,t)}function b(s,t){return s.canvasKitBaseUrl?s.canvasKitBaseUrl:t.engineRevision&&!t.useLocalCanvasKit?S("https://www.gstatic.com/flutter-canvaskit",t.engineRevision):"canvaskit"}var h=class{constructor(){this._scriptLoaded=!1}setTrustedTypesPolicy(t){this._ttPolicy=t}async loadEntrypoint(t){let{entrypointUrl:i=u("main.dart.js"),onEntrypointLoaded:r,nonce:e}=t||{};return this._loadJSEntrypoint(i,r,e)}async load(t,i,r,e,n){n??=o=>{o.initializeEngine(r).then(l=>l.runApp())};let{entryPointBaseUrl:a}=r;if(t.compileTarget==="dart2wasm")return this._loadWasmEntrypoint(t,i,a,n);{let o=t.mainJsPath??"main.dart.js",l=u(a,o);return this._loadJSEntrypoint(l,n,e)}}didCreateEngineInitializer(t){typeof this._didCreateEngineInitializerResolve=="function"&&(this._didCreateEngineInitializerResolve(t),this._didCreateEngineInitializerResolve=null,delete _flutter.loader.didCreateEngineInitializer),typeof this._onEntrypointLoaded=="function"&&this._onEntrypointLoaded(t)}_loadJSEntrypoint(t,i,r){let e=typeof i=="function";if(!this._scriptLoaded){this._scriptLoaded=!0;let n=this._createScriptTag(t,r);if(e)console.debug("Injecting <script> tag. Using callback."),this._onEntrypointLoaded=i,document.head.append(n);else return new Promise((a,o)=>{console.debug("Injecting <script> tag. Using Promises. Use the callback approach instead!"),this._didCreateEngineInitializerResolve=a,n.addEventListener("error",o),document.head.append(n)})}}async _loadWasmEntrypoint(t,i,r,e){if(!this._scriptLoaded){this._scriptLoaded=!0,this._onEntrypointLoaded=e;let{mainWasmPath:n,jsSupportRuntimePath:a}=t,o=u(r,n),l=u(r,a);this._ttPolicy!=null&&(l=this._ttPolicy.createScriptURL(l));let m=WebAssembly.compileStreaming(fetch(o)),c=await import(l),w;t.renderer==="skwasm"?w=(async()=>{let d=await i.skwasm;return window._flutter_skwasmInstance=d,{skwasm:d.wasmExports,skwasmWrapper:d,ffi:{memory:d.wasmMemory}}})():w={};let f=await c.instantiate(m,w);await c.invoke(f)}}_createScriptTag(t,i){let r=document.createElement("script");r.type="application/javascript",i&&(r.nonce=i);let e=t;return this._ttPolicy!=null&&(e=this._ttPolicy.createScriptURL(t)),r.src=e,r}};async function T(s,t,i){if(t<0)return s;let r,e=new Promise((n,a)=>{r=setTimeout(()=>{a(new Error(`${i} took more than ${t}ms to resolve. Moving on.`,{cause:T}))},t)});return Promise.race([s,e]).finally(()=>{clearTimeout(r)})}var v=class{setTrustedTypesPolicy(t){this._ttPolicy=t}loadServiceWorker(t){if(!t)return console.debug("Null serviceWorker configuration. Skipping."),Promise.resolve();if(!("serviceWorker"in navigator)){let o="Service Worker API unavailable.";return window.isSecureContext||(o+=`
The current context is NOT secure.`,o+=`
Read more: https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts`),Promise.reject(new Error(o))}let{serviceWorkerVersion:i,serviceWorkerUrl:r=u(`flutter_service_worker.js?v=${i}`),timeoutMillis:e=4e3}=t,n=r;this._ttPolicy!=null&&(n=this._ttPolicy.createScriptURL(n));let a=navigator.serviceWorker.register(n).then(o=>this._getNewServiceWorker(o,i)).then(this._waitForServiceWorkerActivation);return T(a,e,"prepareServiceWorker")}async _getNewServiceWorker(t,i){if(!t.active&&(t.installing||t.waiting))return console.debug("Installing/Activating first service worker."),t.installing||t.waiting;if(t.active.scriptURL.endsWith(i))return console.debug("Loading from existing service worker."),t.active;{let r=await t.update();return console.debug("Updating service worker."),r.installing||r.waiting||r.active}}async _waitForServiceWorkerActivation(t){if(!t||t.state==="activated")if(t){console.debug("Service worker already active.");return}else throw new Error("Cannot activate a null service worker!");return new Promise((i,r)=>{t.addEventListener("statechange",()=>{t.state==="activated"&&(console.debug("Activated new service worker."),i())})})}};var y=class{constructor(t,i="flutter-js"){let r=t||[/\.js$/,/\.mjs$/];window.trustedTypes&&(this.policy=trustedTypes.createPolicy(i,{createScriptURL:function(e){if(e.startsWith("blob:"))return e;let n=new URL(e,window.location),a=n.pathname.split("/").pop();if(r.some(l=>l.test(a)))return n.toString();console.error("URL rejected by TrustedTypes policy",i,":",e,"(download prevented)")}}))}};var g=s=>{let t=WebAssembly.compileStreaming(fetch(s));return(i,r)=>((async()=>{let e=await t,n=await WebAssembly.instantiate(e,i);r(n,e)})(),{})};var I=(s,t,i,r)=>(window.flutterCanvasKitLoaded=(async()=>{if(window.flutterCanvasKit)return window.flutterCanvasKit;let e=i.hasChromiumBreakIterators&&i.hasImageCodecs;if(!e&&t.canvasKitVariant=="chromium")throw"Chromium CanvasKit variant specifically requested, but unsupported in this browser";let n=e&&t.canvasKitVariant!=="full",a=r;n&&(a=u(a,"chromium"));let o=u(a,"canvaskit.js");s.flutterTT.policy&&(o=s.flutterTT.policy.createScriptURL(o));let l=g(u(a,"canvaskit.wasm")),m=await import(o);return window.flutterCanvasKit=await m.default({instantiateWasm:l}),window.flutterCanvasKit})(),window.flutterCanvasKitLoaded);var U=async(s,t,i,r)=>{let e=u(r,"skwasm.js"),n=e;s.flutterTT.policy&&(n=s.flutterTT.policy.createScriptURL(n));let a=g(u(r,"skwasm.wasm"));return await(await import(n)).default({instantiateWasm:a,locateFile:(l,m)=>{let c=m+l;return c.endsWith(".worker.js")?URL.createObjectURL(new Blob([`importScripts('${c}');`],{type:"application/javascript"})):c},mainScriptUrlOrBlob:e})};var k=class{async loadEntrypoint(t){let{serviceWorker:i,...r}=t||{},e=new y,n=new v;n.setTrustedTypesPolicy(e.policy),await n.loadServiceWorker(i).catch(o=>{console.warn("Exception while loading service worker:",o)});let a=new h;return a.setTrustedTypesPolicy(e.policy),this.didCreateEngineInitializer=a.didCreateEngineInitializer.bind(a),a.loadEntrypoint(r)}async load({serviceWorkerSettings:t,onEntrypointLoaded:i,nonce:r,config:e}={}){e??={};let n=_flutter.buildConfig;if(!n)throw"FlutterLoader.load requires _flutter.buildConfig to be set";let a=d=>{switch(d){case"skwasm":return p.crossOriginIsolated&&p.hasChromiumBreakIterators&&p.hasImageCodecs&&p.supportsWasmGC;default:return!0}},o=(d,C)=>{switch(d.renderer){case"auto":return C=="canvaskit"||C=="html";default:return d.renderer==C}},l=d=>d.compileTarget==="dart2wasm"&&!p.supportsWasmGC||e.renderer&&!o(d,e.renderer)?!1:a(d.renderer),m=n.builds.find(l);if(!m)throw"FlutterLoader could not find a build compatible with configuration and environment.";let c={};c.flutterTT=new y,t&&(c.serviceWorkerLoader=new v,c.serviceWorkerLoader.setTrustedTypesPolicy(c.flutterTT.policy),await c.serviceWorkerLoader.loadServiceWorker(t).catch(d=>{console.warn("Exception while loading service worker:",d)}));let w=b(e,n);m.renderer==="canvaskit"?c.canvasKit=I(c,e,p,w):m.renderer==="skwasm"&&(c.skwasm=U(c,e,p,w));let f=new h;return f.setTrustedTypesPolicy(c.flutterTT.policy),this.didCreateEngineInitializer=f.didCreateEngineInitializer.bind(f),f.load(m,c,e,r,i)}};window._flutter||(window._flutter={});window._flutter.loader||(window._flutter.loader=new k);})();
//# sourceMappingURL=flutter.js.map

// prettier-ignore
if (!window._flutter) {
  window._flutter = {};
}
_flutter.buildConfig = {"engineRevision":"a18df97ca57a249df5d8d68cd0820600223ce262","builds":[{"compileTarget":"dart2js","renderer":"canvaskit","mainJsPath":"main.dart.js"}]};

_flutter.buildConfig.builds.forEach((el) => {
  // 不知道为什么 手机上不能带这个
  delete el.renderer;
});

//
!(function () {
  const robotoDataUri =
    "data:font/truetype;charset=utf-8;base64,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";
  const fontDatrUriToArrayBuffer = function (uri) {
    const base64 = uri.split(",")[1];
    const binaryString = window.atob(base64);
    const len = binaryString.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes.buffer;
  };

  // Because we are using MiniTex for render text, fallbackFont no need to load.
  // Hook it, send empty result to dart.
  const originalFetch = window.fetch;
  const fetchPolyfill = function (url, options) {
    if (url.startsWith("https://fonts.gstatic.com/s/")) {
      return new Promise(function (resolve, reject) {
        resolve({
          ok: true,
          status: 200,
          statusText: "OK",
          headers: {},
          arrayBuffer: function () {
            return Promise.resolve(fontDatrUriToArrayBuffer(robotoDataUri));
          },
          text: function () {
            return Promise.resolve("");
          },
        });
      });
    }
    return originalFetch.apply(this, arguments);
  };
  window.fetch = fetchPolyfill;
})();

// Disable wheel event listener
!(function () {
  var old = Element.prototype.addEventListener;
  Element.prototype.addEventListener = function (...args) {
    if (args[0] === "wheel") return;
    old.apply(this, args);
  };
})();

function loadDebugUtils() {
  function loadScript(src, callback) {
    var script = document.createElement("script");
    script.onload = callback;
    script.src = src;
    document.head.appendChild(script);
  }
  loadScript("https://cdn.jsdelivr.net/npm/eruda", function () {
    eruda.init();
  });
  loadScript("https://cdn.jsdelivr.net/npm/stats-js", function () {
    var stats = new window.Stats();
    document.body.appendChild(stats.dom);
    requestAnimationFrame(function loop() {
      stats.update();
      requestAnimationFrame(loop);
    });
  });
}

function flutterBootstrap() {
  _flutter.loader.load({
    serviceWorker: null, // {{flutter_service_worker}}
    config: {
      // renderer: null,
      // canvasKitBaseUrl: "/canvaskit/",
      // canvasKitVariant: "full",
    },
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine({
        multiViewEnabled: true,
      });

      // function fetchEmbeddingFonts(callback) {
      //   const req = new XMLHttpRequest();
      //   req.open("GET", "assets/FontManifest.json");
      //   req.responseType = "text";
      //   req.onload = function () {
      //     const arr = JSON.parse(req.responseText);
      //     const fonts = [];
      //     for (let index = 0; index < arr.length; index++) {
      //       fonts.push(arr[index]["family"]);
      //     }
      //     callback(fonts);
      //   };
      //   req.send();
      // }
      // // Async Hook MiniTex
      // // Tips: 如果你不希望使用异步等待，可以直接硬编码 embeddingFonts 为 FontManifest.json 中的 family 数组。
      // await fetchEmbeddingFonts(function (embeddingFonts) {
      //   MiniTex.MiniTex.install(
      //     window.flutterCanvasKit,
      //     window.devicePixelRatio,
      //     []
      //   );
      // });
      MiniTex.MiniTex.install(
        window.flutterCanvasKit,
        window.devicePixelRatio,
        []
      );

      const app = await appRunner.runApp();
      const viewId = app.addView({
        hostElement: document.getElementById("my_flutter_host"),
      });
      loadDebugUtils();
    },
  });
}

if (
  document.readyState === "complete" ||
  document.readyState !== "interactive"
) {
  flutterBootstrap();
} else {
  document.addEventListener("load", flutterBootstrap);
}
