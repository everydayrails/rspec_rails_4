require 'spec_helper'

feature "News releases", focus: true do
  context "as a user" do
    scenario "adds a news release" do
      user = create(:user)
      sign_in(user)
      click_link "News"
      expect(page).to_not have_content "BigCo switches to Rails"
      click_link "Add News Release"

      fill_in "Date", with: "2013-07-29"
      fill_in "Title", with: "BigCo switches to Rails"
      fill_in "Body",
        with: "BigCo has released a new website built with open source."
      click_button "Submit"

      expect(current_path).to eq news_releases_path
      expect(page).to have_content "Successfully created news release."
      expect(page).to have_content "2013-07-29: BigCo switches to Rails"
    end
  end

  context "as a guest" do
    scenario "reads a news release"
  end
end