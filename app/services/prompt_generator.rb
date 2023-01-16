require 'matrix'

class PromptGenerator
  MAX_SECTION_LEN = 500
  SEPARATOR = "\n* "
  SEPARATOR_LENGTH = 3

  def initialize(query)
    self.query = query
  end

  def construct_prompt
    header + context + questions + "\n\n\nQ: #{query}\n\nA: "
  end

  def context
    @context ||= begin
      sections = []
      sections_length = 0

      closest_pages.each do |page|
        additional_length = page['tokens'].to_i + SEPARATOR_LENGTH

        if sections_length + additional_length > MAX_SECTION_LEN
          tokens_left = MAX_SECTION_LEN - sections_length - SEPARATOR_LENGTH
          truncated_content = page['content'].split(/\s+/).first(tokens_left).join(' ') # approximate number of tokens with whitespace split
          sections.append(truncated_content)
          break
        end

        sections_length += additional_length
        sections.append(SEPARATOR + page['content'])
      end

      sections.join('')
    end
  end

  private

  attr_accessor :query

  def header
    "Sahil Lavingia is the founder and CEO of Gumroad, and the author of the book The Minimalist Entrepreneur (also known as TME). These are questions and answers by him. Please keep your answers to three sentences maximum, and speak in complete sentences. Stop speaking once your point is made.\n\nContext that may be useful, pulled from The Minimalist Entrepreneur:\n"
  end

  def questions
    question_1 = "\n\n\nQ: How to choose what business to start?\n\nA: First off don't be in a rush. Look around you, see what problems you or other people are facing, and solve one of these problems if you see some overlap with your passions or skills. Or, even if you don't see an overlap, imagine how you would solve that problem anyway. Start super, super small."
    question_2 = "\n\n\nQ: Q: Should we start the business on the side first or should we put full effort right from the start?\n\nA:   Always on the side. Things start small and get bigger from there, and I don't know if I would ever “fully” commit to something unless I had some semblance of customer traction. Like with this product I'm working on now!"
    question_3 = "\n\n\nQ: Should we sell first than build or the other way around?\n\nA: I would recommend building first. Building will teach you a lot, and too many people use “sales” as an excuse to never learn essential skills like building. You can't sell a house you can't build!"
    question_4 = "\n\n\nQ: Andrew Chen has a book on this so maybe touché, but how should founders think about the cold start problem? Businesses are hard to start, and even harder to sustain but the latter is somewhat defined and structured, whereas the former is the vast unknown. Not sure if it's worthy, but this is something I have personally struggled with\n\nA: Hey, this is about my book, not his! I would solve the problem from a single player perspective first. For example, Gumroad is useful to a creator looking to sell something even if no one is currently using the platform. Usage helps, but it's not necessary."
    question_5 = "\n\n\nQ: What is one business that you think is ripe for a minimalist Entrepreneur innovation that isn't currently being pursued by your community?\n\nA: I would move to a place outside of a big city and watch how broken, slow, and non-automated most things are. And of course the big categories like housing, transportation, toys, healthcare, supply chain, food, and more, are constantly being upturned. Go to an industry conference and it's all they talk about! Any industry…"
    question_6 = "\n\n\nQ: How can you tell if your pricing is right? If you are leaving money on the table\n\nA: I would work backwards from the kind of success you want, how many customers you think you can reasonably get to within a few years, and then reverse engineer how much it should be priced to make that work."
    question_7 = "\n\n\nQ: Why is the name of your book 'the minimalist entrepreneur' \n\nA: I think more people should start businesses, and was hoping that making it feel more “minimal” would make it feel more achievable and lead more people to starting-the hardest step."
    question_8 = "\n\n\nQ: How long it takes to write TME\n\nA: About 500 hours over the course of a year or two, including book proposal and outline."
    question_9 = "\n\n\nQ: What is the best way to distribute surveys to test my product idea\n\nA: I use Google Forms and my email list / Twitter account. Works great and is 100% free."
    question_10 = "\n\n\nQ: How do you know, when to quit\n\nA: When I'm bored, no longer learning, not earning enough, getting physically unhealthy, etc… loads of reasons. I think the default should be to “quit” and work on something new. Few things are worth holding your attention for a long period of time."
    [question_1, question_2, question_3, question_4, question_5, question_6, question_7, question_8, question_9, question_10].join('')
  end

  def embedding
    @embedding ||= OpenAI::Client.new.embeddings(parameters: { model: model, input: query })['data'].first['embedding']
  end

  def model
    ENV['DOC_EMBEDDINGS_MODEL']
  end

  def page_embeddings
    @page_embeddings ||= CSV.open('book.embeddings.csv', headers: true).to_a
  end

  def closest_pages
    @closest_pages ||= page_embeddings.sort_by do |page|
      Vector.elements(page.to_a.map { |val| val.last.to_f }[3..-1]).inner_product(Vector.elements(embedding))
    end.reverse
  end
end
