extends Node2D


# Member variables
var thread = Thread.new()


func _ready():
    print("START THREAD!")
    thread.start(self, "upnp_func")
    print("after thread start")


func upnp_func(userdata):
    print("Thread func")
    var upnp = UPNP.new()
    upnp.discover()
    print(upnp.query_external_address())
    for i in range(upnp.get_device_count()):
        print(upnp.get_device(i))   