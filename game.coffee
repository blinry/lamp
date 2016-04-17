rand = (min, max) -> Math.floor Math.random()*(max - min + 1) + min

stage = null
queue = null
light = null
lamp = null
flies = null
win = null
mouse = null
room = null
fireflies = null
dark = null
hole = null
keys = {}
lampHeight = null

preload = ->
    stage = new createjs.Stage("canvas")
    #stage.enableMouseOver(10)

    queue = new createjs.LoadQueue(false)
    queue.installPlugin(createjs.Sound)
    manifest = [
        {src: "click.wav", id: "click"}
        {src: "nom.wav", id: "nom"}
        {src: "room.png", id: "room"}
        {src: "lamp.png", id: "lamp"}
        {src: "light.png", id: "light"}
        {src: "fly.png", id: "fly"}
        {src: "window.png", id: "window"}
        {src: "mouse.png", id: "mouse"}
        {src: "socket.png", id: "socket"}
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
    stage.addChild(room)

    dark = new createjs.Shape()
    dark.graphics.f("black").dr(0,0,stage.canvas.width,stage.canvas.height)
    stage.addChild(dark)
    dark.alpha = 0

    hole = {x:700, y:400}

    mouse = new createjs.Bitmap(queue.getResult("mouse"))
    stage.addChild(mouse)
    mouse.x = 600
    mouse.y = 500
    mouse.regY = mouse.getBounds().height/2

    light = new createjs.Bitmap(queue.getResult("light"))
    stage.addChild(light)
    light.regX = light.getBounds().width/2
    light.regY = light.getBounds().height/2
    light.scaleX = 0.5
    light.scaleY = 0.5

    win = new createjs.Bitmap(queue.getResult("window"))
    stage.addChild(win)
    win.x = 250
    win.y = 150
    win.regX = win.getBounds().width/2
    win.regY = win.getBounds().height/2

    flies = []
    fireflies = []
    #for n in [1..10]
    #    flies.push(newFly())

    #fireflies = []
    #for n in []
    #    fireflies.push(newFly())

    socket = new createjs.Bitmap(queue.getResult("socket"))
    stage.addChild(socket)
    socket.x = stage.canvas.width/2
    socket.y = 280
    socket.regX = socket.getBounds().width/2
    socket.regY = socket.getBounds().height/2
    socket.scaleX = 0.5
    socket.scaleY = 0.5

    cable = new createjs.Shape()
    #cable.graphics = new createjs.Graphics().f("black").dc(0,0,50)#mt(lamp.x, lamp.y).lt(socket.x, socket.y)
    stage.addChild(cable)
    #cable.x = socket.x
    #cable.y = socket.y

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
    lampRange = 400
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
        if this.y+lampHeight < 300
            this.y = 300-lampHeight
        if this.y+lampHeight > stage.canvas.height
            this.y = stage.canvas.height-lampHeight
        if this.x < 0
            this.x = 0
        if this.x > stage.canvas.width
            this.x = stage.canvas.width

        light.x = this.x
        light.y = this.y

        cable.graphics = new createjs.Graphics().s("black").ss(2, "round").mt(lamp.x, lamp.y+lampHeight).lt(socket.x, socket.y)
        #this.x -= Math.cos(this.rotation/180*Math.PI)*this.speed*event.delta
        #this.y -= Math.sin(this.rotation/180*Math.PI)*this.speed*event.delta
    )

    mouse.on("tick", (event) ->
        #if mouse.x < 50
            #alert("You win!")
        holeDist = Math.sqrt((this.x-hole.x)**2 + (this.y-hole.y)**2)
        if holeDist < 10
            mouse.visible = false
        else
            mouse.visible = true

        lampDist = Math.sqrt((this.x-lamp.x)**2 + (this.y-lamp.y)**2)
        if lightOn() and lampDist < lampRange
            this.dir = Math.atan2(hole.y-this.y, hole.x-this.x)
            this.speed = 1/10
        else
            toDelete = []
            nearestDeadFly = null
            minDist = 999999
            for fly in flies when fly.floor
                dist = Math.sqrt((this.x-fly.x)**2 + (this.y-fly.y)**2)
                if dist < 20
                    toDelete.push(fly)
                    createjs.Sound.play("nom")
                else if dist < minDist and dist < 100
                    minDist = dist
                    nearestDeadFly = fly

            for fly in toDelete
                stage.removeChild(fly)
                index = flies.indexOf(fly)
                flies.splice(index, 1)

            if nearestDeadFly != null
                dir = Math.atan2(nearestDeadFly.y-this.y, nearestDeadFly.x-this.x)
                this.dir = dir
                this.speed = 1/20
            else
                this.dir = 0
                this.speed = 0

        this.x += Math.cos(this.dir)*event.delta*this.speed
        this.y += Math.sin(this.dir)*event.delta*this.speed
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

    if rand(1,2000/event.delta) == 1 and lightOn()
        flies.push(newFly())

keydown = (event) ->
    keys[event.keyCode] = true

    objects = [lamp, mouse]#.concat(flies)

    if event.keyCode == 32
        createjs.Sound.play("click")
        if lightOn()
            # switch light off
            createjs.Tween.get(dark).to({alpha:1},100)
            for fly in fireflies
                createjs.Tween.get(fly).to({alpha:1},100)

            for object in objects
                object.filters = [
                    new createjs.ColorFilter(1,1,1,1,-255,-255,-255,0)
                ]
                object.cache(0,0,object.getBounds().width,object.getBounds().height)
        else
            # switch light on
            createjs.Tween.get(dark).to({alpha:0},100)
            for fly in fireflies
                createjs.Tween.get(fly).to({alpha:0},100)

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
    stage.addChild(fly)
    fly.regX = fly.getBounds().width/2
    fly.regY = fly.getBounds().height/2
    border = 100
    fly.x = rand(win.x-win.getBounds().width/2,win.x+win.getBounds().width/2)
    fly.y = rand(win.y-win.getBounds().height/2,win.y+win.getBounds().height/2)
    fly.dir = rand(0,360)/180*Math.PI
    fly.speed = 1/5
    flies.push(fly)
    fly.on("tick", (event) ->
        dist = Math.sqrt((lamp.y-this.y)**2 + (lamp.x-this.x)**2)

        if this.dead
            # nop
        else if dist < 50 and lightOn()
            this.dead = true
            createjs.Tween.get(this).to({y:this.y+lampHeight, rotation:rand(170,190)}, 1000, createjs.Ease.quadIn).set({floor:true})
        else
            this.rotation = rand(-10,10)
            pull = if lightOn()
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

lightOn = ->
    dark.alpha < 1

window.onload = preload

window.addEventListener("keydown", (e) ->
    if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1)
        e.preventDefault()
, false)
