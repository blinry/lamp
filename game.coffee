rand = (min, max) -> Math.floor Math.random()*(max - min + 1) + min

stage = null
queue = null
light = null
lamp = null
flies = null
room = null
fireflies = null
dark = null
keys = {}

preload = ->
    stage = new createjs.Stage("canvas")
    #stage.enableMouseOver(10)

    queue = new createjs.LoadQueue(false)
    queue.installPlugin(createjs.Sound)
    manifest = [
        {src: "click.wav", id: "click"}
        {src: "roomsmall.jpg", id: "room"}
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
    room.scaleX = 1.2
    room.scaleY = 1.2
    stage.addChild(room)

    dark = new createjs.Shape()
    dark.graphics.f("black").dr(0,0,stage.canvas.width,stage.canvas.height)
    stage.addChild(dark)
    dark.alpha = 0

    light = new createjs.Bitmap(queue.getResult("light"))
    stage.addChild(light)
    light.regX = light.getBounds().width/2
    light.regY = light.getBounds().height/2
    light.scaleX = 0.5
    light.scaleY = 0.5

    window = new createjs.Bitmap(queue.getResult("window"))
    stage.addChild(window)
    window.x = 100
    window.y = 100

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

    border = 100
    flies = []
    for n in [1..10]
        fly = new createjs.Bitmap(queue.getResult("fly"))
        stage.addChild(fly)
        fly.regX = fly.getBounds().width/2
        fly.regY = fly.getBounds().height/2
        fly.x = rand(border,stage.canvas.width-border)
        fly.y = rand(border,stage.canvas.height-border)
        fly.dir = rand(0,360)/180*Math.PI
        fly.speed = 1/5
        flies.push(fly)

    fireflies = []
    for n in [1..10]
        fly = new createjs.Bitmap(queue.getResult("fly"))
        stage.addChild(fly)
        fly.regX = fly.getBounds().width/2
        fly.regY = fly.getBounds().height/2
        fly.x = rand(border,stage.canvas.width-border)
        fly.y = rand(border,stage.canvas.height-border)
        fly.dir = rand(0,360)/180*Math.PI
        fly.speed = 1/5
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

    for fly in flies.concat(fireflies)
        fly.on("tick", (event) ->
            dist = Math.sqrt((lamp.y-this.y)**2 + (lamp.x-this.x)**2)
            pull = if dark.alpha < 1
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

            #if (dark.alpha < 1)
            #    dist = Math.sqrt((lamp.y-this.y)**2 + (lamp.x-this.x)**2)
            #    this.dx += (lamp.x-this.x)/1000
            #    this.dy += (lamp.y-this.y)/1000
            #dist = Math.sqrt(this.dx**2 + this.dy**2)
            #speed = 1/10
            #this.dx *= speed/dist
            #this.dy *= speed/dist
            #this.x += this.dx*event.delta
            #this.y += this.dy*event.delta

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

    objects = [lamp].concat(flies)

    if event.keyCode == 32
        createjs.Sound.play("click")
        if dark.alpha == 1
            # switch light on
            createjs.Tween.get(dark).to({alpha:0},100)
            for fly in fireflies
                createjs.Tween.get(fly).to({alpha:0},100)

            for object in objects
                object.uncache()
        else
            # switch light off
            createjs.Tween.get(dark).to({alpha:1},100)
            for fly in fireflies
                createjs.Tween.get(fly).to({alpha:1},100)

            for object in objects
                object.filters = [
                    new createjs.ColorFilter(1,1,1,1,-255,-255,-255,0)
                ]
                object.cache(0,0,object.getBounds().width,object.getBounds().height)

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
