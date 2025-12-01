export default {
    async fetch(request) {
      const ua = request.headers.get("user-agent") || "";
      const isAndroid = /android/i.test(ua);
      const isIOS = /iphone|ipad|ipod/i.test(ua);
  
      const playStore = "https://play.google.com/store/apps/details?id=com.ginlyai.app";
      const appStore = "https://apps.apple.com/us/app/ginly-ai/id6749809985";
      const fallback = "https://www.ginlyai.com/#/download";
  
      if (isAndroid) {
        return Response.redirect(playStore, 302);
      } else if (isIOS) {
        return Response.redirect(appStore, 302);
      } else {
        return Response.redirect(fallback, 302);
      }
    },
  };
  