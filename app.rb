require 'sinatra'
require 'set'

module Boogle
  def self.cache
    @cache ||= Hash.new([])
  end

  def self.cache_page(page)
    page.words.each do |word|
      cache_word_for_page(word, page)
    end
  end

  def self.cache_word_for_page(word, page)
    if found_word = cache.fetch(word, nil)
      found_word << page.page_id
    else
      cache[word] = Set.new([page.page_id])
    end
  end

  def string_to_set(string)
    Set.new(string.gsub(/[^a-zA-Z\s]/, '').split(/\s+/).map(&:downcase))
  end
end

class Page
  include Boogle
  extend Enumerable

  def self.each(&block)
    all.each(&block)
  end

  def self.create(opts)
    new(opts).save
  end

  def self.all
    @all ||= []
  end

  attr_accessor :page_id, :content

  def initialize(opts)
    @page_id = opts.fetch('pageId')
    @content = opts.fetch('content')
  end

  def save
    Page.all << self
    Boogle.cache_page(self)
  end

  def words
    string_to_set(content)
    @words ||= string_to_set(content)
  end
end

class Boogler
  include Boogle
  attr_accessor :query, :matches

  def initialize(query)
    @query = query
    @matches = []
    search
    sort
  end

  def search_terms
    @search_terms ||= string_to_set(query)
  end

  def search
    search_terms.each do |term|
      Boogle.cache[term].each do |pid|
        increment_score_for_page(pid)
      end
    end
  end

  def increment_score_for_page(pid)
    if found_match = matches.detect { |match| match['pageId'] == pid }
      found_match['score'] += 1
    else
      matches << {'pageId' => pid, 'score' => 1}
    end
  end

  def pages_with_term(term)
    Page.select { |page| page.words.include?(term) }
  end

  def sort
    matches.sort! { |a, b| b['score'] <=> a['score'] }
  end

  def to_json
    {'matches' => matches}.to_json
  end
end

get '/search' do
  content_type :json
  Boogler.new(params['query']).to_json
end

post '/index' do
  content_type :json
  params_json = JSON.parse(request.body.read)
  @page = Page.new(params_json)

  if @page.save
    status 204
  else
    status 404
  end
end
