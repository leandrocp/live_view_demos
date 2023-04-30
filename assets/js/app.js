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
    .then((el) => {
      el.style = 'display: flex; max-width: 550px; width: 100%; margin-bottom: 20px;'
      let spinnerEl = document.getElementById("tweet-spinner-" + id)
      spinnerEl.parentNode.removeChild(spinnerEl)
    })
  }
}

let Hooks = {}

Hooks.RenderTweets = {
  mounted() {
    window.twttr.ready((twttr) => renderTweets())
  },
  updated() {
    window.twttr.ready((twttr) => renderTweets())
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

window.addEventListener("phx:page-loading-start", _info => topbar.show(300))

window.addEventListener("phx:page-loading-stop", function(info){
  topbar.hide()

  setTimeout(() => {
    if (!window.twttr.widgets) {
      let el = document.getElementById('loading-error')
      el.classList.remove('hidden')
    }
  }, 3000)
})

liveSocket.connect()

window.liveSocket = liveSocket
