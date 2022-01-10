// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "./vendor/some-package.js"
//
// Alternatively, you can `npm install some-package` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

window.twttr = (function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0], t = window.twttr || {}
  if (d.getElementById(id)) return
  js = d.createElement(s)
  js.id = id
  js.src = "https://platform.twitter.com/widgets.js"
  fjs.parentNode.insertBefore(js, fjs)

  t._e = []
  t.ready = function(f) {
    t._e.push(f)
  };

  return t
}(document, "script", "twitter-wjs"))

let loadTweets = function() {
  const elements = document.getElementsByClassName("tweet")

  for (let i=0; i < elements.length; i++) {
    let el = elements[i]

    window.twttr.widgets.createTweet(el.dataset.tweetid, el, {})
    .then((r) => {
      const id = el.dataset.tweetid
      let facadeEl = document.getElementById("facade-" + id)
      facadeEl.parentNode.removeChild(facadeEl);
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}

Hooks.CreateTweet = {
  mounted() {
    window.twttr.widgets.createTweet(this.el.dataset.tweetid, this.el, {})
    .then((el) => {
      const id = this.el.dataset.tweetid
      let facadeEl = document.getElementById("facade-" + id)
      facadeEl.parentNode.removeChild(facadeEl);
    })
  }
}

Hooks.RenderTweets = {
  mounted() {
    loadTweets()
  },
  updated() {
    loadTweets()
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#5B21B6"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
