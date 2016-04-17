rand = (min, max) -> Math.floor Math.random()*(max - min + 1) + min

stage = null
queue = null
lamp = null
flies = []
cheeses = []
win = null
mouse = null
room = null
fireflies = []
socket = null
hole = null
keys = {}
lampHeight = null
lightOn = true

hBorder = 150
vBorder = 50

preload = ->
    stage = new createjs.Stage("canvas")

    queue = new createjs.LoadQueue(false)
    queue.installPlugin(createjs.Sound)
    manifest = [
        {src: "click.wav", id: "click"}
        {src: "nom.wav", id: "nom"}
        {src: "room.png", id: "room"}
        {src: "lamp.png", id: "lamp"}
        {src: "flylight.png", id: "flylight"}
        {src: "fly.png", id: "fly"}
        {src: "window.png", id: "window"}
        {src: "mouse.png", id: "mouse"}
        {src: "socket.png", id: "socket"}
        {src: "cheese.png", id: "cheese"}
    ]
    queue.loadManifest(manifest)
    queue.on("complete", (event) ->
        init()
    )

init = ->
    room = new createjs.Bitmap(queue.getResult("room"))
    stage.addChild(room)

    hole = {x:700, y:400}

    mouse = new createjs.Bitmap(queue.getResult("mouse"))
    stage.addChild(mouse)
    mouse.x = hole.x
    mouse.y = hole.y
    mouse.regY = mouse.getBounds().height/2

    win = new createjs.Bitmap(queue.getResult("window"))
    stage.addChild(win)
    win.x = 250
    win.y = 150
    win.regX = win.getBounds().width/2
    win.regY = win.getBounds().height/2

    for n in [1..3]
        cheeses.push(newCheese())

    socket = new createjs.Bitmap(queue.getResult("socket"))
    stage.addChild(socket)
    socket.x = stage.canvas.width/2
    socket.y = 280
    socket.regX = socket.getBounds().width/2
    socket.regY = socket.getBounds().height/2
    socket.scaleX = 0.5
    socket.scaleY = 0.5

    cable = new createjs.Shape()
    stage.addChild(cable)

    lamp = new createjs.Bitmap(queue.getResult("lamp"))
    stage.addChild(lamp)
    lamp.x = stage.canvas.width/2
    lamp.y = stage.canvas.height/2
    lamp.regX = lamp.getBounds().width/2
    lamp.regY = 50
    lamp.speed = 0
    lamp.cursor = "help"
    lamp.dx = 0
    lamp.dy = 0
    lamp.range = 400
    lamp.strength = 1
    lampHeight = 240
    lamp.on("tick", (event) ->
        speed = 1/2
        if isDown(37) # left
            this.dx -= event.delta*speed
        if isDown(39) # right
            this.dx += event.delta*speed
        if isDown(38) # up
            this.dy -= event.delta*speed
        if isDown(40) # down
            this.dy += event.delta*speed

        this.dx *= 0.5
        this.dy *= 0.5
        this.x += this.dx
        this.y += this.dy

        maxY = 300
        if this.y+lampHeight < 300+vBorder
            this.y = 300+vBorder-lampHeight
        if this.y+lampHeight > stage.canvas.height-vBorder
            this.y = stage.canvas.height-lampHeight-vBorder
        if this.x < hBorder
            this.x = hBorder
        if this.x > stage.canvas.width-hBorder
            this.x = stage.canvas.width-hBorder

        cable.graphics = new createjs.Graphics().s("black").ss(2, "round").mt(lamp.x, lamp.y+lampHeight).lt(socket.x, socket.y)
    )

    mouse.on("tick", (event) ->
        holeDist = Math.sqrt((this.x-hole.x)**2 + (this.y-hole.y)**2)
        if holeDist < 10
            mouse.visible = false
        else
            mouse.visible = true

        lampDist = Math.sqrt((this.x-lamp.x)**2 + (this.y-lamp.y)**2)
        if lightOn and lampDist < lamp.range
            this.dir = Math.atan2(hole.y-this.y, hole.x-this.x)
            this.speed = 1/10
        else
            toDelete = []
            toDeleteC = []
            nearestFood = null
            minDist = 999999
            for fly in flies when fly.floor
                dist = Math.sqrt((this.x-fly.x)**2 + (this.y-fly.y)**2)
                if dist < 20
                    toDelete.push(fly)
                    createjs.Sound.play("nom")
                else if dist < minDist and dist < fly.range
                    minDist = dist
                    nearestFood = fly
            for cheese in cheeses
                dist = Math.sqrt((this.x-cheese.x)**2 + (this.y-cheese.y)**2)
                if dist < 20
                    toDeleteC.push(cheese)
                    createjs.Sound.play("nom")
                else if dist < minDist and dist < 100
                    minDist = dist
                    nearestFood = cheese

            for fly in toDelete
                stage.removeChild(fly)
                index = flies.indexOf(fly)
                flies.splice(index, 1)

            for cheese in toDeleteC
                stage.removeChild(cheese)
                index = cheeses.indexOf(cheese)
                cheeses.splice(index, 1)

            if nearestFood != null
                dir = Math.atan2(nearestFood.y-this.y, nearestFood.x-this.x)
                this.dir = dir
                this.speed = 1/20
            else
                this.dir = 0
                this.speed = 0

        this.x += Math.cos(this.dir)*event.delta*this.speed
        this.y += Math.sin(this.dir)*event.delta*this.speed
    )

    createjs.Ticker.timingMode = createjs.Ticker.RAF_SYNCHED
    createjs.Ticker.on("tick", tick)
    createjs.Ticker.setFPS(30)

    document.onkeydown = keydown
    document.onkeyup = keyup

