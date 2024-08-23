require 'rails_helper'

RSpec.describe Note, type: :model do

  let(:user) {
      User.create({username: "User 1", name: "1", password: "password"})
  }

  it "is a valid note" do
    note = Note.new(
      title: "Title",
      content: "Content",
      user_id: user.id
    )

    expect(note).to be_valid
  end

  it "is not valid without a user" do
    note = Note.new(
      title: "Title",
      content: "Content",
      user_id: nil
    )

    expect(note).not_to be_valid
  end

  it "is not valid without a title" do
    note = Note.new(
      title: nil,
      content: "Content",
    )

    expect(note).not_to be_valid
  end

  it "is not valid without content" do
    note = Note.new(
      title: "Title",
      content: nil,
    )

    expect(note).not_to be_valid
  end
end