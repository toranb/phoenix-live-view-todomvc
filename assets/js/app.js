// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import topbar from "topbar"
import Sortable from 'sortablejs'
import {LiveSocket} from "phoenix_live_view"

let Hooks = {};

Hooks.DragItem = {
  mounted() {
    new Sortable(this.el, {
      group: 'cards',
      animation: 0,
      delay: 10,
      ghostClass: 'opacity-25',
      delayOnTouchOnly: true,
      onEnd: evt => {
        const re = /item-order-(.*[0-9])/;
        const className = evt.target.previousElementSibling && evt.target.previousElementSibling.className || ""
        const [_, order] = className === "" ? [null, 1] : re.exec(className);
        const itemId = evt.target.dataset.itemId

        this.pushEvent('dropped', {
          id: parseInt(itemId, 10),
          item_order: parseInt(order, 10)
        });
      },
    });
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: {_csrf_token: csrfToken},
  metadata: {
    click: (e, el) => {
      return {
        altKey: e.altKey,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        x: e.x || e.clientX,
        y: e.y || e.clientY,
        pageX: e.pageX,
        pageY: e.pageY,
        screenX: e.screenX,
        screenY: e.screenY,
        offsetX: e.offsetX,
        offsetY: e.offsetY,
        detail: e.detail || 1,
      }
    },
    keydown: (e, el) => {
      return {
        altGraphKey: e.altGraphKey,
        altKey: e.altKey,
        code: e.code,
        ctrlKey: e.ctrlKey,
        key: e.key,
        keyIdentifier: e.keyIdentifier,
        keyLocation: e.keyLocation,
        location: e.location,
        metaKey: e.metaKey,
        repeat: e.repeat,
        shiftKey: e.shiftKey
      }
    }
  }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket
