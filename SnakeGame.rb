require  'ruby2d'
set background: 'yellow'
FPS=15
set fps_cap: FPS

GRID_SIZE=30
GRID_HEIGHT = Window.height/GRID_SIZE
GRID_WIDTH = Window.width/GRID_SIZE

class Game
  attr_writer :time
  attr_reader :time
  def initialize
    @score=0
    @food_x=rand(GRID_WIDTH)
    @food_y=rand(GRID_HEIGHT)
    @finished =false
    @time = 30
  end
  def draw
    unless finished?
      Square.new(x: @food_x*GRID_SIZE,y: @food_y*GRID_SIZE,size: GRID_SIZE-2,color: 'maroon')
      Text.new("Score: #{@score}",x:10,y:10,size:20,color:'fuchsia')
      Text.new("Time Limit: #{@time}",x:300,y:10,size:20,color:'fuchsia')
    end

  end
  def food_eat?(x,y)
    @food_x==x &&@food_y==y
  end
  def record_hit
    @score+=@time
    @food_x=rand(GRID_WIDTH)
    @food_y=rand(GRID_HEIGHT)
    @time+=3
  end
  def time_limit
    @food_x=rand(GRID_WIDTH)
    @food_y=rand(GRID_HEIGHT)
  end
  def time_decrease
    @time-=1
  end
  def game_finish
    @finished=true
  end
  def finished?
    @finished
  end
  def text_message
    if finished?
      Text.new("Game over, Your Score was #{@score}. Press 'R' to restart. ",x:10,y:10,color:'red')

    end
  end

end

class Snake
  attr_writer :direction
  def initialize
    @positions = [[2,0],[2,1],[2,2],[2,3]]
    @direction = 'up'
    @growing =false
  end

  def draw
    @positions.each do |position|
      Square.new(x: position[0]*GRID_SIZE,y:position[1]*GRID_SIZE,size: GRID_SIZE-2,color: 'red')
    end
  end

  def x
    head[0]
  end
  def y
    head[1]
  end
  def changeDirection?(newDirection)
    case @direction
    when 'up' then newDirection !='down'
    when 'down' then newDirection !='up'
    when 'left' then newDirection !='right'
    when 'right' then newDirection !='left'
    end
  end
  def hit_itself?
    @positions.uniq.length != @positions.length
  end


  def move
    if !@growing
      @positions.shift
    end

    case @direction
    when 'down'
      @positions.push(new_coords(head[0],head[1]+1))
    when 'up'
      @positions.push(new_coords(head[0],head[1]-1))
    when 'left'
      @positions.push(new_coords(head[0]-1,head[1]))
    when 'right'
      @positions.push(new_coords(head[0]+1,head[1]))
    end
    @growing=false
  end
  def new_coords(x,y)
    [x% GRID_WIDTH,y%GRID_HEIGHT]
  end
  def head
    @positions.last
  end
  def grow
    @growing=true
  end
  def p_size
    @positions.size
  end
end

snake =Snake.new
game = Game.new
t=10
tick=0
update do
  clear

  unless game.finished?
    snake.move
  end
  snake.draw
  game.draw
  if tick%FPS==0
    game.time_decrease
  end

  if game.time.zero?
    game.game_finish
  end

  tick+=1
  if game.food_eat?(snake.x,snake.y)
    game.record_hit
    snake.grow
    game.time_limit
  end
  if snake.hit_itself?
    if snake.p_size>=5
      game.game_finish
    end
  end
  if game.finished?
    game.text_message
  end

end
on :key_down do |event|
  if ['up','down','left','right'].include?(event.key)
    if snake.changeDirection?(event.key)
      snake.direction = event.key
    end
  end
  if game.finished? && event.key == 'r'
    snake = Snake.new
    game = Game.new
  end
end


show
