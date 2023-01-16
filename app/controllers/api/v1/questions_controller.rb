class Api::V1::QuestionsController < ApplicationController
  def show
  end

  def ask
    if existing_question.present?
      existing_question.ask_count += 1
      existing_question.save!
      render json: existing_question.to_json
    else
      prompt = prompt_generator.construct_prompt
      context = prompt_generator.context
      answer = openai_completion(prompt)
      # audio_source_url = text_to_speech(answer)['item']['audio_source'] TODO: uncomment when sync requests get enabled on my account
      # new_question = Question.create!(question: query, answer: answer, context: context, audio_source_url: audio_source_url)
      new_question = Question.create!(question: query, answer: answer, context: context)
      render json: new_question.to_json
    end
  end

  private

  def text_to_speech(answer)
    Resemble::V2::Clip.create_sync(ENV['RESEMBLE_PROJECT_UUID'], ENV['RESEMBLE_VOICE_UUID'], answer)
  end

  def openai_completion(prompt)
    response = OpenAI::Client.new.completions(parameters: { prompt: prompt, temperature: 0.0, max_tokens: 150, model: ENV['COMPLETIONS_MODEL'] })
    response.dig('choices', 0, 'text').strip
  end

  def prompt_generator
    @prompt_generator ||= PromptGenerator.new(query)
  end

  def existing_question
    @existing_question ||= Question.find_by(question: query)
  end

  def query
    query = params[:question]
    query = query + "?" unless query.end_with?("?")
    query
  end
end
