require 'open-uri'
require 'json'

class PagesController < ApplicationController

def game
  @grid = generate_grid
  @grid = @grid.join(" ")
  @start_time = Time.now
end

def score
  @end_time = Time.now
  @result = run_game(params[:attempt], params[:grid].split(" "), params[:start_time].to_datetime, @end_time)
end

def generate_grid
  (0...9).map do
    ('A'..'Z').to_a[rand(26)]
  end
end

def run_game(attempt, grid, start_time, end_time)
  @result = {}
  attempt = attempt.upcase
  time_attempt = (end_time - start_time)
  @result[:time] = time_attempt.to_s

  url = "http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}"

  translation_result = JSON.parse(open(url).read)
  translation_error = false
  if translation_result["Error"]
    translation_error = true
    @result[:translation] = nil

  else
    @result[:translation] = translation_result["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
  end

  error_grid = check_input_against_grid(grid, attempt)
  if error_grid && !translation_error
    @result[:message] = "not in the grid"
  elsif translation_error
    @result[:message] = "not an english word"
  else
    @result[:message] = "well done"
  end

  @result[:score] = score_time(time_attempt) + score_length(attempt) unless error_grid || translation_error

  @result
end


def score_time(time)
  score = 0
  if time < 5
    score = 10
  elsif time < 10
    score = 8
  elsif time < 40
    score = 5
  else
    score = 1
  end
  score
end

def score_length(attempt)
  attempt.length * 10
end

def check_input_against_grid(grid, attempt)
  error = false
  (0...attempt.length).each do |i|
    char = attempt[i]
    index = grid.index(char)
    if index
      grid.delete_at(index)
    else
      error = true
      break
    end
  end
  error
end

end
