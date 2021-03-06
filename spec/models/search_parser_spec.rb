# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchParser do
  use_moby_cats

  describe '#fragments' do
    it 'returns fragments in search order' do
      lion_first = described_class.new('Lion, tiger').tap(&:execute)
      tiger_first = described_class.new('Tiger, lion').tap(&:execute)

      expect(lion_first.fragments.first.string).to eq 'Lion'
      expect(tiger_first.fragments.first.string).to eq 'Tiger'
    end

    it 'parses out words and operations' do
      parser = described_class.new('lion, -tiger, +cat').tap(&:execute)

      lion_fragment = parser.fragments.find { |f| f.string == 'lion' }
      tiger_fragment = parser.fragments.find { |f| f.string == '-tiger' }
      cat_fragment = parser.fragments.find { |f| f.string == '+cat' }

      expect(lion_fragment.operation).to eq :add
      expect(lion_fragment.word).to be_present

      expect(tiger_fragment.operation).to eq :subtract
      expect(tiger_fragment.word).to be_present

      expect(cat_fragment.operation).to eq :add
      expect(cat_fragment.word).to be_present
    end
  end

  describe '#words' do
    it 'returns Words' do
      parser = described_class.new('Lion, wumpus, unicorn').tap(&:execute)
      expect(parser.words.first).to be_a Word
      expect(parser.words.first.name).to eq 'lion'
    end
  end

  describe '#missing_words' do
    it 'returns missing words in order' do
      parser = described_class.new('lion, wumpus, unicorn').tap(&:execute)
      expect(parser.missing_words.size).to eq 2
      expect(parser.missing_words.first).to eq 'wumpus'
      expect(parser.missing_words.second).to eq 'unicorn'
    end
  end

  describe '#parts of speech' do
    let(:parser) { described_class.new(search).tap(&:execute) }

    context 'when trailing' do
      let(:search) { 'cat, lion pos:verb' }

      specify { expect(parser.part_of_speech).to eq 'verb' }
    end

    context 'when leading' do
      let(:search) { 'pos:verb Maine Coon, lion' }

      specify { expect(parser.part_of_speech).to eq 'verb' }
    end

    context 'when comma separated' do
      let(:search) { 'cat, Maine Coon, pos:verb' }

      specify { expect(parser.part_of_speech).to eq 'verb' }
    end

    context 'with spaces' do
      let(:search) { 'cat, lion, Maine Coon pos:verb' }

      specify { expect(parser.part_of_speech).to eq 'verb' }
    end

    context 'when none' do
      let(:search) { 'cat, lion, ' }

      specify { expect(parser.part_of_speech).to eq nil }
    end
  end
end
