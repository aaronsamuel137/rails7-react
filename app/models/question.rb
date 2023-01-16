class Question < ApplicationRecord
  def to_json
    {
      question: question,
      answer: answer,
      audio_url: audio_source_url
    }
  end
end
