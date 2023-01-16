class PdfParser
  def initialize(pdf_filename)
    self.pages = PDF::Reader.new(pdf_filename).pages
    self.model = ENV['DOC_EMBEDDINGS_MODEL']
  end

  def write_csv
    CSV.open("book.embeddings.csv", 'w') do |csv|
      csv << headers
      pages.each.with_index do |page, index|
        clean_text = page.text.split(/\s+/).join(' ')
        puts "Writing page #{index + 1} of #{pages.size}"
        openai_response = JSON.parse(openai_client.embeddings(parameters: { model: model, input: clean_text }).body)
        if openai_response['data']
          csv << ["Page #{index}", clean_text, openai_response.dig('usage', 'prompt_tokens')] + openai_response['data'].first['embedding']
        else
          puts 'Error'
          puts openai_response
        end
      end
    end
  end

  private

  attr_accessor :pages, :model

  def openai_client
    @openai_client ||= OpenAI::Client.new
  end

  def headers
    %w[title content tokens] + (0..4095).to_a
  end
end
