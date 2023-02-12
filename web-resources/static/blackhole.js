const canvas = document.createElement('canvas'),
	 context = canvas.getContext('2d'),
	 width = canvas.width = window.innerWidth,
	 height = canvas.height = window.innerHeight,
	 mouse = { x: 0, y: 0 },
	 particles = []

document.body.appendChild(canvas)

document.body.addEventListener('mousemove', e => {
	mouse.x = e.pageX
	mouse.y = e.pageY
})

context.fillStyle = '#ff7b66'
context.strokeStyle = '#ff8455'

class Particle {
	constructor(){
		this.position = {
			x: Math.round(Math.random() * width),
			y: Math.round(Math.random() * height)
		}
		
		this.size = 3
		
		let maxSpeed = .8,
		    minSpeed = .3,
		    speed = Math.max(Math.random() * maxSpeed, minSpeed),
		    angle = Math.random() * Math.PI * 2
		
		this.velocity = {
			x: Math.cos(angle) * speed,
			y: Math.sin(angle) * speed
		}
		
		particles.push(this)
	}
	
	move(){
		let { x: vx, y: vy } = this.velocity

		this.position.x += vx
		this.position.y += vy
	}
	
	applyBounds(){
		let { position, velocity } = this,
		    { x, y } = position
		
		if(x > width || x < 0) velocity.x *= -1
		if(y > height || y < 0) velocity.y *= -1
	}
	
	drawLine(){
		let { x, y } = this.position,
		    distanceToMouse = getDistance(this.position, mouse)
		
		if(distanceToMouse > width*.2) return;
		
		let particlesInRange = particles.reduce((acc, x) => {
			if(x == this) return acc;
			let d = getDistance(this.position, x.position)
			if(d < 150) acc.push(x)
			return acc
		}, [])
		
		particlesInRange.map(x => {
			context.moveTo(this.position.x, this.position.y);
			context.lineTo(x.position.x, x.position.y);
		})
	}
	
	
	drawParticle(){
		let { x, y } = this.position
		
		context.moveTo(x, y);
		context.arc(x, y, this.size, 0, 2 * Math.PI);
	}
	
	render(){
		this.move()
		this.applyBounds()
		this.drawParticle()
		this.drawLine()
	}
}

for(var i = 0; i < 300; i++){
	new Particle()
}

function getDistance(p1, p2){
	return Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2))
}

function reverseVelocity(p){
	p.x = p.x * -1
	p.y = p.y * -1
}

function update(){
	context.clearRect(0,0,width,height)
	
	context.beginPath()
	particles.map(x => x.render())
	context.stroke()
	context.fill()
	
	requestAnimationFrame(update)
}
update()