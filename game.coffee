rand = (min, max) -> Math.floor Math.random()*(max - min + 1) + min

stage = null
queue = null
light = null
fireflies = null
dark = null
keys = {}

preload = ->
    stage = new createjs.Stage("canvas")
    #stage.enableMouseOver(10)

    queue = new createjs.LoadQueue(false)
    queue.installPlugin(createjs.Sound)
    manifest = [
        #{src: "piece.wav", id: "piece"}
        {src: "room.jpg", id: "room"}
        {src: "lamp.png", id: "lamp"}
        {src: "light.png", id: "light"}
        {src: "fly.png", id: "fly"}
        {src: "window.png", id: "window"}
    ]
    queue.loadManifest(manifest)
    queue.on("complete", (event) ->
        init()
    )

init = ->
    #for i in [1..10]
    #    circle = new createjs.Bitmap(queue.getResult("duck"))
    #    circle.x = i
    #    circle.y = i
    #    circle.alpha = 0.05
    #    stage.addChild(circle)

    #    circle.on("pressmove", (event) ->
    #        this.x = event.stageX
    #        this.y = event.stageY
    #    )
    #    circle.on("tick", (event) ->
    #        #this.x += event.delta/10
    #    )

    room = new createjs.Bitmap(queue.getResult("room"))
    room.scaleX = 0.2
    room.scaleY = 0.2
    stage.addChild(room)

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
    #lamp.filters = [ new createjs.BlurFilter(5, 5, 2) ]
    #lamp.cache(0,0,500,500)
    lampRange = 100

    flies = []
    for n in [1..10]
        fly = new createjs.Bitmap(queue.getResult("fly"))
        stage.addChild(fly)
        fly.regX = fly.getBounds().width/2
        fly.regY = fly.getBounds().height/2
        fly.x = rand(200,stage.getBounds().width-200)
        fly.y = rand(200,stage.getBounds().height-200)
        dir = rand(0,360)/180*Math.PI
        speed = 1/5
        fly.dx = Math.cos(dir)*speed
        fly.dy = Math.sin(dir)*speed
        flies.push(fly)

    light = new createjs.Bitmap(queue.getResult("light"))
    stage.addChild(light)
    light.regX = light.getBounds().width/2
    light.regY = light.getBounds().height/2
    light.scaleX = 0.5
    light.scaleY = 0.5

    dark = new createjs.Shape()
    dark.graphics.f("black").dr(0,0,stage.canvas.width,stage.canvas.height)
    stage.addChild(dark)
    dark.alpha = 0

    window = new createjs.Bitmap(queue.getResult("window"))
    stage.addChild(window)
    window.x = 400
    window.y = 400

    fireflies = []
    for n in [1..10]
        fly = new createjs.Bitmap(queue.getResult("fly"))
        stage.addChild(fly)
        fly.regX = fly.getBounds().width/2
        fly.regY = fly.getBounds().height/2
        fly.x = rand(200,stage.getBounds().width-200)
        fly.y = rand(200,stage.getBounds().height-200)
        dir = rand(0,360)/180*Math.PI
        speed = 1/5
        fly.dx = Math.cos(dir)*speed
        fly.dy = Math.sin(dir)*speed
        fireflies.push(fly)

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

        light.x = this.x
        light.y = this.y
        #this.x -= Math.cos(this.rotation/180*Math.PI)*this.speed*event.delta
        #this.y -= Math.sin(this.rotation/180*Math.PI)*this.speed*event.delta
    )

    for fly in flies
        fly.on("tick", (event) ->
            #dir = Math.atan2(lamp.y-this.y, lamp.x-this.x)
            #dx = Math.cos(this.dir)*event.delta*this.speed+Math.cos(dir)*(lampRange-dist)*event.delta
            #dy = Math.sin(this.dir)*event.delta*this.speed+Math.sin(dir)*(lampRange-dist)*event.delta
            #this.dir = Math.atan2(dy, dx)

            if (dark.alpha < 1)
                dist = Math.sqrt((lamp.y-this.y)**2 + (lamp.x-this.x)**2)
                this.dx += (lamp.x-this.x)/(dist**2+500)
                this.dy += (lamp.y-this.y)/(dist**2+500)
            dist = Math.sqrt(this.dx**2 + this.dy**2)
            speed = 1/10
            this.dx *= speed/dist
            this.dy *= speed/dist
            this.x += this.dx*event.delta
            this.y += this.dy*event.delta
        )

    for fly in fireflies
        fly.on("tick", (event) ->
            #dir = Math.atan2(lamp.y-this.y, lamp.x-this.x)
            #dx = Math.cos(this.dir)*event.delta*this.speed+Math.cos(dir)*(lampRange-dist)*event.delta
            #dy = Math.sin(this.dir)*event.delta*this.speed+Math.sin(dir)*(lampRange-dist)*event.delta
            #this.dir = Math.atan2(dy, dx)

            if (dark.alpha < 1)
                dist = Math.sqrt((lamp.y-this.y)**2 + (lamp.x-this.x)**2)
                this.dx += (lamp.x-this.x)/(dist**2+500)
                this.dy += (lamp.y-this.y)/(dist**2+500)
            dist = Math.sqrt(this.dx**2 + this.dy**2)
            speed = 1/10
            this.dx *= speed/dist
            this.dy *= speed/dist
            this.x += this.dx*event.delta
            this.y += this.dy*event.delta
        )

    #s = new createjs.Shape()
    #s.graphics.s("yellow").f("red").dc(0,0,30).f("blue").dc(30,0,30)
    #s.x = 300
    #s.y = 300
    #stage.addChild(s)
    #s.on("pressmove", (event) ->
    #    this.x = event.stageX
    #    this.y = event.stageY
    #)
    #s.on("click", ->
    #    createjs.Tween.get(this).to({x:100}, 1000, createjs.Ease.elasticOut)
    #)

    createjs.Ticker.timingMode = createjs.Ticker.RAF_SYNCHED
    createjs.Ticker.on("tick", tick)
    createjs.Ticker.setFPS(30)

    document.onkeydown = keydown
    document.onkeyup = keyup

tick = (event) ->
    stage.update(event)

keydown = (event) ->
    keys[event.keyCode] = true

    if event.keyCode == 32
        if dark.alpha == 1
            createjs.Tween.get(dark).to({alpha:0},100)
            for fly in fireflies
                createjs.Tween.get(fly).to({alpha:0},100)
        else
            createjs.Tween.get(dark).to({alpha:1},100)
            for fly in fireflies
                createjs.Tween.get(fly).to({alpha:1},100)

keyup = (event) ->
    keys[event.keyCode] = false

isDown = (keyCode) ->
    if keys[keyCode]
        true
    else
        false

window.onload = preload

window.addEventListener("keydown", (e) ->
    if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1)
        e.preventDefault()
, false)
