require 'rails_helper'

RSpec.feature 'Searching words', js: true do
  use_moby_thesaurus
  use_moby_cats

  scenario 'Clicks through a word on front page' do
    visit root_path
    # Ensure link does not include Thesuarus because this is Panlexicon search
    expect(page).to have_link 'wordhoard', href: '/?q=wordhoard'

    click_link 'wordhoard'
    # Expect Bobcat to be active
    expect(page).to have_selector 'a.active', text: 'wordhoard'
    # Expect the link to remove the word from search
    expect(page).to have_link 'wordhoard', href: '/?q='

    # 'work of reference' and 'wordhoard' have separate sets
    # so it should not be visible here
    expect(page).not_to have_link 'work of reference'
  end

  scenario 'Entering a word in searchbar' do
    visit root_path
    search_for 'bobcat'

    expect(page).to have_link 'bobcat'
    expect(page).to have_link 'cat'
  end

  scenario 'Subtracting words from dictionary' do
    visit root_path
    search_for 'cat, -leopard'

    expect(page).to have_link 'leopard'
    expect(page).not_to have_link 'puma'
  end

  scenario 'Searching with improper capitalizations' do
    visit root_path
    search_for 'Bobcat'

    expect(page).to have_link 'bobcat'
    expect(page).to have_link 'cat'
  end

  scenario 'Entering 2 comma-separated words in searchbar' do
    visit root_path
    search_for 'wordhoard, dictionary'

    expect(page).to have_link 'wordhoard'
    expect(page).not_to have_link 'work of reference'
  end

  scenario 'Unselecting a word returns the user to front page' do
    visit root_path
    search_for 'bobcat'
    click_link 'bobcat'

    expect(page).to have_link 'thesaurus'
  end

  scenario 'Searching a non-indexed word' do
    visit root_path
    search_for 'the orm'

    expect(page).to have_content 'the orm is not in our dictionary'
  end

  scenario 'Searching words without common synonyms' do
    visit root_path
    search_for 'thesaurus, cat'

    expect(page).to have_content 'No commonality can be found'
  end
end
