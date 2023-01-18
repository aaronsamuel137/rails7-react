class Question < ApplicationRecord
  def to_json
    {
      id: id,
      question: question,
      answer: answer,
      audio_url: audio_source_url
    }
  end
end
