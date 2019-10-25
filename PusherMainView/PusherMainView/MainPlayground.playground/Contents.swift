import Cocoa
import PlaygroundSupport
import PusherMainView

let bundle = Bundle(for: PusherViewController.self)
let storyboard = NSStoryboard(name: "Pusher", bundle: bundle)
let mainVewController = storyboard.instantiateController(withIdentifier: "PusherViewController") as? PusherViewController

PlaygroundPage.current.liveView = mainVewController
