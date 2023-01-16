class Api::V1::QuestionsController < ApplicationController
  def show
  end

  def ask
    query = params[:question]
    query = query + "?" unless query.end_with?("?")

    existing_question = Question.find_by(question: query)
    if existing_question
      render json: existing_question.to_json
    else
      prompt_generator = PromptGenerator.new(query)
      prompt = prompt_generator.construct_prompt
      context = prompt_generator.context
      # TODO:
      # - Send prompt to openai completions endpoint
      # - Send answer to text to speech endpoint
      # new_question = Question.create(question: query, answer: answer, audio_source_url: audio_source_url)
      # render json: new_question.to_json
    end
  end
end
