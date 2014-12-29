# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :blog, :class => 'Blog' do
    title "hk's weblog"
  end
end