tick = (event) ->
    stage.update(event)

    if rand(1,2000/event.delta) == 1 and lightOn
        flies.push(newFly())

    # update lightmap
    lights = []
    glow = []
    if lightOn
        lights.push(lamp)
    else
        for fly in flies
            lights.push(fly)
        glow.push(win)

    l = new createjs.Container()
    for light in lights
        ll = new createjs.Bitmap(queue.getResult("flylight"))
        ll.x = light.x
        ll.y = light.y
        ll.regX = ll.getBounds().width/2
        ll.regY = ll.getBounds().height/2
        ll.scaleX = light.range/150
        ll.scaleY = light.range/150
        ll.alpha = light.strength
        l.addChild(ll)

    for glowy in glow
        l.addChild(glowy.clone())

    l.cache(0,0,800,600)
    stage.filters = [
        new createjs.AlphaMaskFilter(l.cacheCanvas)
    ]
    stage.cache(0,0,800,600)

keydown = (event) ->
    keys[event.keyCode] = true

    objects = [lamp]

    if event.keyCode == 32
        createjs.Sound.play("click")
        lightOn = not lightOn
        if not lightOn
            for object in objects
                object.filters = [
                    new createjs.ColorFilter(1,1,1,1,-255,-255,-255,0)
                ]
                object.cache(0,0,object.getBounds().width,object.getBounds().height)
        else
            for object in objects
                object.uncache()

keyup = (event) ->
    keys[event.keyCode] = false

isDown = (keyCode) ->
    if keys[keyCode]
        true
    else
        false

newFly = ->
    fly = new createjs.Bitmap(queue.getResult("fly"))
    fly.regX = fly.getBounds().width/2
    fly.regY = fly.getBounds().height/2
    border = 100
    fly.x = rand(win.x-win.getBounds().width/2,win.x+win.getBounds().width/2)
    fly.y = rand(win.y-win.getBounds().height/2,win.y+win.getBounds().height/2)
    fly.dir = rand(0,360)/180*Math.PI
    fly.speed = 1/5
    fly.range = 150
    fly.range = 150
    fly.strength = 0.2
    stage.addChild(fly)
    fly.on("tick", (event) ->
        dist = Math.sqrt((lamp.y-this.y)**2 + (lamp.x-this.x)**2)

        if this.dead
            # nop
        else if dist < 50 and lightOn
            this.dead = true
            createjs.Tween.get(this).to({y:this.y+lampHeight, rotation:rand(170,190)}, 1000, createjs.Ease.quadIn).set({floor:true})
        else
            this.rotation = rand(-10,10)
            pull = if lightOn
                Math.sqrt(dist)/1000
            else
                0
            dir = Math.atan2(lamp.y-this.y, lamp.x-this.x)
            randDir = rand(0,360)/180*Math.PI
            randStrength = 1/20
            dx = Math.cos(this.dir)*this.speed+Math.cos(dir)*pull+Math.cos(randDir)*randStrength
            dy = Math.sin(this.dir)*this.speed+Math.sin(dir)*pull+Math.sin(randDir)*randStrength
            this.dir = Math.atan2(dy, dx)
            this.speed = Math.sqrt(dy**2+dx**2)
            if this.speed > 1/5
                this.speed *= 0.8

            this.x += Math.cos(this.dir)*event.delta*this.speed
            this.y += Math.sin(this.dir)*event.delta*this.speed
    )
    fly

newCheese = ->
    cheese = new createjs.Bitmap(queue.getResult("cheese"))
    cheese.regX = cheese.getBounds().width/2
    cheese.regY = cheese.getBounds().height/2
    stage.addChild(cheese)
    cheese.x = rand(hBorder,stage.canvas.width-hBorder)
    cheese.y = rand(300+vBorder,stage.canvas.height-vBorder)
    cheese

lightOff = ->
    l = new createjs.Container()
    for fly in flies
        ll = new createjs.Bitmap(queue.getResult("flylight"))
        ll.x = fly.x
        ll.y = fly.y
        l.addChild(ll)
        l.cache(0,0,800,600)
    stage.filters = [
        new createjs.AlphaMaskFilter(l.cacheCanvas)
    ]
    stage.cache(0,0,800,600)

window.onload = preload

window.addEventListener("keydown", (e) ->
    if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1)
        e.preventDefault()
, false)
