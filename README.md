# README

Small app showing a basic app structure for Rails 7 with React, as well as usage of the the OpenAI API.

## Setup

- Add `OPENAI_API_KEY` to your `.env` file
- You can optionally override the `DOC_EMBEDDINGS_MODEL` in your `.env` file (default is 'text-search-curie-doc-001') 
- Run `rails runner script/pdf_to_embeddings_csv.rb [pdf filename]` to generate the embeddings CSV file.

## Usage

Run the server locally with `bin/dev`
