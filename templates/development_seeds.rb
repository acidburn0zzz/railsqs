if Rails.env.development?
  namespace :dev do
    task prime: "db:setup" do
      # create(:user, email: "user@example.com", password: "password")
    end
  end
end
