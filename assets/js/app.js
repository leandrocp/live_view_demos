import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const renderTweets = function() {
  const elements = document.getElementsByClassName("tweet")

  for (let i=0; i < elements.length; i++) {
    let el = elements[i]
    let id = el.dataset.tweetid
    window.twttr.widgets.createTweetEmbed(id, el, {dnt: true, conversation: "none"})
  }
}

const injectScript = function(callback) {
  let script = document.createElement("script")
  script.setAttribute("src", "//platform.twitter.com/widgets.js")
  script.setAttribute("async", true)
  script.onload = () => callback()
  document.body.appendChild(script)
}

const load = function() {
  if (!window.twttr) {
    injectScript(() => renderTweets())
  } else {
    renderTweets()
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}

Hooks.RenderTweets = {
  mounted() {
    load()
  },
  updated() {
    load()
  }
}

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

topbar.config({barColors: {0: "#5B21B6"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket
