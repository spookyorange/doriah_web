// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}
Hooks.Flash = {
  mounted() {
    this.el.animate(
      [
        { transform: "scale(1)" },
        { transform: "scale(1.1)" },
        { transform: "scale(.5)" },
        { transform: "scale(0)" },
      ],
      {
        duration: 4000,
        fill: "forwards"
      },
    )
  },
  beforeUpdate() {
    this.el.animate(
      [
        { transform: "scale(1)" },
        { transform: "scale(1.1)" },
        { transform: "scale(.5)" },
        { transform: "scale(0)" },
      ],
      {
        duration: 4000,
        fill: "forwards"
      },
    )
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

window.addEventListener("phx:focus-to-element-with-id", (e) => {
  const target = document.getElementById(e.detail.id)

  if (target) {
    target.focus()
  }
})


window.addEventListener("phx:set-focus-to-eol", (e) => {
  const target = document.querySelector(`#${e.detail.id} input`)

  if (target) {
    const targetValueLength = target.value.length
    target.focus()
    target.setSelectionRange(targetValueLength, targetValueLength)
  }
})

window.addEventListener("phx:copy-to-clipboard", (e) => {
  const target = document.getElementById(e.detail.id)

  if (target) {
    navigator.clipboard.writeText(target.getAttribute("value"))
  }
})

window.addEventListener("phx:reset-all-inputs-of-a-form", (e) => {
  const targetForm = document.getElementById(e.detail.id)

  if (targetForm) {
    const allItsInputs = document.querySelectorAll(`#${e.detail.id} input`)

    allItsInputs.forEach(element => {
      element.value = ""
    });

    // then we set the focus to the first input

    allItsInputs[0].focus()
  }
})

window.addEventListener("phx:focus-keyboarder", () => {
  document.activeElement.blur()
})

window.addEventListener("phx:focus-on-id-textarea-and-focus-end", (e) => {
  const target = document.getElementById(e.detail.id)

  if (target) {
    const targetValueLength = target.value.length
    target.focus()
    target.setSelectionRange(targetValueLength, targetValueLength)

    const locator = document.getElementById("whole-script-input-locator")

    if (locator) {
      locator.scrollIntoView({ behavior: 'smooth' })
    }
  }
})

window.addEventListener("phx:get-screen-to-middle-for-editor", () => {
  const locator = document.getElementById("whole-script[itself]")

  if (locator) {
    const substr = locator.value.substr(0, locator.selectionStart)
    const substrLineCount = substr.split("\n").length

    let absoluteTopPositionOfTextarea = 0
    let node = locator
    while (node) {
      absoluteTopPositionOfTextarea += node.offsetTop || 0
      node = node.offsetParent
    }

    // each line makes about 24 px with default configs, we dont offer customs now
    // thing is that the user wants the content from a nice place, when we use the
    // basic technique of concatting em the topmost line is barely seeable
    // what im gonna do is give it 5 lines from myself, meaning minus
    window.scrollTo({ top: absoluteTopPositionOfTextarea - (24 * 5) + substrLineCount * 24, behavior: 'smooth' })
  }
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

