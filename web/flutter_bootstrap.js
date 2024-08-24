// prettier-ignore
{{flutter_js}}
// prettier-ignore
{{flutter_build_config}}
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

      function fetchEmbeddingFonts(callback) {
        const req = new XMLHttpRequest();
        req.open("GET", "assets/FontManifest.json");
        req.responseType = "text";
        req.onload = function () {
          const arr = JSON.parse(req.responseText);
          const fonts = [];
          for (let index = 0; index < arr.length; index++) {
            fonts.push(arr[index]["family"]);
          }
          callback(fonts);
        };
        req.send();
      }
      // Async Hook MiniTex
      // Tips: 如果你不希望使用异步等待，可以直接硬编码 embeddingFonts 为 FontManifest.json 中的 family 数组。
      await fetchEmbeddingFonts(function (embeddingFonts) {
        MiniTex.MiniTex.install(
          window.flutterCanvasKit,
          window.devicePixelRatio,
          []
        );
      });

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
