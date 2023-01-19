require "test_helper"

class PromptGeneratorTest < ActiveSupport::TestCase
  test 'It generates a prompt with the query at the end' do
    query = 'What is the meaning of life?'

    # pass empty csv_filename to the PromptGenerator so this works without a local csv file or network connection
    prompt = PromptGenerator.new(query, csv_filename: '').construct_prompt
    assert prompt.ends_with?("#{query}\n\nA: ")
  end
end
