require 'rails_helper'

RSpec.describe Household, type: :model do
  describe 'associations' do
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:users).through(:memberships) }
    it { should have_many(:pets).dependent(:destroy) }
    it { should have_many(:events).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
