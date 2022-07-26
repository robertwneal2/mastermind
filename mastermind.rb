require 'colorize'
require 'pry-byebug'

module GameColors
  CODE_COLORS = { 'R'=> :red, 'G' => :green, 'Y' => :yellow, 'B' => :blue, 'M' => :magenta, 'C' => :cyan }
  # PEG_COLORS = { 'W' => :white, 'BK' => :black }
end

class Game
  include GameColors

  attr_reader :board

  # pass in Player or ComputerPlayer objects
  def initialize(guesser, selector)
    @guesser = guesser
    @guesser.set_game(self) if @guesser.class == ComputerPlayer
    @selector = selector
    @guesses_left = 10
    @code = []
    @board = Array.new(@guesses_left, '----|----')
  end

  def play
    generate_code
    guess = false
    display_board
    until game_over?(guess)
      guess = make_guess
      add_guess_to_board(guess)
      display_board
    end
    declare_winner(guess)
  end

  def generate_code
    code = @selector.generate_code
    until code_valid?(code)
      puts "Invalid code, try again!"
      code = @selector.generate_code
    end
    system('clear')
    @code = code
  end

  def code_valid?(code)
    return false if code.length != 4
    return code.all? { |char| CODE_COLORS.has_key?(char) } # split code into character array, then check to make sure valid color input
  end

  def decrease_guess_count
    @guesses_left -= 1
  end

  def make_guess
    guess = @guesser.get_guess
    until code_valid?(guess)
      puts "Invalid guess!"
      guess = @guesser.get_guess
    end
    system('clear')
    decrease_guess_count
    guess
  end

  def game_over?(guess)
    return true if @guesses_left <= 0
    return true if guess_correct?(guess)
    false
  end

  def guess_correct?(guess)
    return false unless guess
    @code.each_with_index do |code_char, code_i|
      return false if guess[code_i] != code_char
    end
    true
  end

  def guess_feedback(guess)
    guess_colors_count = { 'R'=> 0, 'G' => 0, 'Y' => 0, 'B' => 0, 'M' => 0, 'C' => 0 }
    code_colors_count = { 'R'=> 0, 'G' => 0, 'Y' => 0, 'B' => 0, 'M' => 0, 'C' => 0 }
    exact_match_count = 0
    partial_match_count = 0

    # colors counts and exact matches
    @code.each_with_index do |code_color, code_i|
      guess_color = guess[code_i]
      guess_colors_count[guess_color] += 1
      code_colors_count[code_color] += 1
      exact_match_count += 1 if guess_color == code_color
    end

    # partial matches
    guess_colors_count.each do |guess_color, guess_color_count|
      code_color_count = code_colors_count[guess_color]
      if code_color_count <= guess_color_count
        partial_match_count += code_color_count
      else
        partial_match_count += guess_color_count 
      end
    end
    partial_match_count -= exact_match_count # remove exact matches form partial matches
    partial_match_count = 0 if partial_match_count <= 0 

    # binding.pry
    output_feedback(exact_match_count, partial_match_count)
  end

  def output_feedback(exact_match_count, partial_match_count)
    feedback = '|'
    exact_match_count.times { feedback += 'E'.colorize(:black)}
    partial_match_count.times { feedback += 'P'.colorize(:white)}
    (4 - exact_match_count - partial_match_count).times { feedback += '-' }
    feedback
  end

  def declare_winner(guess)
    puts
    correct_answer = ''
    @code.each { |char| correct_answer += char.colorize(CODE_COLORS[char])}
    puts "#{correct_answer} was the correct answer"
    if guess_correct?(guess)
      puts "#{@guesser.name} wins!" 
    else
      puts "#{@selector.name} wins!"
    end
  end

  def display_board
    @board.each { |line| puts line}
  end

  def add_guess_to_board(guess)
    guess_line = ''
    guess.each do |char|
      color = CODE_COLORS[char]
      guess_line += char.colorize(color)
    end
    feedback = guess_feedback(guess)
    guess_line += feedback
    @board[@guesses_left] = guess_line
  end

end

class Player
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def generate_code
    puts "#{@name}, enter secret color code. Secret code must be 4 characters long and contain B, C, G, M, R, Y only. Order matters!"
    gets.chomp.upcase.split('')
  end

  def get_guess
    puts "#{@name}, enter guess. Guess must be 4 characters long and contain B, C, G, M, R, Y  only. Order matters!"
    gets.chomp.upcase.split('')
  end
end

class ComputerPlayer
  include GameColors

  attr_reader :name


  def initialize
    @name = "Computer#{rand(1000..9999)}"
    @guess_count = 0
    @guesses
  end

  def set_game(game)
    @game = game
  end

  def generate_code
    code = ''
    4.times { code += CODE_COLORS.keys.sample}
    code.split('')
  end

  #random guess
  def get_guess
    guess = ''
    4.times { guess += CODE_COLORS.keys.sample}
    guess.split('')
  end

  #smart guess
  # def get_guess
  #   case @guess_count
  #   when 0
  #   when 1
  #   when 2
  #   when 3
  #   when 4
  #   when 5
  #   when 6
  #   end
    
  #   @guess_count += 1
  #   guess
  # end
end

p1 = Player.new('Bert')
c1 = ComputerPlayer.new
g1 = Game.new(p1, c1)
g1.play
