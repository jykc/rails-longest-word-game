require 'open-uri'
require 'json'

class PagesController < ApplicationController

  def game
    grid = generate_grid(9)
    @grid = grid.join(" ")
    @start_time = Time.now.to_i
  end

  def score
      @guess = params[:guess]
      @end_time = Time.now.to_i
      @grid = params[:grid]
      @start_time = params[:start_time].to_i
      @time_taken = @end_time - @start_time

      score_and_message = score_and_message(@guess, @grid, @time_taken)
      @score = score_and_message[0]
      @message = score_and_message[1]


  end


  private
  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

    def compute_score(attempt, time_taken)
      time_taken > 60.0 ? 0 : attempt.size * (1.0 - time_taken / 60.0)
    end

    def score_and_message(attempt, grid, time)
      if included?(attempt.upcase, grid)
        if english_word?(attempt)
          score = compute_score(attempt, time)
          [score, "well done"]
        else
          [0, "not an english word"]
        end
      else
        [0, "not in the grid"]
      end
    end

    def english_word?(word)
      response = open("https://wagon-dictionary.herokuapp.com/#{word}")
      json = JSON.parse(response.read)
      return json['found']
    end

end
